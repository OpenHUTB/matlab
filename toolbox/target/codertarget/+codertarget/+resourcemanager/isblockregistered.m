function status=isblockregistered(hBlk)










    if locIsFirstSteOfSubsystemBuild
        status=true;
        return
    end

    if~codertarget.resourcemanager.isregistered(hBlk,'AllBlocks','BlockHandles')
        status=false;
    else
        blocks=codertarget.resourcemanager.get(hBlk,'AllBlocks','BlockHandles');
        blkh=get_param(hBlk,'Handle');
        status=ismember(blkh,blocks);
    end
end


function ret=locIsFirstSteOfSubsystemBuild
    tmpstk=dbstack;
    ret=(any(strcmp({tmpstk.name},'ss2mdl'))||...
    (any(strcmp({tmpstk.name},'makehdl'))));
end
