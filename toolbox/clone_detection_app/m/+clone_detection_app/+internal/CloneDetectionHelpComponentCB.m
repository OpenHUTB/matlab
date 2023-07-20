function CloneDetectionHelpComponentCB(cbinfo)

    st=cbinfo.studio;
    pi=st.getComponent('GLUE2:DDG Component','Clone Detection Help');

    if isempty(pi)

        sysHandle=SLStudio.Utils.getModelName(cbinfo);
        ui=get_param(sysHandle,'CloneDetectionUIObj');
        CloneDetectionUI.internal.util.showEmbedded(ui.ddgHelp,'Left','Tabbed');
        return;
    end

    if pi.isVisible
        st.hideComponent(pi);
    else
        st.showComponent(pi);
    end
end