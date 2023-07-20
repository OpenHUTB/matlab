function openFuncSpecPage(mdlName)




    configset.showParameterGroup(mdlName,{'Code Generation','Interface'});

    tr=DAStudio.ToolRoot;
    dlg=tr.getOpenDialogs;
    for i=1:length(dlg)
        if isa(dlg(i).getSource,'Simulink.ConfigSet')
            dlg=dlg(i);
            break;
        end
    end
    imd=DAStudio.imDialog.getIMWidgets(dlg);

    clickbox=find(imd,'Tag','Tag_ConfigSet_RTW_ERT_GenCustomStepWrapper');
    clickbox.click;
