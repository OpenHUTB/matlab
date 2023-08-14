function[outData]=transformAccumulatorR2015a(inData)



    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;

    if(ismember('penetr_coeff',parameterNames))...
        &&(~ismember('stiff_coeff',parameterNames))




        instanceData(end+1).Name='stiff_coeff';
        instanceData(end).Value='0';
    end

    outData.NewInstanceData=instanceData;

end

