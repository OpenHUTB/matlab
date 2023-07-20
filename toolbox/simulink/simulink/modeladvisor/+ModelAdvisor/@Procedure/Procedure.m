
classdef(CaseInsensitiveProperties=true)Procedure<ModelAdvisor.Group
    methods
        function Obj=Procedure(varargin)
mlock
            Obj=Obj@ModelAdvisor.Group(varargin{:});
            Obj.ShowCheckbox=false;
        end
    end
end