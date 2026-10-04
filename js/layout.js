/* Shared header, footer and small page behaviours. Edit the menu here once for all pages. */
(function () {
  var B = window.CPH.business;
  var page = document.body.getAttribute("data-page") || "";

  var links = [
    ["index.html", "Forside", "home"],
    ["behandlinger.html", "Behandlinger & priser", "behandlinger"],
    ["om.html", "Om mig", "om"],
    ["kontakt.html", "Kontakt", "kontakt"]
  ];

  var nav = links.map(function (l) {
    return '<a href="' + l[0] + '"' + (page === l[2] ? ' aria-current="page"' : "") + ">" + l[1] + "</a>";
  }).join("");

  var header = document.createElement("header");
  header.className = "site-header";
  header.innerHTML =
    '<div class="wrap">' +
      '<a class="brand" href="index.html"><img src="assets/img/logo-96.png" alt="" width="48" height="48">' +
        "<span>Copenhagen<small>Cosmetology</small></span></a>" +
      '<button class="nav-toggle" aria-label="Menu" aria-expanded="false"><span></span><span></span><span></span></button>' +
      '<nav class="nav" aria-label="Hovedmenu">' + nav +
        '<a class="btn" href="booking.html">Book tid</a></nav>' +
    "</div>";
  document.body.prepend(header);

  var toggle = header.querySelector(".nav-toggle");
  var navEl = header.querySelector(".nav");
  toggle.addEventListener("click", function () {
    var open = navEl.classList.toggle("open");
    header.classList.toggle("nav-open", open);
    toggle.setAttribute("aria-expanded", open);
  });

  if (page !== "booking") {
    var fb = document.createElement("a");
    fb.className = "btn float-book";
    fb.href = "booking.html";
    fb.textContent = "Book tid online";
    document.body.appendChild(fb);
    document.body.classList.add("has-float");
  }

  var footer = document.createElement("footer");
  footer.className = "site-footer";
  footer.innerHTML =
    '<div class="wrap"><div class="footer-grid">' +
      "<div><h4>" + B.name + "</h4>" +
        "<p>Professionelle skønhedsbehandlinger i " + B.area + ". " +
        "Behandlinger udføres midlertidigt i diskrete og trygge omgivelser, mens vi søger godkendt kliniklokale. " + B.addressNote + "</p></div>" +
      "<div><h4>Kontakt</h4><ul>" +
        '<li><a href="tel:' + B.phoneLink + '">Tlf. ' + B.phone + "</a></li>" +
        '<li><a href="mailto:' + B.email + '">' + B.email + "</a></li>" +
        '<li><a href="' + B.instagram + '" target="_blank" rel="noopener">Instagram</a></li></ul></div>' +
      "<div><h4>Åbningstider</h4><ul>" +
        "<li>Tirsdag – torsdag: 9.30 – 18.00</li><li>Fredag – mandag: lukket</li></ul></div>" +
      "<div><h4>Information</h4><ul>" +
        '<li><a href="booking.html">Book tid</a></li>' +
        '<li><a href="kontakt.html#gavekort">Gavekort</a></li>' +
        '<li><a href="handelsbetingelser.html">Handelsbetingelser & afbud</a></li>' +
        '<li><a href="privatlivspolitik.html">Privatlivspolitik</a></li></ul></div>' +
    "</div>" +
    '<div class="footer-bottom"><span>© ' + new Date().getFullYear() + " " + B.name + " · CVR " + B.cvr + "</span>" +
      "<span>Betal nemt med MobilePay</span></div></div>";
  document.body.appendChild(footer);

  // Fade-in on scroll
  var els = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add("in"); io.unobserve(e.target); } });
    }, { threshold: .12 });
    els.forEach(function (el) { io.observe(el); });
  } else {
    els.forEach(function (el) { el.classList.add("in"); });
  }
})();
