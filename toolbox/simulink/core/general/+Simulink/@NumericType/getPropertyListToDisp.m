function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    allProps=properties(this);
    builtinclassProps=properties('Simulink.NumericType');



    subclassProps=setdiff(allProps,builtinclassProps,'stable');



    switch this.DataTypeMode
    case{'Boolean','Single','Double','Half'}
        builtinclassPropsToDisp={'DataTypeMode'};
    case 'Fixed-point: unspecified scaling'
        builtinclassPropsToDisp={'DataTypeMode','Signedness','WordLength'};
    case 'Fixed-point: binary point scaling'
        builtinclassPropsToDisp={'DataTypeMode','Signedness','WordLength','FractionLength'};
    case 'Fixed-point: slope and bias scaling'
        builtinclassPropsToDisp={'DataTypeMode','Signedness','WordLength','Slope','Bias'};
    otherwise
        assert(false,'Unhandled case');
    end

    if~strcmp(this.DataTypeOverride,'Inherit')
        builtinclassPropsToDisp{end+1}='DataTypeOverride';
    end

    builtinclassPropsToDisp{end+1}='IsAlias';
    builtinclassPropsToDisp{end+1}='DataScope';
    builtinclassPropsToDisp{end+1}='HeaderFile';
    builtinclassPropsToDisp{end+1}='Description';

    if slfeature('SLDataDictionarySetUserData')>0
        builtinclassPropsToDisp{end+1}='TargetUserData';
    end

    allPropsToDisp=[subclassProps;builtinclassPropsToDisp'];

end


