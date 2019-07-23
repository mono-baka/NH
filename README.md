# NH circle share folder
hello:位置、方位を取得、ライブドア提供の天気APIから宇都宮の天気を表示<br>  
connect_v0:位置、方位を取得、google spreadsheetから値を取得<br>  
connect_v0_1:uuid、位置、方位を取得しspreadsheetへurlクエリで送信、spreadsheetからメッセージ取得<br>  
細かい説明はソースコード参照

## connect_v0_1説明
### アプリ動作説明
 起動後、ボタンを押すとspreadsheetにuuid longitude latitude compassが書き込まれる<br>  
 
 spreadsheet(URL=https://docs.google.com/spreadsheets/d/1QoUJ04bj1sw9MNZ2GXShHsBfVUnRHMhX8pczXC4hgfM/edit#gid=0)の内容<br>  
 <img src="https://github.com/mono-baka/NH/blob/master/1.png" width="500"><br>  
 <br>  
 全体の流れとしては<br>  
 1,ボタン押すとspreadsheetにgetリクエスト<br>  
 2,getした値をiphone下部のdebugコンソールへ表示<br>  
 <br>  
 <br>  
### spreadsheet説明
spreadsheet側でも自作のスクリプトが走っている（swiftのそれとはまるで違う言語、java scriptっぽい？）<br>  
仕事としては<br>  
1. getリクエスト（http通信で調べるべし）が来る
2. urlクエリでuuid,logitude,latitude,compassが投げられたのに対しuuidが新規かどうかを判断
3. 新規だった場合：新しい行を作成　お古だった場合：該当する行を探し更新
4. ついでに右側他機データ格納用セルに"xxx"を入れる（voidだとエラー出るため）
5. 右側他機データ格納用セルのxxxをjson形式に変換、getリクエストの回答として送信

 ツール -> スクリプトエディタ -> 新しいタブでエディタ起動<br>  
 <img src="https://github.com/mono-baka/NH/blob/master/2.png" width="500">
 <br>  
 説明したら２時間くらいかかりそうなので"GAS"でググって

## 今後の展開
 （終了）これからspreadsheetのレイアウトを決めて送受信プロトコルを設定します<br>  
 メッセージ送信をpostリクエストかurlクエリか判断し7/30には１つのものとして動作できるものに仕上げます
 他、目的のアプリになるよう適宜改廃します
