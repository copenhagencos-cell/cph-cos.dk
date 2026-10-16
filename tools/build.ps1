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
  @('index.html', 'Forside', 'home'),
  @('behandlinger.html', 'Behandlinger & priser', 'behandlinger'),
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
    <a class="brand" href="index.html"><img src="assets/img/logo-96.png" alt="" width="48" height="48"><span>Copenhagen<small>Cosmetology</small></span></a>
    <a class="btn header-book" href="booking.html">Book tid</a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false"><span></span><span></span><span></span></button>
    <nav class="nav" aria-label="Hovedmenu">$nav<a class="btn" href="booking.html">Book tid</a></nav>
  </div>
</header>
"@
}

function Footer([string]$page) {
  $float = if ($page -ne 'booking') { "`n<a class=""btn float-book"" href=""booking.html"">Book tid online</a>" } else { '' }
@"
<footer class="site-footer">
  <div class="wrap">
    <div class="footer-grid">
      <div><h4>$(Esc $B.name)</h4>
        <p>Professionelle skønhedsbehandlinger i $(Esc $B.area). Behandlinger udføres midlertidigt i diskrete og trygge omgivelser, mens vi søger godkendt kliniklokale. $(Esc $B.addressNote)</p></div>
      <div><h4>Kontakt</h4><ul>
        <li><a href="tel:$($B.phoneLink)">Tlf. $(Esc $B.phone)</a></li>
        <li><a href="mailto:$($B.email)">$(Esc $B.email)</a></li>
        <li><a href="$($B.instagram)" target="_blank" rel="noopener">Instagram</a></li></ul></div>
      <div><h4>Tider</h4><ul>
        <li>Efter aftale – ingen faste åbningstider</li><li><a href="booking.html">Book online døgnet rundt</a></li></ul></div>
      <div><h4>Information</h4><ul>
        <li><a href="booking.html">Book tid</a></li>
        <li><a href="behandlinger.html">Behandlinger & priser</a></li>
        <li><a href="permanent-makeup.html">Permanent makeup bryn</a></li>
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
    if ($c.id -eq 'krop') { $extra = '<p class="note">Kontakt mig for priser på kropsbehandlinger – de oplyses ved booking.</p>' }
    if ($c.id -eq 'pmu') { $extra = '<p class="note">Permanent makeup er under professionel forberedelse og kan bookes snart. Priserne er vejledende. <a href="permanent-makeup.html">Læs om teknikker, heling og FAQ</a>.</p>' }
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
  $order = @('Booking og praktisk', 'Ansigtsbehandlinger', 'Vipper og bryn', 'Voks', 'Permanent makeup bryn')
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
  'kontakt.html' = 'kontakt'; 'permanent-makeup.html' = 'pmu'; 'privatlivspolitik.html' = 'privatliv'
  'handelsbetingelser.html' = 'vilkaar'; 'faq.html' = 'faq'; '404.html' = '404'
}
$pmuCats = @($J.categories | Where-Object { $_.id -eq 'pmu' })
$blocks = @{
  'cards' = (Cards); 'cat-nav' = (CatNav); 'prices' = (PriceSections); 'packages' = (Packages)
  'faq' = (FaqHtml $J.faq); 'faq-ld' = ''; 'faq-all' = (FaqGrouped); 'faq-all-ld' = (FaqLd $faqAll); 'offers-ld' = (OffersLd $J.categories)
  'faq-pmu' = (FaqHtml $J.faqPmu); 'faq-pmu-ld' = ''
  'pmu-prices' = (PriceList @($J.services | Where-Object { $_.cat -eq 'pmu' }) $true)
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

# ---------- sitemap, robots, llms.txt ----------
$today = Get-Date -Format 'yyyy-MM-dd'
$urls = @(@('', '1.0'), @('behandlinger.html', '0.9'), @('booking.html', '0.9'), @('permanent-makeup.html', '0.8'),
  @('faq.html', '0.7'), @('om.html', '0.7'), @('kontakt.html', '0.7'), @('privatlivspolitik.html', '0.2'), @('handelsbetingelser.html', '0.2'))
$entries = ($urls | ForEach-Object { "  <url><loc>$site$($_[0])</loc><lastmod>$today</lastmod><priority>$($_[1])</priority></url>" }) -join "`n"
[IO.File]::WriteAllText((Join-Path $root 'sitemap.xml'), "<?xml version=""1.0"" encoding=""UTF-8""?>`n<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">`n$entries`n</urlset>`n", $utf8)
[IO.File]::WriteAllText((Join-Path $root 'robots.txt'), "User-agent: *`nAllow: /`n`nSitemap: ${site}sitemap.xml`n", $utf8)

$priceLines = ($J.categories | ForEach-Object { $c = $_
  "`n## $($c.name)$(if ($c.comingSoon) { ' (kommer snart)' })`n" + (($J.services | Where-Object { $_.cat -eq $c.id } | ForEach-Object { "- $($_.name): $(Price $_.price), $(Duration $_.duration)" }) -join "`n")
}) -join "`n"
$llms = @"
# $($B.name)

> Skønhedsklinik i Herlev ved København drevet af lægeeksamineret kosmetolog og hudterapeut $($B.owner). Ansigtsbehandlinger, microneedling, vipper og bryn, negle, voks, kropsbehandlinger og (snart) permanent makeup bryn.

- Område: $($B.area). $($B.addressNote)
- Åbningstider: ingen faste åbningstider, tider efter aftale
- Telefon: $($B.phone) · E-mail: $($B.email)
- Booking: ${site}booking.html
- Betaling: MobilePay eller kontant
- Afbud: senest 24 timer før (50 % ved afbud samme dag, 100 % ved udeblivelse)
- Uddannelse: lægeeksamineret kosmetolog (Nordsjællands Kosmetologskole, 2021); hygiejnekursus for tatovører (2022); DKF fagkursus for kosmetiske tatovører med eksamen (2026); certificeret i permanent makeup bryn, 160 timer (Stella Simone PMU Academy, 2026)

## Sider
- [Behandlinger og priser](${site}behandlinger.html)
- [Permanent makeup bryn](${site}permanent-makeup.html)
- [Om kosmetologen](${site}om.html)
- [Kontakt og gavekort](${site}kontakt.html)
- [Spørgsmål og svar](${site}faq.html)

# Priser
$priceLines
"@
[IO.File]::WriteAllText((Join-Path $root 'llms.txt'), $llms, $utf8)
"built sitemap.xml, robots.txt, llms.txt"
