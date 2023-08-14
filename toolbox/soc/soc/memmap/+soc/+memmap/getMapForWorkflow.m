function[status,statusMsg,mmap]=getMapForWorkflow(mdlH)
    mustSaveMap=false;
    status='';
    statusMsg='';

    savedMap=soc.memmap.getMemoryMap(mdlH);



    if isempty(savedMap)
        mmap=soc.memmap.genAutoMap(mdlH);
        mustSaveMap=true;
        status='info';
        statusMsg=message('soc:memmap:WorkflowNewAutoMap');




    elseif savedMap.isAutoMap

        newAutoMap=soc.memmap.genAutoMap(mdlH);
        [~,equalAuto]=soc.memmap.compareMaps(savedMap,newAutoMap);
        if~equalAuto
            mmap=newAutoMap;
            mustSaveMap=true;
            status='warning';
            statusMsg=message('soc:memmap:WorkflowRegenedAutoMap');
        else
            mmap=savedMap;
            mustSaveMap=false;
            status='info';
            statusMsg=message('soc:memmap:WorkflowExistingAutoMap');
        end



    else
        newAutoMap=soc.memmap.genAutoMap(mdlH);
        [compatibleWithAuto,~]=soc.memmap.compareMaps(savedMap,newAutoMap);
        if~compatibleWithAuto
            mmap='';
            mustSaveMap=false;
            status='error';
            statusMsg=message('soc:memmap:WorkflowBadCustomMap');
        else
            mmap=savedMap;
            mustSaveMap=false;
            status='info';
            statusMsg=message('soc:memmap:WorkflowExistingCustomMap');
        end
    end

    if mustSaveMap
        soc.memmap.setMemoryMap(mdlH,mmap);
    end
end
