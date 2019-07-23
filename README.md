# NH circle share folder
hello:位置、方位を取得、ライブドア提供の天気APIから宇都宮の天気を表示<br>  
connect_v0:位置、方位を取得、google spreadsheetから値を取得<br>  
connect_v0_1:uuid、位置、方位を取得しspreadsheetへurlクエリで送信、spreadsheetからメッセージ取得<br>  
細かい説明はソースコード参照

## connect_v0_1説明

 起動後、ボタンを押すとspreadsheetにuuid longitude latitude compassが書き込まれる<br>  
 
 spreadsheet（これから整備）の内容<br>  
 <img src="https://github.com/mono-baka/NH/blob/master/aaa.png" width="500"><br>  
 <br>  
 全体の流れとしては<br>  
 1,ボタン押すとspreadsheetにgetリクエスト<br>  
 2,getした値をiphone下部のdebugコンソールへ表示<br>  
 <br>  
 <br>  
## 今後の展開
 これからspreadsheetのレイアウトを決めて送受信プロトコルを設定します<br>  
 他、目的のアプリになるよう適宜改廃します
