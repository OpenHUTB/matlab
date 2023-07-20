classdef InputParameters<handle
    properties(Constant)
        IsDebugInput=struct('name','IsDebug','defaultValue',0,'inputString','browser');
        ShowAssociationsInput=struct('name','ShowAssociations','defaultValue',0,'inputString','showAssociations');
        ShowHiddenInput=struct('name','ShowHidden','defaultValue',0,'inputString','ShowHidden');
    end

    properties
        IsDebug;
        ShowAssociations;
        Packages={};
        ShowHidden;
    end

    methods
        function obj=InputParameters
            obj.IsDebug=obj.IsDebugInput.defaultValue;
            obj.ShowAssociations=obj.ShowAssociationsInput.defaultValue;
            obj.ShowHidden=obj.ShowHiddenInput.defaultValue;
        end
    end
end
