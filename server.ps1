# Tiny local web server for the Raffle Draw (uses only built-in Windows PowerShell).
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$types = @{ '.html'='text/html; charset=utf-8'; '.txt'='text/plain; charset=utf-8'; '.csv'='text/plain; charset=utf-8';
  '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.png'='image/png'; '.gif'='image/gif'; '.webp'='image/webp'; '.bmp'='image/bmp' }

$listener = $null
foreach ($port in 8000..8020) {
  $l = New-Object System.Net.HttpListener
  $l.Prefixes.Add("http://localhost:$port/")
  try { $l.Start(); $listener = $l; break } catch { $l.Close() }
}
if (-not $listener) { Write-Host 'Could not start the local server (no free port 8000-8020).'; Read-Host 'Press Enter to exit'; exit 1 }

$url = "http://localhost:$port/index.html"
Write-Host "Raffle Draw running at $url"
Write-Host 'Keep this window open during the draw. Close it to stop.'
Start-Process $url

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $res = $ctx.Response
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if (-not $rel) { $rel = 'index.html' }
    $path = [IO.Path]::GetFullPath((Join-Path $root $rel))
    if ($path.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $path -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($path)
      $ext = [IO.Path]::GetExtension($path).ToLower()
      $res.ContentType = if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' }
      $res.Headers.Add('Cache-Control', 'no-store')
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else { $res.StatusCode = 404 }
  } catch { $res.StatusCode = 500 }
  finally { $res.Close() }
}
