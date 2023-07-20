






function setupSlicerCriteria(obj,currentObjectiveDescr)
    import SldvDebugger.sldvModeEnum

    slicerConfig=SlicerConfiguration.getConfiguration(obj.model);
    dlg=slicerConfig.modelSlicer.dlg;
    dlgSrc=dlg.getSource;


    mapKey=obj.getCriteriaMapKey();
    criteriaIndex=obj.getCriteriaIndex(mapKey);
    if~isempty(criteriaIndex)
        slicerConfig.selectCriteria(criteriaIndex);
    else

        sliceCriteria=obj.addSliceCriteriaForDebugWorkflows();
        blockName=getBlockNameForCriteria(obj.DebugCtx.curBlkSid);
        sliceCriteria.name=[blockName,' : ',currentObjectiveDescr];
        sliceCriteria.description=getString(message(obj.getCriteriaDescription,...
        blockName,currentObjectiveDescr));
        sliceCriteria.refresh;
    end


    obj.criteriaMap(mapKey)=dlgSrc.Model.CurrentCriteria;
end

function name=getBlockNameForCriteria(SID)
    name=getfullname(SID(1));
    for idx=2:length(SID)
        name=[name,', ',getfullname(SID(idx))];%#ok<AGROW> 
    end
end
