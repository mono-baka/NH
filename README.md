# 目指すシステム
２つのシステム（プログラム）を想定<br>  
1. アプリ（送受信）
2. サーバー(spread sheet)
<br>送受信はサーバーを介して行われる
## アプリに必要な機能
### 想定使用手順(送信)
1. アプリが送信メッセージを音声認識
2. アプリが認識文字列を位置と共にサーバーへ送信（HTTP通信：Postリクエスト）
3. サーバーはjava script言語による処理で最も近い個体にセル入力
### 想定使用手順(受信)
1. アプリが個体識別番号(uuid)、位置、方位をサーバーへ通知(HTTP通信：Getリクエスト)
2. サーバーはjava script言語による処理で個体情報をセルにリストアップ
3. サーバーは送信者用セル部分をお返しにアプリへ返す
<br>  
<img src="https://github.com/mono-baka/NH/blob/master/3.png"><br>  

## サーバー（笑）について
spreadsheetのリンク(URL="https://docs.google.com/spreadsheets/d/1QoUJ04bj1sw9MNZ2GXShHsBfVUnRHMhX8pczXC4hgfM/edit?usp=sharing")<br>   
スクリプトのリンク(URL="https://script.google.com/d/1ViP1VshUX4b69YLqoCKJCOEyZP5-tGvNe-nZx5P9qtG8R45gzZQmHliC/edit?usp=sharing")<br>   
間違って編集して動かなくなったらブチギレて家まで来るので編集不可。デバッグは各自コピペして自分のプロジェクト内で実行すること<br>   

## 開発途上アプリ一覧
hello:位置、方位を取得、ライブドア提供の天気APIから宇都宮の天気を表示<br>  
connect_v0:位置、方位を取得、google spreadsheetから値を取得<br>  
connect_v0_1:uuid、位置、方位を取得しspreadsheetへurlクエリで送信、spreadsheetからメッセージ取得<br>  
connect_v0_2:送信、受信など基本的システム完成に伴いβ版の0シリーズ終了<br>  
細かい説明はソースコード参照

## connect_v0_2説明
### アプリ動作説明
<img src="https://github.com/mono-baka/NH/blob/master/2019-07-30%2023.23.03.png" width="500"><br>   
getは実機では1[Hz]で呼ばれる<br>   
実際に受信者がgetを押し、サーバー（シート）にGet要求したところ<br>   
<img src="https://github.com/mono-baka/NH/blob/master/s4.png" width="500"><br>   
サーバーはすべての使用者の位置、方位を把握し続ける<br>   
送信者として別の号機（SIM機）を用意しPost要求<br>   
<img src="https://github.com/mono-baka/NH/blob/master/5.png" width="500"><br>   
サーバーによって最も近い受信者の"xxx"部分に送信者のデータが書き込まれる、ついでに空いてる受信者messageキーに相対距離も入れている（使用法検討中）<br>   
この状態で受信者が（送信者ではない）再びGet要求<br>   
<img src="https://github.com/mono-baka/NH/blob/master/2019-07-30%2023.22.12.png" width="500"><br>   
受信者の元に送信者の情報とmessage「yeaaar」が届く
### 今後の展開
宮田の作ってくれた音声認識と組み合わせます（～今週末）<br>   
動作したビデオをMG報告会までに撮ります

## connect_v0_1説明
### アプリ動作説明
 起動後、ボタンを押すとspreadsheetにuuid longitude latitude compassが書き込まれる<br>  
 
 spreadsheet(URL="https://docs.google.com/spreadsheets/d/1QoUJ04bj1sw9MNZ2GXShHsBfVUnRHMhX8pczXC4hgfM/edit?usp=sharing")の内容<br>  
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
