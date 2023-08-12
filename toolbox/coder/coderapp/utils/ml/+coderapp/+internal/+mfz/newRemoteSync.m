function [ sync, channelObj ] = newRemoteSync( mfzModel, inChannel, outChannel )


R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpeLu2JU.p.
% Please follow local copyright laws when handling this file.

