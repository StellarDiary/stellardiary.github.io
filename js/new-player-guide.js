(() => {
  const DISMISS_KEY = 'stellar-diary-new-player-guide-dismissed-v1';
  const SCREENSHOT_ROOT = 'images/tutorial/register/zh-CN/';

  const COPY = {
    'zh-CN': {
      trigger:'新手教学', aria:'新手注册教学', label:'新手注册教学', subtitle:'第一次来到星辰日记？跟着图片一步一步完成邮箱绑定。',
      introTitle:'先保护你的星辰日记账号',
      introBody:'第一次使用时，你会先以游客身份开始。完成邮箱绑定后，目前的个人资料、星辰农场与使用记录会继续保留，并能在其他装置登录取回。',
      introTip:'已经绑定过邮箱？请使用「已有账号？登录 / 恢复」，不要重复注册。', login:'已有账号？登录 / 恢复',
      steps:[
        ['打开个人资料','点击首页右上角的「游客：设置资料」，先进入个人资料设置。'],
        ['设置星辰称呼','输入 2～5 个全角文字的名称并选择性别，再点击「绑定邮箱账号」。'],
        ['选择绑定新邮箱','进入「账号与安全」后，点击「绑定新邮箱」。当前游客资料会继续保留。'],
        ['填写常用邮箱','输入你可以正常收信的邮箱地址，再点击「发送验证邮件」。'],
        ['选择验证方式','你可以点击邮件里的验证按钮，或直接在网站输入邮件中的 8 位验证码。'],
        ['完成邮箱验证','如果使用 8 位验证码，把邮件中的验证码输入网站即可；也可以直接点击邮件按钮完成验证。']
      ],
      doneTitle:'完成后，你就是正式会员 ✦',
      doneBody:'绑定成功后，换手机、换电脑或清除浏览器资料时，都可以使用同一个邮箱登录并取回云端资料。',
      doneTip:'建议完成绑定后，再开始长期经营星辰农场与保存个人记录。',
      prev:'上一步', next:'下一步', start:'开始教学', bind:'现在去绑定邮箱', close:'关闭', dismiss:'下次不再显示', step:'步骤', imageAlt:'注册教学步骤图片',
      tapImage:'点击图片可放大查看', closeImage:'关闭大图'
    },
    'zh-TW': {
      trigger:'新手教學', aria:'新手註冊教學', label:'新手註冊教學', subtitle:'第一次來到星辰日記？跟著圖片一步一步完成信箱綁定。',
      introTitle:'先保護你的星辰日記帳號',
      introBody:'第一次使用時，你會先以遊客身分開始。完成信箱綁定後，目前的個人資料、星辰農場與使用紀錄會繼續保留，並能在其他裝置登入取回。',
      introTip:'已經綁定過信箱？請使用「已有帳號？登入 / 恢復」，不要重複註冊。', login:'已有帳號？登入 / 恢復',
      steps:[
        ['開啟個人資料','點擊首頁右上角的「遊客：設定資料」，先進入個人資料設定。'],
        ['設定星辰稱呼','輸入 2～5 個全形文字的名稱並選擇性別，再點擊「綁定信箱帳號」。'],
        ['選擇綁定新信箱','進入「帳號與安全」後，點擊「綁定新信箱」。目前的遊客資料會繼續保留。'],
        ['填寫常用信箱','輸入你可以正常收信的 Email，再點擊「發送驗證郵件」。'],
        ['選擇驗證方式','你可以點擊郵件裡的驗證按鈕，或直接在網站輸入郵件中的 8 位驗證碼。'],
        ['完成信箱驗證','如果使用 8 位驗證碼，把郵件中的驗證碼輸入網站即可；也可以直接點擊郵件按鈕完成驗證。']
      ],
      doneTitle:'完成後，你就是正式會員 ✦',
      doneBody:'綁定成功後，換手機、換電腦或清除瀏覽器資料時，都可以使用同一個信箱登入並取回雲端資料。',
      doneTip:'建議完成綁定後，再開始長期經營星辰農場與保存個人紀錄。',
      prev:'上一步', next:'下一步', start:'開始教學', bind:'現在去綁定信箱', close:'關閉', dismiss:'下次不再顯示', step:'步驟', imageAlt:'註冊教學步驟圖片',
      tapImage:'點擊圖片可放大查看', closeImage:'關閉大圖'
    },
    en: {
      trigger:'New Player Guide', aria:'New player registration guide', label:'New Player Registration', subtitle:'New to Stellar Diary? Follow the screenshots to link your email step by step.',
      introTitle:'Protect your Stellar Diary account first',
      introBody:'You begin as a guest. Linking an email upgrades your current identity without erasing your profile, Stellar Farm, or existing records, and lets you recover them on another device.',
      introTip:'Already linked an email? Use “Existing account · Sign in / Restore” instead of registering again.', login:'Existing account · Sign in / Restore',
      steps:[
        ['Open your profile','Select “Guest: Set Profile” in the upper-right corner to open your profile setup.'],
        ['Set your Stellar name','Enter a 2–5 character name, choose your gender, then select “Bind email account”.'],
        ['Choose Bind new email','Under Account & Security, select “Bind new email”. Your current guest data will be kept.'],
        ['Enter an email you use','Enter an email address you can access, then send the verification email.'],
        ['Choose a verification method','Use the button in the email, or enter the 8-digit verification code directly on the website.'],
        ['Finish verification','Enter the 8-digit code from the email, or use the email button to complete verification.']
      ],
      doneTitle:'Done — your account is now protected ✦',
      doneBody:'After linking, you can sign in with the same email on another phone, computer, or browser to recover your cloud data.',
      doneTip:'We recommend linking before you invest long-term progress in Stellar Farm or personal records.',
      prev:'Back', next:'Next', start:'Start guide', bind:'Bind my email now', close:'Close', dismiss:'Don’t show this again', step:'Step', imageAlt:'Registration tutorial screenshot',
      tapImage:'Tap the image to enlarge', closeImage:'Close enlarged image'
    }
  };

  const pages = [
    { kind:'intro' },
    ...Array.from({length:6}, (_,i) => ({kind:'step', step:i+1, image:`step-${String(i+1).padStart(2,'0')}.png`})),
    { kind:'done' }
  ];

  let index = 0;
  let modal = null;
  let lightbox = null;
  let activeImageSrc = '';
  let touchStartX = 0;
  let autoStarted = false;

  const lang = () => ['zh-CN','zh-TW','en'].includes(document.documentElement.lang) ? document.documentElement.lang : 'zh-CN';
  const t = () => COPY[lang()] || COPY['zh-CN'];

  function inject() {
    if (modal) return;
    document.body.insertAdjacentHTML('beforeend', `
      <div class="new-player-guide" data-new-player-guide hidden>
        <div class="new-player-guide-backdrop" data-new-player-guide-close></div>
        <section class="new-player-guide-dialog" role="dialog" aria-modal="true" aria-labelledby="newPlayerGuideTitle">
          <header class="new-player-guide-head">
            <div>
              <span class="new-player-guide-kicker">STELLAR DIARY · GUIDE</span>
              <h2 id="newPlayerGuideTitle"></h2>
              <p data-guide-subtitle></p>
            </div>
            <button class="new-player-guide-close" type="button" data-new-player-guide-close aria-label="Close">×</button>
          </header>
          <div class="new-player-guide-body">
            <div class="new-player-guide-visual" data-guide-visual>
              <button class="new-player-guide-image-button" type="button" data-guide-image-button hidden>
                <img data-guide-image alt="" draggable="false" />
                <span data-guide-image-hint></span>
              </button>
            </div>
            <div class="new-player-guide-copy">
              <span class="new-player-guide-step" data-guide-step></span>
              <h3 data-guide-page-title></h3>
              <p data-guide-page-body></p>
              <p class="new-player-guide-tip" data-guide-tip hidden></p>
              <button class="new-player-guide-login-link" type="button" data-guide-login hidden></button>
            </div>
          </div>
          <div class="new-player-guide-progress" data-guide-progress aria-hidden="true"></div>
          <footer class="new-player-guide-footer">
            <label class="new-player-guide-dismiss"><input type="checkbox" data-guide-dismiss /><span data-guide-dismiss-label></span></label>
            <div class="new-player-guide-actions">
              <button class="new-player-guide-btn is-secondary" type="button" data-guide-prev></button>
              <button class="new-player-guide-btn is-primary" type="button" data-guide-next></button>
            </div>
          </footer>
        </section>
      </div>
      <div class="new-player-guide-lightbox" data-guide-lightbox hidden>
        <button type="button" class="new-player-guide-lightbox-close" data-guide-lightbox-close>×</button>
        <img data-guide-lightbox-image alt="" />
      </div>
    `);
    modal = document.querySelector('[data-new-player-guide]');
    lightbox = document.querySelector('[data-guide-lightbox]');

    modal.querySelectorAll('[data-new-player-guide-close]').forEach(el => el.addEventListener('click', close));
    modal.querySelector('[data-guide-prev]').addEventListener('click', prev);
    modal.querySelector('[data-guide-next]').addEventListener('click', next);
    modal.querySelector('[data-guide-login]').addEventListener('click', () => goAccount('login'));
    modal.querySelector('[data-guide-image-button]').addEventListener('click', openLightbox);
    lightbox.querySelector('[data-guide-lightbox-close]').addEventListener('click', closeLightbox);
    lightbox.addEventListener('click', e => { if (e.target === lightbox) closeLightbox(); });
    document.addEventListener('keydown', e => {
      if (!modal || modal.hidden) return;
      if (e.key === 'Escape') { if (lightbox && !lightbox.hidden) closeLightbox(); else close(); }
      if (lightbox && !lightbox.hidden) return;
      if (e.key === 'ArrowRight') next();
      if (e.key === 'ArrowLeft') prev();
    });
    const dialog = modal.querySelector('.new-player-guide-dialog');
    dialog.addEventListener('touchstart', e => { touchStartX = e.changedTouches?.[0]?.clientX || 0; }, {passive:true});
    dialog.addEventListener('touchend', e => {
      const end = e.changedTouches?.[0]?.clientX || 0;
      const diff = end - touchStartX;
      if (Math.abs(diff) < 70) return;
      if (diff < 0) next(); else prev();
    }, {passive:true});
    render();
  }

  function render() {
    if (!modal) return;
    const c=t();
    const page=pages[index];
    const imageBtn=modal.querySelector('[data-guide-image-button]');
    const image=modal.querySelector('[data-guide-image]');
    const visual=modal.querySelector('[data-guide-visual]');
    const body=modal.querySelector('.new-player-guide-body');
    const tip=modal.querySelector('[data-guide-tip]');
    const loginBtn=modal.querySelector('[data-guide-login]');
    const prevBtn=modal.querySelector('[data-guide-prev]');
    const nextBtn=modal.querySelector('[data-guide-next]');
    const trigger=document.querySelector('[data-new-player-guide-trigger-label]');
    if(trigger) trigger.textContent=c.trigger;
    const triggerButton=document.querySelector('[data-new-player-guide-open]');
    if(triggerButton) triggerButton.setAttribute('aria-label',c.aria);

    modal.querySelector('#newPlayerGuideTitle').textContent=c.label;
    modal.querySelector('[data-guide-subtitle]').textContent=c.subtitle;
    modal.querySelector('[data-guide-dismiss-label]').textContent=c.dismiss;
    modal.querySelector('[data-guide-image-hint]').textContent=c.tapImage;
    modal.querySelector('.new-player-guide-close').setAttribute('aria-label',c.close);

    tip.hidden=true; loginBtn.hidden=true; imageBtn.hidden=true;
    const hasScreenshot=page.kind==='step';
    visual.hidden=!hasScreenshot;
    body.classList.toggle('is-text-only',!hasScreenshot);
    activeImageSrc='';
    if(page.kind==='intro'){
      modal.querySelector('[data-guide-step]').textContent='WELCOME';
      modal.querySelector('[data-guide-page-title]').textContent=c.introTitle;
      modal.querySelector('[data-guide-page-body]').textContent=c.introBody;
      tip.hidden=false; tip.textContent=c.introTip;
      loginBtn.hidden=false; loginBtn.textContent=c.login;
      nextBtn.textContent=c.start;
    }else if(page.kind==='step'){
      imageBtn.hidden=false;
      activeImageSrc=SCREENSHOT_ROOT+page.image;
      image.src=activeImageSrc;
      image.alt=`${c.imageAlt} ${page.step}`;
      modal.querySelector('[data-guide-step]').textContent=`${c.step} ${page.step} / 6`;
      modal.querySelector('[data-guide-page-title]').textContent=c.steps[page.step-1][0];
      modal.querySelector('[data-guide-page-body]').textContent=c.steps[page.step-1][1];
      nextBtn.textContent=c.next;
    }else{
      modal.querySelector('[data-guide-step]').textContent='READY';
      modal.querySelector('[data-guide-page-title]').textContent=c.doneTitle;
      modal.querySelector('[data-guide-page-body]').textContent=c.doneBody;
      tip.hidden=false; tip.textContent=c.doneTip;
      nextBtn.textContent=c.bind;
    }
    prevBtn.textContent=c.prev;
    prevBtn.hidden=index===0;
    const progress=modal.querySelector('[data-guide-progress]');
    progress.innerHTML=pages.map((_,i)=>`<span class="${i===index?'is-active':''}"></span>`).join('');
  }

  function open({manual=false}={}) {
    inject();
    index=0;
    modal.hidden=false;
    document.body.classList.add('new-player-guide-open');
    modal.dataset.manual=manual?'true':'false';
    render();
    requestAnimationFrame(()=>modal.querySelector('[data-guide-next]')?.focus({preventScroll:true}));
  }
  function rememberDismissal(){
    const checked=modal?.querySelector('[data-guide-dismiss]')?.checked;
    if(checked){ try{localStorage.setItem(DISMISS_KEY,'1');}catch(_){ } }
  }
  function close(){
    if(!modal) return;
    rememberDismissal();
    modal.hidden=true;
    document.body.classList.remove('new-player-guide-open');
    closeLightbox();
  }
  function next(){
    if(index < pages.length-1){ index++; render(); return; }
    rememberDismissal();
    goAccount('bind');
  }
  function prev(){ if(index>0){index--;render();} }
  function goAccount(mode){
    rememberDismissal();
    const target=`account.html?guide=${encodeURIComponent(mode)}`;
    if(mode==='bind' && !window.XingchenPlayer?.hasProfile?.()){
      close();
      window.XingchenPlayer?.open?.(()=>window.location.assign(target));
      return;
    }
    window.location.assign(target);
  }
  function openLightbox(){
    if(!activeImageSrc||!lightbox) return;
    const img=lightbox.querySelector('[data-guide-lightbox-image]');
    img.src=activeImageSrc; img.alt=t().imageAlt;
    lightbox.querySelector('[data-guide-lightbox-close]').setAttribute('aria-label',t().closeImage);
    lightbox.hidden=false;
  }
  function closeLightbox(){ if(lightbox) lightbox.hidden=true; }

  async function autoOpen(){
    if(autoStarted) return; autoStarted=true;
    try{ if(localStorage.getItem(DISMISS_KEY)==='1') return; }catch(_){ }
    let state={};
    try{ state=await window.XingchenAuth?.init?.() || window.XingchenAuth?.status?.() || {}; }catch(_){ state=window.XingchenAuth?.status?.()||{}; }
    if(state.signedIn && !state.isAnonymous) return;
    const hasProfile=Boolean(window.XingchenPlayer?.hasProfile?.());
    if(!state.isAnonymous && hasProfile) return;
    setTimeout(()=>open({manual:false}),450);
  }
  function init(){
    inject();
    document.addEventListener('click',e=>{
      const btn=e.target.closest?.('[data-new-player-guide-open]');
      if(!btn) return; e.preventDefault(); open({manual:true});
    });
    window.addEventListener('stellar:language-changed',render);
    autoOpen();
  }
  window.StellarNewPlayerGuide=Object.freeze({open:()=>open({manual:true}),close});
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',init,{once:true}); else init();
})();
