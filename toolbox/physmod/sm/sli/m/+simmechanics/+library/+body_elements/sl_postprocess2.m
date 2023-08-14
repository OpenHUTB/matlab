function outData=sl_postprocess2(inData)



    if isfield(inData,'InstanceData')
        outData.NewInstanceData=inData.InstanceData;
    else
        outData.NewInstanceData=inData.NewInstanceData;
    end
    outData.NewBlockPath='';

    if~isempty(outData.NewInstanceData)
        [ParameterNames{1:length(outData.NewInstanceData)}]=outData.NewInstanceData.Name;

        densityBased=pm_message('mech2:messages:parameters:inertia:geometricInertia:densityBased:ParamName');
        basedOnType=pm_message('mech2:messages:parameters:inertia:geometricInertia:basedOnType:ParamName');
        dbi=strncmp(densityBased,ParameterNames,length(densityBased));

        if any(dbi)
            isDensityBased=outData.NewInstanceData(dbi).Value;
            outData.NewInstanceData(dbi).Name=basedOnType;
            if strcmpi(isDensityBased,'on')
                outData.NewInstanceData(dbi).Value='Density';
            else
                outData.NewInstanceData(dbi).Value='Mass';
            end
        end
    end
