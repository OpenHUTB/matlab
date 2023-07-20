classdef MaskEditorModel<handle




    properties
SystemOrBlockContext
DataModel
ModelListenerCallback
MEData
UUID
MEChannel
MESynchronizer
MaskEditorDataGenerator
    end

    methods
        function obj=MaskEditorModel(systemOrBlockContext,channelName)

            obj.SystemOrBlockContext=systemOrBlockContext;


            obj.DataModel=mf.zero.Model;


            synchronizerChannel=mf.zero.io.ConnectorChannelMS(channelName,channelName);


            obj.MESynchronizer=mf.zero.io.ModelSynchronizer(obj.DataModel,synchronizerChannel);
            obj.MEChannel=synchronizerChannel;


            obj.MESynchronizer.start();
        end

        function attachModelListener(this)

            this.ModelListenerCallback=@(changeReport)maskeditor.internal.ModelListener(changeReport,this.SystemOrBlockContext);

            this.DataModel.addObservingListener(@this.ModelListenerCallback);
        end

        function id=get.UUID(obj)
            id=obj.DataModel.UUID;
        end
    end
end

