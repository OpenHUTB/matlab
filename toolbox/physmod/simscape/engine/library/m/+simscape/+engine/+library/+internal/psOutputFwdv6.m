function out=psOutputFwdv6(in)




    out.NewBlockPath='';
    instanceData=in.InstanceData;
    if~ismember('VectorFormat',{instanceData.Name})
        instanceData(end+1)=struct('Name','VectorFormat','Value','1-D array');
    end
    out.NewInstanceData=instanceData;
end
