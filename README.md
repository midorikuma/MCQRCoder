English | [日本語](https://github.com/midorikuma/MCQRCoder/blob/main/README-ja.md)
# MCQRCoder
![2022-03-26_13 01 52](https://user-images.githubusercontent.com/39437361/160227041-d20aa054-1663-458a-9573-ef9225b1c93c.png)

This resource pack allows you to generate arbitrary QR codes.  
The QR Code is a combination of an arbitrary string prepared in advance and an arbitrary value that changes in Minecraft.  

### Display method

After applying the resource pack, the appearance of the item obtained with the command  
`give @p minecraft:leather_horse_armor{CustomModelData:1,display:{color:0}}` will be a QR code.  
Also, by setting the value of the item tag `color` to any value, the value in the QR code will also change.  
The QR code can also be changed dynamically by having the item in an item frame or armor stand and putting in any value from data command, etc.  


## Changing the display

To change the display, you need to run `gentex_QR.py` and change the texture.  
(To run `gentex_QR.py`, install Python and Pillow)  
First, change `text ="Your score is %v(-1)"` in the py file  
Any value can be displayed by putting `%v(display range of digits)` in any string.  
ex：  
`text ="The last two digits of any value %v(-1) are %v(2-1)"`  
`text ="Your clear time is %v(-5):%v(4-3):%v(2-1)"`  
  
To generate a URL for a tweet, place a statement or value after the following string  
`https://twitter.com/intent/tweet?text=`  
ex：  
`text ="https://twitter.com/intent/tweet?text=Your score is %v(-1)"`  
`text ="https://twitter.com/intent/tweet?text=Your clear time is %v(-5):%v(4-3):%v(2-1)"`  
  
After making the changes, run `gentex_QR.py` and overwrite the generated `display1.png` into  
`MCQRcodeRP\assets\minecraft\textures\item\custom_textures\MCQRCoder\display1.png`  
Finally, use F3+T to reload the resource pack to change the display.
