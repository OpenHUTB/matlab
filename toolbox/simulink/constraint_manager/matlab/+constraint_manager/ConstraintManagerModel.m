classdef ConstraintManagerModel<handle




    properties
BlockHandle
DataModel
CMSynchronizer
CMChannel
ConstraintManagerModelData
UUID
ConstraintManagerDataLoader
    end

    methods
        function obj=ConstraintManagerModel(aBlockHandle,channelName)

            obj.BlockHandle=aBlockHandle;


            obj.DataModel=mf.zero.Model;


            obj.ConstraintManagerDataLoader=constraint_manager.ConstraintManagerDataLoader(obj.DataModel,obj.BlockHandle);
            obj.ConstraintManagerModelData=obj.ConstraintManagerDataLoader.getConstraintManagerModelData();


            synchronizerChannel=mf.zero.io.ConnectorChannelMS(channelName,channelName);


            obj.CMSynchronizer=mf.zero.io.ModelSynchronizer(obj.DataModel,synchronizerChannel);
            obj.CMChannel=synchronizerChannel;


            obj.CMSynchronizer.start();
        end

        function id=get.UUID(obj)
            id=obj.DataModel.UUID;
        end

    end
end

