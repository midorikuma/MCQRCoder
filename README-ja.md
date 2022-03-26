日本語 | [English](https://github.com/midorikuma/MCQRCoder)
# MCQRCoder
![2022-03-26_13 01 52](https://user-images.githubusercontent.com/39437361/160227041-d20aa054-1663-458a-9573-ef9225b1c93c.png)  
  
このリソースパックではマイクラ内で任意のQRコードを生成することができます。  
事前に用意した任意の文字列とマイクラ内で変化する任意の値を組み合わせて  
それらをまとめたものをQRコードとして表示します。  

### 表示方法

リソースパックを適用後、コマンド`give @p minecraft:leather_horse_armor{CustomModelData:1,display:{color:0}}`で  
入手したアイテムの見た目がQRコードとなります。  
またアイテムタグ`color`の値を任意の数値にすることでQRコード内の数値も変化します  
アイテムフレームやアーマースタンドにアイテムを持たせ、dataなどから任意の値を入れることで動的にQRコードを変えることもできます。  


## 表示の変更について

表示を変えるには`gentex_QR.py`を実行しテクスチャを変更する必要があります。  
(`gentex_QR.py`を実行するには Python と Pillow を導入して下さい)  
まずはファイル内にある`text ="Your score is %v(-1)"`を変更します  
任意の文字列中に`%v(ケタの表示範囲)`を入れることで、任意の値を表示させることができます。  
例：  
`text ="任意の値%v(-1)の下二桁は%v(2-1)です。"`  
`text ="あなたのクリアタイムは%v(-5):%v(4-3):%v(2-1)です。"`  
  
つぶやきのURLを生成したい場合には以下の文字列の後に文や値を置きます。  
`https://twitter.com/intent/tweet?text=`  
例：  
`text ="https://twitter.com/intent/tweet?text=あなたのスコアは%v(-1)です。"`  
`text ="https://twitter.com/intent/tweet?text=あなたのクリアタイムは%v(-5):%v(4-3):%v(2-1)です。"`  
  
上記の変更を行った後`gentex_QR.py`を実行し、生成された`display1.png`を  
`MCQRcodeRP\assets\minecraft\textures\item\custom_textures\MCQRCoder\display1.png`へ上書きし  
F3+T 等でリソースパックを再読み込みすることで表示が変更されます。  
