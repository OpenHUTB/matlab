function appAction=getAppAction(~)




    appAction='';

    if coder.internal.toolstrip.license.isEmbeddedCoder
        appAction='embeddedCoderAppAction';
    elseif coder.internal.toolstrip.license.isSimulinkCoder
        appAction='simulinkCoderAppAction';
    end

end

