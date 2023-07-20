classdef(Hidden,Sealed)VRedCompiledSpecialBlockInfo<matlab.mixin.Copyable




    properties
        BlockPath=[];
        ActiveInputPortNumbers=[];
        ActiveOutputPortNumbers=[];
        Operation(1,:)char;
        ReplacedBlock(1,:)char;
    end
end
