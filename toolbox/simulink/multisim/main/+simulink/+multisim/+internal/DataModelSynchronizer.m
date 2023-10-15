classdef DataModelSynchronizer < handle

    properties ( Access = private )
        Channel
        Synchronizer
    end

    properties ( Dependent )
        ChannelName
    end

    methods
        function obj = DataModelSynchronizer( dataModel, channelName )
            arguments
                dataModel( 1, 1 )mf.zero.Model
                channelName( 1, 1 )string = "/simulink/multisim/internal/" + dataModel.UUID;
            end

            synchronizerChannel = mf.zero.io.ConnectorChannelMS( channelName, channelName );
            obj.Synchronizer = mf.zero.io.ModelSynchronizer( dataModel, synchronizerChannel );
            obj.Channel = synchronizerChannel;
            obj.Synchronizer.start(  );
        end

        function channelName = get.ChannelName( obj )
            channelName = obj.Channel.inChannel;
        end
    end
end
