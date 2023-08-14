function CloneDetectionResults(cbinfo,action)

    st=cbinfo.studio;
    pi=st.getComponent('GLUE2:DDG Component',DAStudio.message('sl_pir_cpp:creator:ddgBottomTitle'));


    context=st.App.getAppContextManager.getCustomContext('cloneDetectorApp');

    if isempty(context)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    if isempty(pi)||~pi.isVisible
        context.showResultsPerspective=0;
    else
        context.showResultsPerspective=1;
    end



    if context.showResultsPerspective
        action.selected=1;



    else
        action.selected=0;



    end
end