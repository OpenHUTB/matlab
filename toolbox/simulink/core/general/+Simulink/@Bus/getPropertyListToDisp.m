function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    allProps=properties(this);
    builtinclassProps=properties('Simulink.Bus');



    subclassProps=setdiff(allProps,builtinclassProps,'stable');



    builtinclassPropsToDisp={'Description';'DataScope';'HeaderFile';'Alignment'};
    if sl('busUtils','NDIdxBusUI')
        builtinclassPropsToDisp{end+1}='PreserveElementDimensions';
    end
    builtinclassPropsToDisp{end+1}='Elements';

    if slfeature('SLDataDictionarySetUserData')>0
        builtinclassPropsToDisp{end+1}='TargetUserData';
    end

    allPropsToDisp=[subclassProps;builtinclassPropsToDisp];


