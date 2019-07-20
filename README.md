# NH circle share folder
hello:位置、方位を取得、ライブドア提供の天気APIから宇都宮の天気を表示<br>  
connect_v0:位置、方位を取得、google spreadsheetから値を取得<br>  
細かい説明はソースコード参照

## connect_v0説明

 - 起動画面、load buttonでAPIにGetリクエスト
 <img src="https://github.com/mono-baka/NH/blob/master/2019-07-20%2012.34.40.png" width="300"> 
 - load button 押下後
 <img src="https://github.com/mono-baka/NH/blob/master/2019-07-20%2012.34.58.png" width="300">
 
 spreadsheet（これから整備）の内容
 <img src=https://github.com/mono-baka/NH/blob/master/aaa.png" width="500">
<br>  
 サーバー（笑）の流れとしては<br>  
 ボタン押すとspreadsheetにgetリクエスト<br>  
 getした値をiphone下部のdebugコンソールへ表示<br>  
 <br>  
 <br>  
##今後の展開
 これからspreadsheetのレイアウトを決めて送受信プロトコルを設定します
