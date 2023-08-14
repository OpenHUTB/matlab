classdef Autoscaler<handle














    methods(Static)
        addCompiledBlocksToDataset(runObj,model)
        [resultAdded,numAdded]=addToSrcList(runObj,result,actualSrcIDs)
        collectModelCompiledDesignRange(subsysObj,selectedRunName)
        collectModelDerivedRange(subsysObj,selectedRunName)
        updateSpecifiedDataTypes(datasets,runName)
        [result,numRecAdded]=createSDOResult(runObj,slSignalInfo,modelName)
        [blkSDOPair]=getListForBlocksUseSDO(topSubsysToScale)
    end
end

