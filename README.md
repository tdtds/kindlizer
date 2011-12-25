# Kindlizer #

## Rakefile for self publishing ebook of Kindle made by scanning paper book.

Copy Rakefile to your work directory and modify parameters by your environment:

*  SRC (must): source PDF file name in current directory.
*  TOP, BOTTOM, LEFT, RIGHT: default margins (pixel) of trimming.
*  SIZE: adjust image size by destination format.
*  LEVEL (optional): level option of ImageMagic.

for Debian or Ubuntu user, needs packages below:

* poppler-utils
* poppler-data
* imagemagick
* pdftk
* sam2p

----

## 自炊したPDFから余白を取り除いてKindle向けに最適化するRakefile

Kindleで自炊化PDFを読もうとすると、紙面の余白のせいで文字がずいぶんと小さくなります。このRakefileでトリミングすることで、Kindle向けに余白を最小化したPDFファイルを生成しましょう。

ImageMagicの機能を使って余白を自動認識し、ギリギリまで追い込みます。ただし自動で余白として認識されないノンブルなどの余計なものをあらかじめカットしたい場合にはTOP/BOTTOM/LEFT/RIGHTの値をチューニングして下さい。

再作成する画像は6インチ版Kindleの表示エリアに合わせてリサイズされるので、もっとも美しく読める状態になります。

### カスタマイズ
PDFファイルごとにRakefileをコピーして、以下の値を書き換えて使って下さい:

*  SRC (必須): 最適化元のPDFファイル
*  TOP, BOTTOM, LEFT, RIGHT: あらかじめカットしておく領域(ピクセル)
*  SIZE: Kindleを縦持ち(portrate)にして読むか横持ち(landscape)にして読むか
*  LEVEL (optional): ImageMagicのlevelオプション。地の紙に色が付いている場合に

以下の環境変数を指定すると、それぞれフェーズ2(ppm→pngを行うconvertコマンド)とフェーズ3(png→pdfを行うsam2pコマンド)にオプションを追加できます:

* KINDLIZER_PHASE2_OPT: convertコマンドへのオプション(推奨は「-depth 4」)
* KINDLIZER_PHASE3_OPT: sam2pコマンドへのオプション(上記PHASE2で「-depth 4」を指定しない場合に「-c:jpeg」を指定

convertコマンドのいくつかのバージョンでは「-depth 4」がサポートされていないため、標準では採用していませんが、サポートされている場合には非常にコンパクトなPDFファイルを生成できるため、強く推奨します。

### 実行
Rakeコマンドに指定できるタスクは以下です:

* rake : 全行程を一気に実施し、SRC.out.pdfというファイルを作成します
* rake ppm : 第一工程。PDFから画像の抽出のみ行います
* rake png : 第二工程。第一工程で抽出したPPMファイルをKindle向けPNGファイルに変換します
* rake pdf : 第三工程。PNGファイルとメタデータを使って変換後のPDFを生成します
* rake metadata : 元PDFからメタデータを抽出します
* rake zip : 第二工程までを実行し、PNGファイルをzipアーカイブします。SIZEは600x800にするといいでしょう

最終的に、SRC.out.pdfというファイルができます。Kindleに転送してお読み下さい。ファイル名が書名になります。また、metadata.txtのAuthorを英数字で書き換えると、Kindle上に著者名が(英語で)表示されます。

### 参考

@kamosawaさんが詳細な解説ドキュメントを書いてくださっています。

* [kindlizerの使い方](http://d.hatena.ne.jp/kamosawa/20111116)

