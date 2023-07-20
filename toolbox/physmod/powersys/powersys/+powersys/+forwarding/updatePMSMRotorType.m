function[outData]=updatePMSMRotorType(inData)





    outData.NewBlockPath='';
    outData.NewInstanceData=[];
    instanceData=inData.InstanceData;


    parameterNames={inData.InstanceData.Name}';

    if(~ismember(parameterNames,'RotorType'))

        instanceData(end+1).Name='RotorType';
        instanceData(end).Value='Salient-pole';
    end

    outData.NewInstanceData=instanceData;