function out=solverConfigFwdv3(in)

    idx=strcmp({in.InstanceData.Name},'Accelerate');
    out.NewBlockPath='';
    out.NewInstanceData=in.InstanceData;
    out.NewInstanceData(idx)=[];

end
