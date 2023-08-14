%#codegen
classdef(Abstract)CPUFusableLayer











    methods(Hidden=true)
        function obj=CPUFusableLayer()
            coder.allowpcode('plain');
        end
    end
end