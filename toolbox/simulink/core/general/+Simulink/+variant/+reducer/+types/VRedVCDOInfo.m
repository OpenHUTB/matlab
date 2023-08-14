classdef(Hidden,Sealed)VRedVCDOInfo<handle




    properties
        VCDOName(1,:)char;
        VCDO=[];
        ConfigInfosTobeSaved=Simulink.variant.reducer.types.VRedConfigInfo.empty;
        DefaultConfiguration=[];
    end

    methods
        function delete(obj)
            obj.ConfigInfosTobeSaved=Simulink.variant.reducer.types.VRedConfigInfo.empty;
        end
    end
end
