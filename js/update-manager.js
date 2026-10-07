(function(){
  'use strict';

  const script = document.currentScript;
  const rootHint = script && script.dataset ? (script.dataset.stellarRoot || './') : './';
  const routeHint = script && script.dataset ? (script.dataset.stellarRoute || 'home') : 'home';
  const BUILD = script && script.dataset ? (script.dataset.stellarBuild || '') : '';
  const ROOT = new URL(rootHint, location.href);
  const STORE_VERSION = 'stellar-installed-version';
  const STORE_REVISIONS = 'stellar-asset-revisions';
  const STORE_PREVIOUS_VERSION = 'stellar-previous-version';
  const STORE_PREVIOUS_REVISIONS = 'stellar-previous-asset-revisions';
  const STORE_GROUP_PREFIX = 'stellar-prepared-group:';
  const CACHE_PREFIX = 'stellar-static-v';
  const UPDATE_QUERY = '__stellar_update';

  const T = {
    'zh-CN':{
      brand:'星辰日记',sub:'YOUR STARS, YOUR STORY',checking:'正在检查星辰日记',checkDesc:'正在确认是否有新的网站内容与资源。',
      firstKicker:'首次准备',firstTitle:'正在准备星辰日记',firstDesc:'第一次来到这里，需要先准备网站与游戏资源。完成后，之后开启会更快。',
      updateKicker:'发现新版本',updateTitle:'正在更新星辰日记',updateDesc:'正在准备最新内容。更新完成后会自动进入网站。',
      routeKicker:'准备内容',routeTitle:'正在准备这一页',routeDesc:'正在下载这一页需要的资源，完成后就可以开始使用。',
      notes:'本次更新',status:'正在准备资源…',copying:'正在整理已有资源…',download:'正在下载资源…',finishing:'正在完成更新…',done:'准备完成',doneDesc:'最新内容已经准备好了。',
      current:'当前',latest:'最新',files:'项资源',size:'已处理',retry:'重新更新',error:'更新暂时没有完成，请检查网络后重新尝试。',unsupported:'当前浏览器不支持资源更新功能，将直接使用网站。'
    },
    'zh-TW':{
      brand:'星辰日記',sub:'YOUR STARS, YOUR STORY',checking:'正在檢查星辰日記',checkDesc:'正在確認是否有新的網站內容與資源。',
      firstKicker:'首次準備',firstTitle:'正在準備星辰日記',firstDesc:'第一次來到這裡，需要先準備網站與遊戲資源。完成後，之後開啟會更快。',
      updateKicker:'發現新版本',updateTitle:'正在更新星辰日記',updateDesc:'正在準備最新內容。更新完成後會自動進入網站。',
      routeKicker:'準備內容',routeTitle:'正在準備這一頁',routeDesc:'正在下載這一頁需要的資源，完成後就可以開始使用。',
      notes:'本次更新',status:'正在準備資源…',copying:'正在整理已有資源…',download:'正在下載資源…',finishing:'正在完成更新…',done:'準備完成',doneDesc:'最新內容已經準備好了。',
      current:'目前',latest:'最新',files:'項資源',size:'已處理',retry:'重新更新',error:'更新暫時沒有完成，請檢查網路後重新嘗試。',unsupported:'目前瀏覽器不支援資源更新功能，將直接使用網站。'
    },
    en:{
      brand:'Stellar Diary',sub:'YOUR STARS, YOUR STORY',checking:'Checking Stellar Diary',checkDesc:'Checking for new site content and resources.',
      firstKicker:'FIRST SETUP',firstTitle:'Preparing Stellar Diary',firstDesc:'A few site and game resources need to be prepared before your first visit. Future launches will be faster.',
      updateKicker:'NEW VERSION',updateTitle:'Updating Stellar Diary',updateDesc:'Preparing the latest content. The site will open automatically when the update is ready.',
      routeKicker:'PREPARING CONTENT',routeTitle:'Preparing this page',routeDesc:'Downloading the resources this page needs. You can start as soon as it finishes.',
      notes:'What’s new',status:'Preparing resources…',copying:'Reusing existing resources…',download:'Downloading resources…',finishing:'Finishing update…',done:'Ready',doneDesc:'The latest content is ready.',
      current:'Current',latest:'Latest',files:'resources',size:'Processed',retry:'Retry update',error:'The update could not finish. Check your connection and try again.',unsupported:'This browser does not support the resource updater. The site will continue normally.'
    }
  };

  function lang(){
    try { const v=localStorage.getItem('xingchen-language'); return T[v]?v:'zh-CN'; } catch(_){ return 'zh-CN'; }
  }
  function tr(){ return T[lang()] || T['zh-CN']; }
  function $(id){ return document.getElementById(id); }
  function sleep(ms){ return new Promise(r=>setTimeout(r,ms)); }
  function fmtBytes(n){
    n=Number(n)||0;
    if(n<1024) return n+' B';
    if(n<1024*1024) return (n/1024).toFixed(n<10240?1:0)+' KB';
    return (n/1024/1024).toFixed(n<10*1024*1024?1:0)+' MB';
  }
  function cleanPath(path){ return String(path||'').replace(/^\.\//,'').replace(/^\//,''); }
  function assetUrl(path,bust){
    const u=new URL(cleanPath(path),ROOT);
    if(bust) u.searchParams.set(UPDATE_QUERY,bust);
    return u;
  }
  function requestKey(path){ return new Request(assetUrl(path,false).href,{method:'GET'}); }
  function safeJSON(key,fallback){
    try { const raw=localStorage.getItem(key); return raw?JSON.parse(raw):fallback; } catch(_){ return fallback; }
  }
  function setJSON(key,value){ try { localStorage.setItem(key,JSON.stringify(value)); } catch(_){} }
  function hasLegacyFootprint(){
    const keys=['xingchen-player-profile-v1','stellar-diary-cloud-sync-meta-v1','xingchen-farm-v1','stellar-diary-new-player-guide-dismissed-v1'];
    try{return keys.some(k=>localStorage.getItem(k)!=null);}catch(_){return false;}
  }
  function legacyVersion(){
    try{const meta=JSON.parse(localStorage.getItem('stellar-diary-cloud-sync-meta-v1')||'null');return meta&&typeof meta.version==='string'?meta.version:'';}catch(_){return '';}
  }
  function setText(el,text){ if(el) el.textContent=text==null?'':String(text); }
  function setProgress(pct,status,processed,total,count,totalCount){
    pct=Math.max(0,Math.min(100,Math.round(pct||0)));
    const bar=$('stellarUpdateBar'); if(bar) bar.style.width=pct+'%';
    setText($('stellarUpdatePercent'),pct+'%');
    if(status) setText($('stellarUpdateStatus'),status);
    setText($('stellarUpdateCount'),`${count||0} / ${totalCount||0} ${tr().files}`);
    setText($('stellarUpdateBytes'),`${tr().size} ${fmtBytes(processed||0)} / ${fmtBytes(total||0)}`);
  }
  function renderBase(){
    const s=tr();
    setText($('stellarUpdateBrand'),s.brand); setText($('stellarUpdateSub'),s.sub);
    setText($('stellarUpdateKicker'),''); setText($('stellarUpdateTitle'),s.checking); setText($('stellarUpdateDesc'),s.checkDesc);
    setText($('stellarUpdateNotesTitle'),s.notes); setText($('stellarUpdateStatus'),s.status); setText($('stellarUpdatePercent'),'0%');
    const retry=$('stellarUpdateRetry'); if(retry) retry.textContent=s.retry;
  }
  function showMode(mode,installed,latest){
    const s=tr();
    if(mode==='first'){
      setText($('stellarUpdateKicker'),s.firstKicker); setText($('stellarUpdateTitle'),s.firstTitle); setText($('stellarUpdateDesc'),s.firstDesc);
    } else if(mode==='update'){
      setText($('stellarUpdateKicker'),s.updateKicker); setText($('stellarUpdateTitle'),s.updateTitle); setText($('stellarUpdateDesc'),s.updateDesc);
    } else {
      setText($('stellarUpdateKicker'),s.routeKicker); setText($('stellarUpdateTitle'),s.routeTitle); setText($('stellarUpdateDesc'),s.routeDesc);
    }
    const version=$('stellarUpdateVersion');
    if(version){
      if(installed && installed!==latest) version.innerHTML=`<span>${s.current} <b>V${installed}</b></span><span>→</span><span>${s.latest} <b>V${latest}</b></span>`;
      else version.innerHTML=`<span>${s.latest} <b>V${latest}</b></span>`;
    }
  }
  function renderNotes(versionInfo){
    const box=$('stellarUpdateNotes'),list=$('stellarUpdateNotesList');
    const notes=versionInfo && versionInfo.notes && (versionInfo.notes[lang()] || versionInfo.notes['zh-CN']);
    if(!box||!list||!Array.isArray(notes)||!notes.length){ if(box) box.hidden=true; return; }
    list.replaceChildren();
    notes.slice(0,5).forEach(note=>{ const li=document.createElement('li'); li.textContent=note; list.appendChild(li); });
    box.hidden=false;
  }
  function releaseGate(){
    document.documentElement.classList.remove('stellar-update-pending');
    const gate=$('stellarUpdateGate'); if(gate) gate.hidden=true;
  }
  function fail(err){
    console.error('[Stellar Update]',err);
    const box=$('stellarUpdateError'); if(box){ box.hidden=false; box.textContent=tr().error; }
    const retry=$('stellarUpdateRetry'); if(retry){ retry.hidden=false; retry.disabled=false; retry.onclick=()=>location.reload(); }
  }
  async function fetchJSON(name){
    const u=assetUrl(name,Date.now().toString(36));
    const res=await fetch(u.href,{cache:'no-store',credentials:'same-origin'});
    if(!res.ok) throw new Error(`${name}: HTTP ${res.status}`);
    return res.json();
  }
  function unique(arr){ return Array.from(new Set((arr||[]).map(cleanPath).filter(Boolean))); }
  function groupStamp(manifest,group){
    const list=unique((manifest.groups&&manifest.groups[group])||[]);
    let s=''; for(const p of list){ const meta=manifest.assets&&manifest.assets[p]; s+=p+':'+(meta?meta.revision:'')+'|'; }
    let h=2166136261; for(let i=0;i<s.length;i++){h^=s.charCodeAt(i);h=Math.imul(h,16777619);} return (h>>>0).toString(16);
  }
  async function ensureAssets(manifest,assets,version,previousVersion,previousRevisions){
    const currentCache=await caches.open(CACHE_PREFIX+version);
    const previousCache=previousVersion?await caches.open(CACHE_PREFIX+previousVersion):null;
    const metas=manifest.assets||{};
    const list=unique(assets);
    const totalBytes=list.reduce((n,p)=>n+Number(metas[p]&&metas[p].bytes||0),0);
    let processed=0,count=0;
    setProgress(0,tr().status,0,totalBytes,0,list.length);

    for(const path of list){
      const meta=metas[path]||{};
      const key=requestKey(path);
      let response=null;
      const already=await currentCache.match(key,{ignoreSearch:true});
      if(already) response=already;
      if(!response && previousCache && previousRevisions && previousRevisions[path]===meta.revision){
        const old=await previousCache.match(key,{ignoreSearch:true});
        if(old){ response=old.clone(); await currentCache.put(key,response.clone()); }
      }
      if(!response){
        setText($('stellarUpdateStatus'),tr().download);
        const res=await fetch(assetUrl(path,version).href,{cache:'no-store',credentials:'same-origin'});
        if(!res.ok) throw new Error(`asset ${path}: HTTP ${res.status}`);
        response=res.clone(); await currentCache.put(key,response);
      } else {
        setText($('stellarUpdateStatus'),tr().copying);
      }
      processed+=Number(meta.bytes||0); count++;
      setProgress(totalBytes?processed/totalBytes*100:count/list.length*100,$('stellarUpdateStatus')&&$('stellarUpdateStatus').textContent,processed,totalBytes,count,list.length);
    }
  }
  async function registerWorker(version){
    if(!('serviceWorker' in navigator)) return false;
    const sw=new URL('service-worker.js',ROOT); sw.searchParams.set('v',version);
    const versionToken='v='+encodeURIComponent(version);
    try{
      const reg=await navigator.serviceWorker.register(sw.href,{scope:ROOT.pathname,updateViaCache:'none'});
      try{ await reg.update(); }catch(_){}
      if(reg.waiting){ try{reg.waiting.postMessage({type:'SKIP_WAITING'});}catch(_){} }
      const started=Date.now();
      while(Date.now()-started<8000){
        const active=reg.active;
        const controller=navigator.serviceWorker.controller;
        const activeOk=!!(active && active.state==='activated' && active.scriptURL.includes(versionToken));
        const controllerOk=!!(controller && controller.scriptURL.includes(versionToken));
        if(activeOk && (controllerOk || !controller)){
          try{await navigator.serviceWorker.ready;}catch(_){}
          return true;
        }
        await sleep(100);
      }
      try{await navigator.serviceWorker.ready;}catch(_){}
      return !!(reg.active && reg.active.scriptURL.includes(versionToken));
    }catch(err){ console.warn('[Stellar Update] service worker registration failed',err); return false; }
  }
  async function pruneCaches(version,keepVersion){
    try{
      const keep=new Set([CACHE_PREFIX+version]);
      if(keepVersion) keep.add(CACHE_PREFIX+keepVersion);
      const keys=await caches.keys();
      await Promise.all(keys.filter(k=>k.startsWith(CACHE_PREFIX)&&!keep.has(k)).map(k=>caches.delete(k)));
    }catch(_){}
  }
  async function boot(){
    renderBase();
    window.addEventListener('stellar:language-changed',renderBase);
    if(location.protocol!=='https:' && location.hostname!=='localhost' && location.hostname!=='127.0.0.1'){
      releaseGate(); return;
    }
    if(!('caches' in window) || !('fetch' in window)){
      setText($('stellarUpdateDesc'),tr().unsupported); await sleep(500); releaseGate(); return;
    }
    try{
      const [versionInfo,manifest]=await Promise.all([fetchJSON('version.json'),fetchJSON('asset-manifest.json')]);
      const latest=String(versionInfo.version||manifest.version||BUILD||'').trim();
      if(!latest) throw new Error('missing version');
      const installed=(()=>{try{return localStorage.getItem(STORE_VERSION)||''}catch(_){return''}})();
      const legacyExisting=!installed && hasLegacyFootprint();
      const displayInstalled=installed || (legacyExisting?legacyVersion():'');
      const previousRevisions=safeJSON(STORE_REVISIONS,{});
      const retainedVersion=(()=>{try{return localStorage.getItem(STORE_PREVIOUS_VERSION)||''}catch(_){return''}})();
      const retainedRevisions=safeJSON(STORE_PREVIOUS_REVISIONS,{});
      const shell=unique(manifest.groups&&manifest.groups.shell);
      const route=manifest.groups&&manifest.groups[routeHint]?routeHint:'home';
      const routeAssets=unique(manifest.groups&&manifest.groups[route]);
      const required=unique(shell.concat(routeAssets));
      const stamp=groupStamp(manifest,route);
      const prepared=(()=>{try{return localStorage.getItem(STORE_GROUP_PREFIX+route)||''}catch(_){return''}})();
      const versionChanged=installed!==latest;
      const routeChanged=prepared!==`${latest}:${stamp}`;

      if(!versionChanged && !routeChanged){
        registerWorker(latest); releaseGate(); return;
      }
      const mode=!installed?(legacyExisting?'update':'first'):versionChanged?'update':'route';
      showMode(mode,displayInstalled,latest);
      renderNotes(mode==='update'?versionInfo:null);
      const reuseVersion=versionChanged?installed:(retainedVersion && retainedVersion!==latest?retainedVersion:'');
      const reuseRevisions=versionChanged?previousRevisions:retainedRevisions;
      await ensureAssets(manifest,required,latest,reuseVersion,reuseRevisions);
      setText($('stellarUpdateStatus'),tr().finishing);
      await registerWorker(latest);
      if(versionChanged && installed){
        try{localStorage.setItem(STORE_PREVIOUS_VERSION,installed);}catch(_){}
        setJSON(STORE_PREVIOUS_REVISIONS,previousRevisions);
      }
      try{localStorage.setItem(STORE_VERSION,latest);localStorage.setItem(STORE_GROUP_PREFIX+route,`${latest}:${stamp}`);}catch(_){}
      setJSON(STORE_REVISIONS,Object.fromEntries(Object.entries(manifest.assets||{}).map(([k,v])=>[k,v.revision||''])));
      const keepOld=versionChanged?installed:retainedVersion;
      await pruneCaches(latest,keepOld);
      setProgress(100,tr().done,required.reduce((n,p)=>n+Number(manifest.assets?.[p]?.bytes||0),0),required.reduce((n,p)=>n+Number(manifest.assets?.[p]?.bytes||0),0),required.length,required.length);
      setText($('stellarUpdateTitle'),tr().done); setText($('stellarUpdateDesc'),tr().doneDesc);
      await sleep(mode==='update'?650:450);
      if(mode==='update') location.reload(); else releaseGate();
    }catch(err){ fail(err); }
  }

  boot();
})();
