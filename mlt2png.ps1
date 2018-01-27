# MLTファイルを分割して画像化

# Firefoxのパスを記入
$firefox = "C:\Program Files\Mozilla Firefox\firefox.exe"

# AA画像の最大サイズ 横,縦
$maxsize = "--window-size=1280,1280"

$透過PNG  = $TRUE # $TRUE 又は $FALSE 又はコメントアウト
$タグ禁止 = $TRUE # < > ⇒ &lt; &gt;

$テンプレート = "template.htm"



if(!(Test-Path $firefox)){
	$firefox
	"Firefoxが見つかりません。"
	"インストール済みの場合はmlt2pngファイルを開いてパスを修正してください。"
	exit 1
}

if(get-Process -Name "firefox" -ErrorAction SilentlyContinue){
	"実行前にFirefoxを終了してください。"
	"見つからない場合はタスクマネージャーなどから探して終了できます。"
	exit 1
}

if(!(gcm magick -ErrorAction SilentlyContinue)){
	"magickコマンドが見つかりません。"
	"http://www.imagemagick.org/script/download.php#windows"
	"ImageMagick-*.*.*-*-Q16-x64-dll.exe又は、Q16-x86-dllなどをインストールしてください。"
	exit 1
}


[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "AA ファイル(*.MLT;*.TXT)|*.MLT;*.TXT|MLT ファイル(*.MLT)|*.MLT|すべてのファイル(*.*)|*.*"
$dialog.Title = "MLTファイルを選択してください"
if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::NG){
	exit 1
}
$MLT_FilePath = $dialog.FileName
if($MLT_FilePath -eq ""){
	exit 1
}
$MLTData = Get-Content $MLT_FilePath -Raw -ea stop
$template = Get-Content $テンプレート -Raw -ea stop
$MLT名 = [System.IO.Path]::GetFileNameWithoutExtension($MLT_FilePath)

$カレントディレクトリ = (Get-Item $PWD).FullName
$FirefoxArg = "-no-remote -private $maxsize -screenshot tmp_aa.png `"file://${カレントディレクトリ}\tmp_aa.htm`""

if(!(New-Item $MLT名 -itemType Directory -EA SilentlyContinue)){
	$result = [System.Windows.Forms.MessageBox]::Show("${MLT名}に上書きしますか？", "すでにフォルダが存在します。", "YesNo", "Question");
	if($result -ne "Yes"){
		exit 1
	}
}
$count = 0
$pnglist = @("<html>")
$list = $MLTData -Split "\[SPLIT\]"
$max = $list.Count
foreach ($txt in $list) {
	Remove-Item tmp_aa.png -ErrorAction SilentlyContinue
	Remove-Item tmp_aa.htm -ErrorAction SilentlyContinue
	if($タグ禁止){
		$txt = $txt.Replace("<","&lt;").Replace(">","&gt;")
	}
	$tmp = $template.Replace("{{aa}}",$txt)
	$outfilename = $count.ToString("000") + ".png" 
	$count += 1
	$outfilename + "を作成中...($count/$max)"
	$tmp | Out-File "tmp_aa.htm" -encoding default -ea stop
	Start-Process -FilePath $firefox -ArgumentList $FirefoxArg
    for($idx=0; $idx -lt 400; $idx++) {
		if(Test-Path "tmp_aa.png" -ea SilentlyContinue){
			break
		}
		Start-Sleep -m 50
	}
	if(!(Test-Path "tmp_aa.png")){
		"${outfilename}の作成に失敗しました"
		break
	}
	if($透過PNG){
		&magick convert -strip -trim tmp_aa.png -alpha on -fill none -draw 'color 0,0 replace' "${MLT名}/$outfilename"
	}else{
		&magick convert -strip -trim tmp_aa.png "${MLT名}/$outfilename"
	}
	# Remove-Item tmp_aa.htm -ErrorAction SilentlyContinue
	# Remove-Item tmp_aa.png -ErrorAction SilentlyContinue
	$pnglist += "${outfilename}<br /><img src=`"${outfilename}`"><hr />"
}
$pnglist+="</html>"
$pnglist | Out-File "${MLT名}\#index.htm" -encoding default -ea stop
"${カレントディレクトリ}\${MLT名}\ が作成されました。"
