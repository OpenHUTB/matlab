classdef UpdateInteractable<handle



    properties
        ParentSize double=[1,1,1,1];
    end

    methods(Abstract)
        disableUpdateInteractions(obj);
        enableUpdateInteractions(obj);
    end
end

