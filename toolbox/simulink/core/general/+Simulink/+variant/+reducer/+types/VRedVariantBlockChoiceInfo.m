classdef(Hidden,Sealed)VRedVariantBlockChoiceInfo<handle




    properties
        BlockPath(1,:)char;
        BlockType(1,1)Simulink.variant.reducer.VariantBlockType;
        NumberOfConfigsActive=[];
        NumberOfChoices=[];
        AllChoiceNames=[];
        ActiveChoiceNumbers=[];
        ActiveChoiceNames=[];
        isAZVCActivated=[];






    end
end
