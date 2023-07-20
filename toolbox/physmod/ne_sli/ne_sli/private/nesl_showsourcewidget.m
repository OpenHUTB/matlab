function showWidget=nesl_showsourcewidget(hBlock)







    disabled=nesl_private('nesl_disablesourcewidget');
    showWidget=false;
    [isDisabled,disabledExt]=disabled();
    if isDisabled&&isempty(disabledExt)
        return;
    end


    [sourceFile,isEditable]=simscape.compiler.sli.internal.sourcefilefromblock(hBlock);

    [fileDir,fileBase,fileExt]=fileparts(sourceFile);
    if isDisabled&&any(strcmp(fileExt,disabledExt))
        return;
    end

    showWidget=isEditable;


end
