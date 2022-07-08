1.
在此資料夾下，在終端機執行"make"即完成編譯動作。

2.
在終端機執行"java -cp antlr-3.5.2-complete-no-st3.jar:. myCompiler_test [test_file_name.c] > [test_file_name.ll]"，
可以將測試檔案的結果導入到一個.ll檔案。

3.
若有安裝llvm相關套件，可以在在終端機執行"[your PATH to lli] [test_file_name.ll]" (ex. "/usr/bin/lli-10 test1.ll"),
查看程式實際執行的效果。