function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    allProps=properties(this);
    builtinclassProps=properties('Simulink.ConnectionBus');



    subclassProps=setdiff(allProps,builtinclassProps,'stable');



    builtinclassPropsToDisp={'Description';'Elements'};

    allPropsToDisp=[subclassProps;builtinclassPropsToDisp];
end


