function [ isAvailableForMode ] = isSignalAvailableForMapping( signals, mapMode )







isAvailableForMode = zeros( 1, length( signals ) );


switch lower( mapMode )



case lower( char( Simulink.iospecification.BuiltInMapModes.Index ) )

isAvailableForMode( : ) = 1;


case lower( char( Simulink.iospecification.BuiltInMapModes.SignalName ) )


for kSig = 1:length( signals )
if Simulink.sdi.internal.Util.isSimulationDataSet( signals{ kSig } ) ||  ...
( Simulink.sdi.internal.Util.isMATLABTimeseries( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isSimulinkTimeseries( signals{ kSig } ) ) ||  ...
Simulink.sdi.internal.Util.isSimulationDataElement( signals{ kSig } ) ||  ...
iofile.Util.isValidBusStruct( signals{ kSig } ) ||  ...
iofile.Util.isValidFunctionCallInput( signals{ kSig } ) ||  ...
iofile.Util.isFcnCallTableData( signals{ kSig } ) ||  ...
iofile.Util.isGroundSignal( signals{ kSig } )


isAvailableForMode( kSig ) = 1;

end 
end 


case lower( char( Simulink.iospecification.BuiltInMapModes.BlockName ) )


for kSig = 1:length( signals )
if Simulink.sdi.internal.Util.isSimulationDataSet( signals{ kSig } ) ||  ...
( Simulink.sdi.internal.Util.isMATLABTimeseries( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isSimulinkTimeseries( signals{ kSig } ) ) ||  ...
Simulink.sdi.internal.Util.isSimulationDataElement( signals{ kSig } ) ||  ...
( isstruct( signals{ kSig } ) && iofile.Util.isValidBusStruct( signals{ kSig } ) ) ||  ...
iofile.Util.isValidFunctionCallInput( signals{ kSig } ) ||  ...
iofile.Util.isFcnCallTableData( signals{ kSig } ) ||  ...
iofile.Util.isGroundSignal( signals{ kSig } )


isAvailableForMode( kSig ) = 1;

end 
end 


case lower( char( Simulink.iospecification.BuiltInMapModes.BlockPath ) )


for kSig = 1:length( signals )
if Simulink.sdi.internal.Util.isSimulationDataSet( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isSimulinkTimeseries( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isSimulationDataElement( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isTSArray( signals{ kSig } )


isAvailableForMode( kSig ) = 1;

end 
end 


case lower( char( Simulink.iospecification.BuiltInMapModes.Custom ) )


for kSig = 1:length( signals )
if Simulink.sdi.internal.Util.isSimulationDataSet( signals{ kSig } ) ||  ...
( Simulink.sdi.internal.Util.isMATLABTimeseries( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isSimulinkTimeseries( signals{ kSig } ) ) ||  ...
Simulink.sdi.internal.Util.isSimulationDataElement( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isTSArray( signals{ kSig } ) ||  ...
iofile.Util.isValidBusStruct( signals{ kSig } ) ||  ...
iofile.Util.isValidFunctionCallInput( signals{ kSig } ) ||  ...
iofile.Util.isFcnCallTableData( signals{ kSig } ) ||  ...
iofile.Util.isGroundSignal( signals{ kSig } )


isAvailableForMode( kSig ) = 1;

end 
end 


case lower( char( Simulink.iospecification.BuiltInMapModes.PortOrder ) )

isAvailableForMode( : ) = 1;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpSqnORw.p.
% Please follow local copyright laws when handling this file.

