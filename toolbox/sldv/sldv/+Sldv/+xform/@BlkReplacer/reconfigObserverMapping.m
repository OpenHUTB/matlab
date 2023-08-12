function reconfigObserverMapping( obj, mdlItem )












repBlkH = mdlItem.ReplacementInfo.AfterReplacementH;
repBlkOrigPath = mdlItem.ReplacementInfo.BlockToReplaceOriginalPath;



if ( obj.ObsPortEntityMappingInfo.isKey( repBlkOrigPath ) )
obsEntityAndPortList = obj.ObsPortEntityMappingInfo( repBlkOrigPath );

for i = 1:length( obsEntityAndPortList )
obsEntityAndPort = obsEntityAndPortList( i );


obsPortBlkH = obsEntityAndPort.obsPortBlkH;
obsEntityType = obsEntityAndPort.type;

obsEntityFullNameAfterRep = getfullname( repBlkH );
if ~isempty( obsEntityAndPort.blockFullName )






obsEntityFullNameAfterRep = [ obsEntityFullNameAfterRep, '/' ...
, obsEntityAndPort.blockFullName ];
end 
obsEntityBlkHdls( 1 ) = get_param( obsEntityFullNameAfterRep, 'Handle' );
obsEntityPortId = obsEntityAndPort.portIDOrSSId;

if ( obsEntityType == "SFState" )

Simulink.observer.internal.configureObserverPort( obsPortBlkH,  ...
obsEntityType, obsEntityBlkHdls, { obsEntityAndPort.activityType, num2str( obsEntityPortId ) } );
elseif ( obsEntityType == "SFData" )

Simulink.observer.internal.configureObserverPort( obsPortBlkH,  ...
convertStringsToChars( obsEntityType ), obsEntityBlkHdls, num2str( obsEntityPortId ) );
else 

Simulink.observer.internal.configureObserverPort( obsPortBlkH,  ...
obsEntityType, obsEntityBlkHdls, obsEntityPortId );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfsxa7w.p.
% Please follow local copyright laws when handling this file.

