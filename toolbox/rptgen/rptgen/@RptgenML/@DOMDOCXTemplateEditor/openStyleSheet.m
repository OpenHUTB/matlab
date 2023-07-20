function openStyleSheet(this)





    mlreportgen.utils.word.open(this.TemplatePath);


    wordApp=mlreportgen.utils.word.wordapp();
    hWord=netobj(wordApp);
    hWord.Dialogs.Item(Microsoft.Office.Interop.Word.WdWordDialog.wdDialogStyleManagement).Display;