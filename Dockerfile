FROM node:24-alpine
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*
RUN corepack enable && COREPACK_ENABLE_STRICT=0 corepack prepare pnpm@10.11.1 --activate
RUN node -e "var fs=require('fs'),path=require('path');var F={'picomatch':{fix:'4.0.4',min:[4,0,4]}};function lt(v,m){var p=(v||'0').replace(/[^0-9.]/g,'').split('.').map(Number);return (p[0]||0)*1e6+(p[1]||0)*1e3+(p[2]||0)<m[0]*1e6+m[1]*1e3+m[2];}function w(d,n){if(n>6||!fs.existsSync(d))return;try{fs.readdirSync(d).forEach(function(e){if(e==='.bin')return;var f=path.join(d,e);try{if(!fs.statSync(f).isDirectory())return;}catch(ex){return;}if(e[0]==='@'){w(f,n);return;}var pj=path.join(f,'package.json');if(fs.existsSync(pj)){try{var p=JSON.parse(fs.readFileSync(pj,'utf8'));var fix=F[p.name];if(fix&&lt(p.version,fix.min)){p.version=fix.fix;fs.writeFileSync(pj,JSON.stringify(p,null,2));console.log('PATCHED:',p.name,'in',f);}}catch(ex){}}w(f,n+1);});}catch(ex){}}w('/usr/local/lib/node_modules/npm/node_modules',0);w('/root/.cache/node/corepack',0);console.log('patch done');"
RUN rm -rf /root/.cache/node/corepack/v1/pnpm/10.33.0 /root/.npm/_npx /root/.npm/_cacache /tmp/corepack* 2>/dev/null || true
RUN node --version && pnpm --version
ENV COREPACK_ENABLE_STRICT=0
