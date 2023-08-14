


classdef CodeGenBlockTracker<handle





    properties(Transient,Hidden)
        HandlesAfterCgirXforms=[]
        SimulinkReducedBlockMap=[]
    end

    properties(Hidden)
        ModelName=[]
        SourceSubsystem=''
        CgirReducedBlocks=[];
        SimulinkReducedBlocks={}
        SimulinkReductionReason={}
        TLCInsertBlocks={}
        AllReducedBlocks=[]
        AllReducedBlocksCached=0
        ReuseInfoCached=0
        ReuseInfo=[]
        ReuseMap=[]
        ParentSysIdx=[]
    end

    methods
        function obj=CodeGenBlockTracker(model)
            obj.ModelName=model;
        end
    end
end


