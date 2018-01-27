MLTファイルを連番で画像化するスクリプトです
画像化にFirefox、画像処理にImageMagickが必要になります。

Firefox
https://www.mozilla.org/ja/firefox/new/

ImageMagick Ver7 (magickコマンド)
http://www.imagemagick.org/script/download.php#windows

Win10home Powershell v5 にて作動確認


★mlt2png.ps1
　変換スクリプト本体。インストールしたFireFoxのパスを記入する必要があるので
　デスクトップのfirefoxショートカットを右クリックしプロパティからリンク先をコピーして
　スクリプト内の設定を書き換えてください。

★mlt2png.bat
　このファイルをダブルクリックするとMLT選択ダイアログが開き変換が始まります。
　スクリプトファイルをダブルクリックしても実行されないため必要になります。
　なお実行前にFireFoxをすべて終了してください。

★template.htm
　AAを画像化するときに使われるHTMLファイル
　{{aa}}の文字がAAに置き換わります。
　フォントサイズや行間、見栄えなどをスタイルシートで修正します。

　Firefoxで画像化されるときに固定縦横幅の画像となるので
　左上0,0地点の背景色で画像がトリミングされます。(magickコマンドを使用)

　さらに透明化PNGを作成する場合は、トリミング後の0,0地点の色が対象となります。

★MLTファイル
　TXTファイルなどでも画像化できます。
　template.htmに差し込む時に< > が &lt; &gt; に変換されます。

★tmp_aaファイル
　実行後に作成される一時ファイル。
　削除して問題ありません。
　HTMLファイルはSJISで出力される予定ですが違う場合は、METAタグをSJISから修正してください。

注意点：
　1枚1枚Firefoxで画像化する為、変換速度は低速となります。
