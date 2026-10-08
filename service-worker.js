'use strict';
const BUILD_VERSION='0.21.0';
const CACHE_NAME=`stellar-static-v${BUILD_VERSION}`;
const CACHE_PREFIX='stellar-static-v';
const UPDATE_QUERY='__stellar_update';

self.addEventListener('install',()=>{ self.skipWaiting(); });
self.addEventListener('activate',event=>{ event.waitUntil(self.clients.claim()); });
self.addEventListener('message',event=>{
  if(event.data && event.data.type==='SKIP_WAITING') self.skipWaiting();
});

function isSameOrigin(url){ return url.origin===self.location.origin; }
function isCodeOrData(url,request){
  if(request.mode==='navigate') return true;
  return /\.(?:html?|js|css|json)$/i.test(url.pathname) || /\/(?:version|asset-manifest)\.json$/i.test(url.pathname);
}
async function networkFirst(request){
  const cache=await caches.open(CACHE_NAME);
  try{
    const response=await fetch(new Request(request,{cache:'no-store'}));
    if(response && response.ok && request.method==='GET') await cache.put(request,response.clone());
    return response;
  }catch(err){
    let cached=await cache.match(request,{ignoreSearch:true});
    if(!cached && request.mode==='navigate'){
      const u=new URL(request.url);
      if(u.pathname.endsWith('/')) cached=await cache.match(new URL('index.html',u).href,{ignoreSearch:true});
    }
    if(cached) return cached;
    const keys=await caches.keys();
    for(const key of keys.filter(k=>k.startsWith(CACHE_PREFIX)&&k!==CACHE_NAME).reverse()){
      const old=await caches.open(key); const hit=await old.match(request,{ignoreSearch:true}); if(hit) return hit;
    }
    throw err;
  }
}
async function cacheFirst(request){
  const cache=await caches.open(CACHE_NAME);
  const hit=await cache.match(request,{ignoreSearch:true});
  if(hit) return hit;
  try{
    const response=await fetch(new Request(request,{cache:'no-store'}));
    if(response && response.ok) await cache.put(request,response.clone());
    return response;
  }catch(err){
    const keys=await caches.keys();
    for(const key of keys.filter(k=>k.startsWith(CACHE_PREFIX)&&k!==CACHE_NAME).reverse()){
      const old=await caches.open(key); const fallback=await old.match(request,{ignoreSearch:true}); if(fallback) return fallback;
    }
    throw err;
  }
}
self.addEventListener('fetch',event=>{
  const request=event.request;
  if(request.method!=='GET') return;
  const url=new URL(request.url);
  if(!isSameOrigin(url)) return;
  if(url.searchParams.has(UPDATE_QUERY)){ event.respondWith(fetch(request)); return; }
  if(isCodeOrData(url,request)){ event.respondWith(networkFirst(request)); return; }
  event.respondWith(cacheFirst(request));
});
