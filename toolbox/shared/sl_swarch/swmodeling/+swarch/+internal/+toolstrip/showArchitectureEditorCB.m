function showArchitectureEditorCB(userData,cbinfo)





    studio=cbinfo.studio;
    mgr=swarch.internal.spreadsheet.UIManager.Instance;
    ss=mgr.getSpreadsheet(studio);


    if~isempty(ss)
        ss.toggleVisibility();
    else
        mgr.createSpreadsheet(studio,userData);
    end
end
