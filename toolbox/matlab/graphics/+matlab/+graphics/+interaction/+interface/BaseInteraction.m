classdef BaseInteraction<matlab.mixin.Heterogeneous




    methods(Abstract,Hidden)
        ints=createInteraction(hObj,ax,fig)
        ints=createWebInteraction(hObj,can,ax)
    end
end