/* Small page behaviours. The menu and footer are plain HTML, written into each page by tools/build.ps1. */
(function () {
  var header = document.querySelector(".site-header");
  if (header) {
    var toggle = header.querySelector(".nav-toggle");
    var navEl = header.querySelector(".nav");
    toggle.addEventListener("click", function () {
      var open = navEl.classList.toggle("open");
      header.classList.toggle("nav-open", open);
      toggle.setAttribute("aria-expanded", open);
    });
  }

  if (document.querySelector(".float-book")) document.body.classList.add("has-float");

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
