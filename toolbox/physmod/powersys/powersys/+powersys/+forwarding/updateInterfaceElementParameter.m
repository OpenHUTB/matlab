function[outData]=updateInterfaceElementParameter(inData)






    outData.NewBlockPath='';
    outData.NewInstanceData=[];
    instanceData=inData.InstanceData;


    parameterNames={inData.InstanceData.Name}';
    parameterValues={inData.InstanceData.Value}';

    filterParameterIdx=find(ismember(parameterNames,'Sd'));

    if strcmp(parameterValues(filterParameterIdx),'Simscape Power Systems side')
        instanceData(filterParameterIdx).Value='Specialized Power Systems side';
    end
    outData.NewInstanceData=instanceData;