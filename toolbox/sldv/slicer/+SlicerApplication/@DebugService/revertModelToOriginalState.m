






function revertModelToOriginalState(obj)


    set_param(obj.model,'FastRestart',obj.originalfastRestartValue);

    for i=1:numel(obj.modelRefs)
        set_param(obj.modelRefs{i},'dirty',...
        obj.originalDirtyFlagStatusMap(obj.modelRefs{i}));
    end


    obj.setIsDebugSessionActive(false);
    slicerConfig=SlicerConfiguration.getConfiguration(obj.model);
    slicerConfig.externalPVDManagement=false;


    obj.clearGeneratedSlicerCriterion;


    obj.clearCriteriaMap;
end
