function postCopyBlock(this,hBlock)












    try

        this.addBlock(hBlock,false);

    catch exception




        showErrorDlg(exception.message);
        rethrow(exception);

    end



