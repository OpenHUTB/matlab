function tunableParameterInfo=getTunableParameterInfoforEml(this,slHandle)%#ok<INUSL>















    tunableParameterInfo=[];


    rto=get_param(slHandle,'RuntimeObject');


    sampleTime=rto.SampleTimes(1);


    chartID=sfprivate('block2chart',slHandle);
    r=sfroot;
    chartUddH=r.idToHandle(chartID);
    params=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');


    for ii=1:numel(params)

        paramVal=params(ii).Name;

        tunableParamName=hdlbuiltinimpl.EmlImplBase.getTunableParameter(slHandle,paramVal);
        if~isempty(tunableParamName)
            paramType=params(ii).CompiledType;

            isComplex=0;
            if strcmp(params(ii).ParsedInfo.Complexity,'on')
                isComplex=1;
            end

            dims=1;
            arraySize=params(ii).ParsedInfo.Array.Size;
            if~isempty(arraySize)
                dims=arraySize;
            end

            dataType=getpirsignaltype(paramType,isComplex,dims);

            info=struct();
            info.ParameterName=tunableParamName;
            info.PropertyName='';
            info.DataType=dataType;
            info.SampleTime=sampleTime;

            tunableParameterInfo=[tunableParameterInfo,info];%#ok<AGROW>
        end
    end
end
