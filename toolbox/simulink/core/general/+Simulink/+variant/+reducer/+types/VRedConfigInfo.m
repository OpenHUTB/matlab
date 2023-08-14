classdef(Hidden,Sealed)VRedConfigInfo<handle




    properties
        ConfigName(1,:)char;
        TopModelConfigName(1,:)char;
        Configuration=[];
        CompiledBlocks=[];
        CompiledVarBlkChoiceInfo=[];
        CompiledSpecialBlockInfo=[];
        IsProcessed(1,1)logical=false;
        ModelRefsData=[];
        SourceModelName=[];
        AllCtrlVars=[];
        ModelVsConfigMap=[];
    end
end
