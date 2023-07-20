classdef TransformInterface<matlab.mixin.Heterogeneous




    methods(Abstract)
        wrapper=transform(this,wrapper)
    end
end
