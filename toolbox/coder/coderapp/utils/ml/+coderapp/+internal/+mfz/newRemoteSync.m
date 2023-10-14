function [ sync, channelObj ] = newRemoteSync( mfzModel, inChannel, outChannel )

arguments
    mfzModel( 1, 1 )mf.zero.Model
    inChannel{ mustBeTextScalar( inChannel ) }
    outChannel{ mustBeTextScalar( outChannel ) } = inChannel
end

if nargout < 2
    error( 'Both the sync and channel objects must be held onto for model synchronization to work' );
end

channelObj = mf.zero.io.ConnectorChannelMS( inChannel, outChannel );
sync = mf.zero.io.ModelSynchronizer( mfzModel, channelObj );
end


