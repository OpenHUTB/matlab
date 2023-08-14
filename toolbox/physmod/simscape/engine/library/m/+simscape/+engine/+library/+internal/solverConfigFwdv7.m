function out=solverConfigFwdv7(in)




    out.NewBlockPath='';
    instanceData=in.InstanceData;
    if~ismember('ConsistencySolver',{instanceData.Name})
        instanceData(end+1)=struct('Name','ConsistencySolver','Value','NEWTON_FTOL');
    end
    out.NewInstanceData=instanceData;
end
