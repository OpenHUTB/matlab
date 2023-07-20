function menuList=iced_menu_toolbar_list(figMenu,channelContext,toolbar,tabselector)





    menuList=[];

    figMenuFields={'FileMenuSave','FileMenuSaveas','FileMenuSlBlock',...
    'FileMenuImportFile',...
    'EditMenuCut','EditMenuCopy','EditMenuPaste','EditMenuDelete',...
    'SignalMenu','GroupMenu',...
    'SignalMenuNew','SignalMenuNewConstant','SignalMenuNewStep',...
    'SignalMenuNewSquare','SignalMenuNewPulse','SignalMenuNewTriangle',...
    'SignalMenuNewSin','SignalMenuNewGaussian','SignalMenuNewPrbn',...
    'SignalMenuNewPoisson','SignalMenuNewImport',...
    'SignalMenuReplace','SignalMenuReplaceConstant','SignalMenuReplaceStep',...
    'SignalMenuReplaceSquare','SignalMenuReplacePulse',...
    'SignalMenuReplaceTriangle','SignalMenuReplaceSin',...
    'SignalMenuReplaceGaussian','SignalMenuReplacePrbn',...
    'SignalMenuReplacePoisson','SignalMenuReplaceImport',...
    'SignalMenuChanIndex'};

    for fieldName=figMenuFields
        menuList(end+1)=figMenu.(fieldName{1});
    end

    chanMenuFields={'SignalCntxtCut','SignalCntxtCopy','SignalCntxtPaste',...
    'SignalCntxtDelete','SignalCntxtRename'};

    for fieldName=chanMenuFields
        menuList(end+1)=channelContext.(fieldName{1});
    end


    toolbarNames={'constantSig','stepSig','pulseSig'};

    for fieldName=toolbarNames
        menuList(end+1)=toolbar.(fieldName{1});
    end

    tabselectorNames={'axesH'};

    for fieldName=tabselectorNames
        menuList(end+1)=tabselector.(fieldName{1});
    end

