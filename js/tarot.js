(() => {
  const state = {
    cards: [],
    meanings: new Map(),
    topics: [],
    spreads: [],
    selectedTopic: 'general',
    selectedSpread: 'single',
    currentDraw: [],
    question: '',
    optionA: '',
    optionB: '',
    nextRevealIndex: 0,
    currentDrawId: '',
    autoRevealTimers: [],
    autoRevealToken: 0,
    isAutoRevealing: false,
    history: []
  };

  const byId = (id) => document.getElementById(id);

  const UI = {
    'zh-CN': {
      brand: '星辰日记',
      back: '返回首页',
      title: '塔罗牌占卜',
      intro: '写下真正想问的问题。解读会结合每张牌的牌义、牌位、正逆位、问题意图与牌与牌之间的关系，尽量像一场完整的读牌，而不是逐张套用固定答案。',
      questionHeading: '输入问题',
      questionHint: '把真正想知道的事情写下来，会更容易专注在同一个问题上。',
      questionNote: '问题可以留空；留空时会以你选择的方向进行一般指引。',
      topicHeading: '选择问题',
      topicHint: '先选择你想询问的方向，同一张牌在不同问题里会强调不同面向。',
      spreadHeading: '选择类型',
      spreadHint: '单张看核心；本周、本月、关系与二选一会读取更多牌面结构。',
      draw: '开始抽盘',
      drawHint: '在心里确认问题，默念三次，然后点击牌堆；系统会自动依序揭晓牌面',
      redraw: '重新抽盘',
      resultTitle: '你的牌阵',
      questionPrefix: '你问的是',
      revealGuideTitle: '系统正在依序揭晓牌面',
      revealGuideText: '请稍候，无需点击牌面。系统会按照牌位顺序自动翻牌，全部揭晓后显示完整组合解读。',
      revealNext: '正在揭晓',
      waiting: '等待揭晓',
      combinationLabel: '整体组合解读',
      combinationTitle: '像读牌师一样把牌连起来看',
      directAnswerHeading: '先给你一句话答案',
      storyHeading: '牌与牌之间怎么连起来',
      structureHeading: '读牌重点',
      finalAdviceHeading: '接下来最值得怎么做',
      upright: '正位',
      reversed: '逆位',
      cardMeaning: '牌意',
      topicLens: '放进这个问题里',
      cardAdvice: '这张牌的提醒',
      major: '大阿尔克那',
      minor: '小阿尔克那',
      optionA: '选项 A',
      optionB: '选项 B',
      optionAPlaceholder: '例如：留在现在的工作',
      optionBPlaceholder: '例如：接受新的工作机会',
      choiceMissing: '二选一牌阵建议填写 A、B 两个选项，方便结果对应。',
      allRevealed: '牌面已全部翻开，完整组合解读已经出现。',
      loadError: '牌库暂时无法读取，请重新整理后再试。',
      scrollTop: '回到顶部',
      bottomHome: '返回首页',
      placeholderGeneral: '例如：我目前最需要关注什么？',
      placeholderLove: '例如：我和对方接下来会如何发展？',
      placeholderCareer: '例如：目前这份工作接下来适合怎么走？',
      placeholderMoney: '例如：我最近的财务方向需要注意什么？',
      placeholderStudy: '例如：这次考试／学习计划该怎么调整？',
      historyButton:'历史记录', historyTitle:'最近的塔罗记录',
      historyHint:'结果保存在当前浏览器，最多保留最近 10 则。',
      historyEmpty:'还没有完成的塔罗记录。完整牌阵自动揭晓后，会保存在这里。',
      historyClear:'清空记录', historyClearConfirm:'确定要清空这台浏览器里的塔罗历史记录吗？',
      historyGeneral:'一般指引', historyCards:'牌面', historyAnswer:'直接回答', historyStory:'牌面故事',
      historyStructure:'结构重点', historyAdvice:'最终建议'
    },
    'zh-TW': {
      brand: '星辰日記',
      back: '返回首頁',
      title: '塔羅牌占卜',
      intro: '寫下真正想問的問題。解讀會結合每張牌的牌義、牌位、正逆位、問題意圖與牌與牌之間的關係，盡量像一場完整的讀牌，而不是逐張套用固定答案。',
      questionHeading: '輸入問題',
      questionHint: '把真正想知道的事情寫下來，會更容易專注在同一個問題上。',
      questionNote: '問題可以留空；留空時會以你選擇的方向進行一般指引。',
      topicHeading: '選擇問題',
      topicHint: '先選擇你想詢問的方向，同一張牌在不同問題裡會強調不同面向。',
      spreadHeading: '選擇類型',
      spreadHint: '單張看核心；本週、本月、關係與二選一會讀取更多牌面結構。',
      draw: '開始抽盤',
      drawHint: '在心裡確認問題，默念三次，然後點擊牌堆；系統會自動依序揭曉牌面',
      redraw: '重新抽盤',
      resultTitle: '你的牌陣',
      questionPrefix: '你問的是',
      revealGuideTitle: '系統正在依序揭曉牌面',
      revealGuideText: '請稍候，不需要點擊牌面。系統會依照牌位順序自動翻牌，全部揭曉後顯示完整組合解讀。',
      revealNext: '正在揭曉',
      waiting: '等待揭曉',
      combinationLabel: '整體組合解讀',
      combinationTitle: '像讀牌師一樣把牌連起來看',
      directAnswerHeading: '先給你一句話答案',
      storyHeading: '牌與牌之間怎麼連起來',
      structureHeading: '讀牌重點',
      finalAdviceHeading: '接下來最值得怎麼做',
      upright: '正位',
      reversed: '逆位',
      cardMeaning: '牌意',
      topicLens: '放進這個問題裡',
      cardAdvice: '這張牌的提醒',
      major: '大阿爾克那',
      minor: '小阿爾克那',
      optionA: '選項 A',
      optionB: '選項 B',
      optionAPlaceholder: '例如：留在現在的工作',
      optionBPlaceholder: '例如：接受新的工作機會',
      choiceMissing: '二選一牌陣建議填寫 A、B 兩個選項，方便結果對應。',
      allRevealed: '牌面已全部翻開，完整組合解讀已經出現。',
      loadError: '牌庫暫時無法讀取，請重新整理後再試。',
      scrollTop: '回到頂部',
      bottomHome: '返回首頁',
      placeholderGeneral: '例如：我目前最需要關注什麼？',
      placeholderLove: '例如：我和對方接下來會如何發展？',
      placeholderCareer: '例如：目前這份工作接下來適合怎麼走？',
      placeholderMoney: '例如：我最近的財務方向需要注意什麼？',
      placeholderStudy: '例如：這次考試／學習計畫該怎麼調整？',
      historyButton:'歷史紀錄', historyTitle:'最近的塔羅紀錄',
      historyHint:'結果保存在目前瀏覽器，最多保留最近 10 則。',
      historyEmpty:'還沒有完成的塔羅紀錄。完整牌陣自動揭曉後，會保存在這裡。',
      historyClear:'清空紀錄', historyClearConfirm:'確定要清空這台瀏覽器裡的塔羅歷史紀錄嗎？',
      historyGeneral:'一般指引', historyCards:'牌面', historyAnswer:'直接回答', historyStory:'牌面故事',
      historyStructure:'結構重點', historyAdvice:'最終建議'
    },
    'en': {
      brand: 'Stellar Diary',
      back: 'Home',
      title: 'Tarot Reading',
      intro: 'Write down the question you actually want answered. The reading connects each card’s meaning, position, orientation, your intent and the relationships between cards, so the spread reads as a whole rather than a set of fixed card blurbs.',
      questionHeading: 'Enter your question',
      questionHint: 'Writing the real question helps keep the reading focused on one issue.',
      questionNote: 'You may leave this blank; the reading will then use the selected area as a general guide.',
      topicHeading: 'Choose a question area',
      topicHint: 'Choose the area you want to ask about. The same card can emphasize different facets in different questions.',
      spreadHeading: 'Choose a reading type',
      spreadHint: 'One card for the core; weekly, monthly, relationship and two-path readings use more structural signals.',
      draw: 'Start reading',
      drawHint: 'Confirm your question, repeat it three times, then click the deck. The cards will reveal automatically.',
      redraw: 'Draw again',
      resultTitle: 'Your spread',
      questionPrefix: 'Your question',
      revealGuideTitle: 'The cards are revealing automatically',
      revealGuideText: 'No tapping is needed. The system reveals each position in order, then shows the complete combined interpretation.',
      revealNext: 'Revealing',
      waiting: 'Waiting to reveal',
      combinationLabel: 'Combined reading',
      combinationTitle: 'Read the spread as one connected story',
      directAnswerHeading: 'Direct answer',
      storyHeading: 'How the cards connect',
      structureHeading: 'How to read the signals',
      finalAdviceHeading: 'What to do next',
      upright: 'Upright',
      reversed: 'Reversed',
      cardMeaning: 'Card meaning',
      topicLens: 'In this question',
      cardAdvice: 'Card advice',
      major: 'Major Arcana',
      minor: 'Minor Arcana',
      optionA: 'Option A',
      optionB: 'Option B',
      optionAPlaceholder: 'e.g. Stay in my current job',
      optionBPlaceholder: 'e.g. Accept the new opportunity',
      choiceMissing: 'For a two-path reading, entering both A and B makes the result easier to follow.',
      allRevealed: 'All cards are revealed. The complete combined reading is now available.',
      loadError: 'The tarot data could not be loaded. Please refresh and try again.',
      scrollTop: 'Back to top',
      bottomHome: 'Back home',
      historyButton:'History', historyTitle:'Recent tarot readings',
      historyHint:'Saved in this browser, up to the latest 10 readings.',
      historyEmpty:'No completed tarot readings yet. A reading is saved after the full spread is revealed automatically.',
      historyClear:'Clear history', historyClearConfirm:'Clear tarot history stored in this browser?',
      historyGeneral:'General guidance', historyCards:'Cards', historyAnswer:'Direct answer', historyStory:'Narrative',
      historyStructure:'Structural signals', historyAdvice:'Final advice',
      placeholderGeneral: 'e.g. What deserves my attention right now?',
      placeholderLove: 'e.g. How may this relationship develop from here?',
      placeholderCareer: 'e.g. What direction should I take with my current work?',
      placeholderMoney: 'e.g. What should I pay attention to financially?',
      placeholderStudy: 'e.g. How should I adjust my study plan?'
    }
  };

  const suitMeta = {
    cups: { names: {'zh-CN':'圣杯','zh-TW':'聖杯','en':'Cups'}, element: 'water', elementNames: {'zh-CN':'水','zh-TW':'水','en':'Water'} },
    pentacles: { names: {'zh-CN':'星币','zh-TW':'星幣','en':'Pentacles'}, element: 'earth', elementNames: {'zh-CN':'土','zh-TW':'土','en':'Earth'} },
    swords: { names: {'zh-CN':'宝剑','zh-TW':'寶劍','en':'Swords'}, element: 'air', elementNames: {'zh-CN':'风','zh-TW':'風','en':'Air'} },
    wands: { names: {'zh-CN':'权杖','zh-TW':'權杖','en':'Wands'}, element: 'fire', elementNames: {'zh-CN':'火','zh-TW':'火','en':'Fire'} }
  };

  const topicSuitLens = {
    general: {
      major: {
        'zh-CN':'这张大牌更像在提醒你：眼前不是单一小事件，而是一个值得认真面对的阶段性课题。',
        'zh-TW':'這張大牌更像在提醒你：眼前不是單一小事件，而是一個值得認真面對的階段性課題。',
        'en':'As a Major Arcana card, this points to a broader life theme rather than a small isolated event.'
      },
      cups: {'zh-CN':'这里更强调感受、关系与内在满足感。','zh-TW':'這裡更強調感受、關係與內在滿足感。','en':'This emphasizes feelings, relationships and inner fulfillment.'},
      wands: {'zh-CN':'这里更强调行动、动力、勇气与主动创造。','zh-TW':'這裡更強調行動、動力、勇氣與主動創造。','en':'This emphasizes action, drive, courage and initiative.'},
      swords: {'zh-CN':'这里更强调想法、沟通、判断与需要面对的矛盾。','zh-TW':'這裡更強調想法、溝通、判斷與需要面對的矛盾。','en':'This emphasizes thought, communication, judgment and tensions to address.'},
      pentacles: {'zh-CN':'这里更强调现实条件、稳定度、资源与长期累积。','zh-TW':'這裡更強調現實條件、穩定度、資源與長期累積。','en':'This emphasizes practical conditions, stability, resources and long-term building.'}
    },
    love: {
      major: {'zh-CN':'在感情里，这张大牌通常把焦点拉回关系中的关键课题、重要选择或成长阶段。','zh-TW':'在感情裡，這張大牌通常把焦點拉回關係中的關鍵課題、重要選擇或成長階段。','en':'In love, this Major Arcana card highlights a defining relationship lesson, choice or growth phase.'},
      cups: {'zh-CN':'感情面重点在情绪流动、亲密感、回应与彼此是否真的被理解。','zh-TW':'感情面重點在情緒流動、親密感、回應與彼此是否真的被理解。','en':'In love, focus on emotional flow, intimacy, responsiveness and whether both sides feel understood.'},
      wands: {'zh-CN':'感情面重点在吸引力、主动程度、热度以及双方是否愿意推动关系。','zh-TW':'感情面重點在吸引力、主動程度、熱度以及雙方是否願意推動關係。','en':'In love, focus on attraction, initiative, chemistry and willingness to move the relationship forward.'},
      swords: {'zh-CN':'感情面重点在沟通、界线、误解与那些一直没有说清楚的话。','zh-TW':'感情面重點在溝通、界線、誤解與那些一直沒有說清楚的話。','en':'In love, focus on communication, boundaries, misunderstandings and what remains unsaid.'},
      pentacles: {'zh-CN':'感情面重点在安全感、实际投入、稳定性，以及两个人能不能把关系落到生活里。','zh-TW':'感情面重點在安全感、實際投入、穩定性，以及兩個人能不能把關係落到生活裡。','en':'In love, focus on security, tangible effort, stability and how well the bond works in real life.'}
    },
    career: {
      major: {'zh-CN':'在事业里，这张大牌更像一个转折讯号：你的方向、定位或重要决定正在被放大。','zh-TW':'在事業裡，這張大牌更像一個轉折訊號：你的方向、定位或重要決定正在被放大。','en':'In career, this Major Arcana card magnifies a turning point involving direction, identity or an important decision.'},
      cups: {'zh-CN':'事业面重点在团队关系、工作满足感、合作气氛与价值认同。','zh-TW':'事業面重點在團隊關係、工作滿足感、合作氣氛與價值認同。','en':'In career, focus on teamwork, satisfaction, collaboration and alignment of values.'},
      wands: {'zh-CN':'事业面重点在机会、执行、竞争力、领导与把想法真正推起来。','zh-TW':'事業面重點在機會、執行、競爭力、領導與把想法真正推起來。','en':'In career, focus on opportunity, execution, competitiveness, leadership and momentum.'},
      swords: {'zh-CN':'事业面重点在策略、沟通、判断、压力与必须做出的清晰选择。','zh-TW':'事業面重點在策略、溝通、判斷、壓力與必須做出的清晰選擇。','en':'In career, focus on strategy, communication, judgment, pressure and clear decisions.'},
      pentacles: {'zh-CN':'事业面重点在资源、薪酬、技能累积、稳定度与长期可持续性。','zh-TW':'事業面重點在資源、薪酬、技能累積、穩定度與長期可持續性。','en':'In career, focus on resources, compensation, skill-building, stability and sustainability.'}
    },
    money: {
      major: {'zh-CN':'在财务问题里，这张大牌提醒你先看长期方向与价值判断，不要只盯着眼前数字。','zh-TW':'在財務問題裡，這張大牌提醒你先看長期方向與價值判斷，不要只盯著眼前數字。','en':'In money matters, this Major Arcana card asks you to consider long-term direction and values, not only immediate numbers.'},
      cups: {'zh-CN':'财务面要留意情绪性消费、人情支出，以及「想要」和「真正需要」之间的差别。','zh-TW':'財務面要留意情緒性消費、人情支出，以及「想要」和「真正需要」之間的差別。','en':'For money, watch emotional spending, social expenses and the difference between wants and needs.'},
      wands: {'zh-CN':'财务面与主动开源、机会判断和风险承受有关；有冲劲，也要保留计算。','zh-TW':'財務面與主動開源、機會判斷和風險承受有關；有衝勁，也要保留計算。','en':'For money, this points to earning initiatives, opportunity judgment and risk tolerance—keep the drive, but do the math.'},
      swords: {'zh-CN':'财务面重点在数字、合约、判断与风险控制；越需要冷静，越不要凭一时情绪决定。','zh-TW':'財務面重點在數字、合約、判斷與風險控制；越需要冷靜，越不要憑一時情緒決定。','en':'For money, focus on numbers, contracts, judgment and risk control. Avoid emotional decisions.'},
      pentacles: {'zh-CN':'财务面是这组能量最直接的领域：现金流、储蓄、资产、工作收入与现实资源都值得具体检查。','zh-TW':'財務面是這組能量最直接的領域：現金流、儲蓄、資產、工作收入與現實資源都值得具體檢查。','en':'This suit speaks most directly to money: review cash flow, savings, assets, earned income and practical resources.'}
    },
    study: {
      major: {'zh-CN':'在学业里，这张大牌强调的不只是成绩，而是你正在建立怎样的学习态度、方向与自我认知。','zh-TW':'在學業裡，這張大牌強調的不只是成績，而是你正在建立怎樣的學習態度、方向與自我認知。','en':'In study, this Major Arcana card is about more than grades—it highlights learning direction, mindset and self-understanding.'},
      cups: {'zh-CN':'学业面重点在兴趣、情绪状态、同伴互动，以及能不能对学习保持真实连接。','zh-TW':'學業面重點在興趣、情緒狀態、同伴互動，以及能不能對學習保持真實連結。','en':'For study, focus on interest, emotional state, peer interaction and genuine connection with the subject.'},
      wands: {'zh-CN':'学业面重点在动力、目标感、行动速度与持续把计划做下去。','zh-TW':'學業面重點在動力、目標感、行動速度與持續把計畫做下去。','en':'For study, focus on motivation, goals, momentum and consistently following the plan.'},
      swords: {'zh-CN':'学业面重点在理解、逻辑、考试压力、时间判断与思绪是否过度紧绷。','zh-TW':'學業面重點在理解、邏輯、考試壓力、時間判斷與思緒是否過度緊繃。','en':'For study, focus on comprehension, logic, exam pressure, time judgment and mental overload.'},
      pentacles: {'zh-CN':'学业面重点在规律、练习量、基础能力与一点一点累积出来的稳定成果。','zh-TW':'學業面重點在規律、練習量、基礎能力與一點一點累積出來的穩定成果。','en':'For study, focus on routine, practice volume, fundamentals and steady accumulated results.'}
    }
  };

  function currentLanguage() {
    const saved = localStorage.getItem('xingchen-language');
    return ['zh-CN','zh-TW','en'].includes(saved) ? saved : 'zh-CN';
  }

  function ui(key) {
    const lang = currentLanguage();
    return UI[lang]?.[key] ?? UI['zh-CN'][key] ?? key;
  }

  function localized(obj) {
    const lang = currentLanguage();
    return obj?.[lang] ?? obj?.['zh-CN'] ?? '';
  }

  function escapeHtml(text) {
    return String(text ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function secureRandomInt(maxExclusive) {
    const maxUint = 0x100000000;
    const limit = maxUint - (maxUint % maxExclusive);
    const arr = new Uint32Array(1);
    do crypto.getRandomValues(arr); while (arr[0] >= limit);
    return arr[0] % maxExclusive;
  }

  function shuffledUniqueCards(count) {
    const pool = [...state.cards];
    for (let i = pool.length - 1; i > 0; i--) {
      const j = secureRandomInt(i + 1);
      [pool[i], pool[j]] = [pool[j], pool[i]];
    }
    return pool.slice(0, count);
  }

  function imageFromRoot(path) {
    return `../${path}`;
  }

  function selectedTopic() {
    return state.topics.find(x => x.key === state.selectedTopic) || state.topics[0];
  }

  function selectedSpread() {
    return state.spreads.find(x => x.key === state.selectedSpread) || state.spreads[0];
  }

  function orientationText(reversed) {
    return reversed ? ui('reversed') : ui('upright');
  }

  function cardName(card) {
    return card.name[currentLanguage()] || card.name['zh-CN'];
  }

  function arcanaText(card) {
    if (card.arcana === 'major') return ui('major');
    return `${ui('minor')} · ${localized(suitMeta[card.suit].names)}`;
  }

  function questionPlaceholder() {
    const map = {
      general: 'placeholderGeneral',
      love: 'placeholderLove',
      career: 'placeholderCareer',
      money: 'placeholderMoney',
      study: 'placeholderStudy'
    };
    return ui(map[state.selectedTopic] || 'placeholderGeneral');
  }

  function renderStaticLanguage() {
    document.documentElement.lang = currentLanguage();
    byId('tarotBrandTitle').textContent = ui('brand');
    byId('tarotBackLink').textContent = ui('back');
    byId('tarotPageTitle').textContent = ui('title');
    byId('tarotIntro').textContent = ui('intro');
    byId('questionHeading').textContent = ui('questionHeading');
    byId('questionHint').textContent = ui('questionHint');
    byId('questionNote').textContent = ui('questionNote');
    byId('topicHeading').textContent = ui('topicHeading');
    byId('topicHint').textContent = ui('topicHint');
    byId('spreadHeading').textContent = ui('spreadHeading');
    byId('spreadHint').textContent = ui('spreadHint');
    byId('drawButtonText').textContent = ui('draw');
    byId('drawButtonHint').textContent = ui('drawHint');
    byId('drawTarotAgainBtn').innerHTML = `<span class="stellar-core-icon is-button-site-icon" data-core-icon="refresh" aria-hidden="true"></span><span>${ui('redraw')}</span>`;
    byId('resultTitle').textContent = ui('resultTitle');
    byId('revealGuideTitle').textContent = ui('revealGuideTitle');
    byId('revealGuideText').textContent = ui('revealGuideText');
    byId('combinationLabel').textContent = ui('combinationLabel');
    byId('combinationTitle').textContent = ui('combinationTitle');
    byId('directAnswerHeading').textContent = ui('directAnswerHeading');
    byId('storyHeading').textContent = ui('storyHeading');
    byId('structureHeading').textContent = ui('structureHeading');
    byId('finalAdviceHeading').textContent = ui('finalAdviceHeading');
    byId('tarotLoadError').textContent = ui('loadError');
    byId('optionALabel').textContent = ui('optionA');
    byId('optionBLabel').textContent = ui('optionB');
    byId('optionAInput').placeholder = ui('optionAPlaceholder');
    byId('optionBInput').placeholder = ui('optionBPlaceholder');
    byId('questionInput').placeholder = questionPlaceholder();
    byId('tarotHistoryButtonText').textContent = ui('historyButton');
    byId('tarotHistoryTitle').textContent = ui('historyTitle');
    byId('tarotHistoryHint').textContent = ui('historyHint');
    byId('tarotHistoryClear').innerHTML = `<span class="stellar-ui-icon is-button-site-icon" data-site-icon="delete" aria-hidden="true"></span><span>${ui('historyClear')}</span>`;
  }

  function positionName(position) {
    const spread = selectedSpread();
    const base = localized(position.name);

    if (spread.key !== 'choice5') return base;

    const A = state.optionA.trim();
    const B = state.optionB.trim();
    if (position.key === 'optionA' && A) return `${ui('optionA')} · ${A}`;
    if (position.key === 'optionAOutcome' && A) {
      return currentLanguage() === 'en' ? `${A} · Outcome` : `${A} · ${currentLanguage() === 'zh-TW' ? '發展' : '发展'}`;
    }
    if (position.key === 'optionB' && B) return `${ui('optionB')} · ${B}`;
    if (position.key === 'optionBOutcome' && B) {
      return currentLanguage() === 'en' ? `${B} · Outcome` : `${B} · ${currentLanguage() === 'zh-TW' ? '發展' : '发展'}`;
    }
    return base;
  }

  function renderControls() {
    const lang = currentLanguage();

    byId('topicOptions').innerHTML = state.topics.map(topic => `
      <button class="tarot-choice-pill ${topic.key === state.selectedTopic ? 'active' : ''}"
              type="button" data-topic="${topic.key}">
        ${escapeHtml(topic.name[lang] || topic.name['zh-CN'])}
      </button>
    `).join('');

    byId('topicDescription').textContent = localized(selectedTopic().description);
    byId('questionInput').placeholder = questionPlaceholder();

    byId('spreadOptions').innerHTML = state.spreads.map(spread => `
      <button class="tarot-spread-choice ${spread.key === state.selectedSpread ? 'active' : ''}"
              type="button" data-spread="${spread.key}">
        <span class="tarot-spread-icon" aria-hidden="true">
          <img src="../images/tarot/cards/CardBacks.webp" alt="" />
        </span>
        <span>
          <strong>${escapeHtml(localized(spread.name))}</strong>
          <small>${escapeHtml(localized(spread.subtitle))}</small>
        </span>
      </button>
    `).join('');

    byId('choiceFields').hidden = state.selectedSpread !== 'choice5';

    document.querySelectorAll('[data-topic]').forEach(btn => {
      btn.addEventListener('click', () => {
        state.selectedTopic = btn.dataset.topic;
        renderControls();
      });
    });

    document.querySelectorAll('[data-spread]').forEach(btn => {
      btn.addEventListener('click', () => {
        state.selectedSpread = btn.dataset.spread;
        renderControls();
      });
    });
  }

  function topicLens(card, reversed) {
    const lang = currentLanguage();
    const sourceKey = card.arcana === 'major' ? 'major' : card.suit;
    const base = topicSuitLens[state.selectedTopic]?.[sourceKey]?.[lang]
      || topicSuitLens.general[sourceKey]?.[lang]
      || '';
    if (!reversed) return base;

    const tails = {
      'zh-CN': ' 逆位出现时，更适合先检查这股能量是否受阻、过度，或被压住没有真正表达。',
      'zh-TW': ' 逆位出現時，更適合先檢查這股能量是否受阻、過度，或被壓住沒有真正表達。',
      'en': ' Reversed, first check whether this energy is blocked, excessive, delayed, or not being expressed clearly.'
    };
    return base + tails[lang];
  }

  // --- V0.19.7.0 · Contextual reading layer ---------------------------------
  // The base meanings remain stable RWS-inspired copy. This layer changes how a
  // card is read according to the user's question, spread position, orientation
  // and neighbouring cards, so the result behaves more like an actual reading
  // and less like five independent dictionary entries.

  const majorArchetypeLens = Object.freeze({
    thefool:      {'zh-CN':'愚人谈的是迈出未知、自由与风险之间的取舍。','zh-TW':'愚人談的是邁出未知、自由與風險之間的取捨。',en:'The Fool is about stepping into the unknown and balancing freedom with risk.'},
    themagician:  {'zh-CN':'魔术师强调把已有资源集中起来，让意图真正变成行动。','zh-TW':'魔術師強調把已有資源集中起來，讓意圖真正變成行動。',en:'The Magician focuses on concentrating available resources and turning intent into action.'},
    thehighpriestess:{'zh-CN':'女祭司把焦点放在尚未说出口的信息、直觉与需要等待确认的部分。','zh-TW':'女祭司把焦點放在尚未說出口的資訊、直覺與需要等待確認的部分。',en:'The High Priestess points to unspoken information, intuition and what still needs time to become clear.'},
    theempress:   {'zh-CN':'皇后关注滋养、关系里的承接力，以及一件事有没有真实生长空间。','zh-TW':'皇后關注滋養、關係裡的承接力，以及一件事有沒有真實生長空間。',en:'The Empress asks whether there is nourishment, receptivity and real room for growth.'},
    theemperor:   {'zh-CN':'皇帝强调结构、界线、责任与谁真正掌握决定权。','zh-TW':'皇帝強調結構、界線、責任與誰真正掌握決定權。',en:'The Emperor emphasizes structure, boundaries, responsibility and who actually holds decision-making power.'},
    thehierophant:{'zh-CN':'教皇关注规则、承诺、价值观，以及关系或选择能否进入稳定框架。','zh-TW':'教皇關注規則、承諾、價值觀，以及關係或選擇能否進入穩定框架。',en:'The Hierophant focuses on rules, commitment, shared values and whether something can enter a stable framework.'},
    thelovers:    {'zh-CN':'恋人不只谈吸引，也谈价值一致、选择与是否愿意对选择负责。','zh-TW':'戀人不只談吸引，也談價值一致、選擇與是否願意對選擇負責。',en:'The Lovers is not only attraction; it is alignment, choice and responsibility for that choice.'},
    thechariot:   {'zh-CN':'战车强调方向感、推进力，以及能不能把彼此拉扯的力量导向同一个目标。','zh-TW':'戰車強調方向感、推進力，以及能不能把彼此拉扯的力量導向同一個目標。',en:'The Chariot is about direction, momentum and steering competing forces toward one goal.'},
    strength:     {'zh-CN':'力量关注稳定情绪、耐心与柔韧控制，而不是用力压过问题。','zh-TW':'力量關注穩定情緒、耐心與柔韌控制，而不是用力壓過問題。',en:'Strength is about emotional steadiness, patience and soft control rather than overpowering the issue.'},
    thehermit:    {'zh-CN':'隐者把答案拉回独处、反思与先确认自己真正要什么。','zh-TW':'隱者把答案拉回獨處、反思與先確認自己真正要什麼。',en:'The Hermit turns the answer inward: reflection, distance and clarifying what you actually want.'},
    wheeloffortune:{'zh-CN':'命运之轮强调局势正在转动，时机与外部变化会比单方面控制更重要。','zh-TW':'命運之輪強調局勢正在轉動，時機與外部變化會比單方面控制更重要。',en:'The Wheel of Fortune shows a changing cycle where timing and external movement matter more than control.'},
    justice:      {'zh-CN':'正义要求回到事实、对等、因果与该承担的责任。','zh-TW':'正義要求回到事實、對等、因果與該承擔的責任。',en:'Justice returns the reading to facts, reciprocity, consequences and accountability.'},
    thehangedman: {'zh-CN':'倒吊人代表暂停、换角度与暂时不能靠原方法推进。','zh-TW':'倒吊人代表暫停、換角度與暫時不能靠原方法推進。',en:'The Hanged Man points to pause, a new perspective and a situation that cannot be pushed in the usual way.'},
    death:        {'zh-CN':'死神强调一个旧阶段必须结束，重点在转化而不是维持原样。','zh-TW':'死神強調一個舊階段必須結束，重點在轉化而不是維持原樣。',en:'Death marks an ending that requires transformation rather than preserving the old form.'},
    temperance:   {'zh-CN':'节制要求调和差异、放慢节奏，并找到双方或两种需求能够共存的比例。','zh-TW':'節制要求調和差異、放慢節奏，並找到雙方或兩種需求能夠共存的比例。',en:'Temperance asks for pacing, integration and a workable balance between different needs.'},
    thedevil:     {'zh-CN':'恶魔会把依赖、欲望、控制或明知不舒服却难以脱离的模式放大。','zh-TW':'惡魔會把依賴、慾望、控制或明知不舒服卻難以脫離的模式放大。',en:'The Devil magnifies attachment, desire, control or a pattern that is hard to leave even when it is uncomfortable.'},
    thetower:     {'zh-CN':'高塔指出原本的结构撑不住了，真相或变化会逼迫事情重新排列。','zh-TW':'高塔指出原本的結構撐不住了，真相或變化會逼迫事情重新排列。',en:'The Tower shows a structure that can no longer hold; truth or change forces a reordering.'},
    thestar:      {'zh-CN':'星星强调希望、修复、重新相信，以及在混乱之后找到较清楚的方向。','zh-TW':'星星強調希望、修復、重新相信，以及在混亂之後找到較清楚的方向。',en:'The Star is about hope, repair, renewed trust and finding direction after disruption.'},
    themoon:      {'zh-CN':'月亮提醒你现在看到的未必完整，情绪、猜测与隐藏信息容易混在一起。','zh-TW':'月亮提醒你現在看到的未必完整，情緒、猜測與隱藏資訊容易混在一起。',en:'The Moon warns that the picture may be incomplete, with emotion, projection and hidden information intertwined.'},
    thesun:       {'zh-CN':'太阳强调看得见的事实、坦率表达、活力与事情逐渐明朗。','zh-TW':'太陽強調看得見的事實、坦率表達、活力與事情逐漸明朗。',en:'The Sun emphasizes visible facts, openness, vitality and increasing clarity.'},
    judgement:    {'zh-CN':'审判代表一次回看与醒悟：旧事会被重新评估，并要求你做出更清醒的回应。','zh-TW':'審判代表一次回看與醒悟：舊事會被重新評估，並要求你做出更清醒的回應。',en:'Judgement brings review and awakening: the past is reassessed and calls for a more conscious response.'},
    theworld:     {'zh-CN':'世界强调完成、整合与阶段闭环，也会问你是否准备进入下一阶段。','zh-TW':'世界強調完成、整合與階段閉環，也會問你是否準備進入下一階段。',en:'The World emphasizes completion, integration and whether you are ready to move into the next cycle.'}
  });

  const suitCoreLens = Object.freeze({
    cups:{'zh-CN':'圣杯处理情绪流动、关系回应与心里真正重视的东西。','zh-TW':'聖杯處理情緒流動、關係回應與心裡真正重視的東西。',en:'Cups describe emotional flow, relationship response and what matters to the heart.'},
    wands:{'zh-CN':'权杖处理欲望、行动意愿、热度与推动事情的力量。','zh-TW':'權杖處理慾望、行動意願、熱度與推動事情的力量。',en:'Wands describe desire, initiative, heat and the force that moves a situation.'},
    swords:{'zh-CN':'宝剑处理事实、判断、沟通、界线与心理压力。','zh-TW':'寶劍處理事實、判斷、溝通、界線與心理壓力。',en:'Swords describe facts, judgment, communication, boundaries and mental pressure.'},
    pentacles:{'zh-CN':'星币处理现实投入、资源、安全感、时间与能否持续。','zh-TW':'星幣處理現實投入、資源、安全感、時間與能否持續。',en:'Pentacles describe practical effort, resources, security, time and sustainability.'}
  });

  const rankStageLens = Object.freeze({
    1:{'zh-CN':'一代表种子刚出现，重点是潜力有没有被真正接住。','zh-TW':'一代表種子剛出現，重點是潛力有沒有被真正接住。',en:'Ace is the seed: the question is whether new potential is actually received and used.'},
    2:{'zh-CN':'二把重点放在两股力量如何对接、平衡或做选择。','zh-TW':'二把重點放在兩股力量如何對接、平衡或做選擇。',en:'Two focuses on how two forces meet, balance or choose between alternatives.'},
    3:{'zh-CN':'三代表事情开始扩展，需要互动、合作或把想法带到外部。','zh-TW':'三代表事情開始擴展，需要互動、合作或把想法帶到外部。',en:'Three expands the situation through interaction, collaboration or expression.'},
    4:{'zh-CN':'四在问稳定与停留：现在是在建立基础，还是因为抓得太紧而停住。','zh-TW':'四在問穩定與停留：現在是在建立基礎，還是因為抓得太緊而停住。',en:'Four asks about stability and holding: building a base, or becoming stuck by holding too tightly.'},
    5:{'zh-CN':'五通常带来摩擦、缺口或失衡，逼你看见原本忽略的问题。','zh-TW':'五通常帶來摩擦、缺口或失衡，逼你看見原本忽略的問題。',en:'Five introduces friction, lack or imbalance that exposes what was being overlooked.'},
    6:{'zh-CN':'六进入调整与重新分配阶段，重点是怎样把失衡拉回较可行的位置。','zh-TW':'六進入調整與重新分配階段，重點是怎樣把失衡拉回較可行的位置。',en:'Six moves into adjustment and rebalancing—how to restore a more workable flow.'},
    7:{'zh-CN':'七是测试期：选择变多、立场被挑战，也更需要辨别什么值得坚持。','zh-TW':'七是測試期：選擇變多、立場被挑戰，也更需要辨別什麼值得堅持。',en:'Seven is a testing stage: more options, challenged positions and the need to discern what is worth holding.'},
    8:{'zh-CN':'八把能量推向持续行动、推进或离开旧状态，不能只停在想法里。','zh-TW':'八把能量推向持續行動、推進或離開舊狀態，不能只停在想法裡。',en:'Eight pushes energy into sustained movement, work or leaving an old state behind.'},
    9:{'zh-CN':'九接近阶段高点，成果与压力都会变得更个人化、更明显。','zh-TW':'九接近階段高點，成果與壓力都會變得更個人化、更明顯。',en:'Nine approaches culmination, making both reward and pressure more personal and visible.'},
    10:{'zh-CN':'十来到阶段结算，重点是完成之后还要不要继续背着原有模式。','zh-TW':'十來到階段結算，重點是完成之後還要不要繼續背著原有模式。',en:'Ten reaches culmination and asks what should be completed, released or carried into the next cycle.'},
    11:{'zh-CN':'侍从像刚出现的消息、好奇或学习姿态，真实度要看后续有没有继续发展。','zh-TW':'侍從像剛出現的消息、好奇或學習姿態，真實度要看後續有沒有繼續發展。',en:'The Page is a new message, curiosity or learning stance whose significance depends on what follows.'},
    12:{'zh-CN':'骑士代表能量开始移动，重点是行动速度、方向与是否会持续。','zh-TW':'騎士代表能量開始移動，重點是行動速度、方向與是否會持續。',en:'The Knight puts energy in motion; pace, direction and follow-through become central.'},
    13:{'zh-CN':'王后把力量放在内在成熟、感受与稳定承接，不一定高调但很有持续性。','zh-TW':'王后把力量放在內在成熟、感受與穩定承接，不一定高調但很有持續性。',en:'The Queen expresses mature inward mastery, receptivity and steady holding power.'},
    14:{'zh-CN':'国王把力量放在外在掌控、决策与承担后果，重点是能不能稳定兑现。','zh-TW':'國王把力量放在外在掌控、決策與承擔後果，重點是能不能穩定兌現。',en:'The King expresses outward mastery, decision-making and responsibility for sustained results.'}
  });

  const positionRoleLens = Object.freeze({
    guidance:{'zh-CN':'落在「核心指引」，它不是在预测一个固定结果，而是在指出你现在最需要看清的主轴。','zh-TW':'落在「核心指引」，它不是在預測一個固定結果，而是在指出你現在最需要看清的主軸。',en:'In Core Guidance, this is less a fixed prediction and more the central pattern to understand now.'},
    current:{'zh-CN':'落在「目前状态」，先把它当成现在已经存在的事实、心理状态或互动模式。','zh-TW':'落在「目前狀態」，先把它當成現在已經存在的事實、心理狀態或互動模式。',en:'In Current State, read this as what is already active in the facts, mindset or interaction pattern.'},
    trend:{'zh-CN':'落在「发展趋势」，它说明照目前节奏继续下去，下一阶段最容易往哪里移动。','zh-TW':'落在「發展趨勢」，它說明照目前節奏繼續下去，下一階段最容易往哪裡移動。',en:'In Development, this shows where the present pattern is most likely to move next.'},
    advice:{'zh-CN':'落在「行动建议」，重点不是吉凶，而是你能主动调整的做法。','zh-TW':'落在「行動建議」，重點不是吉凶，而是你能主動調整的做法。',en:'In Advice, the point is not fortune but what you can actively change.'},
    early:{'zh-CN':'落在「月初」，它像这个月的起手式，说明最先出现的气氛或课题。','zh-TW':'落在「月初」，它像這個月的起手式，說明最先出現的氣氛或課題。',en:'In Early Month, this is the opening tone or first issue likely to become active.'},
    mid1:{'zh-CN':'落在「月中前」，它显示事情进入推进期后，第一个需要处理的变化。','zh-TW':'落在「月中前」，它顯示事情進入推進期後，第一個需要處理的變化。',en:'In Mid-Month I, this is the first adjustment as the month gains momentum.'},
    mid2:{'zh-CN':'落在「月中后」，它接着前一阶段，说明局势会怎样被重新修正或放大。','zh-TW':'落在「月中後」，它接著前一階段，說明局勢會怎樣被重新修正或放大。',en:'In Mid-Month II, this shows how the earlier pattern is corrected, intensified or redirected.'},
    late:{'zh-CN':'落在「月底」，它比较接近本轮发展会停在哪里，以及什么结果开始成形。','zh-TW':'落在「月底」，它比較接近本輪發展會停在哪裡，以及什麼結果開始成形。',en:'In Month End, this is closest to where the current cycle lands and what result begins to take shape.'},
    self:{'zh-CN':'落在「自身状态」，它先说的是你带进这段关系／事件里的需要、期待与反应方式。','zh-TW':'落在「自身狀態」，它先說的是你帶進這段關係／事件裡的需要、期待與反應方式。',en:'In My State, this describes the needs, expectations and response pattern you bring into the situation.'},
    other:{'zh-CN':'落在「对方／环境」，它描述另一边目前呈现出来的状态；这不是读心证据，而是牌阵里对外部一侧的象征。','zh-TW':'落在「對方／環境」，它描述另一邊目前呈現出來的狀態；這不是讀心證據，而是牌陣裡對外部一側的象徵。',en:'In Other / Environment, this symbolizes the other side as it is presenting now; it is not literal mind-reading evidence.'},
    core:{'zh-CN':'落在「互动核心」，这张牌最重要，因为它说的是双方碰在一起后实际形成的模式。','zh-TW':'落在「互動核心」，這張牌最重要，因為它說的是雙方碰在一起後實際形成的模式。',en:'In Core Interaction, this is especially important because it describes the pattern created when both sides meet.'},
    obstacle:{'zh-CN':'落在「主要阻碍」，不要只把它当坏牌；它是在指出哪一种模式最容易让事情卡住。','zh-TW':'落在「主要阻礙」，不要只把它當壞牌；它是在指出哪一種模式最容易讓事情卡住。',en:'In Main Obstacle, do not reduce it to a “bad card”; it identifies the pattern most likely to block progress.'},
    direction:{'zh-CN':'落在「发展建议」，它是牌阵给出的修正方向：如果想让局势不同，需要练习这张牌更成熟的表达。','zh-TW':'落在「發展建議」，它是牌陣給出的修正方向：如果想讓局勢不同，需要練習這張牌更成熟的表達。',en:'In Direction, this is the correction: if you want the pattern to change, practice the mature expression of this card.'},
    optionA:{'zh-CN':'它落在选项 A 本身，描述选择这条路时你会先面对的条件与体验。','zh-TW':'它落在選項 A 本身，描述選擇這條路時你會先面對的條件與體驗。',en:'On Path A, this describes the conditions and experience you meet first if you choose this route.'},
    optionAOutcome:{'zh-CN':'它落在 A 的发展位，更接近这条路照当前条件走下去会形成的结果。','zh-TW':'它落在 A 的發展位，更接近這條路照目前條件走下去會形成的結果。',en:'In A Outcome, this is closer to what the path develops into under current conditions.'},
    optionB:{'zh-CN':'它落在选项 B 本身，描述选择这条路时你会先面对的条件与体验。','zh-TW':'它落在選項 B 本身，描述選擇這條路時你會先面對的條件與體驗。',en:'On Path B, this describes the conditions and experience you meet first if you choose this route.'},
    optionBOutcome:{'zh-CN':'它落在 B 的发展位，更接近这条路照当前条件走下去会形成的结果。','zh-TW':'它落在 B 的發展位，更接近這條路照目前條件走下去會形成的結果。',en:'In B Outcome, this is closer to what the path develops into under current conditions.'}
  });

  function stableHash(value) {
    const text = String(value || '');
    let h = 2166136261;
    for (let i = 0; i < text.length; i += 1) {
      h ^= text.charCodeAt(i);
      h = Math.imul(h, 16777619);
    }
    return h >>> 0;
  }

  function stablePick(seed, values) {
    if (!values?.length) return '';
    return values[stableHash(seed) % values.length];
  }

  function pickLocalized(seed, cn, tw, en) {
    const lang = currentLanguage();
    return stablePick(seed, lang === 'en' ? en : (lang === 'zh-TW' ? tw : cn));
  }

  function detectQuestionScenario(question, topic) {
    const q = String(question || '').toLowerCase();
    const has = pattern => pattern.test(q);
    if (topic === 'love') {
      if (has(/第三者|第三人|别人|別人|其他人|小三|新欢|新歡|劈腿|出轨|出軌|someone else|third party|cheat/)) return 'third_party';
      if (has(/确定关系|確定關係|在一起|交往|承诺|承諾|结婚|結婚|婚姻|名分|commit|relationship|marry/)) return 'commitment';
      if (has(/冷淡|断联|斷聯|已读|已讀|不回|聊天|消息|訊息|联系|聯絡|沟通|溝通|contact|message|reply|communicat/)) return 'communication';
    }
    if (topic === 'career') {
      if (has(/离职|離職|辞职|辭職|换工作|換工作|跳槽|新工作|转职|轉職|quit|change job|new job/)) return 'job_change';
      if (has(/面试|面試|录取|錄取|offer|应聘|應聘|interview|hire/)) return 'interview';
      if (has(/升职|升職|晋升|晉升|加薪|promotion|raise/)) return 'promotion';
    }
    if (topic === 'money') {
      if (has(/投资|投資|股票|基金|加密|虛擬幣|虚拟币|币|幣|理财|理財|investment|stock|fund|crypto/)) return 'investment';
      if (has(/负债|負債|债务|債務|借款|贷款|貸款|debt|loan/)) return 'debt';
    }
    if (topic === 'study') {
      if (has(/考试|考試|成绩|成績|及格|上榜|分数|分數|exam|test|score|pass/)) return 'exam';
      if (has(/申请|申請|学校|學校|升学|升學|志愿|志願|录取|錄取|application|admission|school/)) return 'application';
    }
    return 'general';
  }

  function cardIdentityLens(item) {
    if (!item?.card) return '';
    if (item.card.arcana === 'major') {
      return localized(majorArchetypeLens[item.card.key]) || topicLens(item.card,item.reversed);
    }
    const suit = localized(suitCoreLens[item.card.suit]);
    const rank = localized(rankStageLens[item.card.rank]);
    return [suit,rank].filter(Boolean).join(' ');
  }

  function positionContextLens(item) {
    const direct = positionRoleLens[item?.position?.key];
    if (!direct) return tarotText(
      `它落在「${positionName(item.position)}」，所以要先按这个牌位的任务来读，而不是只看牌名。`,
      `它落在「${positionName(item.position)}」，所以要先按這個牌位的任務來讀，而不是只看牌名。`,
      `Because it falls in ${positionName(item.position)}, read it through that position's job rather than by card name alone.`
    );
    return localized(direct);
  }

  function intentCardFocus(item, profile, index = 0) {
    const kw = keyThemes([item],2);
    const joined = kw.join(currentLanguage() === 'en' ? ' and ' : '、') || cardName(item.card);
    const seed = `${state.currentDrawId}|${item.card.key}|${item.position?.key}|${profile.intent}|${profile.scenario}|${index}`;
    const intent = profile.intent;

    if (intent === 'feelings') return pickLocalized(seed,
      [
        `如果你问的是对方的感受，这张牌把观察点放在「${joined}」：它能说明情绪倾向，但还不能单独等同于承诺。`,
        `放到“对方怎么想／有没有感觉”这个问题里，「${joined}」比单纯的喜欢或不喜欢更关键；还要看这种感受有没有转成稳定回应。`
      ],
      [
        `如果你問的是對方的感受，這張牌把觀察點放在「${joined}」：它能說明情緒傾向，但還不能單獨等同於承諾。`,
        `放到「對方怎麼想／有沒有感覺」這個問題裡，「${joined}」比單純的喜歡或不喜歡更關鍵；還要看這種感受有沒有轉成穩定回應。`
      ],
      [
        `For feelings, the key signal is ${joined}. It can describe an emotional tendency, but it is not the same as commitment.`,
        `In a “how do they feel?” question, ${joined} matters more than a simple like/dislike label; look for whether it becomes consistent response.`
      ]);

    if (intent === 'action') return pickLocalized(seed,
      [`如果你问“会不会主动／联系”，这张牌要看的不是脑中有没有想法，而是「${joined}」能不能真正转成行动。`,`在行动题里，「${joined}」要用后续行为验证：一次冲动或一条消息，都不能自动算成持续主动。`],
      [`如果你問「會不會主動／聯絡」，這張牌要看的不是腦中有沒有想法，而是「${joined}」能不能真正轉成行動。`,`在行動題裡，「${joined}」要用後續行為驗證：一次衝動或一則訊息，都不能自動算成持續主動。`],
      [`For action/contact questions, the issue is whether ${joined} becomes behavior rather than staying as thought or impulse.`,`In an action question, verify ${joined} through follow-through; one message or one burst of energy is not sustained initiative.`]);

    if (intent === 'reason') return pickLocalized(seed,
      [`作为“为什么”的线索，这张牌把其中一层原因指向「${joined}」；它更像原因结构的一部分，不适合被当成唯一真相。`,`原因题里，这张牌比较像在解释「${joined}」怎样参与了现在的局面，还要和阻碍位、核心位一起对照。`],
      [`作為「為什麼」的線索，這張牌把其中一層原因指向「${joined}」；它更像原因結構的一部分，不適合被當成唯一真相。`,`原因題裡，這張牌比較像在解釋「${joined}」怎樣參與了現在的局面，還要和阻礙位、核心位一起對照。`],
      [`As a “why” clue, this points to ${joined} as one layer of the cause, not the only truth.`,`For cause questions, this shows how ${joined} contributes to the situation and should be compared with the obstacle/core positions.`]);

    if (intent === 'reconcile') return pickLocalized(seed,
      [`放到复合问题里，「${joined}」要读成旧关系里还在运作的模式；重点是它有没有机会被用不同方式处理。`,`复合题不能只看还有没有感情。这张牌更具体地问：围绕「${joined}」的旧问题，双方有没有新的处理能力。`],
      [`放到復合問題裡，「${joined}」要讀成舊關係裡還在運作的模式；重點是它有沒有機會被用不同方式處理。`,`復合題不能只看還有沒有感情。這張牌更具體地問：圍繞「${joined}」的舊問題，雙方有沒有新的處理能力。`],
      [`In reconciliation, ${joined} describes a pattern still active from the old relationship; the issue is whether it can now be handled differently.`,`Reconciliation is not only about remaining feelings. This card asks whether the old pattern around ${joined} can be managed in a new way.`]);

    if (intent === 'timing') return pickLocalized(seed,
      [`时间题里，这张牌更适合当作“条件指标”：当「${joined}」开始真实出现或松动时，事情才比较接近下一阶段。`,`这里不要把牌硬换算成日期；「${joined}」描述的是时机成熟前必须出现的状态。`],
      [`時間題裡，這張牌更適合當作「條件指標」：當「${joined}」開始真實出現或鬆動時，事情才比較接近下一階段。`,`這裡不要把牌硬換算成日期；「${joined}」描述的是時機成熟前必須出現的狀態。`],
      [`For timing, use this as a readiness marker: when ${joined} actually appears or clears, the situation is closer to moving.`,`Do not force this into a date; ${joined} describes a condition that needs to mature first.`]);

    if (intent === 'decision' || intent === 'binary') return pickLocalized(seed,
      [`在决定题里，这张牌不是替你盖“可以／不可以”的章，而是把一个关键条件放在「${joined}」上。`,`如果你想要一个是非答案，这张牌更有价值的地方是说明：结果会被「${joined}」这个条件怎样影响。`],
      [`在決定題裡，這張牌不是替你蓋「可以／不可以」的章，而是把一個關鍵條件放在「${joined}」上。`,`如果你想要一個是非答案，這張牌更有價值的地方是說明：結果會被「${joined}」這個條件怎樣影響。`],
      [`In a decision question, this does not stamp “yes/no”; it identifies ${joined} as a condition that matters.`,`For a binary question, the useful part is how ${joined} changes the conditions of the outcome.`]);

    if (intent === 'development') return pickLocalized(seed,
      [`放在后续发展里，「${joined}」描述的是事情会用什么方式进入下一阶段，不代表结果已经固定。`,`发展题要把这张牌当成“过程中的一段”：围绕「${joined}」的处理方式，会明显改变后面的走向。`],
      [`放在後續發展裡，「${joined}」描述的是事情會用什麼方式進入下一階段，不代表結果已經固定。`,`發展題要把這張牌當成「過程中的一段」：圍繞「${joined}」的處理方式，會明顯改變後面的走向。`],
      [`For development, ${joined} describes how the situation moves into its next phase, not a fixed destiny.`,`Treat this as one stage in the process: how ${joined} is handled will materially shape what follows.`]);

    if (intent === 'advice') return pickLocalized(seed,
      [`你问的是“该怎么做”，所以这张牌最实用的部分就是把「${joined}」转成一个可以执行的动作。`,`建议题里不要停在理解牌意；围绕「${joined}」，你需要做出一个现实里看得见的调整。`],
      [`你問的是「該怎麼做」，所以這張牌最實用的部分就是把「${joined}」轉成一個可以執行的動作。`,`建議題裡不要停在理解牌意；圍繞「${joined}」，你需要做出一個現實裡看得見的調整。`],
      [`Because you asked what to do, turn ${joined} into a concrete action rather than leaving it as an abstract meaning.`,`For advice, do not stop at interpretation; make one visible real-world adjustment around ${joined}.`]);

    return pickLocalized(seed,
      [`放回你现在的问题，这张牌真正值得抓住的是「${joined}」，而不是只记住“好牌／坏牌”的标签。`,`结合这个牌位来看，「${joined}」是这张牌和你当前问题之间最直接的连接点。`],
      [`放回你現在的問題，這張牌真正值得抓住的是「${joined}」，而不是只記住「好牌／壞牌」的標籤。`,`結合這個牌位來看，「${joined}」是這張牌和你目前問題之間最直接的連接點。`],
      [`In your question, the useful signal is ${joined}, not a simple “good/bad card” label.`,`Through this position, ${joined} is the clearest bridge between the card and your current issue.`]);
  }

  function contextualCardReading(item, index, profile = analyseQuestion()) {
    const identity = cardIdentityLens(item);
    const position = positionContextLens(item);
    const orientation = item.reversed
      ? tarotText(
          `逆位让这股能量更像受阻、内化、延迟或用力过头；要看「${keyThemes([item],2).join('、') || cardName(item.card)}」具体是卡在哪里。`,
          `逆位讓這股能量更像受阻、內化、延遲或用力過頭；要看「${keyThemes([item],2).join('、') || cardName(item.card)}」具體是卡在哪裡。`,
          `Reversed, the energy may be blocked, internalized, delayed or overdone; ask where ${keyThemes([item],2).join(' and ') || cardName(item.card)} is getting stuck.`)
      : tarotText(
          '正位时，这股能量比较直接地表达出来，但仍要看它落在哪个牌位、是否被旁边的牌支持。',
          '正位時，這股能量比較直接地表達出來，但仍要看它落在哪個牌位、是否被旁邊的牌支持。',
          'Upright, the energy is expressed more directly, but its position and neighbouring cards still determine how it functions.'
        );
    return [position,identity,orientation,intentCardFocus(item,profile,index)].filter(Boolean).join(' ');
  }

  function elementRelationKey(a,b) {
    if (!a?.card || !b?.card || a.card.arcana === 'major' || b.card.arcana === 'major') return 'none';
    const x = suitMeta[a.card.suit]?.element;
    const y = suitMeta[b.card.suit]?.element;
    if (!x || !y) return 'none';
    if (x === y) return 'same';
    const pair = [x,y].sort().join('-');
    if (pair === 'air-fire' || pair === 'earth-water') return 'support';
    if (pair === 'fire-water' || pair === 'air-earth') return 'friction';
    return 'mixed';
  }

  function connectionPriority(a,b) {
    let value = Math.abs(cardTone(a)-cardTone(b));
    if (a.card.arcana === 'major' && b.card.arcana === 'major') value += 1.2;
    if (a.card.suit && a.card.suit === b.card.suit) value += .55;
    if (a.reversed !== b.reversed) value += .25;
    if (elementRelationKey(a,b) === 'friction') value += .55;
    return value;
  }

  function pairConnectionSentence(a,b,seed='') {
    if (!a || !b) return '';
    const aName = `${cardName(a.card)}・${orientationText(a.reversed)}`;
    const bName = `${cardName(b.card)}・${orientationText(b.reversed)}`;
    const aTheme = keyThemes([a],1)[0] || cardName(a.card);
    const bTheme = keyThemes([b],1)[0] || cardName(b.card);
    const relation = elementRelationKey(a,b);
    const toneA = cardTone(a), toneB = cardTone(b);
    const choose = (tag,cn,tw,en) => pickLocalized(`${seed}|${tag}`,cn,tw,en);

    if (a.card.arcana === 'major' && b.card.arcana === 'major') return choose('major',
      [
        `「${aName}」接着「${bName}」连续出现两张大牌，这通常不是小情绪的起伏，而是从「${aTheme}」走向「${bTheme}」的一次阶段变化。`,
        `这里两张大牌连在一起很有分量：「${aName}」先把「${aTheme}」推到台前，「${bName}」则把课题带向「${bTheme}」。`
      ],
      [
        `「${aName}」接著「${bName}」連續出現兩張大牌，這通常不是小情緒的起伏，而是從「${aTheme}」走向「${bTheme}」的一次階段變化。`,
        `這裡兩張大牌連在一起很有份量：「${aName}」先把「${aTheme}」推到台前，「${bName}」則把課題帶向「${bTheme}」。`
      ],
      [
        `${aName} followed by ${bName} gives two Major Arcana in sequence. This is more than a mood swing: the issue moves from ${aTheme} toward ${bTheme}.`,
        `Two Major Arcana meet here. ${aName} brings ${aTheme} to the foreground, while ${bName} carries the lesson toward ${bTheme}.`
      ]);

    if (relation === 'same') return choose('same',
      [
        `「${aName}」到「${bName}」属于同一元素，前一张的「${aTheme}」会继续延伸到后一张的「${bTheme}」；这条线更适合连着读。`,
        `这两张牌使用同一种元素语言。「${aName}」先指出「${aTheme}」，到了「${bName}」时，这股力量没有消失，而是进一步变成「${bTheme}」。`
      ],
      [
        `「${aName}」到「${bName}」屬於同一元素，前一張的「${aTheme}」會繼續延伸到後一張的「${bTheme}」；這條線更適合連著讀。`,
        `這兩張牌使用同一種元素語言。「${aName}」先指出「${aTheme}」，到了「${bName}」時，這股力量沒有消失，而是進一步變成「${bTheme}」。`
      ],
      [
        `${aName} and ${bName} share an element, so ${aTheme} continues into ${bTheme}; they read more clearly as one developing line.`,
        `These two cards speak the same elemental language: ${aName} introduces ${aTheme}, and ${bName} develops it into ${bTheme}.`
      ]);

    if (relation === 'support') return choose('support',
      [
        `「${aName}」与「${bName}」的元素彼此有支撑；如果前一张的「${aTheme}」处理得当，会替后一张的「${bTheme}」创造空间。`,
        `这两张牌不是互相抵消，而是能接力：先把「${aTheme}」稳住，后面的「${bTheme}」会更容易发挥。`
      ],
      [
        `「${aName}」與「${bName}」的元素彼此有支撐；如果前一張的「${aTheme}」處理得當，會替後一張的「${bTheme}」創造空間。`,
        `這兩張牌不是互相抵消，而是能接力：先把「${aTheme}」穩住，後面的「${bTheme}」會更容易發揮。`
      ],
      [
        `${aName} and ${bName} have supportive elements. If ${aTheme} is handled well, it creates more room for ${bTheme}.`,
        `These cards can work as a relay rather than cancel each other: stabilize ${aTheme}, and ${bTheme} has more room to develop.`
      ]);

    if (relation === 'friction') return choose('friction',
      [
        `「${aName}」与「${bName}」的元素有拉扯：一边强调「${aTheme}」，另一边要求「${bTheme}」。真正的卡点往往就是这两种需求暂时难以兼顾。`,
        `这里不是单纯的好或坏，而是两股需求在抢方向。「${aName}」要处理「${aTheme}」，「${bName}」又把你拉向「${bTheme}」，所以会有明显的内外冲突。`
      ],
      [
        `「${aName}」與「${bName}」的元素有拉扯：一邊強調「${aTheme}」，另一邊要求「${bTheme}」。真正的卡點往往就是這兩種需求暫時難以兼顧。`,
        `這裡不是單純的好或壞，而是兩股需求在搶方向。「${aName}」要處理「${aTheme}」，「${bName}」又把你拉向「${bTheme}」，所以會有明顯的內外衝突。`
      ],
      [
        `${aName} and ${bName} create elemental friction: one side emphasizes ${aTheme}, while the other asks for ${bTheme}. The real tension is trying to meet both at once.`,
        `This is not simply good versus bad; two needs pull in different directions. ${aName} asks for ${aTheme}, while ${bName} pulls toward ${bTheme}.`
      ]);

    if (toneA < -.15 && toneB > .15) return choose('lift',
      [
        `从「${aName}」走到「${bName}」，牌势由阻力转向较有空间；但它不是自动变好，而是前一张的问题被处理后，后一张才有机会真正展开。`,
        `这组衔接有一种“先难后松”的感觉。「${aName}」先暴露卡点，「${bName}」才给出突破口，关键在于中间那一步有没有真的做到。`
      ],
      [
        `從「${aName}」走到「${bName}」，牌勢由阻力轉向較有空間；但它不是自動變好，而是前一張的問題被處理後，後一張才有機會真正展開。`,
        `這組銜接有一種「先難後鬆」的感覺。「${aName}」先暴露卡點，「${bName}」才給出突破口，關鍵在於中間那一步有沒有真的做到。`
      ],
      [
        `The move from ${aName} to ${bName} shifts from friction toward more room, but only if the first card's issue is actually addressed.`,
        `This sequence reads as pressure first, opening second: ${aName} exposes the block, and ${bName} shows the opening if the middle step is truly taken.`
      ]);

    if (toneA > .15 && toneB < -.15) return choose('turn',
      [
        `「${aName}」之后接「${bName}」，表示前面的顺势并不能直接保证结果；从「${aTheme}」到「${bTheme}」之间有一个需要修正的转折。`,
        `前一张看起来有推进感，但「${bName}」提醒你别太早下结论。这里从「${aTheme}」转向「${bTheme}」，中途有一个现实考验。`
      ],
      [
        `「${aName}」之後接「${bName}」，表示前面的順勢並不能直接保證結果；從「${aTheme}」到「${bTheme}」之間有一個需要修正的轉折。`,
        `前一張看起來有推進感，但「${bName}」提醒你別太早下結論。這裡從「${aTheme}」轉向「${bTheme}」，中途有一個現實考驗。`
      ],
      [
        `${aName} followed by ${bName} means early momentum does not secure the result; there is a corrective turn between ${aTheme} and ${bTheme}.`,
        `The first card has momentum, but ${bName} warns against concluding too soon. Moving from ${aTheme} to ${bTheme} brings a real test in between.`
      ]);

    if (a.reversed !== b.reversed) return choose('orientation',
      [
        `「${aName}」与「${bName}」一正一逆，说明两个环节的速度并不一致：一边已经能表达出来，另一边仍可能卡住、犹豫或往内收。`,
        `一正一逆放在一起时，我会把它读成“不同步”。「${aName}」和「${bName}」不是没有关系，而是一个环节走在前面，另一个还没跟上。`
      ],
      [
        `「${aName}」與「${bName}」一正一逆，說明兩個環節的速度並不一致：一邊已經能表達出來，另一邊仍可能卡住、猶豫或往內收。`,
        `一正一逆放在一起時，我會把它讀成「不同步」。「${aName}」和「${bName}」不是沒有關係，而是一個環節走在前面，另一個還沒跟上。`
      ],
      [
        `${aName} and ${bName} have different orientations, so the two stages are not moving at the same speed: one is more expressed while the other is still blocked, hesitant or internal.`,
        `With one upright and one reversed, I would read this as a timing mismatch: ${aName} and ${bName} are connected, but one part is ahead of the other.`
      ]);

    return choose('transition',
      [`「${aName}」接到「${bName}」，可以把它读成从「${aTheme}」过渡到「${bTheme}」；后一张是在回应前一张留下的问题。`,`把「${aName}」和「${bName}」连起来看，前者先提出「${aTheme}」，后者则告诉你这股能量接下来会怎样变成「${bTheme}」。`],
      [`「${aName}」接到「${bName}」，可以把它讀成從「${aTheme}」過渡到「${bTheme}」；後一張是在回應前一張留下的問題。`,`把「${aName}」和「${bName}」連起來看，前者先提出「${aTheme}」，後者則告訴你這股能量接下來會怎樣變成「${bTheme}」。`],
      [`Read ${aName} into ${bName} as a transition from ${aTheme} toward ${bTheme}; the second card answers what the first leaves in motion.`,`Link ${aName} with ${bName}: the first introduces ${aTheme}, and the second shows how that energy develops into ${bTheme}.`]);
  }

  function buildConnectionNarrative(draw, profile = analyseQuestion()) {
    if (!draw || draw.length < 2) return '';
    let pairs = [];
    if (profile.spread === 'relationship5' && draw.length >= 5) {
      pairs = [[draw[0],draw[1]],[draw[2],draw[3]],[draw[3],draw[4]]];
    } else if (profile.spread === 'choice5' && draw.length >= 5) {
      pairs = [[draw[1],draw[2]],[draw[3],draw[4]]];
    } else {
      pairs = draw.slice(0,-1).map((item,index) => [item,draw[index+1]]);
      if (pairs.length > 2) pairs = [...pairs].sort((x,y) => connectionPriority(y[0],y[1])-connectionPriority(x[0],x[1])).slice(0,2);
    }
    const sentences = pairs.map((pair,index) => pairConnectionSentence(pair[0],pair[1],`${state.currentDrawId}|pair|${index}`)).filter(Boolean);
    if (!sentences.length) return '';
    const lead = tarotText('更关键的是牌与牌之间：','更關鍵的是牌與牌之間：','The more important part is how the cards interact:');
    return `${lead}${sentences.join(' ')}`;
  }

  function directEvidence(draw, profile = analyseQuestion()) {
    if (!draw?.length) return '';
    let relevant = mostRelevantItems(draw,profile);
    if (profile.spread === 'relationship5') {
      const byKey = key => draw.find(x => x.position?.key === key);
      if (profile.intent === 'reason') relevant = [byKey('obstacle'),byKey('core')].filter(Boolean);
      else if (['feelings','action','reconcile','development'].includes(profile.intent)) relevant = [byKey('other'),byKey('core'),byKey('direction')].filter(Boolean);
    } else if (profile.spread === 'choice5') {
      relevant = [draw[2],draw[4]].filter(Boolean);
    }
    relevant = relevant.slice(0,3);
    if (relevant.length === 1) {
      const item = relevant[0];
      return tarotText(
        `这个判断主要来自「${positionName(item.position)}」的「${cardName(item.card)}・${orientationText(item.reversed)}」，它把重点落在「${keyThemes([item],2).join('、')}」。`,
        `這個判斷主要來自「${positionName(item.position)}」的「${cardName(item.card)}・${orientationText(item.reversed)}」，它把重點落在「${keyThemes([item],2).join('、')}」。`,
        `This judgment is anchored in ${cardName(item.card)} (${orientationText(item.reversed)}) at ${positionName(item.position)}, emphasizing ${keyThemes([item],2).join(' and ')}.`);
    }
    const pieces = relevant.map(item => tarotText(
      `「${positionName(item.position)}」的${cardName(item.card)}指向「${keyThemes([item],1)[0] || item.meaning.keywords[0]}」`,
      `「${positionName(item.position)}」的${cardName(item.card)}指向「${keyThemes([item],1)[0] || item.meaning.keywords[0]}」`,
      `${cardName(item.card)} at ${positionName(item.position)} points to ${keyThemes([item],1)[0] || item.meaning.keywords[0]}`));
    return tarotText(
      `之所以这样判断，是因为${pieces.join('，而')}；这些位置合在一起，比单看某一张牌更接近你的问题。`,
      `之所以這樣判斷，是因為${pieces.join('，而')}；這些位置合在一起，比單看某一張牌更接近你的問題。`,
      `The reason is that ${pieces.join(', while ')}. Together these positions answer the question better than any single card.`);
  }

  function scenarioGrounding(profile) {
    const s = profile?.scenario;
    if (s === 'third_party') return tarotText(
      '如果你问的是“有没有第三者”，塔罗最多只能提示隐藏、分心或第三股压力的象征，不能把它当成现实中确有第三者的证据；最后仍要回到可验证的行为与事实。',
      '如果你問的是「有沒有第三者」，塔羅最多只能提示隱藏、分心或第三股壓力的象徵，不能把它當成現實中確有第三者的證據；最後仍要回到可驗證的行為與事實。',
      'If you are asking about a third party, tarot can only symbolize secrecy, distraction or outside pressure; it is not evidence that another person actually exists. Verify through facts and behavior.'
    );
    if (s === 'commitment') return tarotText(
      '判断“会不会确定关系／承诺”时，除了感受，还要看持续投入、公开程度、时间安排与实际责任有没有同步出现。',
      '判斷「會不會確定關係／承諾」時，除了感受，還要看持續投入、公開程度、時間安排與實際責任有沒有同步出現。',
      'For commitment, look beyond feelings to consistency, visibility, time investment and actual responsibility.'
    );
    if (s === 'job_change') return tarotText(
      '如果问题涉及离职或换工作，牌面可以帮你整理倾向，但实际决定要同时核对薪资、合约、工作内容、现金缓冲和退路。',
      '如果問題涉及離職或換工作，牌面可以幫你整理傾向，但實際決定要同時核對薪資、合約、工作內容、現金緩衝和退路。',
      'For changing jobs, use the reading to organize your preference, then verify salary, contract, role scope, cash buffer and fallback options.'
    );
    if (s === 'interview') return tarotText(
      '面试／录取题更适合把牌当成准备度与过程提示，不把任何一张牌当成录取保证。',
      '面試／錄取題更適合把牌當成準備度與過程提示，不把任何一張牌當成錄取保證。',
      'For interviews/admission, use the cards as preparation and process signals, not a guarantee of acceptance.'
    );
    if (s === 'investment') return tarotText(
      '投资类问题里，塔罗只能帮助你看情绪、风险偏好与决策盲点，不应替代价格、基本面、资产配置与可承受损失的判断。',
      '投資類問題裡，塔羅只能幫助你看情緒、風險偏好與決策盲點，不應取代價格、基本面、資產配置與可承受損失的判斷。',
      'For investing, tarot can highlight emotion, risk tolerance and decision blind spots; it should not replace price, fundamentals, allocation and loss-capacity analysis.'
    );
    if (s === 'debt') return tarotText(
      '债务问题优先看真实现金流、利率、还款顺序与是否需要专业协助；牌面只作为整理压力与行为模式的辅助。',
      '債務問題優先看真實現金流、利率、還款順序與是否需要專業協助；牌面只作為整理壓力與行為模式的輔助。',
      'For debt, prioritize cash flow, rates, repayment order and professional help where needed; use tarot only as a reflection aid.'
    );
    if (s === 'exam') return tarotText(
      '考试题可以读学习状态与策略，但不能把牌面当成成绩保证；真正可控的是复习量、弱项、作息与模拟表现。',
      '考試題可以讀學習狀態與策略，但不能把牌面當成成績保證；真正可控的是複習量、弱項、作息與模擬表現。',
      'For exams, read the cards as study-state and strategy guidance, not a score guarantee; revision volume, weak areas, sleep and practice results remain controllable.'
    );
    return '';
  }

  function intentLabel(intent) {
    const labels = {
      feelings:{'zh-CN':'感受','zh-TW':'感受',en:'Feelings'},
      reason:{'zh-CN':'原因','zh-TW':'原因',en:'Why'},
      action:{'zh-CN':'主动／联系','zh-TW':'主動／聯絡',en:'Action / contact'},
      reconcile:{'zh-CN':'复合','zh-TW':'復合',en:'Reconciliation'},
      timing:{'zh-CN':'时间','zh-TW':'時間',en:'Timing'},
      decision:{'zh-CN':'要不要做','zh-TW':'要不要做',en:'Decision'},
      binary:{'zh-CN':'会不会／能不能','zh-TW':'會不會／能不能',en:'Yes / no'},
      development:{'zh-CN':'后续发展','zh-TW':'後續發展',en:'Development'},
      advice:{'zh-CN':'怎么做','zh-TW':'怎麼做',en:'Advice'},
      choice:{'zh-CN':'二选一','zh-TW':'二選一',en:'Two paths'},
      general:{'zh-CN':'整体','zh-TW':'整體',en:'Overall'}
    };
    return localized(labels[intent] || labels.general);
  }

  function buildMultiIntentAnswer(draw, analysis, profile) {
    const intents = (profile?.intents || []).filter(x => x && x !== 'general');
    if (intents.length <= 1) return buildDirectAnswer(draw,analysis,profile);
    const answers = intents.slice(0,4).map(intent => {
      const text = buildDirectAnswer(draw,analysis,{...profile,intent,intents:[intent]});
      return `${intentLabel(intent)}：${text}`;
    });
    const intro = tarotText(
      '你的问题其实包含不止一个层次，所以这次不把它硬压成一个结论，我会分开回答：',
      '你的問題其實包含不只一個層次，所以這次不把它硬壓成一個結論，我會分開回答：',
      'Your question contains more than one layer, so I will answer the parts separately instead of forcing one verdict:'
    );
    return `${intro}\n${answers.join('\n')}`;
  }

  function buildDirectAnswerV2(draw, analysis, profile = analyseQuestion()) {
    const base = buildMultiIntentAnswer(draw,analysis,profile);
    const evidence = directEvidence(draw,profile);
    const grounding = scenarioGrounding(profile);
    return [base,evidence,grounding].filter(Boolean).join('\n\n');
  }

  function firstMeaningSentence(item) {
    const text = String(item?.meaning?.meaning || '').trim();
    if (!text) return '';
    const match = text.match(/^.*?[。！？.!?](?:\s|$)/);
    return (match?.[0] || text).trim();
  }

  function cardNarrativeBit(item) {
    const themes = keyThemes([item],2).join(currentLanguage() === 'en' ? ' and ' : '、');
    return tarotText(
      `「${cardName(item.card)}・${orientationText(item.reversed)}」把重点放在「${themes || cardName(item.card)}」。${firstMeaningSentence(item)}`,
      `「${cardName(item.card)}・${orientationText(item.reversed)}」把重點放在「${themes || cardName(item.card)}」。${firstMeaningSentence(item)}`,
      `${cardName(item.card)} (${orientationText(item.reversed)}) centers on ${themes || cardName(item.card)}. ${firstMeaningSentence(item)}`
    );
  }

  function buildHumanNarrative(draw, analysis, profile = analyseQuestion()) {
    const spread = selectedSpread()?.key;
    const questionLead = state.question
      ? tarotText(`回到你问的“${state.question}”，`,`回到你問的「${state.question}」，`,`Coming back to “${state.question},” `)
      : '';

    if (spread === 'single') {
      const item = draw[0];
      return tarotText(
        `${questionLead}这次只有一张牌，所以它的份量会更集中。${cardNarrativeBit(item)} 它落在「${positionName(item.position)}」，更像是在提醒你：先把这张牌指向的模式看清楚，再决定下一步，而不是把它当成一个固定预言。`,
        `${questionLead}這次只有一張牌，所以它的份量會更集中。${cardNarrativeBit(item)} 它落在「${positionName(item.position)}」，更像是在提醒你：先把這張牌指向的模式看清楚，再決定下一步，而不是把它當成一個固定預言。`,
        `${questionLead}this is a one-card reading, so the message is concentrated. ${cardNarrativeBit(item)} In ${positionName(item.position)}, it is better used as the pattern to understand before choosing your next step, not as a fixed prediction.`
      );
    }

    if (spread === 'relationship5' && draw.length >= 5) {
      const [self,other,core,obstacle,direction] = draw;
      const counterpart = counterpartLabel();
      return tarotText(
        `${questionLead}先看两边各自带进来的状态。你这边是${cardNarrativeBit(self)} ${counterpart}这一边则是${cardNarrativeBit(other)} 这两张放在一起，已经能看出双方关注点并不完全相同。\n\n真正决定互动质感的是核心位：${cardNarrativeBit(core)} 也就是说，两个人碰在一起之后，关系实际形成的是这张牌描述的模式，而不只是任何一方单独的心情。\n\n接着看为什么会卡住：${cardNarrativeBit(obstacle)} 这张牌在阻碍位，代表最容易反复发生、把关系拖回原状的地方。最后的方向位是${cardNarrativeBit(direction)} 所以如果你问后续能不能改变，重点不是等结果自动发生，而是有没有人开始用方向牌的方式处理阻碍牌的问题。`,
        `${questionLead}先看兩邊各自帶進來的狀態。你這邊是${cardNarrativeBit(self)} ${counterpart}這一邊則是${cardNarrativeBit(other)} 這兩張放在一起，已經能看出雙方關注點並不完全相同。\n\n真正決定互動質感的是核心位：${cardNarrativeBit(core)} 也就是說，兩個人碰在一起之後，關係實際形成的是這張牌描述的模式，而不只是任何一方單獨的心情。\n\n接著看為什麼會卡住：${cardNarrativeBit(obstacle)} 這張牌在阻礙位，代表最容易反覆發生、把關係拖回原狀的地方。最後的方向位是${cardNarrativeBit(direction)} 所以如果你問後續能不能改變，重點不是等結果自動發生，而是有沒有人開始用方向牌的方式處理阻礙牌的問題。`,
        `${questionLead}start with what each side brings in. Your side is ${cardNarrativeBit(self)} ${counterpart} is ${cardNarrativeBit(other)} Together, these already show that the two sides are not focused on exactly the same thing.\n\nThe core interaction is more decisive: ${cardNarrativeBit(core)} This describes what the relationship actually becomes when both sides meet, not just either person's private feeling.\n\nThe main obstacle is ${cardNarrativeBit(obstacle)} In the obstacle position, this is the pattern most likely to repeat and pull the connection back into the same place. The direction is ${cardNarrativeBit(direction)} So change depends less on waiting for an outcome and more on whether someone begins handling the obstacle through the direction card.`
      );
    }

    if (spread === 'weekly3' && draw.length >= 3) {
      const [current,trend,advice] = draw;
      return tarotText(
        `${questionLead}目前状态由${cardNarrativeBit(current)} 这说明事情现在是从这里出发。接下来趋势转到${cardNarrativeBit(trend)} 所以重点要看前一张的状态，是被延续、放大，还是开始被修正。最后建议位是${cardNarrativeBit(advice)} 这张牌不是额外补充，而是告诉你：如果想让趋势往更可控的方向走，你最能主动介入的是这里。`,
        `${questionLead}目前狀態由${cardNarrativeBit(current)} 這說明事情現在是從這裡出發。接下來趨勢轉到${cardNarrativeBit(trend)} 所以重點要看前一張的狀態，是被延續、放大，還是開始被修正。最後建議位是${cardNarrativeBit(advice)} 這張牌不是額外補充，而是告訴你：如果想讓趨勢往更可控的方向走，你最能主動介入的是這裡。`,
        `${questionLead}the current state is ${cardNarrativeBit(current)} This is the starting point. The trend moves into ${cardNarrativeBit(trend)} so the question is whether the first pattern is continued, amplified or corrected. The advice card is ${cardNarrativeBit(advice)} This is not an extra note; it is the part you can actively influence if you want the trend to move differently.`
      );
    }

    if (spread === 'monthly5' && draw.length >= 5) {
      const [early,mid1,mid2,late,advice] = draw;
      return tarotText(
        `${questionLead}这个月不是一张牌定调，而是明显有阶段变化。月初先从${cardNarrativeBit(early)} 开始；到月中前，局势进入${cardNarrativeBit(mid1)}；月中后再转成${cardNarrativeBit(mid2)}；月底落在${cardNarrativeBit(late)}。把四个时间点连起来，会比单看哪张牌“最好”更重要，因为它显示的是问题怎样一步一步变形。\n\n整体建议则由${cardNarrativeBit(advice)} 收尾。它是在提醒你：无论前面哪一段顺或不顺，真正能影响整月体验的是你最后采用什么处理方式。`,
        `${questionLead}這個月不是一張牌定調，而是明顯有階段變化。月初先從${cardNarrativeBit(early)} 開始；到月中前，局勢進入${cardNarrativeBit(mid1)}；月中後再轉成${cardNarrativeBit(mid2)}；月底落在${cardNarrativeBit(late)}。把四個時間點連起來，會比單看哪張牌「最好」更重要，因為它顯示的是問題怎樣一步一步變形。\n\n整體建議則由${cardNarrativeBit(advice)} 收尾。它是在提醒你：無論前面哪一段順或不順，真正能影響整月體驗的是你最後採用什麼處理方式。`,
        `${questionLead}the month has clear stages rather than one fixed tone. Early month begins with ${cardNarrativeBit(early)} Mid-month I moves into ${cardNarrativeBit(mid1)} Mid-month II becomes ${cardNarrativeBit(mid2)} and month-end lands on ${cardNarrativeBit(late)} Reading these four points as a sequence matters more than picking the “best” card, because it shows how the issue changes shape.\n\nThe overall advice is ${cardNarrativeBit(advice)} Whatever happens earlier, this is the handling style most likely to influence how the month feels in practice.`
      );
    }

    if (spread === 'choice5' && draw.length >= 5) {
      const [current,a,aOut,b,bOut] = draw;
      const A = state.optionA || ui('optionA');
      const B = state.optionB || ui('optionB');
      return tarotText(
        `${questionLead}先看你是在什么状态下做这个选择：${cardNarrativeBit(current)} 这张牌会影响你怎么看两条路，所以要先确认自己是不是因为焦虑、期待或压力而把某一边放大。\n\n选择「${A}」时，起点是${cardNarrativeBit(a)}，继续走下去则来到${cardNarrativeBit(aOut)}。选择「${B}」时，起点是${cardNarrativeBit(b)}，发展则来到${cardNarrativeBit(bOut)}。真正要比较的不是哪边完全没阻力，而是哪一种过程与结果更符合你的优先顺序，也更能承受它的代价。`,
        `${questionLead}先看你是在什麼狀態下做這個選擇：${cardNarrativeBit(current)} 這張牌會影響你怎麼看兩條路，所以要先確認自己是不是因為焦慮、期待或壓力而把某一邊放大。\n\n選擇「${A}」時，起點是${cardNarrativeBit(a)}，繼續走下去則來到${cardNarrativeBit(aOut)}。選擇「${B}」時，起點是${cardNarrativeBit(b)}，發展則來到${cardNarrativeBit(bOut)}。真正要比較的不是哪邊完全沒阻力，而是哪一種過程與結果更符合你的優先順序，也更能承受它的代價。`,
        `${questionLead}first notice the state from which you are choosing: ${cardNarrativeBit(current)} This can bias how each option looks, so check whether anxiety, hope or pressure is magnifying one side.\n\nPath ${A} begins with ${cardNarrativeBit(a)} and develops into ${cardNarrativeBit(aOut)} Path ${B} begins with ${cardNarrativeBit(b)} and develops into ${cardNarrativeBit(bOut)} The useful comparison is not which path has zero friction, but which process and outcome better fit your priorities and costs you can carry.`
      );
    }

    return buildStoryBase(draw,analysis,profile);
  }

  function buildStoryV2(draw, analysis, profile = analyseQuestion()) {
    const base = buildHumanNarrative(draw,analysis,profile);
    const connected = buildConnectionNarrative(draw,profile);
    return [base,connected].filter(Boolean).join('\n\n');
  }

  function scenarioNextStep(profile, draw) {
    const s = profile?.scenario;
    const intent = profile?.intent;
    if (s === 'communication') return tarotText(
      '接下来别只数消息次数，观察三件事：谁主动开启话题、回应是否有内容、互动能不能自然延续到下一次。',
      '接下來別只數訊息次數，觀察三件事：誰主動開啟話題、回應是否有內容、互動能不能自然延續到下一次。',
      'Do not only count messages. Watch who initiates, whether replies have substance, and whether the interaction naturally continues.'
    );
    if (s === 'commitment') return tarotText(
      '把“有没有感觉”暂时放一边，接下来只看承诺型行为：是否稳定出现、愿不愿安排时间、能不能讨论现实计划与边界。',
      '把「有沒有感覺」暫時放一邊，接下來只看承諾型行為：是否穩定出現、願不願安排時間、能不能討論現實計畫與界線。',
      'Temporarily set feelings aside and watch commitment behavior: consistency, time allocation, real plans and boundaries.'
    );
    if (s === 'job_change') return tarotText(
      '把牌面提示转换成一张现实比较表：新旧工作的收入、成长空间、工时、稳定度与最坏情况各写一栏，再决定是否行动。',
      '把牌面提示轉換成一張現實比較表：新舊工作的收入、成長空間、工時、穩定度與最壞情況各寫一欄，再決定是否行動。',
      'Turn the reading into a comparison table: income, growth, hours, stability and worst case for each option, then decide.'
    );
    if (s === 'investment') return tarotText(
      '如果仍想行动，先把最大可承受损失、退出条件与仓位写下来；这些数字比“感觉会涨”更重要。',
      '如果仍想行動，先把最大可承受損失、退出條件與部位寫下來；這些數字比「感覺會漲」更重要。',
      'If you still plan to act, write down maximum acceptable loss, exit conditions and position size first; those numbers matter more than a feeling that price will rise.'
    );
    if (s === 'exam') return tarotText(
      '把建议落到下一周：列出最弱的两项、每天可完成的练习量，以及一次模拟检验；用结果再调整，而不是继续猜。',
      '把建議落到下一週：列出最弱的兩項、每天可完成的練習量，以及一次模擬檢驗；用結果再調整，而不是繼續猜。',
      'Turn the advice into next week: identify two weak areas, set a daily practice target, and run one mock test; adjust from evidence.'
    );
    if (intent === 'feelings') return tarotText(
      '接下来最有价值的验证不是继续猜心，而是比较“牌里的感受讯号”和现实里的持续行为有没有一致。',
      '接下來最有價值的驗證不是繼續猜心，而是比較「牌裡的感受訊號」和現實裡的持續行為有沒有一致。',
      'The best verification is not more mind-reading; compare the emotional signal in the cards with consistent real behavior.'
    );
    if (intent === 'action') return tarotText(
      '给“主动”一个清楚定义：例如主动开启联系、提出具体安排并持续跟进；没有达到这个标准，就先不要替对方补完行动。',
      '給「主動」一個清楚定義：例如主動開啟聯絡、提出具體安排並持續跟進；沒有達到這個標準，就先不要替對方補完行動。',
      'Define initiative clearly: starting contact, proposing something concrete and following through. If that is absent, do not fill in the action for them.'
    );
    if (intent === 'reconcile') return tarotText(
      '如果真的要重新靠近，先确认旧问题有没有新的解决方式；只有重新联系、但没有新处理方法，很容易回到同一个循环。',
      '如果真的要重新靠近，先確認舊問題有沒有新的解決方式；只有重新聯絡、但沒有新處理方法，很容易回到同一個循環。',
      'Before reconnecting, identify a genuinely new way to handle the old problem; contact without a new method often recreates the same cycle.'
    );
    if (intent === 'timing') return tarotText(
      '不要设死日期，改成列出两到三个“事情开始成熟”的现实讯号；当这些讯号出现，再重新评估时间会更可靠。',
      '不要設死日期，改成列出兩到三個「事情開始成熟」的現實訊號；當這些訊號出現，再重新評估時間會更可靠。',
      'Do not lock onto a date. List two or three real-world readiness signals and reassess timing when they appear.'
    );
    if (intent === 'decision' || intent === 'binary') return tarotText(
      '把这次读牌当成条件清单：哪些条件满足时你会往前，哪些红线出现时你会停；这样比只记住“偏是／偏否”更有用。',
      '把這次讀牌當成條件清單：哪些條件滿足時你會往前，哪些紅線出現時你會停；這樣比只記住「偏是／偏否」更有用。',
      'Turn the reading into conditions: what must be true to move forward, and what red flags make you stop. That is more useful than remembering only “lean yes/no.”'
    );
    const guide = guidanceItem(draw);
    return guide?.meaning?.advice || '';
  }

  function buildFinalAdviceV2(draw, analysis, profile = analyseQuestion()) {
    if (selectedSpread()?.key === 'choice5') {
      const base = buildFinalAdviceBase(draw,analysis,profile);
      const next = scenarioNextStep(profile,draw);
      return [base,next].filter(Boolean).join('\n\n');
    }
    const guide = guidanceItem(draw);
    const blocker = challengeItem(draw);
    const lead = pickLocalized(`${state.currentDrawId}|advice-lead`,
      [
        `如果把整组牌压缩成一个可执行重点，我会先抓「${cardName(guide.card)}・${orientationText(guide.reversed)}」。${guide.meaning.advice}`,
        `这组牌最后不是要你记住所有关键词，而是先照「${cardName(guide.card)}・${orientationText(guide.reversed)}」做一个改变：${guide.meaning.advice}`,
        `真正能改变后续走向的，是把「${cardName(guide.card)}・${orientationText(guide.reversed)}」从牌义变成行动。${guide.meaning.advice}`
      ],
      [
        `如果把整組牌壓縮成一個可執行重點，我會先抓「${cardName(guide.card)}・${orientationText(guide.reversed)}」。${guide.meaning.advice}`,
        `這組牌最後不是要你記住所有關鍵詞，而是先照「${cardName(guide.card)}・${orientationText(guide.reversed)}」做一個改變：${guide.meaning.advice}`,
        `真正能改變後續走向的，是把「${cardName(guide.card)}・${orientationText(guide.reversed)}」從牌義變成行動。${guide.meaning.advice}`
      ],
      [
        `If I reduce the spread to one actionable point, start with ${cardName(guide.card)} (${orientationText(guide.reversed)}): ${guide.meaning.advice}`,
        `Do not try to remember every keyword. Make one change through ${cardName(guide.card)} (${orientationText(guide.reversed)}): ${guide.meaning.advice}`,
        `What can actually change the trajectory is turning ${cardName(guide.card)} (${orientationText(guide.reversed)}) into behavior: ${guide.meaning.advice}`
      ]);
    const blockerLine = blocker && blocker !== guide
      ? tarotText(
          `同时留意「${cardName(blocker.card)}・${orientationText(blocker.reversed)}」：它代表最容易让你回到旧模式的地方，关键词是「${keyThemes([blocker],2).join('、')}」。`,
          `同時留意「${cardName(blocker.card)}・${orientationText(blocker.reversed)}」：它代表最容易讓你回到舊模式的地方，關鍵詞是「${keyThemes([blocker],2).join('、')}」。`,
          `Also watch ${cardName(blocker.card)} (${orientationText(blocker.reversed)}): it is the easiest place to fall back into the old pattern, especially around ${keyThemes([blocker],2).join(' and ')}.`)
      : '';
    const next = scenarioNextStep(profile,draw);
    const checkpoint = profile?.scenario && profile.scenario !== 'general' ? '' : realityCheckpoint(profile,draw);
    return [lead,blockerLine,next,checkpoint].filter(Boolean).join('\n\n') + questionFraming();
  }

  function tarotHistoryKey() {
    return window.XingchenRecords?.KEYS?.tarotHistory || 'xingchen-tarot-history-v1';
  }

  function readTarotHistory() {
    if (window.XingchenRecords?.read) {
      const value = window.XingchenRecords.read(tarotHistoryKey(),[]);
      return Array.isArray(value) ? value.slice(0,10) : [];
    }
    try {
      const value = JSON.parse(localStorage.getItem(tarotHistoryKey()) || '[]');
      return Array.isArray(value) ? value.slice(0,10) : [];
    } catch {
      return [];
    }
  }

  function writeTarotHistory(records) {
    const next = Array.isArray(records) ? records.slice(0,10) : [];
    if (window.XingchenRecords?.write) {
      window.XingchenRecords.write(tarotHistoryKey(),next);
    } else {
      try { localStorage.setItem(tarotHistoryKey(),JSON.stringify(next)); } catch {}
    }
    state.history = next;
    return next;
  }

  function pushTarotHistory(record) {
    if (window.XingchenRecords?.pushCapped) {
      state.history = window.XingchenRecords.pushCapped(tarotHistoryKey(),record,10);
    } else {
      const existing = readTarotHistory().filter(item => item?.id !== record.id);
      state.history = writeTarotHistory([record,...existing].slice(0,10));
    }
    return state.history;
  }

  function historyTopicName(record) {
    const source = state.topics.find(item => item.key === record.topicKey);
    return source ? localized(source.name) : (record.topicName || record.topicKey || '');
  }

  function historySpreadName(record) {
    const source = state.spreads.find(item => item.key === record.spreadKey);
    return source ? localized(source.name) : (record.spreadName || record.spreadKey || '');
  }

  function historyCardName(item) {
    const card = state.cards.find(card => card.key === item.key);
    return card ? cardName(card) : (item.name || item.key || '');
  }

  function historyDateLabel(value) {
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return value || '';
    const locale = currentLanguage() === 'en'
      ? 'en-US'
      : (currentLanguage() === 'zh-TW' ? 'zh-TW' : 'zh-CN');
    return new Intl.DateTimeFormat(locale,{
      year:'numeric',month:'2-digit',day:'2-digit',
      hour:'2-digit',minute:'2-digit',hour12:false
    }).format(date);
  }

  function renderTarotHistory() {
    state.history = readTarotHistory();
    const list = byId('tarotHistoryList');
    const count = byId('tarotHistoryCount');
    if (count) count.textContent = String(state.history.length);
    if (!list) return;

    if (!state.history.length) {
      list.innerHTML = `<p class="tarot-history-empty">${escapeHtml(ui('historyEmpty'))}</p>`;
      return;
    }

    list.innerHTML = state.history.map(record => {
      const question = record.question || ui('historyGeneral');
      const cards = (record.cards || []).map((item,index) =>
        `<li>
          <span>${index+1}. ${escapeHtml(item.positionName || '')}</span>
          <strong>${escapeHtml(historyCardName(item))}</strong>
          <small class="${item.reversed ? 'is-reversed' : ''}">${escapeHtml(item.reversed ? ui('reversed') : ui('upright'))}</small>
        </li>`
      ).join('');

      return `
        <details class="tarot-history-item">
          <summary>
            <span class="tarot-history-date">${escapeHtml(historyDateLabel(record.createdAt))}</span>
            <strong>${escapeHtml(historyTopicName(record))} · ${escapeHtml(historySpreadName(record))}</strong>
            <small>${escapeHtml(question)}</small>
          </summary>
          <div class="tarot-history-detail">
            <section>
              <h3>${escapeHtml(ui('historyCards'))}</h3>
              <ol class="tarot-history-cards">${cards}</ol>
            </section>
            ${record.directAnswer ? `<section class="tarot-history-answer">
              <h3>${escapeHtml(ui('historyAnswer') || ui('directAnswerHeading'))}</h3>
              <p>${escapeHtml(record.directAnswer)}</p>
            </section>` : ''}
            <section>
              <h3>${escapeHtml(ui('historyStory'))}</h3>
              <p>${escapeHtml(record.story || '')}</p>
            </section>
            <section>
              <h3>${escapeHtml(ui('historyStructure'))}</h3>
              <p>${escapeHtml(record.structure || '')}</p>
            </section>
            <section class="tarot-history-advice">
              <h3>${escapeHtml(ui('historyAdvice'))}</h3>
              <p>${escapeHtml(record.finalAdvice || '')}</p>
            </section>
          </div>
        </details>`;
    }).join('');
  }

  function saveCompletedTarotHistory(analysis, texts) {
    if (!state.currentDrawId || !state.currentDraw.length) return;

    const topic = selectedTopic();
    const spread = selectedSpread();

    const record = {
      version:1,
      id:state.currentDrawId,
      createdAt:new Date().toISOString(),
      topicKey:state.selectedTopic,
      topicName:localized(topic?.name),
      spreadKey:state.selectedSpread,
      spreadName:localized(spread?.name),
      question:state.question,
      optionA:state.optionA,
      optionB:state.optionB,
      cards:state.currentDraw.map(item => ({
        key:item.card.key,
        name:cardName(item.card),
        reversed:Boolean(item.reversed),
        positionKey:item.position?.key || '',
        positionName:positionName(item.position)
      })),
      signals:signalChips(analysis),
      directAnswer:texts.directAnswer || '',
      story:texts.story,
      structure:texts.structure,
      finalAdvice:texts.finalAdvice
    };

    pushTarotHistory(record);
    renderTarotHistory();
  }

  function readInputs() {
    state.question = byId('questionInput').value.trim();
    state.optionA = byId('optionAInput').value.trim();
    state.optionB = byId('optionBInput').value.trim();
  }

  function draw() {
    if (!window.XingchenPlayer?.hasProfile?.()) {
      window.XingchenPlayer?.ensure?.(() => draw());
      return;
    }
    cancelAutoReveal();
    readInputs();
    const spread = selectedSpread();
    if (!spread || !state.cards.length) return;

    if (spread.key === 'choice5' && (!state.optionA || !state.optionB)) {
      byId('questionNote').textContent = ui('choiceMissing');
      byId('choiceFields').classList.add('needs-attention');
      setTimeout(() => byId('choiceFields').classList.remove('needs-attention'), 900);
    } else {
      byId('questionNote').textContent = ui('questionNote');
    }

    const cards = shuffledUniqueCards(spread.count);
    state.currentDraw = cards.map((card, index) => {
      const reversed = secureRandomInt(2) === 1;
      const meaningSet = state.meanings.get(card.key);
      const meaning = meaningSet?.[reversed ? 'reversed' : 'upright'];
      return {
        card,
        reversed,
        meaning,
        position: spread.positions[index],
        revealed: false
      };
    }).filter(item => item.meaning);

    state.nextRevealIndex = 0;
    state.currentDrawId = globalThis.crypto?.randomUUID?.()
      || `tarot-${Date.now()}-${Math.random().toString(36).slice(2,9)}`;
    renderResult();
  }

  function flipCardHtml(item, index) {
    const {card, reversed, meaning, position} = item;
    const name = cardName(card);
    const pos = positionName(position);
    return `
      <article class="tarot-spread-card tarot-reveal-item" data-card-index="${index}">
        <div class="tarot-position-badge">
          <span>${String(index + 1).padStart(2,'0')}</span>
          <strong>${escapeHtml(pos)}</strong>
        </div>

        <button class="tarot-flip-card is-waiting"
                type="button"
                data-reveal-index="${index}"
                disabled
                tabindex="-1"
                aria-label="${escapeHtml(pos)} · ${ui('waiting')}">
          <span class="tarot-flip-inner">
            <span class="tarot-flip-face tarot-flip-back">
              <img src="../images/tarot/cards/CardBacks.webp" alt="" />
              <span class="tarot-flip-prompt">${ui('waiting')}</span>
            </span>
            <span class="tarot-flip-face tarot-flip-front ${reversed ? 'is-reversed' : ''}">
              <img src="${imageFromRoot(card.image)}" alt="${escapeHtml(name)} · ${orientationText(reversed)}" />
            </span>
          </span>
        </button>

        <div class="tarot-card-reveal-caption" hidden>
          <span class="tarot-orientation ${reversed ? 'is-reversed' : ''}">${orientationText(reversed)}</span>
        </div>

        <div class="tarot-spread-card-reading" hidden>
          <p class="tarot-card-index">${String(card.id + 1).padStart(2,'0')} / 78 · ${escapeHtml(arcanaText(card))}</p>
          <h3>${escapeHtml(name)}</h3>
          <p class="tarot-card-en">${escapeHtml(card.name.en)}</p>
          <div class="tarot-keywords">${meaning.keywords.map(k => `<span>${escapeHtml(k)}</span>`).join('')}</div>

          <section class="tarot-reading-block">
            <span class="tarot-reading-label">${ui('cardMeaning')}</span>
            <p>${escapeHtml(meaning.meaning)}</p>
          </section>

          <section class="tarot-reading-block tarot-topic-lens">
            <span class="tarot-reading-label">${ui('topicLens')} · ${escapeHtml(localized(selectedTopic().name))}</span>
            <p>${escapeHtml(contextualCardReading(item, index, analyseQuestion()))}</p>
          </section>

          <section class="tarot-advice-block">
            <span>${ui('cardAdvice')}</span>
            <strong>${escapeHtml(meaning.advice)}</strong>
          </section>
        </div>
      </article>
    `;
  }

  function renderResult() {
    const spread = selectedSpread();
    const topic = selectedTopic();

    byId('resultSubtitle').textContent =
      `${localized(topic.name)} · ${localized(spread.name)} · ${localized(spread.subtitle)}`;

    if (state.question) {
      byId('questionSummary').hidden = false;
      byId('questionSummary').textContent = `${ui('questionPrefix')}：「${state.question}」`;
    } else {
      byId('questionSummary').hidden = true;
      byId('questionSummary').textContent = '';
    }

    byId('tarotSpreadGrid').dataset.count = String(spread.count);
    byId('tarotSpreadGrid').dataset.spread = spread.key;
    byId('tarotSpreadGrid').innerHTML = state.currentDraw.map(flipCardHtml).join('');

    byId('combinationReading').hidden = true;
    byId('revealGuideTitle').textContent = ui('revealGuideTitle');
    byId('revealGuideText').textContent = ui('revealGuideText');
    byId('tarotResult').hidden = false;

    requestAnimationFrame(() => {
      byId('tarotResult').scrollIntoView({behavior:'smooth', block:'start'});
      startAutoReveal();
    });
  }

  function revealDelays() {
    const reduced = globalThis.matchMedia?.('(prefers-reduced-motion: reduce)')?.matches;
    return reduced
      ? {initial:120, ready:0, settle:90, gap:70}
      : {initial:650, ready:260, settle:650, gap:180};
  }

  function setDrawLocked(locked) {
    const main = byId('drawTarotBtn');
    const again = byId('drawTarotAgainBtn');
    if (main) main.disabled = locked;
    if (again) again.disabled = locked;
  }

  function cancelAutoReveal() {
    state.autoRevealTimers.forEach(id => window.clearTimeout(id));
    state.autoRevealTimers = [];
    state.autoRevealToken += 1;
    state.isAutoRevealing = false;
  }

  function queueAutoReveal(callback, delay, token) {
    const id = window.setTimeout(() => {
      state.autoRevealTimers = state.autoRevealTimers.filter(x => x !== id);
      if (token !== state.autoRevealToken) return;
      callback();
    }, Math.max(0, delay));
    state.autoRevealTimers.push(id);
  }

  function startAutoReveal() {
    cancelAutoReveal();
    const token = state.autoRevealToken;
    const delays = revealDelays();
    state.nextRevealIndex = 0;
    state.isAutoRevealing = true;
    setDrawLocked(true);

    if (!state.currentDraw.length) {
      state.isAutoRevealing = false;
      setDrawLocked(false);
      return;
    }
    queueAutoReveal(() => autoRevealCard(0, token, delays), delays.initial, token);
  }

  function autoRevealCard(index, token, delays) {
    if (token !== state.autoRevealToken || index !== state.nextRevealIndex) return;
    const item = state.currentDraw[index];
    const button = document.querySelector(`[data-reveal-index="${index}"]`);
    if (!item || !button || item.revealed) return;

    button.classList.remove('is-waiting');
    button.classList.add('is-ready');
    const prompt = button.querySelector('.tarot-flip-prompt');
    if (prompt) prompt.textContent = ui('revealNext');
    button.setAttribute('aria-label', `${positionName(item.position)} · ${ui('revealNext')}`);

    queueAutoReveal(() => {
      if (token !== state.autoRevealToken) return;
      item.revealed = true;
      button.classList.remove('is-ready');
      button.classList.add('is-flipped');

      const article = button.closest('.tarot-reveal-item');
      const caption = article?.querySelector('.tarot-card-reveal-caption');
      const reading = article?.querySelector('.tarot-spread-card-reading');

      queueAutoReveal(() => {
        if (token !== state.autoRevealToken) return;
        if (caption) caption.hidden = false;
        if (reading) reading.hidden = false;
        article?.classList.add('is-revealed');
        state.nextRevealIndex += 1;

        if (state.nextRevealIndex < state.currentDraw.length) {
          queueAutoReveal(
            () => autoRevealCard(state.nextRevealIndex, token, delays),
            delays.gap,
            token
          );
        } else {
          state.isAutoRevealing = false;
          setDrawLocked(false);
          revealCombination();
        }
      }, delays.settle, token);
    }, delays.ready, token);
  }

  function truncateUtf8(text, maxBytes) {
    const value = String(text || '');
    const encoder = new TextEncoder();
    if (encoder.encode(value).length <= maxBytes) return value;
    let out = '';
    for (const char of value) {
      if (encoder.encode(out + char + '…').length > maxBytes) break;
      out += char;
    }
    return out.trimEnd() + '…';
  }

  function sendTarotBark(analysis, texts) {
    if (!window.XingchenBark?.send) return;

    const player = window.XingchenPlayer?.label?.() || '未命名玩家';
    const topicText = localized(selectedTopic()?.name) || state.selectedTopic;
    const spreadText = localized(selectedSpread()?.name) || state.selectedSpread;

    const cards = state.currentDraw.map((item,index) =>
      `${index+1}. ${positionName(item.position)}｜${cardName(item.card)}｜${orientationText(item.reversed)}`
    );

    const fullBody = [
      `玩家：${player}`,
      `问题方向：${topicText}`,
      `牌阵：${spreadText}`,
      state.question ? `问题：${state.question}` : '问题：一般指引',
      state.selectedSpread === 'choice5'
        ? `选项 A：${state.optionA || '未填写'}\n选项 B：${state.optionB || '未填写'}`
        : '',
      '',
      '牌面：',
      ...cards,
      '',
      `直接回答：${texts?.directAnswer || buildDirectAnswerV2(state.currentDraw, analysis, analyseQuestion())}`,
      '',
      `生活指引：${texts?.finalAdvice || buildFinalAdviceV2(state.currentDraw, analysis, analyseQuestion())}`
    ].filter(Boolean).join('\n');

    // The website keeps the full teacher-style analysis. Bark gets a compact
    // summary so richer local text never exceeds the Edge Function body limit.
    const body = truncateUtf8(fullBody, 2650);

    window.XingchenBark.send({
      title:'🔮 星辰日记｜塔罗结果',
      subtitle:player,
      body,
      group:'星辰日记·塔罗牌'
    });
  }

  function revealCombination() {
    const analysis = analyseStructure(state.currentDraw);
    const questionProfile = analyseQuestion();
    const texts = {
      directAnswer:buildDirectAnswerV2(state.currentDraw, analysis, questionProfile),
      story:buildStoryV2(state.currentDraw, analysis, questionProfile),
      structure:buildStructure(analysis, questionProfile, state.currentDraw),
      finalAdvice:buildFinalAdviceV2(state.currentDraw, analysis, questionProfile)
    };

    byId('signalChips').innerHTML =
      signalChips(analysis).map(x => `<span>${escapeHtml(x)}</span>`).join('');
    byId('directAnswerText').textContent = texts.directAnswer;
    byId('storyText').textContent = texts.story;
    byId('structureText').textContent = texts.structure;
    byId('finalAdviceText').textContent = texts.finalAdvice;
    byId('combinationReading').hidden = false;
    byId('revealGuideTitle').textContent = ui('allRevealed');
    byId('revealGuideText').textContent = '';

    requestAnimationFrame(() => {
      byId('combinationReading').classList.add('is-visible');
    });

    saveCompletedTarotHistory(analysis,texts);
    sendTarotBark(analysis,texts);
  }

  function analyseStructure(draw) {
    const total = draw.length;
    const majorCount = draw.filter(x => x.card.arcana === 'major').length;
    const reversedCount = draw.filter(x => x.reversed).length;
    const uprightCount = total - reversedCount;

    const suitCounts = {cups:0, wands:0, swords:0, pentacles:0};
    const elementCounts = {water:0, fire:0, air:0, earth:0};
    const rankCounts = {};
    let courtCount = 0;
    let aceCount = 0;
    let tenCount = 0;

    draw.forEach(x => {
      const c = x.card;
      if (c.arcana === 'minor') {
        suitCounts[c.suit] += 1;
        elementCounts[suitMeta[c.suit].element] += 1;
        if (c.rank >= 1 && c.rank <= 10) {
          rankCounts[c.rank] = (rankCounts[c.rank] || 0) + 1;
        }
        if (c.rank >= 11 && c.rank <= 14) courtCount += 1;
        if (c.rank === 1) aceCount += 1;
        if (c.rank === 10) tenCount += 1;
      }
    });

    const suitEntries = Object.entries(suitCounts).sort((a,b) => b[1]-a[1]);
    const maxSuit = suitEntries[0]?.[1] || 0;
    const dominantSuits = maxSuit >= 2
      ? suitEntries.filter(([,v]) => v === maxSuit).map(([k]) => k)
      : [];

    const repeatedRanks = Object.entries(rankCounts)
      .filter(([, count]) => count >= 2)
      .map(([rank, count]) => ({rank: Number(rank), count}));

    const uniqueRanks = Object.keys(rankCounts).map(Number).sort((a,b) => a-b);
    const sequences = [];
    let current = [];
    uniqueRanks.forEach(rank => {
      if (!current.length || rank === current[current.length - 1] + 1) {
        current.push(rank);
      } else {
        if (current.length >= 2) sequences.push([...current]);
        current = [rank];
      }
    });
    if (current.length >= 2) sequences.push([...current]);

    const majorRuns = [];
    let run = [];
    draw.forEach((item, index) => {
      if (item.card.arcana === 'major') {
        run.push(index);
      } else {
        if (run.length >= 2) majorRuns.push([...run]);
        run = [];
      }
    });
    if (run.length >= 2) majorRuns.push([...run]);

    const minorCount = total - majorCount;
    const missingElements = minorCount >= 3
      ? Object.entries(elementCounts).filter(([,v]) => v === 0).map(([k]) => k)
      : [];

    const firstHalf = draw.slice(0, Math.ceil(total / 2));
    const secondHalf = draw.slice(Math.floor(total / 2));
    const firstRev = firstHalf.filter(x => x.reversed).length;
    const secondRev = secondHalf.filter(x => x.reversed).length;
    const orientationFlow =
      secondRev < firstRev ? 'clearing' :
      secondRev > firstRev ? 'tightening' : 'steady';

    return {
      total, majorCount, reversedCount, uprightCount,
      suitCounts, elementCounts, dominantSuits,
      courtCount, aceCount, tenCount,
      repeatedRanks, sequences, majorRuns,
      missingElements, orientationFlow
    };
  }

  function numberLabel(rank) {
    const zh = ['','一','二','三','四','五','六','七','八','九','十'];
    return currentLanguage() === 'en' ? String(rank) : zh[rank] || String(rank);
  }

  function elementName(key) {
    const lookup = {
      water: {'zh-CN':'水','zh-TW':'水','en':'Water'},
      fire: {'zh-CN':'火','zh-TW':'火','en':'Fire'},
      air: {'zh-CN':'风','zh-TW':'風','en':'Air'},
      earth: {'zh-CN':'土','zh-TW':'土','en':'Earth'}
    };
    return localized(lookup[key]);
  }

  function signalChips(a) {
    const lang = currentLanguage();
    const chips = [];

    if (lang === 'en') {
      chips.push(`Major ${a.majorCount}/${a.total}`);
      chips.push(`Reversed ${a.reversedCount}/${a.total}`);
      if (a.courtCount >= 2) chips.push(`Court cards ×${a.courtCount}`);
      if (a.aceCount >= 2) chips.push(`Aces ×${a.aceCount}`);
      if (a.tenCount >= 2) chips.push(`Tens ×${a.tenCount}`);
      a.dominantSuits.forEach(s => chips.push(`Focus · ${suitMeta[s].names.en}`));
      a.repeatedRanks.forEach(r => chips.push(`Repeated ${r.rank} ×${r.count}`));
    } else {
      chips.push(`大牌 ${a.majorCount}/${a.total}`);
      chips.push(`逆位 ${a.reversedCount}/${a.total}`);
      if (a.courtCount >= 2) chips.push(`宫廷牌 ×${a.courtCount}`);
      if (a.aceCount >= 2) chips.push(`Ace ×${a.aceCount}`);
      if (a.tenCount >= 2) chips.push(`十号牌 ×${a.tenCount}`);
      a.dominantSuits.forEach(s => chips.push(`集中 · ${localized(suitMeta[s].names)}`));
      a.repeatedRanks.forEach(r => chips.push(`数字${numberLabel(r.rank)} ×${r.count}`));
    }
    return chips;
  }

  function itemShort(item) {
    const kw = item.meaning.keywords.slice(0,2).join('、');
    return `${positionName(item.position)}「${cardName(item.card)}・${orientationText(item.reversed)}」〔${kw}〕`;
  }

  function counterpartLabel() {
    const labels = {
      general: {
        'zh-CN': '外在环境',
        'zh-TW': '外在環境',
        'en': 'the outside environment'
      },
      love: {
        'zh-CN': '对方',
        'zh-TW': '對方',
        'en': 'the other person'
      },
      career: {
        'zh-CN': '合作方／工作环境',
        'zh-TW': '合作方／工作環境',
        'en': 'the other side / work environment'
      },
      money: {
        'zh-CN': '外在资源／市场环境',
        'zh-TW': '外在資源／市場環境',
        'en': 'external resources / market conditions'
      },
      study: {
        'zh-CN': '学习环境／外在条件',
        'zh-TW': '學習環境／外在條件',
        'en': 'the learning environment / external conditions'
      }
    };
    return labels[state.selectedTopic]?.[currentLanguage()]
      || labels.general[currentLanguage()];
  }

  // V0.19.7.0 · Question-aware connected-reading engine 2.0.
  // This deliberately stays deterministic and local: no question text is sent to an AI service.
  function analyseQuestion() {
    const q = (state.question || '').trim();
    const spreadKey = selectedSpread()?.key || '';
    const lower = q.toLowerCase();
    const has = (pattern) => pattern.test(q) || pattern.test(lower);
    const intents = [];
    const add = (name, pattern, condition = true) => {
      if (condition && has(pattern) && !intents.includes(name)) intents.push(name);
    };

    if (spreadKey === 'choice5') {
      intents.push('choice');
    } else {
      // Order here is presentation order for multi-part questions, not a hard
      // priority. A user can ask “does he care, why is he cold, will he text?”
      // and the result will answer all three instead of silently keeping only one.
      add('feelings', /喜欢我|喜歡我|爱我|愛我|在意我|想我|对我.*感觉|對我.*感覺|心里.*我|心裡.*我|怎么看我|怎麼看我|feel.*about me|like me|love me/i, state.selectedTopic === 'love');
      add('reason', /为什么|為什麼|因为|因為|原因|怎么会|怎麼會|为何|為何|why/i);
      add('action', /主动|主動|联系|聯絡|找我|回我|消息|訊息|行动|行動|表白|告白|约我|約我|开口|開口|会来|會來|will.*contact|will.*message|reach out/i);
      add('reconcile', /复合|復合|和好|重新在一起|重来|重來|回到一起|reconcil/i, state.selectedTopic === 'love');
      add('timing', /什么时候|什麼時候|何时|幾時|何時|多久|哪一天|幾天|几天|when|how long|what time/i);
      add('decision', /应不应该|應不應該|应该|應該|该不该|該不該|要不要|适不适合|適不適合|适合[^，。！？?]{0,16}[吗嗎]|適合[^，。！？?]{0,16}[嗎吗]|值不值得|值得吗|值得嗎|怎么选|怎麼選|should i|which should|worth it/i);
      add('binary', /会不会|會不會|能不能|是不是|是否|有没有|有沒有|能[^，。！？?]{0,14}[吗嗎]|會[^，。！？?]{0,14}[嗎吗]|will it|can i|yes or no/i);
      add('development', /发展|發展|走向|结果|結果|未来|未來|接下来|接下來|最后|最後|会怎样|會怎樣|如何发展|如何發展|outcome|future|develop/i);
      add('advice', /怎么办|怎麼辦|怎么做|怎麼做|该怎么|該怎麼|怎么准备|怎麼準備|建议|建議|如何处理|如何處理|如何准备|如何準備|what should|how should|advice/i);
    }

    const intent = intents[0] || 'general';
    return {
      raw:q,
      intent,
      intents:intents.length ? intents : ['general'],
      hasQuestion:Boolean(q),
      topic:state.selectedTopic,
      spread:spreadKey,
      scenario:detectQuestionScenario(q,state.selectedTopic)
    };
  }

  const positiveToneTerms = [
    '新开始','新開始','自由','信任','行动','行動','资源','資源','创造','創造','直觉','直覺','成长','成長','丰盛','豐盛','稳定','穩定','成功','希望','疗愈','療癒','喜悦','喜悅','庆祝','慶祝','合作','和谐','和諧','吸引','热情','熱情','勇气','勇氣','平衡','清晰','沟通','溝通','前进','前進','机会','機會','收获','收穫','满足','滿足','成就','承诺','承諾','支持','安全','成熟','恢复','恢復','完成','智慧','掌控','突破','好运','好運','幸福','连接','連結','亲密','親密','互惠','坚定','堅定'
  ];
  const challengingToneTerms = [
    '鲁莽','魯莽','逃避','准备不足','準備不足','分心','操控','混乱','混亂','秘密','阻碍','阻礙','拖延','冲突','衝突','失落','焦虑','焦慮','恐惧','恐懼','欺骗','欺騙','控制','停滞','停滯','孤立','不安','破裂','危机','危機','压力','壓力','争执','爭執','犹豫','猶豫','依赖','依賴','嫉妒','固执','固執','背叛','痛苦','悲伤','悲傷','耗损','耗損','匮乏','匱乏','束缚','束縛','执念','執念','幻觉','幻覺','隐藏','隱藏','防御','防禦','冷淡','延迟','延遲','过度','過度','未完成','受阻','结束','結束','崩塌','牺牲','犧牲','压抑','壓抑','怀疑','懷疑'
  ];

  const majorToneGuide = Object.freeze({
    thefool:{upright:.30,reversed:-.30}, themagician:{upright:.55,reversed:-.40},
    thehighpriestess:{upright:.05,reversed:-.18}, theempress:{upright:.65,reversed:-.35},
    theemperor:{upright:.45,reversed:-.35}, thehierophant:{upright:.30,reversed:-.25},
    thelovers:{upright:.55,reversed:-.42}, thechariot:{upright:.60,reversed:-.42},
    strength:{upright:.60,reversed:-.28}, thehermit:{upright:.02,reversed:-.18},
    wheeloffortune:{upright:.32,reversed:-.22}, justice:{upright:.22,reversed:-.28},
    thehangedman:{upright:-.12,reversed:-.18}, death:{upright:-.12,reversed:-.22},
    temperance:{upright:.58,reversed:-.34}, thedevil:{upright:-.68,reversed:.18},
    thetower:{upright:-.78,reversed:-.42}, thestar:{upright:.72,reversed:-.34},
    themoon:{upright:-.32,reversed:.12}, thesun:{upright:.82,reversed:.22},
    judgement:{upright:.48,reversed:-.30}, theworld:{upright:.76,reversed:-.25}
  });

  function cardTone(item) {
    if (item?.card?.arcana === 'major' && majorToneGuide[item.card.key]) {
      return majorToneGuide[item.card.key][item.reversed ? 'reversed' : 'upright'];
    }
    const text = `${item?.meaning?.keywords?.join(' ') || ''} ${item?.meaning?.meaning || ''}`;
    let positive = 0;
    let challenging = 0;
    positiveToneTerms.forEach(term => { if (text.includes(term)) positive += 1; });
    challengingToneTerms.forEach(term => { if (text.includes(term)) challenging += 1; });

    let score = (positive - challenging) * 0.28;
    if (!positive && !challenging) score += item?.reversed ? -0.16 : 0.10;
    if (item?.reversed) score -= 0.10;
    return Math.max(-1, Math.min(1, score));
  }

  function positionWeight(item) {
    const spread = selectedSpread()?.key;
    const key = item?.position?.key || '';
    const weights = {
      single:{guidance:1.2},
      weekly3:{current:0.75,trend:1.25,advice:0.8},
      monthly5:{early:0.5,mid1:0.65,mid2:0.8,late:1.2,advice:0.75},
      relationship5:{self:0.55,other:0.9,core:1.2,obstacle:1.0,direction:1.35},
      choice5:{current:0.45,optionA:0.9,optionAOutcome:1.25,optionB:0.9,optionBOutcome:1.25}
    };
    return weights[spread]?.[key] || 1;
  }

  function spreadTendency(draw) {
    let weighted = 0;
    let totalWeight = 0;
    draw.forEach(item => {
      const weight = positionWeight(item);
      weighted += cardTone(item) * weight;
      totalWeight += weight;
    });
    return totalWeight ? weighted / totalWeight : 0;
  }

  function branchTendency(items) {
    if (!items?.length) return 0;
    return items.reduce((sum,item,index) => sum + cardTone(item) * (index === items.length - 1 ? 1.35 : 1),0)
      / items.reduce((sum,_,index) => sum + (index === items.length - 1 ? 1.35 : 1),0);
  }

  function tendencyBand(score) {
    if (score >= 0.42) return 'supportive';
    if (score >= 0.12) return 'leaning-supportive';
    if (score <= -0.42) return 'challenging';
    if (score <= -0.12) return 'leaning-challenging';
    return 'mixed';
  }

  function keyThemes(items, limit = 3) {
    const seen = new Set();
    const result = [];
    (items || []).forEach(item => {
      (item?.meaning?.keywords || []).forEach(keyword => {
        const value = String(keyword || '').trim();
        if (!value || seen.has(value)) return;
        seen.add(value);
        result.push(value);
      });
    });
    return result.slice(0, limit);
  }

  function mostRelevantItems(draw, profile) {
    const byKey = (key) => draw.find(item => item.position?.key === key);
    if (profile.intent === 'reason' && profile.spread === 'relationship5') {
      return [byKey('obstacle'),byKey('other'),byKey('core')].filter(Boolean);
    }
    if ((profile.intent === 'feelings' || profile.intent === 'action' || profile.intent === 'reconcile') && profile.spread === 'relationship5') {
      return [byKey('other'),byKey('core'),byKey('direction'),byKey('obstacle')].filter(Boolean);
    }
    if (profile.intent === 'timing') return draw.slice(-Math.min(3,draw.length));
    return [...draw].sort((a,b) => positionWeight(b) - positionWeight(a)).slice(0,Math.min(3,draw.length));
  }

  function buildDirectAnswer(draw, analysis, profile = analyseQuestion()) {
    const lang = currentLanguage();
    const score = spreadTendency(draw);
    const band = tendencyBand(score);
    const relevant = mostRelevantItems(draw, profile);
    const themes = keyThemes(relevant,3);
    const themeText = themes.join(lang === 'en' ? ', ' : '、');

    if (profile.intent === 'choice' && draw.length >= 5) {
      const A = state.optionA || ui('optionA');
      const B = state.optionB || ui('optionB');
      const aScore = branchTendency([draw[1],draw[2]]);
      const bScore = branchTendency([draw[3],draw[4]]);
      const diff = aScore - bScore;
      if (Math.abs(diff) < 0.18) return tarotText(
        `两条路目前差距不大；「${A}」与「${B}」更像各有代价。与其找绝对正确答案，不如比较哪一种成本是你愿意承担的。`,
        `兩條路目前差距不大；「${A}」與「${B}」更像各有代價。與其找絕對正確答案，不如比較哪一種成本是你願意承擔的。`,
        `The two paths are close. ${A} and ${B} carry different trade-offs rather than a clear winner; compare which cost you are more willing to carry.`
      );
      const better = diff > 0 ? A : B;
      return tarotText(
        `目前牌面较偏向「${better}」这条路较顺，但这是条件式倾向，不代表结果已经被固定。`,
        `目前牌面較偏向「${better}」這條路較順，但這是條件式傾向，不代表結果已經被固定。`,
        `${better} currently reads as the smoother path, but the cards still describe conditions rather than a guaranteed outcome.`
      );
    }

    if (!profile.hasQuestion) {
      if (band.includes('supportive')) return tarotText(
        '整体牌势偏顺，现在可以往前走，但建议位仍要当成行动前的检查点。',
        '整體牌勢偏順，現在可以往前走，但建議位仍要當成行動前的檢查點。',
        'The overall flow is constructive: move forward, but keep the advice card as your practical checkpoint.'
      );
      if (band.includes('challenging')) return tarotText(
        '整体阻力偏高，现在不是硬推的时候；先处理卡住的环节，后面的路会更清楚。',
        '整體阻力偏高，現在不是硬推的時候；先處理卡住的環節，後面的路會更清楚。',
        'The spread is asking for adjustment before acceleration; resolve the blocked part first.'
      );
      return tarotText(
        '牌面讯号有好有坏，事情不是不能走，而是暂时不适合急着下最终结论。',
        '牌面訊號有好有壞，事情不是不能走，而是暫時不適合急著下最終結論。',
        'The spread is mixed: there is room to move, but the next step matters more than forcing a final verdict.'
      );
    }

    if (profile.intent === 'reason') return tarotText(
      `核心原因比较不像单一事件，而是「${themeText || '几股不同压力'}」叠在一起。尤其要把阻碍位与对方／环境位一起看，不宜只抓一个原因下结论。`,
      `核心原因比較不像單一事件，而是「${themeText || '幾股不同壓力'}」疊在一起。尤其要把阻礙位與對方／環境位一起看，不宜只抓一個原因下結論。`,
      `The core cause looks less like one isolated event and more like a mix of ${themeText || 'several pressures'}. Read the obstacle and counterpart positions together before blaming a single factor.`
    );

    if (profile.intent === 'feelings') {
      if (score >= .28) return tarotText(
        '这组牌偏向“有感受／有在意”，但能不能变成稳定关系，要看对方是否有持续而一致的实际行动。',
        '這組牌偏向「有感受／有在意」，但能不能變成穩定關係，要看對方是否有持續而一致的實際行動。',
        'The relationship energy suggests genuine interest or emotional connection, but it still needs consistent behavior to become reliable.'
      );
      if (score <= -.28) return tarotText(
        '目前牌面看不到足够稳定的情感投入；退缩、顾虑或自我保护，比明确追求更强。',
        '目前牌面看不到足夠穩定的情感投入；退縮、顧慮或自我保護，比明確追求更強。',
        'The cards do not show enough stable emotional investment right now; distance, hesitation or self-protection is stronger than clear pursuit.'
      );
      return tarotText(
        '牌面里有感情讯号，但彼此矛盾；可以说“不是完全没感觉”，但现在还不足以把它当成明确承诺。',
        '牌面裡有感情訊號，但彼此矛盾；可以說「不是完全沒感覺」，但現在還不足以把它當成明確承諾。',
        'There are emotional signals, but they are mixed. Interest may exist, yet the pattern is not stable enough to treat as a clear declaration.'
      );
    }

    if (profile.intent === 'action') {
      if (score >= .30) return tarotText(
        '偏向有机会出现主动或联系，但速度仍取决于目前的犹豫或阻力能不能被处理。',
        '偏向有機會出現主動或聯絡，但速度仍取決於目前的猶豫或阻力能不能被處理。',
        'There is a reasonable chance of action or contact, though the pace still depends on whether the current hesitation is resolved.'
      );
      if (score <= -.30) return tarotText(
        '短期主动性偏弱；与其预设对方很快会行动，不如先观察是否真的出现明确而持续的动作。',
        '短期主動性偏弱；與其預設對方很快會行動，不如先觀察是否真的出現明確而持續的動作。',
        'Short-term initiative looks weak. Waiting for clear action is more realistic than assuming contact is imminent.'
      );
      return tarotText(
        '有联系／行动的可能，但讯号不稳定；真正值得判断的是后续有没有持续，而不是单次消息或一时热度。',
        '有聯絡／行動的可能，但訊號不穩定；真正值得判斷的是後續有沒有持續，而不是單次訊息或一時熱度。',
        'Contact is possible, but the signal is inconsistent; watch actual follow-through rather than reading too much into one message.'
      );
    }

    if (profile.intent === 'reconcile') {
      if (score >= .30) return tarotText(
        '有重新靠近的可能，但前提是旧问题要用不同方式处理；互动模式不变，复合也容易回到原本的卡点。',
        '有重新靠近的可能，但前提是舊問題要用不同方式處理；互動模式不變，復合也容易回到原本的卡點。',
        'Reconnection is possible, but only if the old obstacle is handled differently this time.'
      );
      if (score <= -.30) return tarotText(
        '短期不太像能顺利复合，未处理的阻碍仍比重新连接的力量更强。',
        '短期不太像能順利復合，未處理的阻礙仍比重新連結的力量更強。',
        'The cards lean away from a smooth reconciliation in the near term; unresolved issues are stronger than reunion energy.'
      );
      return tarotText(
        '复合并非完全没有可能，但条件还没成熟；目前更重要的是旧问题能不能被真正处理。',
        '復合並非完全沒有可能，但條件還沒成熟；目前更重要的是舊問題能不能被真正處理。',
        'Reconciliation is not ruled out, but the conditions are not mature enough for a confident yes.'
      );
    }

    if (profile.intent === 'timing') {
      if (analysis.orientationFlow === 'clearing' && score > -.10) return tarotText(
        '时间点正在接近，但要先等目前的卡点松开。牌面比较能看出“条件成熟的顺序”，不适合硬换算成某一天。',
        '時間點正在接近，但要先等目前的卡點鬆開。牌面比較能看出「條件成熟的順序」，不適合硬換算成某一天。',
        'Timing looks closer once the current blockage begins to clear. The cards show sequence and readiness, not a reliable calendar date.'
      );
      if (analysis.orientationFlow === 'tightening' || score < -.25) return tarotText(
        '目前条件还没完全到位，时间上偏向需要再等；后段阻力仍在增加，先看事情是否开始出现实际松动。',
        '目前條件還沒完全到位，時間上偏向需要再等；後段阻力仍在增加，先看事情是否開始出現實際鬆動。',
        'The conditions do not look fully ready yet. More delay or adjustment is likely before the event can move naturally.'
      );
      return tarotText(
        '时间仍有变动性；与其猜固定日期，更适合观察后段牌所代表的条件何时真正出现。',
        '時間仍有變動性；與其猜固定日期，更適合觀察後段牌所代表的條件何時真正出現。',
        'The timing is still fluid. Watch for the conditions described by the later cards rather than forcing an exact date.'
      );
    }

    if (profile.intent === 'decision') {
      if (score >= .28) return tarotText(
        '牌面偏向可以往前做，但不是无条件的“可以”；先确认现实条件与风险都有被照顾。',
        '牌面偏向可以往前做，但不是無條件的「可以」；先確認現實條件與風險都有被照顧。',
        'The cards lean toward taking the step, provided you can meet the practical conditions shown in the spread.'
      );
      if (score <= -.28) return tarotText(
        '目前更适合先停一下、重整条件再决定；眼前的阻力不是小杂音，而是需要纳入判断的重要讯号。',
        '目前更適合先停一下、重整條件再決定；眼前的阻力不是小雜音，而是需要納入判斷的重要訊號。',
        'The cards lean toward slowing down or reconsidering before committing; the current friction is meaningful.'
      );
      return tarotText(
        '这不是很干脆的“要／不要”；先把你愿意承担的代价说清楚，答案会比硬问吉凶更实际。',
        '這不是很乾脆的「要／不要」；先把你願意承擔的代價說清楚，答案會比硬問吉凶更實際。',
        'This is not a clean yes/no decision. Clarify the trade-off first, then choose the path whose cost you can actually accept.'
      );
    }

    if (profile.intent === 'binary') {
      if (score >= .35) return tarotText('整体偏向“可以／有机会”，但属于有条件成立，不是百分之百保证。','整體偏向「可以／有機會」，但屬於有條件成立，不是百分之百保證。','The spread leans yes, but conditionally rather than absolutely.');
      if (score <= -.35) return tarotText('目前偏向“不容易／还不是时候”，主要阻力仍然存在。','目前偏向「不容易／還不是時候」，主要阻力仍然存在。','The spread currently leans no / not yet, with meaningful resistance still present.');
      return tarotText('牌面不足以干脆回答“是”或“否”；真正决定结果的是接下来条件有没有改变。','牌面不足以乾脆回答「是」或「否」；真正決定結果的是接下來條件有沒有改變。','The spread is too mixed for a clean yes/no; the conditions matter more than the binary verdict.');
    }

    if (profile.intent === 'development') {
      if (score >= .28) return tarotText('后续走势偏正向，但需要持续投入，不能把目前的好讯号直接当成结果已经确定。','後續走勢偏正向，但需要持續投入，不能把目前的好訊號直接當成結果已經確定。','The direction is constructive, but the spread still asks for steady follow-through rather than assuming the outcome is secured.');
      if (score <= -.28) return tarotText('短期走势比较颠簸；如果互动或做法不调整，事情比较容易停住、延迟或拉开距离。','短期走勢比較顛簸；如果互動或做法不調整，事情比較容易停住、延遲或拉開距離。','The near-term development is bumpy; without adjustment, the current pattern is more likely to stall or create distance.');
      return tarotText('后续仍是开放局面；有机会，也有需要修正的地方，下一步怎么做会明显影响结果。','後續仍是開放局面；有機會，也有需要修正的地方，下一步怎麼做會明顯影響結果。','The development is still open. The later cards show both opportunity and correction, so the outcome depends heavily on what happens next.');
    }

    if (profile.intent === 'advice') {
      const guide = draw.find(item => ['advice','direction','guidance'].includes(item.position?.key)) || draw[draw.length - 1];
      const themes = keyThemes([guide],2).join(lang === 'en' ? ', ' : '、');
      return tarotText(
        `如果只抓一个重点，「${cardName(guide.card)}・${orientationText(guide.reversed)}」把课题放在「${themes || '你接下来的回应方式'}」：${guide?.meaning?.advice || '先看清楚最明显的卡点，再决定怎么回应。'}`,
        `如果只抓一個重點，「${cardName(guide.card)}・${orientationText(guide.reversed)}」把課題放在「${themes || '你接下來的回應方式'}」：${guide?.meaning?.advice || '先看清楚最明顯的卡點，再決定怎麼回應。'}`,
        `${cardName(guide.card)} (${orientationText(guide.reversed)}) puts the lesson on ${themes || 'the way you respond next'}: ${guide?.meaning?.advice || 'work with the clearest issue before adding more pressure.'}`
      );
    }

    if (band.includes('supportive')) return tarotText(
      `整体倾向偏正向${themeText ? `，关键在「${themeText}」` : ''}。`,
      `整體傾向偏正向${themeText ? `，關鍵在「${themeText}」` : ''}。`,
      `The spread leans constructive.${themeText ? ` The key themes are ${themeText}.` : ''}`
    );
    if (band.includes('challenging')) return tarotText(
      `目前阻力比顺势更明显${themeText ? `，尤其要留意「${themeText}」` : ''}。`,
      `目前阻力比順勢更明顯${themeText ? `，尤其要留意「${themeText}」` : ''}。`,
      `The spread highlights meaningful resistance.${themeText ? ` Watch ${themeText}.` : ''}`
    );
    return tarotText('目前讯号偏混合，先保留弹性；真正答案要看接下来实际发展。','目前訊號偏混合，先保留彈性；真正答案要看接下來實際發展。','The message is mixed, so keep the situation open and judge it by what actually develops next.');
  }
  function tarotText(cn, tw, en) {
    const lang = currentLanguage();
    return lang === 'en' ? en : (lang === 'zh-TW' ? tw : cn);
  }

  function guidanceItem(draw) {
    return (draw || []).find(item => ['advice','direction','guidance'].includes(item?.position?.key))
      || draw?.[draw.length - 1];
  }

  function challengeItem(draw) {
    return (draw || []).reduce((worst, item) => {
      if (!worst) return item;
      return cardTone(item) < cardTone(worst) ? item : worst;
    }, null);
  }

  function teachingCaution(profile = analyseQuestion()) {
    const map = {
      feelings: {
        'zh-CN':'这里最容易误会的是：有感觉，不等于愿意承担一段关系。真正能把感情坐实的，是持续、投入和清楚表达。',
        'zh-TW':'這裡最容易誤會的是：有感覺，不等於願意承擔一段關係。真正能把感情坐實的，是持續、投入和清楚表達。',
        en:'The common mistake is treating feelings as commitment. Reliable interest shows up through consistency, effort and clarity.'
      },
      action: {
        'zh-CN':'这里要分清楚三件事：想法、冲动和行动不是同一层级；一次联系，也不等于持续主动。',
        'zh-TW':'這裡要分清楚三件事：想法、衝動和行動不是同一層級；一次聯絡，也不等於持續主動。',
        en:'Separate thought, impulse and action. One message is not the same as sustained initiative.'
      },
      reason: {
        'zh-CN':'原因题最怕把一张牌当成“唯一真相”。牌更适合指出压力结构，你仍要用现实行为去验证。',
        'zh-TW':'原因題最怕把一張牌當成「唯一真相」。牌更適合指出壓力結構，你仍要用現實行為去驗證。',
        en:'Cause questions become misleading when one card is treated as the only truth. Use the spread as a pressure map, then verify it with behavior.'
      },
      reconcile: {
        'zh-CN':'还有感情，不等于适合复合；复合真正要看的，是旧问题能不能被用新的方式处理。',
        'zh-TW':'還有感情，不等於適合復合；復合真正要看的，是舊問題能不能被用新的方式處理。',
        en:'Remaining feelings do not automatically make reconciliation healthy. The key is whether the old problem can be handled differently.'
      },
      timing: {
        'zh-CN':'时间题不要把牌硬换算成日期。更可靠的读法，是先找出“条件成熟时会出现什么讯号”。',
        'zh-TW':'時間題不要把牌硬換算成日期。更可靠的讀法，是先找出「條件成熟時會出現什麼訊號」。',
        en:'Do not force timing cards into a date. A better reading asks what signs will appear when the conditions are ready.'
      },
      decision: {
        'zh-CN':'好牌不代表零成本，逆位也不等于绝对不能做。决定题要把收益、代价和自己能承受的最坏情况一起看。',
        'zh-TW':'好牌不代表零成本，逆位也不等於絕對不能做。決定題要把收益、代價和自己能承受的最壞情況一起看。',
        en:'A supportive card does not mean zero cost, and a reversal does not mean “never.” Include benefit, cost and the worst case you can carry.'
      },
      binary: {
        'zh-CN':'是非题真正有用的地方，不是替你盖章，而是看“什么条件下更像会、什么条件下更像不会”。',
        'zh-TW':'是非題真正有用的地方，不是替你蓋章，而是看「什麼條件下更像會、什麼條件下更像不會」。',
        en:'A yes/no spread is most useful when it shows the conditions that make “yes” more or less likely, rather than stamping a verdict.'
      },
      development: {
        'zh-CN':'走势是趋势，不是命定。后续牌告诉你的，是当前模式继续下去会走向哪里，以及哪里还有修正空间。',
        'zh-TW':'走勢是趨勢，不是命定。後續牌告訴你的，是目前模式繼續下去會走向哪裡，以及哪裡還有修正空間。',
        en:'A trend is not fate. Later cards show where the current pattern leads and where there is still room to change it.'
      },
      advice: {
        'zh-CN':'建议牌不是命令，而是一种练习方向。好的建议应该能放进现实，而不是让你为了“照牌做”忽略自己的界线。',
        'zh-TW':'建議牌不是命令，而是一種練習方向。好的建議應該能放進現實，而不是讓你為了「照牌做」忽略自己的界線。',
        en:'Advice cards are practice directions, not commands. A useful suggestion should fit real life without asking you to ignore your boundaries.'
      },
      choice: {
        'zh-CN':'二选一不是找“完美答案”，而是比较两条路各自会要求你付出什么、得到什么。',
        'zh-TW':'二選一不是找「完美答案」，而是比較兩條路各自會要求你付出什麼、得到什麼。',
        en:'A two-path reading is not about finding a perfect answer; it compares what each path asks you to give and what it may return.'
      }
    };
    if (map[profile.intent]) return localized(map[profile.intent]);
    if (profile.topic === 'love') return tarotText(
      '感情牌最值得学的是：把“感受”和“关系事实”分开看，前者可以很强，后者仍要靠双方行动建立。',
      '感情牌最值得學的是：把「感受」和「關係事實」分開看，前者可以很強，後者仍要靠雙方行動建立。',
      'In relationship readings, separate emotional intensity from relationship facts; feelings can be strong while the bond still needs mutual action.'
    );
    if (profile.topic === 'money') return tarotText(
      '财务牌要把象征落回数字：现金流、风险、期限与资源，至少要有一项能被具体检查。',
      '財務牌要把象徵落回數字：現金流、風險、期限與資源，至少要有一項能被具體檢查。',
      'Money readings should come back to numbers: cash flow, risk, timing and resources should be checked concretely.'
    );
    return tarotText(
      '把牌当成整理局势的方法，而不是拿来取代事实、界线与你的判断。',
      '把牌當成整理局勢的方法，而不是拿來取代事實、界線與你的判斷。',
      'Treat the cards as a way to organize the situation, not as a replacement for facts, boundaries or judgment.'
    );
  }

  function realityCheckpoint(profile = analyseQuestion(), draw = state.currentDraw) {
    const guide = guidanceItem(draw);
    const lang = currentLanguage();
    const guideThemes = keyThemes([guide],2).join(lang === 'en' ? ', ' : '、');
    const map = {
      feelings: {
        'zh-CN':'接下来不要只看他说了什么，观察三件事：会不会主动靠近、愿不愿意稳定投入时间、遇到关键问题时会不会说清楚。',
        'zh-TW':'接下來不要只看他說了什麼，觀察三件事：會不會主動靠近、願不願意穩定投入時間、遇到關鍵問題時會不會說清楚。',
        en:'Watch three things next: initiative, consistent time investment, and whether important issues are addressed clearly.'
      },
      action: {
        'zh-CN':'真正的验证标准是“连续性”：不是有没有一次动作，而是之后是否还有第二次、第三次，并且前后态度一致。',
        'zh-TW':'真正的驗證標準是「連續性」：不是有沒有一次動作，而是之後是否還有第二次、第三次，並且前後態度一致。',
        en:'Use continuity as the test: not whether one action happens, but whether it repeats and stays consistent.'
      },
      reason: {
        'zh-CN':'如果后续行为持续呈现牌面指出的卡点，这个解释才更有参考价值；如果现实不吻合，就要允许自己修正判断。',
        'zh-TW':'如果後續行為持續呈現牌面指出的卡點，這個解釋才更有參考價值；如果現實不吻合，就要允許自己修正判斷。',
        en:'If later behavior repeatedly matches the blockage shown here, the interpretation gains weight. If reality does not match, revise it.'
      },
      reconcile: {
        'zh-CN':'先看旧矛盾有没有出现新的处理方式；只有“重新联系”却没有“新的相处方法”，还不算真正进入复合条件。',
        'zh-TW':'先看舊矛盾有沒有出現新的處理方式；只有「重新聯絡」卻沒有「新的相處方法」，還不算真正進入復合條件。',
        en:'Look for a new way of handling the old conflict. Reconnection without a changed pattern is not yet a mature reconciliation condition.'
      },
      timing: {
        'zh-CN':'把后段牌的关键词当成时间讯号；当这些条件开始在现实里出现，才代表时机真的在靠近。',
        'zh-TW':'把後段牌的關鍵詞當成時間訊號；當這些條件開始在現實裡出現，才代表時機真的在靠近。',
        en:'Use the later-card themes as timing signals. When those conditions begin to appear in real life, the timing is genuinely getting closer.'
      },
      decision: {
        'zh-CN':'做决定前写下三个标准：你最想得到什么、最不能失去什么、最坏情况能不能承受。牌面应该帮助你比较，而不是替你承担后果。',
        'zh-TW':'做決定前寫下三個標準：你最想得到什麼、最不能失去什麼、最壞情況能不能承受。牌面應該幫助你比較，而不是替你承擔後果。',
        en:'Before deciding, write down three criteria: what you most want, what you cannot afford to lose, and whether you can carry the worst case.'
      },
      binary: {
        'zh-CN':'把“会不会”改成两个观察题：什么条件正在支持它发生？什么阻力仍在阻止它发生？这样答案会比单纯押是或否更有用。',
        'zh-TW':'把「會不會」改成兩個觀察題：什麼條件正在支持它發生？什麼阻力仍在阻止它發生？這樣答案會比單純押是或否更有用。',
        en:'Turn “will it?” into two checks: what supports it happening, and what still blocks it? That is more useful than betting on yes or no.'
      },
      development: {
        'zh-CN':'后续若持续出现与后段牌相同的讯号，就说明趋势在成形；如果关键条件改变，结果也应重新评估。',
        'zh-TW':'後續若持續出現與後段牌相同的訊號，就說明趨勢在成形；如果關鍵條件改變，結果也應重新評估。',
        en:'If later events repeat the themes of the later cards, the trend is forming. If key conditions change, reassess the outcome.'
      }
    };
    if (map[profile.intent]) return localized(map[profile.intent]);
    return tarotText(
      `把“${guideThemes || cardName(guide.card)}”当成检查点：接下来找一个现实中的行为或条件，确认这个主题是不是真的出现。`,
      `把「${guideThemes || cardName(guide.card)}」當成檢查點：接下來找一個現實中的行為或條件，確認這個主題是不是真的出現。`,
      `Use “${guideThemes || cardName(guide.card)}” as the checkpoint: look for one real-world behavior or condition that proves this theme is actually present.`
    );
  }

  function topicPractice(item) {
    if (!item) return '';
    const base = item?.meaning?.advice || '';
    if (item.card?.arcana === 'major') {
      return base + tarotText(
        ' 这是一张大阿尔克那，所以更适合把它当成一段时间要练习的原则，而不是只做一次的小技巧。',
        ' 這是一張大阿爾克那，所以更適合把它當成一段時間要練習的原則，而不是只做一次的小技巧。',
        ' Because this is Major Arcana, treat it as a principle to practice rather than a one-off trick.'
      );
    }
    const lenses = {
      cups: tarotText('练习把感受说清楚，也分辨“我希望如此”和“现实真的如此”。','練習把感受說清楚，也分辨「我希望如此」和「現實真的如此」。','Practice naming feelings clearly while separating what you hope is true from what is actually happening.'),
      wands: tarotText('把热度转成有节奏的行动；能持续的小步，比一时很用力更有价值。','把熱度轉成有節奏的行動；能持續的小步，比一時很用力更有價值。','Turn energy into paced action. A repeatable small step is more useful than one burst of force.'),
      swords: tarotText('先厘清事实、界线和真正需要说的话；不要让反复猜测代替沟通与判断。','先釐清事實、界線和真正需要說的話；不要讓反覆猜測代替溝通與判斷。','Clarify facts, boundaries and what truly needs to be said; do not let repeated guessing replace communication and judgment.'),
      pentacles: tarotText('回到可衡量的现实：时间、资源、投入、承诺与稳定度，至少抓一项具体检查。','回到可衡量的現實：時間、資源、投入、承諾與穩定度，至少抓一項具體檢查。','Return to measurable reality: time, resources, effort, commitment and stability. Check at least one concretely.')
    };
    return [base,lenses[item.card?.suit] || ''].filter(Boolean).join(' ');
  }

  function buildStoryBase(draw, analysis, profile = analyseQuestion()) {
    const lang = currentLanguage();
    const spread = selectedSpread();

    if (spread.key === 'single') {
      const item = draw[0];
      const themes = keyThemes([item],2).join(lang === 'en' ? ', ' : '、');
      return tarotText(
        `${state.question ? `放回你问的“${state.question}”，` : ''}先看牌本身：“${cardName(item.card)}・${orientationText(item.reversed)}”把重点放在“${themes || '目前最核心的课题'}”。${item.meaning.meaning} 这里要学会的一件事是：单张牌不是判决书，它更像一盏灯，照出你现在最需要看清楚的模式。`,
        `${state.question ? `放回你問的「${state.question}」，` : ''}先看牌本身：「${cardName(item.card)}・${orientationText(item.reversed)}」把重點放在「${themes || '目前最核心的課題'}」。${item.meaning.meaning} 這裡要學會的一件事是：單張牌不是判決書，它更像一盞燈，照出你現在最需要看清楚的模式。`,
        `Start with the card itself: ${cardName(item.card)} (${orientationText(item.reversed)}) speaks about ${themes || 'the core issue'}. ${item.meaning.meaning} The teaching point is not to turn one card into a verdict; use it to identify the pattern that deserves attention.`
      );
    }

    if (spread.key === 'relationship5') {
      const [self, other, core, obstacle, direction] = draw;
      const counterpart = counterpartLabel();
      const selfTheme = keyThemes([self],2).join(lang === 'en' ? ', ' : '、');
      const otherTheme = keyThemes([other],2).join(lang === 'en' ? ', ' : '、');
      const coreTheme = keyThemes([core],2).join(lang === 'en' ? ', ' : '、');
      const obstacleTheme = keyThemes([obstacle],2).join(lang === 'en' ? ', ' : '、');
      const directionTheme = keyThemes([direction],2).join(lang === 'en' ? ', ' : '、');
      return tarotText(
        `${state.question ? `针对你问的“${state.question}”，` : ''}这个牌阵要分三层读。第一层是“你”和“${counterpart}”各自的状态：你这一侧偏向“${selfTheme || cardName(self.card)}”，${counterpart}则偏向“${otherTheme || cardName(other.card)}”；这两张牌都不能单独当成“关系答案”。第二层看互动核心“${coreTheme || cardName(core.card)}”，它才是在说两边碰在一起后形成了什么。第三层再看阻碍“${obstacleTheme || cardName(obstacle.card)}”与方向“${directionTheme || cardName(direction.card)}”——前者告诉你卡在哪里，后者告诉你要用什么方式才有机会改变模式。所以这组牌真正教你的，是把“个人感受、两人互动、现实行为”分开看。`,
        `${state.question ? `針對你問的「${state.question}」，` : ''}這個牌陣要分三層讀。第一層是「你」和「${counterpart}」各自的狀態：你這一側偏向「${selfTheme || cardName(self.card)}」，${counterpart}則偏向「${otherTheme || cardName(other.card)}」；這兩張牌都不能單獨當成「關係答案」。第二層看互動核心「${coreTheme || cardName(core.card)}」，它才是在說兩邊碰在一起後形成了什麼。第三層再看阻礙「${obstacleTheme || cardName(obstacle.card)}」與方向「${directionTheme || cardName(direction.card)}」——前者告訴你卡在哪裡，後者告訴你要用什麼方式才有機會改變模式。所以這組牌真正教你的，是把「個人感受、兩人互動、現實行為」分開看。`,
        `Read this spread in three layers. Your side (${cardName(self.card)}) and ${counterpart} (${cardName(other.card)}) are two different states; neither alone equals “the relationship.” ${cardName(core.card)} shows what is actually being created between the two sides. ${cardName(obstacle.card)} shows where it gets stuck, while ${cardName(direction.card)} shows the skill or direction that can change the pattern. Keep personal feeling, shared dynamic and real-world behavior separate.`
      );
    }

    if (spread.key === 'choice5') {
      const [current, a, aOut, b, bOut] = draw;
      const A = state.optionA || ui('optionA');
      const B = state.optionB || ui('optionB');
      return tarotText(
        `二选一最容易犯的错，是先找哪一边的牌“比较漂亮”。其实“${cardName(current.card)}”先说明了你是站在什么状态做选择；A“${A}”从“${cardName(a.card)}”走向“${cardName(aOut.card)}”，B“${B}”则从“${cardName(b.card)}”走向“${cardName(bOut.card)}”。真正要比较的不是哪条路完全没阻力，而是：哪条路要求你的代价你承受得起、哪个结果更符合你的优先顺序。`,
        `二選一最容易犯的錯，是先找哪一邊的牌「比較漂亮」。其實「${cardName(current.card)}」先說明了你是站在什麼狀態做選擇；A「${A}」從「${cardName(a.card)}」走向「${cardName(aOut.card)}」，B「${B}」則從「${cardName(b.card)}」走向「${cardName(bOut.card)}」。真正要比較的不是哪條路完全沒阻力，而是：哪條路要求你的代價你承受得起、哪個結果更符合你的優先順序。`,
        `Do not start by asking which path has the “prettier” cards. ${cardName(current.card)} describes the state from which you are choosing. Path A (${A}) begins with ${cardName(a.card)} and develops toward ${cardName(aOut.card)}; Path B (${B}) begins with ${cardName(b.card)} and develops toward ${cardName(bOut.card)}. Compare what each route asks from you, what friction it contains, and whether its outcome matches your priorities.`
      );
    }

    const parts = draw.map(itemShort);
    const firstThemes = keyThemes(draw.slice(0,Math.ceil(draw.length/2)),2).join(lang === 'en' ? ', ' : '、');
    const lastThemes = keyThemes(draw.slice(Math.floor(draw.length/2)),2).join(lang === 'en' ? ', ' : '、');
    const flow = analysis.orientationFlow === 'clearing'
      ? tarotText('后段比前段更松，表示这不是一路卡到底，而是有“先难、后面逐渐打开”的可能。','後段比前段更鬆，表示這不是一路卡到底，而是有「先難、後面逐漸打開」的可能。','The later positions become more open, so the spread reads like a difficult beginning that can loosen with adjustment.')
      : analysis.orientationFlow === 'tightening'
        ? tarotText('后段阻力增加，所以前面就算顺，也不能太早把它当成结果已经稳了。','後段阻力增加，所以前面就算順，也不能太早把它當成結果已經穩了。','The later positions carry more resistance, so early ease should not be mistaken for a secured outcome.')
        : tarotText('前后讯号交错，代表事情不同部分的速度不一样，不能只挑最好或最坏的一张来下结论。','前後訊號交錯，代表事情不同部分的速度不一樣，不能只挑最好或最壞的一張來下結論。','The flow is mixed, which means different parts of the situation are moving at different speeds.');

    return tarotText(
      `${state.question ? `放回你问的“${state.question}”，` : ''}先不要急着逐张下结论，先看整条发展线：${parts.join(' → ')}。前半段主要在说“${firstThemes || '目前怎么形成'}”，后半段则把问题推向“${lastThemes || '接下来怎么调整'}”。${flow} 这也是为什么同一张牌放在“现在”和放在“结果／建议”位置，意思会不一样；牌位是在教你看因果与顺序。`,
      `${state.question ? `放回你問的「${state.question}」，` : ''}先不要急著逐張下結論，先看整條發展線：${parts.join(' → ')}。前半段主要在說「${firstThemes || '目前怎麼形成'}」，後半段則把問題推向「${lastThemes || '接下來怎麼調整'}」。${flow} 這也是為什麼同一張牌放在「現在」和放在「結果／建議」位置，意思會不一樣；牌位是在教你看因果與順序。`,
      `Read the spread as a lesson in sequence: ${parts.join(' → ')}. The first half is mostly about ${firstThemes || 'the current condition'}, while the later half shifts toward ${lastThemes || 'what needs to happen next'}. ${flow} This is why the answer comes from the relationship between positions, not from any single card.`
    );
  }

  function buildStructure(a, profile = analyseQuestion(), draw = state.currentDraw) {
    const lang = currentLanguage();
    const notes = [];
    const t = (cn, tw, en) => lang === 'en' ? en : (lang === 'zh-TW' ? tw : cn);

    if (a.majorCount >= Math.ceil(a.total * 0.5)) {
      notes.push(t(
        '大阿尔克那占比偏高，这组牌更像在谈一个有分量的转折、选择或长期课题。',
        '大阿爾克那占比偏高，這組牌更像在談一個有份量的轉折、選擇或長期課題。',
        'Major Arcana are prominent, pointing to a meaningful turning point, choice or longer-term lesson.'
      ));
    } else if (a.majorCount > 0) {
      notes.push(t(
        '牌面有大阿尔克那介入，但现实中的日常选择与具体做法仍然很重要。',
        '牌面有大阿爾克那介入，但現實中的日常選擇與具體做法仍然很重要。',
        'Major Arcana are present, but practical day-to-day choices still matter strongly.'
      ));
    } else {
      notes.push(t(
        '没有大牌主导，事情比较偏向可以透过沟通、习惯与具体选择去调整。',
        '沒有大牌主導，事情比較偏向可以透過溝通、習慣與具體選擇去調整。',
        'No Major Arcana dominate; concrete choices, habits and communication remain highly adjustable.'
      ));
    }

    if (a.reversedCount === 0) {
      notes.push(t('全数正位，整体能量表达直接。','全數正位，整體能量表達直接。','All cards are upright, giving the spread relatively direct momentum.'));
    } else if (a.reversedCount > a.total / 2) {
      notes.push(t(
        '逆位过半，比起急着推进，更需要先处理延迟、内在阻力、过度反应或尚未完成的问题。',
        '逆位過半，比起急著推進，更需要先處理延遲、內在阻力、過度反應或尚未完成的問題。',
        'Reversed cards are the majority; address delays, resistance, overcorrection or unfinished issues before pushing harder.'
      ));
    } else {
      notes.push(t(
        '正逆位交错，表示事情可以推进，但不同环节的速度并不一致。',
        '正逆位交錯，表示事情可以推進，但不同環節的速度並不一致。',
        'Upright and reversed cards are mixed, so progress is possible but different parts move at different speeds.'
      ));
    }

    if (a.orientationFlow === 'clearing' && a.total >= 3) {
      notes.push(t(
        '从前段到后段，逆位比例下降，牌面有「先卡、后松」的趋势。',
        '從前段到後段，逆位比例下降，牌面有「先卡、後鬆」的趨勢。',
        'Reversals decrease toward the later positions, suggesting a blocked beginning that gradually clears.'
      ));
    } else if (a.orientationFlow === 'tightening' && a.total >= 3) {
      notes.push(t(
        '后段逆位增加，表示越往后越需要谨慎处理细节，不适合只靠前期顺势一路推进。',
        '後段逆位增加，表示越往後越需要謹慎處理細節，不適合只靠前期順勢一路推進。',
        'Reversals increase later in the spread, so details and resistance become more important as the situation develops.'
      ));
    }

    if (a.dominantSuits.length) {
      const suitNames = a.dominantSuits.map(s => localized(suitMeta[s].names)).join('、');
      const elements = a.dominantSuits.map(s => localized(suitMeta[s].elementNames)).join('、');
      notes.push(t(
        `${suitNames}重复出现，整组解读明显向「${elements}元素」及其对应议题集中。`,
        `${suitNames}重複出現，整組解讀明顯向「${elements}元素」及其對應議題集中。`,
        `${suitNames} repeats, concentrating the reading around the ${elements} element and its related themes.`
      ));
    }

    if (a.courtCount >= 2) {
      notes.push(t(
        `宫廷牌出现 ${a.courtCount} 张，人际互动、角色立场或「谁在以什么方式行动」会比抽象情绪更重要。`,
        `宮廷牌出現 ${a.courtCount} 張，人際互動、角色立場或「誰在以什麼方式行動」會比抽象情緒更重要。`,
        `${a.courtCount} court cards appear, increasing the importance of people, roles and how each person acts.`
      ));
    }

    if (a.aceCount >= 2) {
      notes.push(t(
        `出现 ${a.aceCount} 张 Ace，新机会、新起点或尚在萌芽的可能性被明显放大。`,
        `出現 ${a.aceCount} 張 Ace，新機會、新起點或尚在萌芽的可能性被明顯放大。`,
        `${a.aceCount} Aces amplify new opportunities, beginnings or potential that is still taking shape.`
      ));
    }

    if (a.tenCount >= 2) {
      notes.push(t(
        `出现 ${a.tenCount} 张十号牌，某个阶段接近完成、结算或需要决定是否进入下一轮。`,
        `出現 ${a.tenCount} 張十號牌，某個階段接近完成、結算或需要決定是否進入下一輪。`,
        `${a.tenCount} Tens emphasize completion, culmination or a decision about what comes after this cycle.`
      ));
    }

    a.repeatedRanks.forEach(r => {
      notes.push(t(
        `数字「${numberLabel(r.rank)}」重复 ${r.count} 次，同一种成长阶段正在不同领域重复出现。`,
        `數字「${numberLabel(r.rank)}」重複 ${r.count} 次，同一種成長階段正在不同領域重複出現。`,
        `The number ${r.rank} repeats ${r.count} times, echoing the same developmental stage across different areas.`
      ));
    });

    a.sequences.forEach(seq => {
      const label = seq.map(numberLabel).join(' → ');
      notes.push(t(
        `出现连续数字 ${label}，牌面带有明显的阶段推进感。`,
        `出現連續數字 ${label}，牌面帶有明顯的階段推進感。`,
        `A consecutive number sequence (${label}) adds a clear sense of progression.`
      ));
    });

    if (a.majorRuns.length) {
      notes.push(t(
        '相邻位置连续出现大阿尔克那，表示这些阶段彼此紧密相连，不适合完全拆开解释。',
        '相鄰位置連續出現大阿爾克那，表示這些階段彼此緊密相連，不適合完全拆開解釋。',
        'Adjacent Major Arcana form a run, linking those positions into one larger turning point rather than separate events.'
      ));
    }

    if (a.missingElements.length >= 2 && a.total >= 5) {
      const missing = a.missingElements.map(elementName).join('、');
      notes.push(t(
        `小阿尔克那的元素分布不平均，${missing}能量没有出现；这通常提醒你检查自己是否忽略了对应的思考方式或行动资源。`,
        `小阿爾克那的元素分布不平均，${missing}能量沒有出現；這通常提醒你檢查自己是否忽略了對應的思考方式或行動資源。`,
        `The elemental mix is uneven and ${missing} is absent among the Minor Arcana. Check whether a corresponding resource or way of responding is being overlooked.`
      ));
    }

    const lesson = teachingCaution(profile);
    if (lesson) {
      notes.push((lang === 'en' ? 'Reading lesson: ' : (lang === 'zh-TW' ? '讀牌提醒：' : '读牌提醒：')) + lesson);
    }

    return notes.join('\n\n');
  }

  function choiceBranchText(items, label) {
    const lang = currentLanguage();
    const reversed = items.filter(x => x.reversed).length;
    const majors = items.filter(x => x.card.arcana === 'major').length;
    const outcome = items[items.length - 1];

    if (lang === 'en') {
      const pace = reversed === 0
        ? 'currently reads as the more direct path'
        : reversed === items.length
          ? 'currently carries more friction or unfinished conditions'
          : 'contains both momentum and points that need adjustment';
      const weight = majors ? ` It also contains ${majors} Major Arcana signal${majors > 1 ? 's' : ''}, giving this path extra long-term weight.` : '';
      return `${label} ${pace}; its outcome card is ${cardName(outcome.card)} (${orientationText(outcome.reversed)}).${weight}`;
    }

    const trad = lang === 'zh-TW';
    const pace = reversed === 0
      ? (trad ? '目前看起來較直接、阻力較少' : '目前看起来较直接、阻力较少')
      : reversed === items.length
        ? (trad ? '目前帶著較多阻力、延遲或尚未完成的條件' : '目前带着较多阻力、延迟或尚未完成的条件')
        : (trad ? '同時有推進力與需要修正的地方' : '同时有推进力与需要修正的地方');
    const weight = majors
      ? `${trad ? '這條路另外出現' : '这条路另外出现'} ${majors} ${trad ? '張大牌，代表它對長期方向的影響較有份量。' : '张大牌，代表它对长期方向的影响较有分量。'}`
      : '';
    return `${label}${pace}；${trad ? '結果位' : '结果位'}是「${cardName(outcome.card)}・${orientationText(outcome.reversed)}」。${weight}`;
  }

  function questionFraming() {
    const q = state.question;
    const lang = currentLanguage();
    if (!q) return '';

    const isTiming = /(什么时候|什麼時候|何时|多久|幾時|何時|when|how long)/i.test(q);
    const isBinary = /(会不会|能不能|是不是|是否|會不會|能不能|是不是|是否|will it|should i|yes or no)/i.test(q);

    if (isTiming) {
      return lang === 'en'
        ? ' Because your question asks about timing, treat the cards as showing readiness and sequence rather than a guaranteed calendar date.'
        : (lang === 'zh-TW'
            ? ' 你的問題包含時間性，這組牌比較適合看「何時具備條件、事情如何推進」，不把牌面當成保證發生的固定日期。'
            : ' 你的问题包含时间性，这组牌比较适合看「何时具备条件、事情如何推进」，不把牌面当成保证发生的固定日期。');
    }

    if (isBinary) {
      return lang === 'en'
        ? ' Because your question is close to yes/no, use the spread to understand conditions and consequences rather than forcing the cards into a binary verdict.'
        : (lang === 'zh-TW'
            ? ' 你的問題接近「是／否」，這組牌更適合拿來看成立條件、阻力與後果，而不是硬把牌壓成單一二元答案。'
            : ' 你的问题接近「是／否」，这组牌更适合拿来看成立条件、阻力与后果，而不是硬把牌压成单一二元答案。');
    }
    return '';
  }

  function buildFinalAdviceBase(draw, analysis, profile = analyseQuestion()) {
    const lang = currentLanguage();
    const spread = selectedSpread();
    const topic = localized(selectedTopic().name);
    const qPrefix = state.question
      ? tarotText(`针对你问的“${state.question}”，`,`針對你問的「${state.question}」，`,`For “${state.question}”, `)
      : tarotText(`针对“${topic}”，`,`針對「${topic}」，`,`For ${topic}, `);

    const guide = guidanceItem(draw);
    const blocker = challengeItem(draw);
    const caution = teachingCaution(profile);
    const checkpoint = realityCheckpoint(profile,draw);

    if (spread.key === 'choice5') {
      const A = state.optionA || ui('optionA');
      const B = state.optionB || ui('optionB');
      const aScore = branchTendency([draw[1],draw[2]]);
      const bScore = branchTendency([draw[3],draw[4]]);
      const close = Math.abs(aScore - bScore) < 0.18;
      const better = aScore > bScore ? A : B;
      const first = close
        ? tarotText(
            `${qPrefix}两条路的差距没有大到可以直接替你做决定；这组牌更像在要求你比较代价，而不是找一个“完美答案”。`,
            `${qPrefix}兩條路的差距沒有大到可以直接替你做決定；這組牌更像在要求你比較代價，而不是找一個「完美答案」。`,
            `${qPrefix}the two paths are close enough that the cards are asking you to compare trade-offs, not chase a winner.`)
        : tarotText(
            `${qPrefix}目前较顺的路线是“${better}”，但“较顺”不等于“没有代价”；你仍要确认它是不是你真正想承担的方向。`,
            `${qPrefix}目前較順的路線是「${better}」，但「較順」不等於「沒有代價」；你仍要確認它是不是你真正想承擔的方向。`,
            `${qPrefix}${better} currently reads as the smoother route, but “smoother” is not the same as “cost-free.”`);
      const homework = tarotText(
        '把它当成一份作业：分别写下 A、B 会得到什么、失去什么，以及半年后你比较能接受哪一种代价。',
        '把它當成一份作業：分別寫下 A、B 會得到什麼、失去什麼，以及半年後你比較能接受哪一種代價。',
        'Use this as homework: write down what each path gives you, what it asks you to sacrifice, and which cost you can live with six months from now.'
      );
      return [first,`${homework} ${checkpoint}`].filter(Boolean).join('\n\n');
    }

    if (spread.key === 'relationship5') {
      const obstacle = draw.find(x => x.position?.key === 'obstacle') || blocker;
      const direction = draw.find(x => x.position?.key === 'direction') || guide;
      const first = tarotText(
        `${qPrefix}先不要急着追结果；这组牌要你先处理“${cardName(obstacle.card)}・${orientationText(obstacle.reversed)}”代表的卡点，再去练习“${cardName(direction.card)}・${orientationText(direction.reversed)}”带来的方向。换句话说，阻碍牌是在教你“问题在哪”，方向牌是在教你“新的做法是什么”。`,
        `${qPrefix}先不要急著追結果；這組牌要你先處理「${cardName(obstacle.card)}・${orientationText(obstacle.reversed)}」代表的卡點，再去練習「${cardName(direction.card)}・${orientationText(direction.reversed)}」帶來的方向。換句話說，阻礙牌是在教你「問題在哪」，方向牌是在教你「新的做法是什麼」。`,
        `${qPrefix}the spread asks you to work with ${cardName(obstacle.card)} before expecting the relationship to behave like ${cardName(direction.card)}. The obstacle is the lesson, and the direction card is the skill to practice.`
      );
      return [first,`${topicPractice(direction)} ${checkpoint}`].filter(Boolean).join('\n\n') + questionFraming();
    }

    const guideLead = tarotText(
      `${qPrefix}真正适合带回生活练习的，是“${cardName(guide.card)}・${orientationText(guide.reversed)}”。${topicPractice(guide)}`,
      `${qPrefix}真正適合帶回生活練習的，是「${cardName(guide.card)}・${orientationText(guide.reversed)}」。${topicPractice(guide)}`,
      `${qPrefix}the practical teaching card is ${cardName(guide.card)} (${orientationText(guide.reversed)}). ${topicPractice(guide)}`
    );

    const blockerText = blocker && blocker !== guide
      ? tarotText(
          `这组牌里最需要留意的是“${cardName(blocker.card)}・${orientationText(blocker.reversed)}”。它比较像你容易被绊住的地方，不是要你害怕，而是提醒你别用旧方法重复同一个问题。`,
          `這組牌裡最需要留意的是「${cardName(blocker.card)}・${orientationText(blocker.reversed)}」。它比較像你容易被絆住的地方，不是要你害怕，而是提醒你別用舊方法重複同一個問題。`,
          `The card that deserves the most caution is ${cardName(blocker.card)} (${orientationText(blocker.reversed)}); it shows where your usual pattern may trip you up.`)
      : '';

    return [guideLead,blockerText,checkpoint]
      .filter(Boolean)
      .join('\n\n') + questionFraming();
  }

  async function init() {
    renderStaticLanguage();

    try {
      const [cardsResponse, meaningsResponse, spreadsResponse] = await Promise.all([
        fetch('../data/tarot/cards.json', { cache: 'no-store' }),
        fetch('../data/tarot/meanings.json', { cache: 'no-store' }),
        fetch('../data/tarot/spreads.json', { cache: 'no-store' })
      ]);

      if (!cardsResponse.ok || !meaningsResponse.ok || !spreadsResponse.ok) {
        throw new Error('Tarot data load failed');
      }

      const cardsPayload = await cardsResponse.json();
      const meaningsPayload = await meaningsResponse.json();
      const spreadsPayload = await spreadsResponse.json();

      state.cards = cardsPayload.cards;
      state.meanings = new Map(meaningsPayload.meanings.map(item => [item.key, item]));
      state.topics = spreadsPayload.topics;
      state.spreads = spreadsPayload.spreads;

      if (state.cards.length !== 78 || state.meanings.size !== 78) {
        throw new Error(`Tarot data incomplete: cards=${state.cards.length}, meanings=${state.meanings.size}`);
      }
      if (state.spreads.length < 5) throw new Error('V0.7 spread definitions missing');

      renderControls();
      renderTarotHistory();
      byId('drawTarotBtn').disabled = false;
    } catch (error) {
      console.error(error);
      byId('tarotLoadError').hidden = false;
    }
  }

  window.addEventListener('stellar:cloud-data-updated', event => {
    if (event.detail?.type !== 'tarot') return;
    renderTarotHistory();
  });

  document.addEventListener('DOMContentLoaded', () => {
    byId('questionInput')?.addEventListener('input', (event) => {
      byId('questionCount').textContent = String(event.target.value.length);
    });

    byId('optionAInput')?.addEventListener('input', (event) => {
      state.optionA = event.target.value.trim();
    });
    byId('optionBInput')?.addEventListener('input', (event) => {
      state.optionB = event.target.value.trim();
    });

    byId('drawTarotBtn')?.addEventListener('click', draw);
    byId('drawTarotAgainBtn')?.addEventListener('click', draw);

    byId('tarotHistoryToggle')?.addEventListener('click', () => {
      const panel = byId('tarotHistoryPanel');
      const opening = panel.hidden;
      panel.hidden = !opening;
      byId('tarotHistoryToggle').setAttribute('aria-expanded', opening ? 'true' : 'false');
      if (opening) renderTarotHistory();
    });

    byId('tarotHistoryClear')?.addEventListener('click', async () => {
      if (!window.confirm(ui('historyClearConfirm'))) return;
      writeTarotHistory([]);
      renderTarotHistory();
      if (window.XingchenCloudSync?.clearTarotCloud) {
        const result = await window.XingchenCloudSync.clearTarotCloud();
        if (!result?.ok && result?.error) console.warn('[星辰日记] 云端塔罗记录清除失败：', result.error);
      }
    });

    byId('scrollTopBtn')?.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    init();
  });
})();
