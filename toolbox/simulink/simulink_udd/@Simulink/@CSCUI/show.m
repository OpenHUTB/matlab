function show(hUI)




    tr=DAStudio.ToolRoot;
    dlgs=tr.getOpenDialogs;
    thisDlg=[];

    for i=1:size(dlgs)
        tag=dlgs(i).DialogTag;
        if isequal(tag,'Tag_CSCUI')
            thisDlg=dlgs(i);
            break;
        end
    end

    if~isempty(thisDlg)
        thisDlg.show;
    end




