function out=getSignpostInfo(signpostFile)












    try
        sp=hwconnectinstaller.SignpostReader(signpostFile);
    catch %#ok<CTCH>

        out={};
        return;
    end


    out={
    sp.PackageName
    sp.FullName
    sp.BaseProduct
    };
