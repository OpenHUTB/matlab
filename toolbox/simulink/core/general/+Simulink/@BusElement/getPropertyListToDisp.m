function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    allProps=properties(this);
    builtinclassProps=properties('Simulink.BusElement');



    subclassProps=setdiff(allProps,builtinclassProps,'stable');



    builtinclassPropsToDisp=...
    {'Name';'Complexity';'Dimensions';'DataType';...
    'Min';'Max';'DimensionsMode';'SampleTime';...
    'Unit';'Description'};



    valueTypePropsToDisp=...
    {'Name';'DataType';'SampleTime'};

    if slfeature('SLDataDictionarySetUserData')>0
        builtinclassPropsToDisp{end+1}='TargetUserData';
        valueTypePropsToDisp{end+1}='TargetUserData';
    end


    if(sl('busUtils','BusElementSampleTime')==1)&&(this.SampleTime(1)==-1)
        builtinclassPropsToDisp(contains(builtinclassPropsToDisp,'SampleTime'))=[];
        valueTypePropsToDisp(contains(valueTypePropsToDisp,'SampleTime'))=[];
    end

    if slfeature('SLValueType')==1&&startsWith(this.DataType,'ValueType:')
        allPropsToDisp=[subclassProps;valueTypePropsToDisp];
    else
        allPropsToDisp=[subclassProps;builtinclassPropsToDisp];
    end

end


