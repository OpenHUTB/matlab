function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    allProps=properties(this);
    builtinclassProps=properties('Simulink.AliasType');



    subclassProps=setdiff(allProps,builtinclassProps,'stable');



    builtinclassPropsToDisp=...
    {'Description';'DataScope';'HeaderFile';'BaseType'};

    if slfeature('SLDataDictionarySetUserData')>0
        builtinclassPropsToDisp{end+1}='TargetUserData';
    end

    allPropsToDisp=[subclassProps;builtinclassPropsToDisp];

end


