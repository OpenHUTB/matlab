function[period,event]=findTaskPeriod(gcbh)
















    tskBlk=[];
    thisBlk=gcbh;
    cond=true;
    period=-1;
    event='';
    while cond
        parentBlk=get_param(thisBlk,'Parent');
        inpPorts=get_param(parentBlk,'PortConnectivity');
        for i=1:numel(inpPorts)
            if isequal(inpPorts(i).Type,'trigger')
                tskBlk=inpPorts(i).SrcBlock;
                cond=false;
                break
            end
        end
        thisBlk=parentBlk;
    end
    blkMask=Simulink.Mask.get(tskBlk);
    idx=ismember({blkMask.Parameters.Name},'taskPeriod');
    if~isempty(idx)&&any(idx)
        period=str2double(get_param(tskBlk,'taskPeriod'));
        event=get_param(tskBlk,'taskEvent');
    end
end