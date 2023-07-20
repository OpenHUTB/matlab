function out=util_resizeUsingWSVar(name,value,isValue)



    try
        out=initFromValue(value,isValue);

        testComp=Sldv.Token.get.getTestComponent;
        if isValue
            param_runtime_type='';
            if isfield(testComp.analysisInfo,'paramsRunTimeTypes')&&...
                ~isempty(testComp.analysisInfo.paramsRunTimeTypes)&&...
                isfield(testComp.analysisInfo.paramsRunTimeTypes,name)
                param_runtime_type=testComp.analysisInfo.paramsRunTimeTypes.(name);
            end

            if~isempty(param_runtime_type)
                if iscell(param_runtime_type)
                    param_runtime_type=param_runtime_type{1};
                end
                out=sldvshareprivate('getTypedValue',value,param_runtime_type,false,testComp.analysisInfo.analyzedModelH);
            end
        end

        dataAccessor=Simulink.data.DataAccessor.create(get_param(testComp.analysisInfo.analyzedModelH,'name'));
        varId=dataAccessor.identifyByName(name);
        wsVal=dataAccessor.getVariable(varId);
        if isa(wsVal,'Simulink.Parameter')
            dimension=wsVal.Dimensions;
        else
            dimension=size(wsVal);
        end

        out=reshape(out,dimension);
    catch Mex %#ok<NASGU>
        out=initFromValue(value,isValue);
    end

    function out=initFromValue(aValue,aIsValue)
        if aIsValue&&(ischar(aValue)||iscell(aValue)||isstring(aValue))
            out=str2double(aValue);
        else
            out=aValue;
        end
