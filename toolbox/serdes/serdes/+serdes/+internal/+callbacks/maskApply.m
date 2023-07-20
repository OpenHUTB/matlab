



function maskApply(block)
    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    blkObject=get_param(block,'Object');
    if isempty(dlgs)||isempty(blkObject)
        return
    end
    dlgSrc=blkObject.getDialogSource;
    if isempty(dlgSrc)
        return
    end
    for i=1:length(dlgs)
        openDlgSrc=dlgs(i).getDialogSource;
        if~isempty(openDlgSrc)&&isequal(dlgSrc,openDlgSrc)
            dlgs(i).apply;
        end
    end
end

