function CloneDetectionHelpComponent(cbinfo,action)

    st=cbinfo.studio;
    pi=st.getComponent('GLUE2:DDG Component',DAStudio.message('sl_pir_cpp:creator:helpDialogTitle'));

    if isempty(pi)||~pi.isVisible
        action.selected=0;
    else
        action.selected=1;
    end
end