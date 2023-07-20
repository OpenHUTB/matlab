classdef(Abstract)BlockDiagramAssociatedDataInterface



    methods(Abstract,Static)
        TF=isRegistered(modelHandle,dataId)
        register(modelHandle,dataId,dataType)
        unregister(modelHandle,dataId)
        set(modelHandle,dataId,value)
    end
end