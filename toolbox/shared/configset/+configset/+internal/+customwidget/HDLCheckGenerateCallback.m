function updateDeps=HDLCheckGenerateCallback(cs,msg)





    updateDeps=false;
    cs=cs.getConfigSet;
    hdlcc=cs.getComponent('HDL Coder');

    mdlName=hdlcc.getModelName;
    hdriver=hdlcc.getHDLCoder;
    if~strcmp(mdlName,hdriver.ModelName)
        hdriver.ModelName=mdlName;
    end

    commitBuild=slprivate('checkSimPrm',cs);
    if commitBuild
        try
            button=msg.name;
            dlg=msg.dialog;
            cs=getActiveConfigSet(mdlName);
            isWebDialog=isa(dlg.getDialogSource,'configset.dialog.HTMLView');
            web=ConfigSet.DDGWrapper(dlg);
            if strcmp(button,'CheckHDLButton')
                if isWebDialog
                    web.disableDialog;
                else
                    cs.readonly='on';
                    cs.refreshDialog;
                end
                hdriver.checkhdl;
                if isWebDialog
                    web.enableDialog;
                else
                    cs.readonly='off';
                    cs.refreshDialog;
                end
            elseif strcmp(button,'GenerateHDL')
                if isWebDialog
                    web.disableDialog;
                else
                    cs.readonly='on';
                    cs.refreshDialog;
                end
                hdriver.makehdl;
                if isWebDialog
                    web.enableDialog;
                else
                    cs.readonly='off';
                    cs.refreshDialog;
                end
            end
        catch ME

            if isWebDialog
                web.enableDialog;
            else
                cs=getActiveConfigSet(mdlName);
                cs.readonly='off';
                cs.refreshDialog;
            end

            Simulink.output.Stage('HDLCoder','ModelName',mdlName,'UIMode',true);
            Simulink.output.error(ME,'Component','HDLCoder','Category','HDL');
        end
    end


