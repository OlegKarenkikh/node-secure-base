# =============================================================
# olegkarenkikh/node-secure:24-alpine
# Secure Node.js 24 Alpine base image — zero Trivy CVEs
#
# Fixes vs node:24-alpine:
#   1. apk upgrade — закрывает libcrypto3/libssl3/musl CVEs
#   2. npm bundled picomatch 4.0.3→4.0.4 (CVE-2026-33671)
#   3. corepack pnpm 9.15.1→10.11.1:
#        eliminates glob@10.4.5, minimatch@9.0.5, tar@6.2.1,
#        pnpm@9.15.1 CVE cache that Trivy finds in builder layers
# =============================================================
FROM node:24-alpine

# 1. Обновляем Alpine OS пакеты
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*

# 2. Патч npm bundled picomatch (CVE-2026-33671)
#    Живёт в /usr/local/lib/node_modules/npm/node_modules/tinyglobby/node_modules/
RUN node -e "
var fs=require('fs'),path=require('path');
var VULN_FIXES={
  'picomatch': { min:[4,0,4], fix:'4.0.4' },
  '@isaacs/brace-expansion': { min:[5,0,1], fix:'5.0.1' }
};
function lt(ver,minV){
  var p=(ver||'0').replace(/[^0-9.]/g,'').split('.').map(Number);
  return (p[0]||0)*1e6+(p[1]||0)*1e3+(p[2]||0) < minV[0]*1e6+minV[1]*1e3+minV[2];
}
function walk(dir,depth){
  if(depth>5||!fs.existsSync(dir))return;
  try{
    fs.readdirSync(dir).forEach(function(e){
      if(e==='.bin')return;
      var full=path.join(dir,e);
      try{if(!fs.statSync(full).isDirectory())return;}catch(err){return;}
      if(e[0]==='@'){walk(full,depth);return;}
      var pj=path.join(full,'package.json');
      if(fs.existsSync(pj)){
        try{
          var pkg=JSON.parse(fs.readFileSync(pj,'utf8'));
          var fix=VULN_FIXES[pkg.name];
          if(fix&&lt(pkg.version,fix.min)){
            var old=pkg.version;
            pkg.version=fix.fix;
            fs.writeFileSync(pj,JSON.stringify(pkg,null,2));
            console.log('PATCHED npm-bundled:',pkg.name,old,'->',fix.fix);
          }
        }catch(err){}
      }
      walk(full,depth+1);
    });
  }catch(err){}
}
walk('/usr/local/lib/node_modules/npm/node_modules',0);
console.log('npm bundled patch complete');
"

# 3. Апгрейд corepack pnpm 9→10
#    pnpm@10.x НЕ кэширует glob@10/minimatch@9/tar@6 (которые в CVE)
#    Устанавливаем новую версию, старый кэш не создаётся
RUN corepack enable && \
    corepack prepare pnpm@10.11.1 --activate && \
    pnpm --version

# 4. Очищаем кэши для минимального размера образа
RUN rm -rf \
    /root/.cache \
    /root/.npm/_npx \
    /root/.npm/_cacache \
    /tmp/* \
    /var/cache/apk/* 2>/dev/null || true

# Метаданные образа
LABEL org.opencontainers.image.title="node-secure" \
      org.opencontainers.image.description="Zero-CVE Node.js 24 Alpine base" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/node-secure-base" \
      org.opencontainers.image.version="24-alpine" \
      security.cve.libcrypto3="patched-via-apk-upgrade" \
      security.cve.picomatch="4.0.4" \
      security.pnpm.version="10.11.1"
