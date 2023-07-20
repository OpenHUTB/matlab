function out=changePlatformWarningDlg(mdl,platform,outputText)




    out=true;
    cgb=get_param(mdl,'CodeGenBehavior');
    current=coder.internal.toolstrip.util.getPlatformType(mdl);
    set_param(mdl,'CodeGenBehavior','Default');
    if strcmp(cgb,'None')
        if isa(getActiveConfigSet(mdl),'Simulink.ConfigSetRef')

            return
        end
        pf=get_param(mdl,'PlatformDefinition');
        if isempty(platform)
            defaultAP=configset.internal.getApplicationPlatformName;
            if strcmp(pf,defaultAP)

            else
                set_param(mdl,'PlatformDefinition',defaultAP);
            end
        else
            if~strcmp(pf,platform)
                set_param(mdl,'PlatformDefinition',platform);
            end
        end

        return
    elseif(current==0&&isempty(platform))||...
        (current==1&&~isempty(platform))


        return
    end

    text=message('ToolstripCoderApp:toolstrip:OutputChangeWarning',outputText).getString;
    dp=DAStudio.DialogProvider;
    title=message('ToolstripCoderApp:toolstrip:PlatformSwitchingWarningDialogTitle').getString;
    btnOK=message('ToolstripCoderApp:toolstrip:PlatformSwitchingWarningDialogOK').getString;
    btnCancel=message('ToolstripCoderApp:toolstrip:PlatformSwitchingWarningDialogCancel').getString;
    answer=dp.questdlg(text,title,{btnOK,btnCancel},btnCancel);
    if strcmp(answer,btnOK)
        set_param(mdl,'PlatformDefinition',platform);
        set_param(mdl,'CodeGenBehavior','Default');
    else
        out=false;
    end
