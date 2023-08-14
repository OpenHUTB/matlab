function res=isCompatible(this,cvd)



    res=[];
    if~valid(cvd)
        return;
    end
    res=findTargetCvId(this,cvd);
end

function targetSubsys=findTargetCvId(this,cvd)
    targetSubsys={};

    topCvId=cv('get',this.rootID,'.topSlsf');
    if~cv('ishandle',topCvId)
        return;
    end
    allCvIds=[topCvId,cv('DecendentsOf',topCvId)];
    simulinkCvIds=cv('find',allCvIds,'slsfobj.origin',1);
    sourceCheckSum=cv('get',cvd.rootId,'.checksum');
    for idx=1:numel(simulinkCvIds)
        targetCheckSum=cv('get',simulinkCvIds(idx),'.cvChecksum');
        if isequal(targetCheckSum,...
            sourceCheckSum)
            targetSubsys{end+1}=getfullname(cv('get',simulinkCvIds(idx)','.handle'));%#ok<AGROW>
        end
    end
end
