# Build script for cph-cos.dk
# Reads data/site.json and writes it into the pages, so prices, menu, FAQ and Google data
# are plain HTML that search engines and AI crawlers can read without JavaScript.
#
# Run after changing data/site.json:
#   powershell -ExecutionPolicy Bypass -File tools\build.ps1
#
# Content between <!-- BUILD:name --> and <!-- /BUILD:name --> markers is replaced on every run.

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$utf8 = New-Object Text.UTF8Encoding $false
$da = [Globalization.CultureInfo]::GetCultureInfo('da-DK')

$jsonText = [IO.File]::ReadAllText((Join-Path $root 'data\site.json'), [Text.Encoding]::UTF8)
$J = $jsonText | ConvertFrom-Json
$B = $J.business
$site = $B.siteUrl

function Esc([string]$s) { if ($null -eq $s) { return '' }; $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;') }
function JsonStr([string]$s) { '"' + $s.Replace('\', '\\').Replace('"', '\"') + '"' }
function Price($p) { if ($null -eq $p) { 'Pris på forespørgsel' } else { ([int]$p).ToString('N0', $da) + ' kr.' } }
function Duration([int]$m) { if ($m -lt 60) { "$m min" } else { $h = [Math]::Floor($m / 60); $r = $m % 60; if ($r) { "$h t $r min" } else { "$h t" } } }

# ---------- shared blocks ----------
$navLinks = @(
  @('/', 'Forside', 'home'),
  @('behandlinger.html', 'Behandlinger & priser', 'behandlinger'),
  @('tilbud.html', 'Tilbud -20 %', 'tilbud'),
  @('permanent-makeup.html', 'Permanent makeup', 'pmu'),
  @('om.html', 'Om mig', 'om'),
  @('kontakt.html', 'Kontakt', 'kontakt')
)
function Header([string]$page) {
  $nav = ($navLinks | ForEach-Object {
    $cur = if ($page -eq $_[2]) { ' aria-current="page"' } else { '' }
    "<a href=""$($_[0])""$cur>$(Esc $_[1])</a>"
  }) -join ''
@"
<header class="site-header">
  <div class="wrap">
    <a class="brand" href="/"><img src="assets/img/logo-96.png" alt="" width="48" height="48"><span>Copenhagen<small>Cosmetology</small></span></a>
    <a class="btn header-book" href="booking.html">Book tid</a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false"><span></span><span></span><span></span></button>
    <nav class="nav" aria-label="Hovedmenu">$nav<a class="btn" href="booking.html">Book tid</a></nav>
  </div>
</header>
"@
}

function Footer([string]$page) {
  $float = if ($page -ne 'booking') { "`n<a class=""btn float-book"" href=""booking.html"">Book tid online</a>" } else { '' }
  # WhatsApp chat button on every page (wa.me needs the number with country code, no +)
  $wa = "https://wa.me/45$($B.phoneLink -replace '\D','' -replace '^45','')"
  $float += "`n<a class=""float-wa"" href=""$wa"" target=""_blank"" rel=""noopener"" aria-label=""Skriv til os på WhatsApp""><svg viewBox=""0 0 24 24"" width=""28"" height=""28"" aria-hidden=""true""><path fill=""currentColor"" d=""M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z""/></svg></a>"
@"
<footer class="site-footer">
  <div class="wrap">
    <div class="footer-grid">
      <div><h4>$(Esc $B.name)</h4>
        <p>Professionelle skønhedsbehandlinger i $(Esc $B.area). Behandlinger udføres midlertidigt i diskrete og trygge omgivelser, mens vi søger godkendt kliniklokale. $(Esc $B.addressNote)</p></div>
      <div><h4>Kontakt</h4><ul>
        <li><a href="tel:$($B.phoneLink)">Tlf. $(Esc $B.phone)</a></li>
        <li><a href="$wa" target="_blank" rel="noopener">WhatsApp</a></li>
        <li><a href="mailto:$($B.email)">$(Esc $B.email)</a></li>
        <li><a href="$($B.instagram)" target="_blank" rel="noopener">Instagram</a></li></ul></div>
      <div><h4>Tider</h4><ul>
        <li>Efter aftale – ingen faste åbningstider</li><li><a href="booking.html">Book online døgnet rundt</a></li></ul></div>
      <div><h4>Information</h4><ul>
        <li><a href="booking.html">Book tid</a></li>
        <li><a href="behandlinger.html">Behandlinger & priser</a></li>
        <li><a href="tilbud.html">Tilbud: 20 % på første besøg</a></li>
        <li><a href="ansigtsbehandling-kobenhavn.html">Ansigtsbehandling & microneedling</a></li>
        <li><a href="vipper-og-bryn.html">Lash lift & brow lamination</a></li>
        <li><a href="permanent-makeup.html">Permanent makeup bryn</a></li>
        <li><a href="permanent-makeup-laeber.html">Permanent makeup læber</a></li>
        <li><a href="faq.html">Spørgsmål & svar</a></li>
        <li><a href="kontakt.html#gavekort">Gavekort</a></li>
        <li><a href="handelsbetingelser.html">Handelsbetingelser & afbud</a></li>
        <li><a href="privatlivspolitik.html">Privatlivspolitik</a></li></ul></div>
    </div>
    <div class="footer-bottom"><span>© $(Get-Date -Format yyyy) $(Esc $B.name) · CVR $($B.cvr)</span><span>Betal nemt med MobilePay</span></div>
  </div>
</footer>$float
"@
}

# ---------- price list ----------
function PriceItem($s, [bool]$comingSoon) {
  $book = if ($comingSoon -or $s.bookable -eq $false) {
    '<span class="btn btn-small btn-outline" aria-disabled="true" style="opacity:.5;cursor:default">Snart</span>'
  } else { "<a class=""btn btn-small"" href=""booking.html?service=$($s.id)"">Book</a>" }
  $desc = if ($s.desc) { "<p>$(Esc $s.desc)</p>" } else { '' }
  "<li class=""price-item""><div><h4>$(Esc $s.name)</h4>$desc</div><div class=""price-meta""><strong>$(Price $s.price)</strong><small>$(Duration $s.duration)</small></div>$book</li>"
}

function PriceList($list, [bool]$comingSoon) {
  $groups = @($list | Where-Object { $_.group } | ForEach-Object { $_.group } | Select-Object -Unique)
  if ($groups.Count) {
    ($groups | ForEach-Object { $g = $_
      "<h3 class=""subhead"">$(Esc $g)</h3><ul class=""price-list"">" + (($list | Where-Object { $_.group -eq $g } | ForEach-Object { PriceItem $_ $comingSoon }) -join "`n") + '</ul>'
    }) -join "`n"
  } else {
    '<ul class="price-list">' + (($list | ForEach-Object { PriceItem $_ $comingSoon }) -join "`n") + '</ul>'
  }
}

function SkinProblems {
  if (-not $J.skinProblems) { return '' }
  $cards = ($J.skinProblems | ForEach-Object { $p = $_
    $links = ($p.services | ForEach-Object { $id = $_
      $s = $J.services | Where-Object { $_.id -eq $id } | Select-Object -First 1
      if ($s) { "<a href=""booking.html?service=$($s.id)"">$(Esc $s.name)</a>" }
    }) -join ' · '
    "<article class=""problem""><h3>$(Esc $p.title)</h3><p>$(Esc $p.text)</p><p class=""problem-links""><strong>Anbefalet:</strong> $links</p></article>"
  }) -join "`n"
@"
<div class="problems" id="hudproblemer">
<h3 class="subhead">Ansigtsbehandling mod dit hudproblem</h3>
<p class="muted">Alle behandlinger tilpasses din hud. Her er, hvad vi typisk anbefaler. Ved første behandling laver vi en hudanalyse og lægger en plan sammen.</p>
<div class="problem-grid">
$cards
</div>
</div>
"@
}

function PriceSections {
  ($J.categories | ForEach-Object { $c = $_
    $list = @($J.services | Where-Object { $_.cat -eq $c.id })
    $extra = ''
    if ($c.id -eq 'pmu') { $extra = '<p class="note">Book permanent makeup bryn online eller på tlf. 28 68 93 84. Priserne er vejledende, og den endelige pris aftales ved konsultationen. <a href="permanent-makeup.html">Læs om teknikker, heling og FAQ</a>.</p>' }
    $after = if ($c.id -eq 'ansigt') { SkinProblems } else { '' }
    $soon = [bool]$c.comingSoon
@"
<div class="price-cat" id="$($c.id)"><div class="price-cat-head"><img src="$($c.img)" alt="$(Esc $c.name) hos Copenhagen Cosmetology i Herlev" loading="lazy"><div><h2>$(Esc $c.name)</h2><p class="lead">$(Esc $c.intro)</p></div></div>
$extra$(PriceList $list $soon)
$after</div>
"@
  }) -join "`n"
}

function CatNav {
  (($J.categories | ForEach-Object { "<a class=""chip"" href=""#$($_.id)"">$(Esc $_.name)</a>" }) -join '') + '<a class="chip" href="#hudproblemer">Hudproblemer</a><a class="chip" href="#klippekort">Klippekort</a><a class="chip" href="#faq">Spørgsmål & svar</a>'
}

function Packages {
  ($J.packages | ForEach-Object {
    "<tr><td>$(Esc $_.name)</td><td class=""num""><s>$(Price $_.normal)</s></td><td class=""num""><strong>$(Price $_.price)</strong></td><td class=""num"">$(Price $_.each)</td></tr>"
  }) -join "`n"
}

function Cards {
  ($J.categories | ForEach-Object {
    $href = if ($_.page) { $_.page } else { "behandlinger.html#$($_.id)" }
    $link = if ($_.comingSoon) { 'Kommer snart – læs mere →' } else { 'Se priser →' }
    "<a class=""card"" href=""$href""><img src=""$($_.img)"" alt=""$(Esc $_.name) i Herlev"" loading=""lazy""><div class=""card-body""><h3>$(Esc $_.name)</h3><p>$(Esc $_.intro)</p><span class=""card-link"">$link</span></div></a>"
  }) -join "`n"
}

# ---------- FAQ ----------
function FaqHtml($items) {
  '<div class="faq">' + (($items | ForEach-Object {
    "<details class=""faq-item""><summary>$(Esc $_.q)</summary><p>$(Esc $_.a)</p></details>"
  }) -join "`n") + '</div>'
}
function FaqLd($items) {
  $qs = ($items | ForEach-Object {
    "{ ""@type"": ""Question"", ""name"": $(JsonStr $_.q), ""acceptedAnswer"": { ""@type"": ""Answer"", ""text"": $(JsonStr $_.a) } }"
  }) -join ",`n    "
  "<script type=""application/ld+json"">`n{ ""@context"": ""https://schema.org"", ""@type"": ""FAQPage"", ""mainEntity"": [`n    $qs`n] }`n</script>"
}
# faq.html: all questions grouped by topic. Google wants FAQ markup on one page only, so faq.html
# carries the FAQPage data and behandlinger.html / permanent-makeup.html show their FAQ without it.
$faqAll = @($J.faq) + @($J.faqPmu | ForEach-Object { $_ | Add-Member -NotePropertyName group -NotePropertyValue 'Permanent makeup bryn' -Force -PassThru })
function FaqGrouped {
  $order = @('Booking og praktisk', 'Ansigtsbehandlinger', 'Vipper og bryn', 'Negle', 'Voks', 'Permanent makeup bryn')
  $groups = @($order | Where-Object { $faqAll.group -contains $_ })
  $chips = '<nav class="cat-nav" aria-label="Emner">' + (($groups | ForEach-Object { $i = [array]::IndexOf($groups, $_); "<a class=""chip"" href=""#emne-$i"">$(Esc $_)</a>" }) -join '') + '</nav>'
  $chips + "`n" + (($groups | ForEach-Object { $g = $_; $i = [array]::IndexOf($groups, $g)
    "<h2 id=""emne-$i"">$(Esc $g)</h2>`n" + (FaqHtml @($faqAll | Where-Object { $_.group -eq $g }))
  }) -join "`n")
}

# ---------- Google data: services with prices ----------
function OffersLd($cats, [string]$pageUrl) {
  $sections = ($cats | ForEach-Object { $c = $_
    $offers = ($J.services | Where-Object { $_.cat -eq $c.id -and $null -ne $_.price } | ForEach-Object {
      "{ ""@type"": ""Offer"", ""price"": ""$($_.price)"", ""priceCurrency"": ""DKK"", ""itemOffered"": { ""@type"": ""Service"", ""name"": $(JsonStr $_.name) } }"
    }) -join ",`n        "
    if ($offers) { "{ ""@type"": ""OfferCatalog"", ""name"": $(JsonStr $c.name), ""itemListElement"": [`n        $offers`n      ] }" }
  } | Where-Object { $_ }) -join ",`n      "
  "<script type=""application/ld+json"">`n{ ""@context"": ""https://schema.org"", ""@type"": ""BeautySalon"", ""@id"": ""${site}#business"", ""name"": $(JsonStr $B.name), ""url"": ""$site"", ""telephone"": ""$($B.phoneLink)"",`n  ""address"": { ""@type"": ""PostalAddress"", ""addressLocality"": ""Herlev"", ""addressCountry"": ""DK"" },`n  ""hasOfferCatalog"": { ""@type"": ""OfferCatalog"", ""name"": ""Behandlinger og priser"", ""itemListElement"": [`n      $sections`n  ] } }`n</script>"
}

# ---------- write into pages ----------
function Set-Block([string]$html, [string]$name, [string]$content) {
  $pattern = "(?s)(<!-- BUILD:$name -->).*?(<!-- /BUILD:$name -->)"
  if (-not [regex]::IsMatch($html, $pattern)) { return $html }
  [regex]::Replace($html, $pattern, { param($m) $m.Groups[1].Value + "`n" + $content + "`n" + $m.Groups[2].Value })
}

$pages = [ordered]@{
  'index.html' = 'home'; 'behandlinger.html' = 'behandlinger'; 'booking.html' = 'booking'; 'om.html' = 'om'
  'kontakt.html' = 'kontakt'; 'permanent-makeup.html' = 'pmu'; 'permanent-makeup-laeber.html' = 'pmu'; 'privatlivspolitik.html' = 'privatliv'
  'handelsbetingelser.html' = 'vilkaar'; 'faq.html' = 'faq'; 'tilbud.html' = 'tilbud'
  'ansigtsbehandling-kobenhavn.html' = 'behandlinger'; 'vipper-og-bryn.html' = 'behandlinger'; '404.html' = '404'
}
$pmuCats = @($J.categories | Where-Object { $_.id -eq 'pmu' })

# ---------- tilbud.html: every priced service with the first-visit price ----------
$pct = [int]$J.offer.firstVisitPercent
function OfferPrice($p) { [Math]::Round($p * (100 - $pct) / 100) }
function OfferTable {
  ($J.categories | ForEach-Object { $c = $_
    $rows = ($J.services | Where-Object { $_.cat -eq $c.id -and $null -ne $_.price -and $_.bookable -ne $false } | ForEach-Object {
      "<tr><td>$(Esc $_.name)</td><td class=""num""><s>$(Price $_.price)</s></td><td class=""num""><strong>$(Price (OfferPrice $_.price))</strong></td><td class=""num""><a class=""btn btn-small"" href=""booking.html?service=$($_.id)"">Book</a></td></tr>"
    }) -join "`n"
    if ($rows) {
      $more = if ($c.page) { $c.page } else { "behandlinger.html#$($c.id)" }
@"
<h2 id="tilbud-$($c.id)">$(Esc $c.name) – tilbud</h2>
<div class="table-scroll"><table class="package-table offer-table">
<thead><tr><th>Behandling</th><th class="num">Normalpris</th><th class="num">Første besøg (-$pct %)</th><th class="num"></th></tr></thead>
<tbody>
$rows
</tbody></table></div>
<p class="muted"><a href="$more">Læs mere om $(Esc $c.name.ToLower())</a></p>
"@
    }
  }) -join "`n"
}
# Category pages (ansigtsbehandling-kobenhavn.html, vipper-og-bryn.html): prices and FAQ for one topic.
function CatPrices([string]$id) { PriceList @($J.services | Where-Object { $_.cat -eq $id }) $false }
function FaqGroup([string]$g) { FaqHtml @($faqAll | Where-Object { $_.group -eq $g }) }
$blocks = @{
  'cards' = (Cards); 'cat-nav' = (CatNav); 'prices' = (PriceSections); 'packages' = (Packages)
  'faq' = (FaqHtml $J.faq); 'faq-ld' = ''; 'faq-all' = (FaqGrouped); 'faq-all-ld' = (FaqLd $faqAll); 'offers-ld' = (OffersLd $J.categories)
  'faq-pmu' = (FaqHtml $J.faqPmu); 'faq-pmu-ld' = ''
  'pmu-prices' = (PriceList @($J.services | Where-Object { $_.cat -eq 'pmu' }) $false)
  'offer-table' = (OfferTable); 'offer-pct' = "$pct"
  'prices-ansigt' = (CatPrices 'ansigt'); 'prices-vipper-bryn' = (CatPrices 'vipper-bryn'); 'skin-problems' = (SkinProblems)
  'faq-ansigt' = (FaqGroup 'Ansigtsbehandlinger'); 'faq-vipper-bryn' = (FaqGroup 'Vipper og bryn')
  'offers-ld-ansigt' = (OffersLd @($J.categories | Where-Object { $_.id -eq 'ansigt' })); 'offers-ld-vipper-bryn' = (OffersLd @($J.categories | Where-Object { $_.id -eq 'vipper-bryn' }))
}
foreach ($file in $pages.Keys) {
  $path = Join-Path $root $file
  if (-not (Test-Path $path)) { continue }
  $html = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
  $html = Set-Block $html 'header' (Header $pages[$file])
  $html = Set-Block $html 'footer' (Footer $pages[$file])
  foreach ($k in $blocks.Keys) { $html = Set-Block $html $k $blocks[$k] }
  [IO.File]::WriteAllText($path, $html, $utf8)
  "built $file"
}

# ---------- js/data.js for the booking calendar ----------
$helpers = @'

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
'@
$dataJs = "/* GENERATED by tools/build.ps1 from data/site.json – edit site.json, not this file. */`nwindow.CPH = " + $jsonText.Trim() + ";`n" + $helpers
[IO.File]::WriteAllText((Join-Path $root 'js\data.js'), $dataJs, $utf8)
"built js/data.js"

# ---------- sitemap, robots, llms.txt, llms-full.txt ----------
$today = Get-Date -Format 'yyyy-MM-dd'
$urls = @(@('', '1.0'), @('behandlinger.html', '0.9'), @('booking.html', '0.9'), @('permanent-makeup.html', '0.8'), @('permanent-makeup-laeber.html', '0.8'),
  @('tilbud.html', '0.9'), @('ansigtsbehandling-kobenhavn.html', '0.9'), @('vipper-og-bryn.html', '0.9'), @('faq.html', '0.7'), @('om.html', '0.7'), @('kontakt.html', '0.7'), @('privatlivspolitik.html', '0.2'), @('handelsbetingelser.html', '0.2'))
$entries = ($urls | ForEach-Object { "  <url><loc>$site$($_[0])</loc><lastmod>$today</lastmod><priority>$($_[1])</priority></url>" }) -join "`n"
[IO.File]::WriteAllText((Join-Path $root 'sitemap.xml'), "<?xml version=""1.0"" encoding=""UTF-8""?>`n<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">`n$entries`n</urlset>`n", $utf8)
[IO.File]::WriteAllText((Join-Path $root 'robots.txt'), "User-agent: *`nAllow: /`n`nSitemap: ${site}sitemap.xml`n`n# Overview for AI assistants: ${site}llms.txt (full text: ${site}llms-full.txt)`n", $utf8)

# llms.txt follows llmstxt.org: one H1, a summary blockquote, then H2 sections.
$priceLines = ($J.categories | ForEach-Object { $c = $_
  "`n### $($c.name)$(if ($c.comingSoon) { ' (kommer snart)' })`n" + (($J.services | Where-Object { $_.cat -eq $c.id } | ForEach-Object { "- $($_.name): $(Price $_.price), $(Duration $_.duration)" }) -join "`n")
}) -join "`n"
$packageLines = ($J.packages | ForEach-Object { "- $($_.name): $(Price $_.price) (normalpris $(Price $_.normal), $(Price $_.each) pr. behandling)" }) -join "`n"
$intro = @"
# $($B.name)

> Skønhedsklinik i Herlev ved København drevet af lægeeksamineret kosmetolog og hudterapeut $($B.owner). Ansigtsbehandlinger, microneedling, vipper og bryn, massage (kun for kvinder) og permanent makeup til bryn og læber. Book online eller på telefon. Nye kunder får $($J.offer.firstVisitPercent) % rabat på første besøg.

- Område: $($B.area). $($B.addressNote)
- Åbningstider: ingen faste åbningstider, tider efter aftale
- Telefon: $($B.phone) · E-mail: $($B.email)
- Online booking: ${site}booking.html
- Betaling: MobilePay eller kontant. Klippekort og gavekort betales forud.
- Afbud: senest 24 timer før (50 % ved afbud samme dag, 100 % ved udeblivelse)
- CVR: $($B.cvr)

## Uddannelse
- Medicinsk viden og basal hjerte-lunge-redning for tatovører, Yanhee International Hospital, Bangkok (2017)
- Permanent makeup, bryn (3D/6D) og læber, Madame Eyebrows Academy, Thailand (2018, 2020)
- Rasita ProFace Trainer, ansigtsmassage og ansigtstræning (anti-aging facial exercise) (2019)
- Dermalogica Certified (2020–2024) og CND Shellac Brand Certification (2020)
- Lægeeksamineret kosmetolog og hudterapeut, Nordsjællands Kosmetologskole (2021)
- Lycon Basic Waxing Techniques (2021) og Elleebana Lash Lift (2021)
- Lovpligtigt hygiejnekursus for tatovører, Tatoveringsklinikken, Bispebjerg Hospital (2022)
- Medlearn-kurser i atopisk eksem og immunmedierede inflammatoriske hudsygdomme (2023)
- Fagkursus for kosmetiske tatovører med eksamen, Dansk Kosmetolog Forening (2026)
- Certificeret kosmetisk tatovør, bryn pigmentering, 160 timer, og Swiss Color Artist, Stella Simone PMU Academy (2026)
- Perfect Color Fade™ Master (healed PMU) og ShadeFix™ Master (avanceret farvekorrektion), Stella Simone PMU Academy (2026)
"@
$llms = @"
$intro

## Sider
- [Behandlinger og priser](${site}behandlinger.html): alle behandlinger med pris og varighed, hudproblemer og klippekort
- [Tilbud: $($J.offer.firstVisitPercent) % på første besøg](${site}tilbud.html): normalpris og tilbudspris for alle behandlinger
- [Ansigtsbehandling og microneedling i Herlev](${site}ansigtsbehandling-kobenhavn.html): priser, hudproblemer, microneedling
- [Lash lift og brow lamination i Herlev](${site}vipper-og-bryn.html): priser, holdbarhed og efterpleje
- [Permanent makeup bryn](${site}permanent-makeup.html): powder/ombré, combo brows, Blade + Shade, heling og pleje
- [Permanent makeup læber](${site}permanent-makeup-laeber.html): full lip color, shaded lip liner, ombré lips, lip blush og aquarelle lips, 2.000 kr. pr. behandling, heling og pleje
- [Book tid online](${site}booking.html): vælg behandling, dag og tidspunkt
- [Spørgsmål og svar](${site}faq.html): booking, priser, afbud og behandlinger
- [Om kosmetologen](${site}om.html): uddannelse, certifikater og erfaring
- [Kontakt og gavekort](${site}kontakt.html)
- [Alt indhold i ren tekst](${site}llms-full.txt): priser og alle spørgsmål og svar

## Priser
$priceLines

### Klippekort
$packageLines

## Optional
- [Handelsbetingelser og afbudspolitik](${site}handelsbetingelser.html)
- [Privatlivspolitik](${site}privatlivspolitik.html)
"@
[IO.File]::WriteAllText((Join-Path $root 'llms.txt'), $llms, $utf8)

# llms-full.txt: the same facts plus every FAQ answer, so an assistant can answer without crawling the site.
$faqText = (@('Booking og praktisk', 'Ansigtsbehandlinger', 'Vipper og bryn', 'Voks', 'Permanent makeup bryn') | Where-Object { $faqAll.group -contains $_ } | ForEach-Object { $g = $_
  "### $g`n`n" + (($faqAll | Where-Object { $_.group -eq $g } | ForEach-Object { "**$($_.q)**`n$($_.a)" }) -join "`n`n")
}) -join "`n`n"
$problemText = ($J.skinProblems | ForEach-Object { "- **$($_.title):** $($_.text)" }) -join "`n"
$full = @"
$intro

## Priser
$priceLines

### Klippekort
$packageLines

## Ansigtsbehandling mod hudproblemer
$problemText

## Spørgsmål og svar

$faqText
"@
[IO.File]::WriteAllText((Join-Path $root 'llms-full.txt'), $full, $utf8)
"built sitemap.xml, robots.txt, llms.txt, llms-full.txt"
