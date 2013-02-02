aloha usb driver in ruby for Mac OSX
===
[アロハUSB（ナンバーディスプレイアダプタ）](http://www.nikko-ew.co.jp/CTI/aloha_usb.html )  
![アロハUSB](https://raw.github.com/aloha-mahalo/aloha/master/doc/aloha_usb.gif)

アロハUSBをMacで使おうとしたけど、どこにもドライバーらしきものも見つからなかったので作ってみました。

インストール
--
1. まずアロハUSBが認識出来るようUSBドライバを入れる [PL2303 Mac OS X Driver Download ](http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=229&pcid=41)
2. Gemfileに`gem "aloha", git: "https://github.com/aloha-mahalo/aloha.git"`を追加し、`bundle install`
3. アロハUSBをMacに接続、電話を繋ぎ電源を入れる

使い方
--
まず、アロハUSBが繋がれているUSBシリアルポートを探します。
```bash
$ ls /dev/cu.usbserial*
/dev/cu.usbserial
```
複数出る場合は、下の手順をそれぞれで試してみてください。


```ruby
$ irb

require "aloha"
                                # ここに上で見つけたポートを設定
Aloha.wait_for_caller_infomation("/dev/cu.usbserial") do |time, number|
  # 電話がかかってくるまでこのブロックは呼ばれません
  # 電話がかかってくれば、アロハ受信時間、電話番号が通知されます
  puts time, number
end
```

