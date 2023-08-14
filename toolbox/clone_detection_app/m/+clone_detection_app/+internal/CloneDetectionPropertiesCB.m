function CloneDetectionPropertiesCB(cbinfo)




    st=cbinfo.studio;















    context=st.App.getAppContextManager.getCustomContext('cloneDetectorApp');
    context.showPropertiesPerspective=~context.showPropertiesPerspective;

    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        if context.showPropertiesPerspective
            CloneDetectionUI.internal.util.showEmbedded(ui.ddgRight,'Right','Tabbed');
            pi=st.getComponent('GLUE2:DDG Component',DAStudio.message('sl_pir_cpp:creator:ddgRightTitle'));
            if~isempty(pi)
                st.showComponent(pi);
            end
        else
            CloneDetectionUI.internal.util.hideEmbedded(ui.ddgRight);
        end
    end
end


