function nesl_opensourcefile(hBlock)






    [sourceFile,isEditable]=simscape.compiler.sli.internal.sourcefilefromblock(hBlock);
    if isempty(sourceFile)
        blkName=pmsl_sanitizename(get_param(hBlock,'name'));
        errordlg(pm_message('physmod:ne_sli:nesl_opensourcefile:SourceFileNotFound',blkName));
        return;
    end


    if isEditable
        edit(sourceFile);
    else
        blkName=pmsl_sanitizename(get_param(hBlock,'name'));
        errordlg(pm_message('physmod:ne_sli:nesl_opensourcefile:SourceFileNotEditable',...
        sourceFile,blkName));
        return;
    end

end
