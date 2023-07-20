function tunableParameterInfo=getTunableParameterInfo(this,slHandle)















    tunableParameterInfo=[];


    rto=get_param(slHandle,'RuntimeObject');


    sampleTime=rto.SampleTimes(1);

    [TunableParamInputs,TunableParamStrs,TunableParamTypes]=...
    getTunableProperty(this,slHandle);







    TunablePropertyNames=fieldnames(TunableParamInputs);
    for ii=1:numel(TunablePropertyNames)
        tunablePropertyName=TunablePropertyNames{ii};
        tunableParamName=TunableParamInputs.(tunablePropertyName);
        tunableParamType=TunableParamTypes(strcmp(TunableParamStrs,...
        tunableParamName));

        info=struct();
        info.ParameterName=tunableParamName;
        info.PropertyName=tunablePropertyName;
        info.DataType=tunableParamType;
        info.SampleTime=sampleTime;

        tunableParameterInfo=[tunableParameterInfo,info];%#ok<AGROW>
    end

end
