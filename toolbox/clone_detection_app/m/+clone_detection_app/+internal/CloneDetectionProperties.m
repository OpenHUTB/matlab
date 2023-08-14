function CloneDetectionProperties(cbinfo,action)

    st=cbinfo.studio;
    pi=st.getComponent('GLUE2:DDG Component',DAStudio.message('sl_pir_cpp:creator:ddgRightTitle'));







    context=st.App.getAppContextManager.getCustomContext('cloneDetectorApp');
    if isempty(context)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    if isempty(pi)||~pi.isVisible
        context.showPropertiesPerspective=0;
    else
        context.showPropertiesPerspective=1;
    end




    if context.showPropertiesPerspective
        action.selected=1;



    else
        action.selected=0;



    end
end