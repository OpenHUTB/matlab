function cscuicallback(hDlg,widgetTag,tabIdx)





    hUI=getDialogSource(hDlg);

    switch widgetTag

    case 'tMainTabs'
        set(hUI,'MainActiveTab',tabIdx);
        hDlg.refresh;

    case 'tcscSubTabs'
        set(hUI,'CSCActiveSubTab',tabIdx);


    case 'subsysParamsddg'
        set(hUI,'ActiveTab',tabIdx);


    case 'tabContainer'



        helperTag=[widgetTag,'_ActiveTabHelper'];
        sigObjCache=getUserData(hDlg,helperTag);
        if~isempty(sigObjCache)
            sigObjCache.ActiveTab=tabIdx;
        end

    otherwise
        DAStudio.error('Simulink:dialog:InvalidCSCTagInCSCUICallBck',widgetTag);

    end



