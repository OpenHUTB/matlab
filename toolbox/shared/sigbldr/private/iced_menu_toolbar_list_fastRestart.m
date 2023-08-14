function menuList=iced_menu_toolbar_list_fastRestart(figMenu,channelContext,toolbar)





    menuList=[];

    figMenuFields={'FileMenuImportFile','FileMenuSlBlock',...
    'EditMenuCut','EditMenuCopy','EditMenuPaste','EditMenuDelete',...
    'SignalMenuNew','SignalMenuNewConstant','SignalMenuNewStep',...
    'SignalMenuNewSquare','SignalMenuNewPulse','SignalMenuNewTriangle',...
    'SignalMenuNewSin','SignalMenuNewGaussian','SignalMenuNewPrbn',...
    'SignalMenuNewPoisson','SignalMenuNewImport',...
    'SignalMenuChanIndex','SignalMenuOutput'};

    for fieldName=figMenuFields
        menuList(end+1)=figMenu.(fieldName{1});
    end

    chanMenuFields={'SignalCntxtCut','SignalCntxtCopy','SignalCntxtPaste',...
    'SignalCntxtDelete'};

    for fieldName=chanMenuFields
        menuList(end+1)=channelContext.(fieldName{1});
    end

    toolbarNames={'constantSig','stepSig','pulseSig','copy','cut'};

    for fieldName=toolbarNames
        menuList(end+1)=toolbar.(fieldName{1});
    end


