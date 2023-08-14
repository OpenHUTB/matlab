classdef TableDescriptionGenerator<matlab.mixin.Heterogeneous





    methods(Abstract)
        description=generate(this,path)
    end
end