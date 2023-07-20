function[ok,msg]=tdkfpgaConfigDlgAction(hDlg,hObj,action,page)%#ok










    ok=1;
    msg='';


    if~istdkfpgainstalled
        return;
    end

    if strcmp(action,'apply')
        hObj.sourceToConfigSet;
    elseif strcmp(action,'cancel')
        hObj.configSetToSource;
    end
