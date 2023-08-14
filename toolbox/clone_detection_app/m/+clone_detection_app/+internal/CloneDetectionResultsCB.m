
function CloneDetectionResultsCB(cbinfo)




    st=cbinfo.studio;















    context=st.App.getAppContextManager.getCustomContext('cloneDetectorApp');
    context.showResultsPerspective=~context.showResultsPerspective;

    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');

    if~isempty(ui)
        if context.showResultsPerspective
            CloneDetectionUI.internal.util.showEmbedded(ui.ddgBottom,'Bottom','Tabbed');
            pi=st.getComponent('GLUE2:DDG Component',DAStudio.message('sl_pir_cpp:creator:ddgBottomTitle'));
            if~isempty(pi)
                st.showComponent(pi);
            end
        else
            CloneDetectionUI.internal.util.hideEmbedded(ui.ddgBottom);
        end
    end

end


