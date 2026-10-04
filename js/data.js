/*
  Copenhagen Cosmetology – business info, opening hours and price list.
  Edit prices and treatments here; the price page and the booking calendar both read from this file.
  Prices are taken from the "Priser" page on the old Hostinger site (October 2026).
  duration = minutes. price = kroner. price: null shows "Pris på forespørgsel".
*/
window.CPH = {
  business: {
    name: "Copenhagen Cosmetology",
    owner: "Phattree Nancy Jensen",
    cvr: "41512598",
    phone: "28 68 93 84",
    phoneLink: "+4528689384",
    email: "copenhagencos@gmail.com",
    instagram: "https://www.instagram.com/nancyjensen231",
    area: "Herlev og Københavns omegn",
    addressNote: "Adressen oplyses ved bekræftet booking."
  },

  /*
    Booking setup.
    mode "demo": the built-in calendar is shown, nothing is sent (for preview).
    mode "easypractice": the EasyPractice/Terapeut Booking calendar is embedded on the booking page,
    so bookings land directly in Nancy's EasyPractice calendar. Set easyPracticeUrl to the link from
    EasyPractice > Online Booking.
  */
  booking: {
    mode: "demo",
    easyPracticeUrl: "",
    slotStep: 30,          // minutes between start times
    daysAhead: 60,         // how far ahead customers can book
    minHoursNotice: 12     // earliest booking from now
  },

  // 0 = Sunday ... 6 = Saturday. null = closed.
  hours: {
    0: null,
    1: null,
    2: ["09:30", "18:00"],
    3: ["09:30", "18:00"],
    4: ["09:30", "18:00"],
    5: null,
    6: null
  },

  categories: [
    {
      id: "ansigt", name: "Ansigtsbehandlinger", img: "assets/img/ansigt.jpg",
      intro: "Professionelle ansigtsbehandlinger tilpasset din hudtype og dine behov – fra en hurtig opfriskning til avanceret microneedling."
    },
    {
      id: "vipper-bryn", name: "Vipper & Bryn", img: "assets/img/bryn.jpg",
      intro: "Lash lift, brow lift, farvning og extensions, der fremhæver dit blik med et naturligt og holdbart resultat."
    },
    {
      id: "negle", name: "Negle", img: "assets/img/negle.jpg",
      intro: "Manicure, pedicure og CND Shellac – smukke, velplejede negle med produkter af høj kvalitet."
    },
    {
      id: "krop", name: "Kropsbehandlinger", img: "assets/img/krop.jpg",
      intro: "Massage, rygbehandling og luksuriøse spa-behandlinger, der giver ro, balance og ny energi."
    },
    {
      id: "voks", name: "Hårfjerning med voks", img: "assets/img/voks.jpg",
      intro: "Skånsom og effektiv voksbehandling. Resultatet holder typisk 3–4 uger. Hårene bør være min. 0,5 cm lange."
    },
    {
      id: "pmu", name: "Permanent makeup – bryn", img: "assets/img/pmu.jpg", comingSoon: true,
      intro: "Kommer snart. Permanent makeup åbner, når alle sundhedsmæssige og faglige krav er fuldt implementeret."
    }
  ],

  services: [
    // Ansigt
    { id: "proskin30", cat: "ansigt", name: "ProSkin 30", duration: 30, price: 395,
      desc: "Hurtig og effektiv behandling med fokus på ét hudproblem – fx udbrud, tørhed eller træt hud." },
    { id: "proskin60", cat: "ansigt", name: "ProSkin 60", duration: 50, price: 725,
      desc: "Skræddersyet ansigtsbehandling med dybderens, eksfoliering, maske, massage og fugt." },
    { id: "proskin90", cat: "ansigt", name: "ProSkin 90", duration: 75, price: 895,
      desc: "Den lange, fordybende ansigtsbehandling til hud der trænger til ekstra pleje." },
    { id: "proface", cat: "ansigt", name: "ProFace Facial Exercise inkl. Gua Sha", duration: 85, price: 995,
      desc: "Naturligt ansigtsløft uden nåle – ansigtsbehandling kombineret med løftende massage og Gua Sha." },
    { id: "proface-luksus", cat: "ansigt", name: "Luksus ProFace (Pro Firm)", duration: 90, price: 1195,
      desc: "Fastere og mere tonet hud med avanceret massage, stimulering og lymfedrænage." },
    { id: "microneedling", cat: "ansigt", name: "Microneedling med ansigtsbehandling", duration: 70, price: 1725,
      desc: "Microneedling med aktivt serum kombineret med ansigtsbehandling for opstramning og cellefornyelse." },
    { id: "advanced", cat: "ansigt", name: "Advanced ProFace Microneedling + LED", duration: 85, price: 2030,
      desc: "Signaturbehandlingen: peeling, ProFace massage, microneedling med serum, maske og LED-lysterapi." },

    // Vipper & bryn
    { id: "farv-vipper-el-bryn", cat: "vipper-bryn", name: "Farvning af vipper eller bryn", duration: 30, price: 195 },
    { id: "farv-bryn-retning", cat: "vipper-bryn", name: "Farvning af bryn inkl. retning", duration: 25, price: 250 },
    { id: "farv-vipper-bryn", cat: "vipper-bryn", name: "Farvning af vipper og bryn inkl. retning", duration: 35, price: 395 },
    { id: "brow-lift", cat: "vipper-bryn", name: "Brow lift / lamination inkl. farvning, retning og biotin", duration: 60, price: 650 },
    { id: "lash-lift", cat: "vipper-bryn", name: "Lash lift Deluxe med farve inkl. biotin", duration: 50, price: 625 },
    { id: "lash-brow-lift", cat: "vipper-bryn", name: "Lash lift & brow lift inkl. farvning og retning", duration: 75, price: 995 },
    { id: "lash-ext", cat: "vipper-bryn", name: "Lash extension – single lash", duration: 60, price: 500 },
    { id: "lash-ext-vol", cat: "vipper-bryn", name: "Lash extension – volume", duration: 90, price: 800 },
    { id: "lash-removal", cat: "vipper-bryn", name: "Fjernelse af vippe-extensions", duration: 15, price: 200 },
    { id: "brow-ext", cat: "vipper-bryn", name: "Brow extension", duration: 40, price: 350 },

    // Negle
    { id: "manicure", cat: "negle", name: "Manicure", duration: 20, price: 295 },
    { id: "pedicure", cat: "negle", name: "Pedicure", duration: 20, price: 295 },
    { id: "luksus-manicure", cat: "negle", name: "Luksus manicure med peeling og maske (Karmameju)", duration: 30, price: 395 },
    { id: "luksus-pedicure", cat: "negle", name: "Luksus pedicure med peeling og maske (Karmameju)", duration: 30, price: 395 },
    { id: "luksus-manicure-shellac", cat: "negle", name: "Luksus manicure inkl. shellac i valgfri farve", duration: 110, price: 695 },
    { id: "mani-pedi-fransk", cat: "negle", name: "Manicure & pedicure med fransk shellac", duration: 95, price: 990 },
    { id: "shellac", cat: "negle", name: "Shellac (alene)", duration: 50, price: 375 },
    { id: "manicure-shellac", cat: "negle", name: "Manicure med shellac – hænder", duration: 60, price: 445 },
    { id: "pedicure-shellac", cat: "negle", name: "Pedicure med shellac – tånegle", duration: 60, price: 445 },
    { id: "shellac-fransk-taa", cat: "negle", name: "Fransk shellac på tånegle inkl. aftagning", duration: 60, price: 595 },
    { id: "shellac-opfyld", cat: "negle", name: "Shellac opfyldning inkl. aftagning", duration: 60, price: 545 },
    { id: "shellac-aftag", cat: "negle", name: "Aftagning af shellac", duration: 15, price: 150 },

    // Krop – the old site lists these without prices
    { id: "rygmassage", cat: "krop", name: "Rygmassage", duration: 20, price: null,
      desc: "Afhjælper muskelspændinger og giver ro i kroppen." },
    { id: "rygbehandling", cat: "krop", name: "Rygbehandling", duration: 30, price: null,
      desc: "Afrensning, peeling, dyb udrensning, rygmassage, maske og afsluttende creme." },
    { id: "aromamassage", cat: "krop", name: "Aromavelvære / europæisk kropsmassage", duration: 60, price: null,
      desc: "Afslappende massage med varme, aromatiske olier." },
    { id: "body-firm", cat: "krop", name: "Luksus Spa Pro Body Firm træmassage", duration: 85, price: null,
      desc: "Anti-cellulite træmassage med aromaterapi og produkter fra Karmameju." },
    { id: "proface-body", cat: "krop", name: "Luksus ProFace & Spa Pro Body Firm", duration: 110, price: null,
      desc: "Komplet luksusoplevelse: ansigtsløft, træmassage, fodpleje, kropspeeling og massage." },

    // Voks – the old site has no durations for wax, so 15–60 min are estimates
    { id: "voks-overlaebe", cat: "voks", group: "Ansigt", name: "Overlæbe", duration: 15, price: 95 },
    { id: "voks-hage", cat: "voks", group: "Ansigt", name: "Hage", duration: 15, price: 135 },
    { id: "voks-naese", cat: "voks", group: "Ansigt", name: "Næse", duration: 15, price: 120 },
    { id: "voks-ansigt", cat: "voks", group: "Ansigt", name: "Hele ansigtet inkl. retning af bryn", duration: 30, price: 410 },
    { id: "voks-armhuler", cat: "voks", group: "Krop", name: "Armhuler", duration: 15, price: 195 },
    { id: "voks-arme", cat: "voks", group: "Krop", name: "Arme", duration: 30, price: 390 },
    { id: "voks-halv-arm", cat: "voks", group: "Krop", name: "Halv arm", duration: 20, price: 285 },
    { id: "voks-laend", cat: "voks", group: "Krop", name: "Lænd", duration: 15, price: 190 },
    { id: "voks-nakke", cat: "voks", group: "Krop", name: "Nakke", duration: 15, price: 149 },
    { id: "voks-bikini", cat: "voks", group: "Intim", name: "Bikini", duration: 20, price: 295 },
    { id: "voks-balder", cat: "voks", group: "Intim", name: "Balder", duration: 20, price: 260 },
    { id: "voks-tanga", cat: "voks", group: "Intim", name: "Tanga (Californian)", duration: 30, price: 370 },
    { id: "voks-brasil", cat: "voks", group: "Intim", name: "Brasiliansk eller Hollywood", duration: 30, price: 495 },
    { id: "voks-laar-bikini", cat: "voks", group: "Ben", name: "Lår inkl. bikini", duration: 40, price: 480 },
    { id: "voks-laar-tanga", cat: "voks", group: "Ben", name: "Lår inkl. tanga", duration: 45, price: 560 },
    { id: "voks-laar-brasil", cat: "voks", group: "Ben", name: "Lår inkl. brasiliansk/Hollywood", duration: 50, price: 690 },
    { id: "voks-halvben-bikini", cat: "voks", group: "Ben", name: "½ ben inkl. bikini", duration: 40, price: 480 },
    { id: "voks-halvben-brasil", cat: "voks", group: "Ben", name: "½ ben inkl. brasiliansk/Hollywood", duration: 50, price: 690 },
    { id: "voks-helben-bikini", cat: "voks", group: "Ben", name: "Hele ben inkl. bikini", duration: 50, price: 620 },
    { id: "voks-helben-tanga", cat: "voks", group: "Ben", name: "Hele ben inkl. tanga", duration: 55, price: 690 },
    { id: "voks-helben-brasil", cat: "voks", group: "Ben", name: "Hele ben inkl. brasiliansk/Hollywood", duration: 60, price: 795 },

    // Permanent makeup – shown on the price page, not bookable yet
    { id: "pmu-strokes", cat: "pmu", name: "Strokes / Microblading", duration: 150, price: 2000, bookable: false,
      desc: "Fine, naturlige hårstrøg. Holdbarhed ca. 1–2 år." },
    { id: "pmu-combo", cat: "pmu", name: "Combo Brows", duration: 180, price: 2000, bookable: false,
      desc: "Hair-strokes i fronten og blød shading i resten af brynet." },
    { id: "pmu-blade-shade", cat: "pmu", name: "Blade + Shade", duration: 150, price: 2000, bookable: false,
      desc: "Microblading kombineret med shading for ekstra dybde." },
    { id: "pmu-ombre", cat: "pmu", name: "Ombré Brows", duration: 120, price: 2000, bookable: false,
      desc: "Blød farveovergang – lysere i fronten, mørkere i halen." },
    { id: "pmu-korrektion", cat: "pmu", name: "Korrektion inkl. nyt bryndesign", duration: 120, price: 3500, bookable: false }
  ],

  // Klippekort (packages)
  packages: [
    { name: "ProSkin 60 – betal for 3", normal: 2175, price: 1875, each: 625 },
    { name: "ProSkin 60 – betal for 5, få den 6. gratis", normal: 3625, price: 3125, each: 520 },
    { name: "Microneedling – betal for 3", normal: 5175, price: 4500, each: 1500 },
    { name: "Microneedling – betal for 5, få den 6. gratis", normal: 8625, price: 7500, each: 1200 },
    { name: "Advanced målrettet ansigtsbehandling – betal for 3", normal: 6060, price: 5325, each: 1775 },
    { name: "Advanced målrettet ansigtsbehandling – betal for 5, få den 6. gratis", normal: 10100, price: 8875, each: 1480 },
    { name: "Luksus ProFace (Pro Firm) – betal for 3", normal: 3585, price: 2985, each: 995 },
    { name: "Luksus ProFace (Pro Firm) – betal for 5, få den 6. gratis", normal: 5975, price: 5475, each: 913 }
  ]
};

window.CPH.formatPrice = function (p) {
  return p == null ? "Pris på forespørgsel" : p.toLocaleString("da-DK") + " kr.";
};
window.CPH.formatDuration = function (m) {
  if (m < 60) return m + " min";
  var h = Math.floor(m / 60), r = m % 60;
  return h + " t" + (r ? " " + r + " min" : "");
};
window.CPH.serviceById = function (id) {
  return window.CPH.services.find(function (s) { return s.id === id; });
};
