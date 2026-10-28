$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8080/')
$listener.Start()
Write-Host 'Listening on http://localhost:8080/'

$root = 'C:\Users\evans\.gemini\antigravity\scratch\yatch-tz'

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $reqPath = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($reqPath)) { $reqPath = 'index.html' }
    $filePath = Join-Path $root $reqPath
    $res = $ctx.Response
    if (Test-Path $filePath -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      if ($filePath.EndsWith('.jpg') -or $filePath.EndsWith('.jpeg')) {
        $res.ContentType = 'image/jpeg'
      } elseif ($filePath.EndsWith('.png')) {
        $res.ContentType = 'image/png'
      } else {
        $res.ContentType = 'text/html; charset=utf-8'
      }
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
    }
    $res.OutputStream.Close()
  } catch {
    # Ignore transient client disconnects
  }
}
