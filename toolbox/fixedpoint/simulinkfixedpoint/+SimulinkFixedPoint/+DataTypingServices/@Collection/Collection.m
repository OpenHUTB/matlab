classdef Collection<SimulinkFixedPoint.DataTypingServices.AbstractAction


















    properties(Hidden)
simIn
    end

    methods(Access=public)
        function this=Collection(sysToScaleName,refMdls,proposalSettings,simIn)
            this.sysToScaleName=sysToScaleName;
            this.refMdls=refMdls;
            this.proposalSettings=proposalSettings;
            if nargin<4
                this.simIn=Simulink.SimulationInput(bdroot(this.refMdls{end}));
            else
                this.simIn=simIn;
            end
        end

        execute(this)
    end

    methods(Access=public,Hidden=true)
        updateParametersForModel(this,model)
        updateParametersForScenarios(this)
        performCollection(this)
        performSharing(this)
        scale_collect(this,modelObj,modelName,runObj)
        newResults=processParameterObjects(this,modelName,runObj)
        result=setDesignMinMaxAndSpecifiedDT(this,EA,result)
        [newResults,numRecAdded]=createAndUpdateParameterResults(this,pObjInfoList,runObj,modelObject)
        allResults=processNamedDTObjects(this,modelObject,varNameDTRes,runObj)
        [ntResults]=createResults(this,contextModel,runObject,dTContainerInfo)
        shareAcrossModelReference(this,runObj)
        [reqUpdateInGroupID,subRecReqUpdate]=shareAcrossDataset(this,runObj,dsRecord)
        [totalNumAdded,totalRecAdded]=getDTConstraintRecords(this,runObj,curDTConstraintsSet)
        [newBusObjectResults,totalRecAdded]=createAndUpdateBusObjectResults(this,busObjHandleAndICList,busSrcBlks,runObj)
        [busObjectResult,busObjHandle]=updateIC(this,IC,busObjHandle,busObjectResult,leafChildIndex,leafBusElementName)
        [sharedRecords,totalNumAdded,totalRecAdded]=getSharedRecords(this,sharedList,runObj)
        [totalRecAdded,totalNumAdded]=setAssociatedParam(this,associatedParam,runObj)
        [curRecord,recAdded,numAdded]=getRecordWithBusObjectSwap(this,curSignal,busObjectHandleMap,runObj)
        discoverResults(this,runObj,modelObject,modelName);
        [allNodesMap,allEdgesMap]=getGraphElementsFromRuns(this);
        [allNodes,allEdges]=removeInvalidGraphElements(this,allNodesMap,allEdgesMap);
        collapseNode(~,nodeA,nodeB);
        [allEdges]=shareDataObjects(this,allNodes,allEdges);
        compileHandler=startCompile(this,modelName);
        stopCompile(this,compileHandler);
        [newBusObjectResults,numbOfBusRecAdded]=createBusResultsFromParameter(this,parameterObjectWrapper,runObj,srcIDs)
        updateParameterModelRequiredRanges(~,parameterObjectWrapper,pObjInfo,result)
        srcIDs=updateParameterSourceBlocks(~,varUsage,result,runObj)
        [result,isNew,parameterObjectWrapper]=createParameterResult(this,modelName,pObjInfo,runObj)
        createParameterConstraints(this,parameterObjectWrapper,result,runObj)
    end
end


