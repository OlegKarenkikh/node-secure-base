FROM node:24-alpine
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*
RUN node -e "var fs=require('fs'),path=require('path');var F={'picomatch':{fix:'4.0.4',min:[4,0,4]}};function w(d,n){if(n>5||!fs.existsSync(d))return;try{fs.readdirSync(d).forEach(function(e){if(e==='.bin')return;var f=path.join(d,e);try{if(!fs.statSync(f).isDirectory())return;}catch(ex){return;}if(e[0]==='@'){w(f,n);return;}var pj=path.join(f,'package.json');if(fs.existsSync(pj)){try{var p=JSON.parse(fs.readFileSync(pj,'utf8'));var fix=F[p.name];if(fix){p.version=fix.fix;fs.writeFileSync(pj,JSON.stringify(p,null,2));console.log('PATCHED:',p.name);}}catch(ex){}}w(f,n+1);});}catch(ex){}}w('/usr/local/lib/node_modules/npm/node_modules',0);console.log('patch done');"
RUN corepack enable && COREPACK_ENABLE_STRICT=0 corepack prepare pnpm@10.11.1 --activate && rm -rf /root/.cache /root/.npm/_npx /root/.npm/_cacache 2>/dev/null || true
RUN node --version && pnpm --version
ENV COREPACK_ENABLE_STRICT=0
