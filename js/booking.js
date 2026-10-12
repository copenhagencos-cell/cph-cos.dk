/* Online booking.
   EasyPractice mode ("mode": "easypractice" in site.json, current): Nancy's Terapeut Booking page is
   embedded, so bookings land directly in her EasyPractice calendar.
   Cal.com mode ("mode": "calcom"): step 1 (treatment) stays on this page, then Cal.com takes over.
   Demo mode runs all four steps here with example times. */
(function () {
  var cfg = CPH.booking;
  var root = document.getElementById("booking-root");

  if (cfg.mode === "easypractice" && cfg.easyPracticeUrl) {
    // EasyPractice's own script resizes the embedded booking to fit its content.
    var s = document.createElement("script");
    s.src = "https://system.easypractice.net/js/templates/onlinebook_iframe.js";
    document.head.appendChild(s);
    root.innerHTML =
      '<p class="muted center" style="margin-bottom:16px">Vælg behandling, dag og tid herunder. ' +
      'Virker bookingen ikke i din browser, så <a href="' + cfg.easyPracticeUrl + '" target="_blank" rel="noopener">åbn bookingen i et nyt vindue</a>.</p>' +
      '<iframe class="ep-frame" src="' + cfg.easyPracticeUrl + '" title="Online booking hos Copenhagen Cosmetology" loading="eager"></iframe>';
    return;
  }

  var live = cfg.mode === "calcom" && !!cfg.calLink;
  if (!live) document.getElementById("demo-banner").hidden = false;

  // ---------- Cal.com ----------
  // Cal.com has one booking type per length ("behandling-15" … "behandling-120"). A treatment uses the
  // shortest one it fits in, unless it has its own "calEvent" in site.json. The treatment name and price
  // are filled into the "behandling" field, so Nancy sees what was booked.
  var CAL_LENGTHS = [15, 30, 45, 60, 75, 90, 120];
  var calUser = String(cfg.calLink || "").replace(/^https?:\/\/(app\.)?cal\.com\//, "").replace(/\/.*$/, "");
  var calCount = 0;

  function calEventFor(svc) {
    if (svc.calEvent) return svc.calEvent;
    var len = CAL_LENGTHS.filter(function (l) { return l >= svc.duration; })[0] || CAL_LENGTHS[CAL_LENGTHS.length - 1];
    return "behandling-" + len;
  }

  function loadCalEmbed() {
    if (window.Cal) return;
    // Official Cal.com embed loader (https://cal.com/docs/embed).
    (function (C, A, L) {
      var p = function (a, ar) { a.q.push(ar); };
      var d = C.document;
      C.Cal = C.Cal || function () {
        var cal = C.Cal, ar = arguments;
        if (!cal.loaded) { cal.ns = {}; cal.q = cal.q || []; d.head.appendChild(d.createElement("script")).src = A; cal.loaded = true; }
        if (ar[0] === L) {
          var api = function () { p(api, arguments); }, namespace = ar[1];
          api.q = api.q || [];
          if (typeof namespace === "string") { cal.ns[namespace] = cal.ns[namespace] || api; p(cal.ns[namespace], ar); p(cal, ["initNamespace", namespace]); }
          else p(cal, ar);
          return;
        }
        p(cal, ar);
      };
    })(window, "https://app.cal.com/embed/embed.js", "init");
  }

  function showCal(svc) {
    loadCalEmbed();
    var el = document.getElementById("cal-inline");
    el.innerHTML = "";
    var ns = "cph" + (++calCount); // a fresh namespace per treatment, so switching treatment reloads the calendar
    Cal("init", ns, { origin: "https://cal.com" });
    Cal.ns[ns]("inline", {
      elementOrSelector: "#cal-inline",
      calLink: calUser + "/" + calEventFor(svc),
      layout: "month_view",
      config: { layout: "month_view", behandling: svc.name + " – " + CPH.formatPrice(svc.price) }
    });
    Cal.ns[ns]("ui", { theme: "light", hideEventTypeDetails: true, layout: "month_view",
      cssVarsPerTheme: { light: { "cal-brand": "#2f3b44" } } });
  }

  if (live) {
    // Step 2 shows the Cal.com calendar instead of the demo calendar; steps 3–4 happen inside Cal.com.
    var p2 = document.querySelector('[data-panel="2"]');
    p2.querySelector(".cal-cols").style.display = "none";
    document.getElementById("to-3").style.display = "none";
    p2.querySelector("[data-back]").textContent = "← Skift behandling";
    var calBox = document.createElement("div");
    calBox.id = "cal-inline";
    calBox.style.cssText = "width:100%;min-height:560px;overflow:auto";
    p2.querySelector(".cal-cols").after(calBox);
    var stepItems = document.querySelectorAll("#steps li");
    stepItems[1].textContent = "Dag, tid & dine oplysninger";
    stepItems[2].style.display = stepItems[3].style.display = "none";
  }

  var DOW = ["man", "tir", "ons", "tor", "fre", "lør", "søn"];
  var state = { service: null, date: null, time: null, step: 1, details: null };
  var bookable = CPH.services.filter(function (s) { return s.bookable !== false; });
  var cats = CPH.categories.filter(function (c) {
    return bookable.some(function (s) { return s.cat === c.id; });
  });

  // ---------- helpers ----------
  function $(id) { return document.getElementById(id); }
  function pad(n) { return (n < 10 ? "0" : "") + n; }
  function ymd(d) { return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()); }
  function toMin(hhmm) { var p = hhmm.split(":"); return +p[0] * 60 + +p[1]; }
  function fromMin(m) { return pad(Math.floor(m / 60)) + ":" + pad(m % 60); }
  function startOfDay(d) { return new Date(d.getFullYear(), d.getMonth(), d.getDate()); }
  function longDate(d) {
    return d.toLocaleDateString("da-DK", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
  }

  // Demo availability: a stable pseudo-random set of "taken" slots per day.
  function hash(str) {
    var h = 2166136261;
    for (var i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); }
    return (h >>> 0) / 4294967295;
  }
  function isTaken(dateKey, minute) {
    // Block in 30-minute chunks so neighbouring times look realistic.
    var chunk = Math.floor(minute / 30);
    return hash(dateKey + ":" + chunk) < 0.38;
  }

  function slotsFor(date, duration) {
    var hrs = CPH.hours[date.getDay()];
    if (!hrs) return [];
    var open = toMin(hrs[0]), close = toMin(hrs[1]);
    var key = ymd(date);
    var earliest = new Date(Date.now() + cfg.minHoursNotice * 3600000);
    var out = [];
    for (var m = open; m + duration <= close; m += cfg.slotStep) {
      var start = new Date(date.getFullYear(), date.getMonth(), date.getDate(), Math.floor(m / 60), m % 60);
      var free = start >= earliest;
      for (var t = m; free && t < m + duration; t += 30) if (isTaken(key, t)) free = false;
      out.push({ time: fromMin(m), free: free });
    }
    return out;
  }

  function hasFree(date) {
    if (!state.service) return false;
    return slotsFor(date, state.service.duration).some(function (s) { return s.free; });
  }

  var today = startOfDay(new Date());
  var lastDay = new Date(today); lastDay.setDate(lastDay.getDate() + cfg.daysAhead);
  var viewMonth = new Date(today.getFullYear(), today.getMonth(), 1);

  // ---------- step navigation ----------
  function go(step) {
    state.step = step;
    document.querySelectorAll("[data-panel]").forEach(function (p) {
      p.hidden = +p.getAttribute("data-panel") !== step;
    });
    document.querySelectorAll("#steps li").forEach(function (li) {
      var n = +li.getAttribute("data-step");
      li.classList.toggle("active", n === step);
      li.classList.toggle("done", n < step);
    });
    $("summary").hidden = step === 4;
    if (step === 2 && live) {
      showCal(state.service);
    } else if (step === 2) {
      if (!state.date) {
        // Open the calendar on the month of the first day with free times.
        for (var d = new Date(today); d <= lastDay; d.setDate(d.getDate() + 1)) {
          if (hasFree(d)) { viewMonth = new Date(d.getFullYear(), d.getMonth(), 1); break; }
        }
      }
      renderCalendar();
    }
    var top = $("steps").getBoundingClientRect().top + window.scrollY - 100;
    if (window.scrollY > top) window.scrollTo({ top: top, behavior: "smooth" });
  }
  document.querySelectorAll("[data-back]").forEach(function (b) {
    b.addEventListener("click", function () { go(+b.getAttribute("data-back")); });
  });

  function updateSummary() {
    var s = state.service;
    $("s-service").textContent = s ? s.name : "–";
    $("s-duration").textContent = s ? CPH.formatDuration(s.duration) : "–";
    $("s-price").textContent = s ? CPH.formatPrice(s.price) : "–";
    if (live) {
      $("s-date").textContent = $("s-time").textContent = "Vælges i kalenderen";
    } else {
      $("s-date").textContent = state.date ? longDate(state.date) : "–";
      $("s-time").textContent = state.time ? "kl. " + state.time + " – " + fromMin(toMin(state.time) + s.duration) : "–";
    }
    $("to-2").disabled = !s;
    $("to-3").disabled = !(state.date && state.time);
  }

  // ---------- step 1: treatment ----------
  var activeCat = cats[0].id;

  function renderTabs() {
    $("svc-tabs").innerHTML = cats.map(function (c) {
      return '<button class="chip' + (c.id === activeCat ? " active" : "") + '" role="tab" data-cat="' + c.id + '">' + c.name + "</button>";
    }).join("");
    $("svc-tabs").querySelectorAll("button").forEach(function (b) {
      b.addEventListener("click", function () { activeCat = b.getAttribute("data-cat"); renderTabs(); renderServices(); });
    });
  }

  function renderServices() {
    var list = bookable.filter(function (s) { return s.cat === activeCat; });
    $("svc-list").innerHTML = list.map(function (s) {
      var sel = state.service && state.service.id === s.id;
      return '<li><button class="svc' + (sel ? " selected" : "") + '" data-id="' + s.id + '" aria-pressed="' + sel + '">' +
        "<span><strong>" + s.name + "</strong><small>" + CPH.formatDuration(s.duration) + (s.group ? " · " + s.group : "") + "</small></span>" +
        '<span class="svc-price">' + CPH.formatPrice(s.price) + "</span></button></li>";
    }).join("");
    $("svc-list").querySelectorAll(".svc").forEach(function (b) {
      b.addEventListener("click", function () {
        var svc = CPH.serviceById(b.getAttribute("data-id"));
        if (!state.service || state.service.id !== svc.id) { state.time = null; }
        state.service = svc;
        renderServices();
        updateSummary();
      });
      b.addEventListener("dblclick", function () { go(2); });
    });
  }

  $("to-2").addEventListener("click", function () { go(2); });

  // ---------- step 2: calendar ----------
  function renderCalendar() {
    var y = viewMonth.getFullYear(), mo = viewMonth.getMonth();
    $("cal-title").textContent = viewMonth.toLocaleDateString("da-DK", { month: "long", year: "numeric" });
    $("cal-prev").disabled = y === today.getFullYear() && mo === today.getMonth();
    $("cal-next").disabled = new Date(y, mo + 1, 1) > lastDay;

    var html = DOW.map(function (d) { return '<div class="cal-dow">' + d + "</div>"; }).join("");
    var first = new Date(y, mo, 1);
    var offset = (first.getDay() + 6) % 7; // Monday first
    for (var i = 0; i < offset; i++) html += "<span></span>";
    var days = new Date(y, mo + 1, 0).getDate();
    for (var d = 1; d <= days; d++) {
      var date = new Date(y, mo, d);
      var inRange = date >= today && date <= lastDay;
      var open = inRange && hasFree(date);
      var cls = "cal-day" + (open ? " open" : "") +
        (state.date && ymd(state.date) === ymd(date) ? " selected" : "") +
        (ymd(date) === ymd(today) ? " today" : "");
      html += '<button class="' + cls + '" data-date="' + ymd(date) + '"' + (open ? "" : " disabled") +
        ' aria-label="' + longDate(date) + (open ? ", ledige tider" : ", ingen ledige tider") + '">' + d + "</button>";
    }
    $("cal-grid").innerHTML = html;
    $("cal-grid").querySelectorAll(".cal-day.open").forEach(function (b) {
      b.addEventListener("click", function () {
        var p = b.getAttribute("data-date").split("-");
        state.date = new Date(+p[0], +p[1] - 1, +p[2]);
        state.time = null;
        renderCalendar();
        updateSummary();
        // On phones the times sit below the calendar, so bring them into view.
        if (window.innerWidth < 760) $("times-title").scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });
    renderTimes();
  }

  function renderTimes() {
    if (!state.date) {
      $("times-title").textContent = "Vælg en dag";
      $("times-hint").hidden = false;
      $("times").innerHTML = "";
      return;
    }
    $("times-title").textContent = longDate(state.date).replace(/^./, function (c) { return c.toUpperCase(); });
    $("times-hint").hidden = true;
    var slots = slotsFor(state.date, state.service.duration);
    $("times").innerHTML = slots.map(function (s) {
      return '<button class="time' + (state.time === s.time ? " selected" : "") + '" data-time="' + s.time + '"' +
        (s.free ? "" : " disabled") + ">" + s.time + "</button>";
    }).join("");
    $("times").querySelectorAll(".time:not([disabled])").forEach(function (b) {
      b.addEventListener("click", function () {
        state.time = b.getAttribute("data-time");
        renderTimes();
        updateSummary();
      });
    });
  }

  $("cal-prev").addEventListener("click", function () { viewMonth.setMonth(viewMonth.getMonth() - 1); renderCalendar(); });
  $("cal-next").addEventListener("click", function () { viewMonth.setMonth(viewMonth.getMonth() + 1); renderCalendar(); });
  $("to-3").addEventListener("click", function () { go(3); });

  // ---------- step 3: details ----------
  var form = $("details");
  function check(el, ok) { el.classList.toggle("invalid", !ok); return ok; }
  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var name = $("f-name"), phone = $("f-phone"), email = $("f-email"), terms = $("f-terms");
    var ok = [
      check(name, name.value.trim().length > 1),
      check(phone, /^[+\d][\d\s-]{7,}$/.test(phone.value.trim())),
      check(email, /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())),
      check(terms.parentNode, terms.checked)
    ].every(Boolean);
    if (!ok) { form.querySelector(".invalid input, input.invalid").focus(); return; }
    state.details = { name: name.value.trim(), phone: phone.value.trim(), email: email.value.trim(), note: $("f-note").value.trim() };
    confirmBooking();
  });

  // ---------- step 4: confirmation ----------
  function confirmBooking() {
    var s = state.service;
    $("confirm-text").textContent = "Kære " + state.details.name.split(" ")[0] + ", din tid til " + s.name + " er " +
      longDate(state.date) + " kl. " + state.time + ". Du får en bekræftelse med adressen på " + state.details.email + ".";
    $("confirm-demo").hidden = false;
    go(4);
  }

  $("ics").addEventListener("click", function () {
    var s = state.service;
    var start = new Date(state.date); var t = state.time.split(":");
    start.setHours(+t[0], +t[1]);
    var end = new Date(start.getTime() + s.duration * 60000);
    function fmt(d) { return d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + "T" + pad(d.getHours()) + pad(d.getMinutes()) + "00"; }
    var ics = [
      "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Copenhagen Cosmetology//Booking//DA",
      "BEGIN:VEVENT", "UID:" + Date.now() + "@cph-cos.dk", "DTSTAMP:" + fmt(new Date()),
      "DTSTART:" + fmt(start), "DTEND:" + fmt(end),
      "SUMMARY:" + s.name + " – Copenhagen Cosmetology",
      "DESCRIPTION:Tlf. " + CPH.business.phone + ". Afbud senest 24 timer før.",
      "END:VEVENT", "END:VCALENDAR"
    ].join("\r\n");
    var a = document.createElement("a");
    a.href = URL.createObjectURL(new Blob([ics], { type: "text/calendar" }));
    a.download = "copenhagen-cosmetology-booking.ics";
    a.click();
  });

  // ---------- start ----------
  var pre = new URLSearchParams(location.search).get("service");
  var preSvc = pre && CPH.serviceById(pre);
  if (preSvc && preSvc.bookable !== false) { state.service = preSvc; activeCat = preSvc.cat; }
  renderTabs();
  renderServices();
  updateSummary();
  go(preSvc ? 2 : 1);
  if (!preSvc) window.scrollTo(0, 0);
})();
