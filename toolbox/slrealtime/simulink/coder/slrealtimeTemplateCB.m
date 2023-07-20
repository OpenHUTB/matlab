function slrealtimeTemplateCB(action)





    switch action
    case 'SLRTPane'
        openCSPane({'Code Generation','Simulink Real-Time Options'});
    case 'SolverPane'
        openCSPane('Solver')
    otherwise

    end

end

function openCSPane(pane)
    if ischar(pane)
        pane={pane};
    end
    an=getCallbackAnnotation;
    cs=getActiveConfigSet(an.Parent);
    cs.view;
    configset.showParameterGroup(cs,pane);
end
