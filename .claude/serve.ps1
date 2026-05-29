$root = Split-Path $PSScriptRoot -Parent
$port = 8080
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $local = $req.Url.LocalPath.TrimStart('/')
    if ($local -eq '' -or $local -eq '/') {
        $local = 'onepage_b2b_tag_dashboard_dark_v8.html'
    }
    $file = Join-Path $root $local
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [System.IO.Path]::GetExtension($file).ToLower()
        $res.ContentType = if ($ext -eq '.html') { 'text/html; charset=utf-8' }
                           elseif ($ext -eq '.js') { 'application/javascript' }
                           elseif ($ext -eq '.css') { 'text/css' }
                           else { 'application/octet-stream' }
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $local")
        $res.OutputStream.Write($msg, 0, $msg.Length)
    }
    $res.OutputStream.Close()
}
