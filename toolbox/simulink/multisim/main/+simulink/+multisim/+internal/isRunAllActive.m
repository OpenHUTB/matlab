function isActive=isRunAllActive(modelHandle)





    isActive=false;

    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
    designSession=bdData.SessionDataModel.topLevelElements;

    if~designSession.ActiveDesignSuiteSet
        return;
    end

    designSuiteData=bdData.DesignSuiteMap(designSession.ActiveDesignSuiteUUID);
    activeDesignSuite=designSuiteData.DesignSuite;

    designStudies=activeDesignSuite.DesignStudies.toArray();
    selectedDesignStudies=[designStudies.SelectedForRun];
    if any(selectedDesignStudies)
        isActive=true;
    end
end
