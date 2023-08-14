function outData=sl_postprocess(inData)


    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;
    outData.NewInstanceData=inData.InstanceData;

    pIdx=find(~cellfun(@isempty,strfind(ParameterNames,'ActuationMode')));
    for idx=pIdx
        if isempty(strfind(outData.NewInstanceData(idx).Name,'Torque'))...
            &&isempty(strfind(outData.NewInstanceData(idx).Name,'Motion'))

            outData.NewInstanceData(idx).Name=...
            strrep(inData.InstanceData(idx).Name,'ActuationMode',...
            'TorqueActuationMode');
            if strcmp(inData.InstanceData(idx).Value,'TorqueForceActuation')||...
                strcmp(inData.InstanceData(idx).Value,'TorqueActuation')
                outData.NewInstanceData(idx).Value='InputTorque';
            else
                outData.NewInstanceData(idx).Value='NoTorque';
            end
        end
    end




    outData=simmechanics.library.sl_postprocess(outData);