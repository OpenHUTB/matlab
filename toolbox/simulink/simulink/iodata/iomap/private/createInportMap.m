function map = createInportMap( modelName, blockName, signalName )








inportNames = Simulink.iospecification.InportProperty.getInportNames( modelName );


enableNames = Simulink.iospecification.InportProperty.getEnableNames( modelName );


triggerNames = Simulink.iospecification.InportProperty.getTriggerNames( modelName );


allPortNames = { inportNames{ : }, enableNames{ : }, triggerNames{ : } };%#ok<CCAT>





if ~any( strcmp( allPortNames, blockName ) )
DAStudio.error( 'sl_inputmap:inputmap:notBlockNameFound', modelName, blockName );
end 


blkPath = Simulink.iospecification.InportProperty.makeBlockPath( modelName, blockName );
portType = get_param( get_param( blkPath, 'Handle' ), 'BlockType' );


outSignalName = get_param( get_param(  ...
blkPath, 'Handle' ),  ...
'OutputSignalNames' );



if isempty( outSignalName )
outSignalName = [  ];
else 

outSignalName = outSignalName{ : };
end 

if strcmp( portType, 'Inport' )
PortNum = str2double( get_param(  ...
blkPath, 'Port' ) );
else 

PortNum = [  ];
end 


SSID = Simulink.ID.getSID( blkPath );


aDestination = Simulink.iospecification.Destination(  ...
blkPath,  ...
blockName,  ...
outSignalName,  ...
PortNum,  ...
SSID );

map = Simulink.iospecification.InputMap(  ...
portType,  ...
signalName,  ...
aDestination );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpc2EfZb.p.
% Please follow local copyright laws when handling this file.

