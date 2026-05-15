### Lazy Git
$msg = "Date: $(Get-Date)"
$msg

git add .
git commit -m $msg
git push

