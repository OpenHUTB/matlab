function [ inputMap, MAPPED_CONTAINER, varNameMapped ] = createBuiltInMap( modelName, mappingMode, customFunction, dataOnSource, throwWarning )



















dataOnSource = lFilterDataByMappingMode( dataOnSource, mappingMode );

if isempty( dataOnSource.Data ) && isempty( dataOnSource.Names )
DAStudio.error( 'sl_inputmap:inputmap:modeAndInputMisMatch' );
end 




switch lower( mappingMode )


case lower( char( Simulink.iospecification.BuiltInMapModes.Index ) )

aInputSpec = Simulink.iospecification.InputSpecification( 'Index' );

mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioIndex' );


case lower( char( Simulink.iospecification.BuiltInMapModes.PortOrder ) )

aInputSpec = Simulink.iospecification.InputSpecification( 'PortOrder' );

mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioPortOrder' );


case lower( char( Simulink.iospecification.BuiltInMapModes.SignalName ) )


aInputSpec = Simulink.iospecification.InputSpecification( 'SignalName' );

mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioSignalName' );


case lower( char( Simulink.iospecification.BuiltInMapModes.BlockName ) )


aInputSpec = Simulink.iospecification.InputSpecification( 'BlockName' );

mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioBlockName' );


case lower( char( Simulink.iospecification.BuiltInMapModes.BlockPath ) )


aInputSpec = Simulink.iospecification.InputSpecification( 'BlockPath' );

mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioBlockPath' );


case lower( char( Simulink.iospecification.BuiltInMapModes.Custom ) )


if isempty( customFunction )
DAStudio.error( 'sl_inputmap:inputmap:apiCustomModeNoFile' );
else 
[ ~, customFile, ~ ] = fileparts( customFunction );
end 


aInputSpec = Simulink.iospecification.InputSpecification( 'Custom',  ...
'None', customFile );
mappingModeWarningStr = DAStudio.message( 'sl_inputmap:inputmap:radioCustom' );
end 


MAPPED_CONTAINER = false;
[ isContainer ] = isContainerSignal( dataOnSource.Data );


HAD_TO_LOAD_MDL = false;

if ~bdIsLoaded( modelName )
load_system( modelName );
HAD_TO_LOAD_MDL = true;
end 


inputMap = getRootInportMap( 'empty' );

varNameMapped = [  ];



idxCont = find( isContainer == 1 );


classOfData = cell( 1, length( idxCont ) );
for kAgg = 1:length( idxCont )

classOfData{ kAgg } = class( dataOnSource.Data{ idxCont( kAgg ) } );

end 


isDs = strcmp( 'Simulink.SimulationData.Dataset', classOfData );



if ~all( isDs ) && any( isDs )

idxCont = [ idxCont( isDs ), idxCont( ~isDs ) ];
end 




for kAgg = 1:length( idxCont )


if lIsContainerGoodForModel( dataOnSource.Data{ idxCont( kAgg ) }, modelName )
try 
inputMap = getMap( aInputSpec, modelName,  ...
dataOnSource.Names( idxCont( kAgg ) ),  ...
dataOnSource.Data( idxCont( kAgg ) ) );
catch ME

throwAsCaller( ME );
end 


if ~isempty( inputMap )


dataOnSource.Names = dataOnSource.Names( idxCont( kAgg ) );
dataOnSource.Data = dataOnSource.Data( idxCont( kAgg ) );
MAPPED_CONTAINER = true;
varNameMapped = dataOnSource.Names;
break ;
end 
end 


end 


if ~MAPPED_CONTAINER



if ~isempty( idxCont )
dataOnSource.Data( idxCont ) = [  ];
dataOnSource.Names( idxCont ) = [  ];
end 


if ~isempty( dataOnSource.Data ) && ~isempty( dataOnSource.Names )

try 
inputMap = getMap( aInputSpec, modelName,  ...
dataOnSource.Names,  ...
dataOnSource.Data );

varNameMapped = { inputMap( : ).DataSourceName };
catch ME

throwAsCaller( ME );
end 
end 
end 


if HAD_TO_LOAD_MDL

close_system( modelName, 0 );
end 


if isempty( inputMap ) && throwWarning
MSLDiagnostic( 'sl_inputmap:inputmap:apiInputMapEmpty', mappingModeWarningStr, modelName ).reportAsWarning;
end 

end 


function [ isGood ] = lIsContainerGoodForModel( aggregateSignal, model )

isGood = true;


if Simulink.sdi.internal.Util.isSimulationDataSet( aggregateSignal )
return ;
end 

Inports = find_system( model,  ...
'SearchDepth', 1, 'BlockType', 'Inport' );
Enables = find_system( model,  ...
'SearchDepth', 1, 'BlockType', 'EnablePort' );
Triggers = find_system( model,  ...
'SearchDepth', 1, 'BlockType', 'TriggerPort' );

numPortsInModel = length( Inports ) + length( Enables ) + length( Triggers );




if Simulink.sdi.internal.Util.isStructureWithTime( aggregateSignal ) ||  ...
Simulink.sdi.internal.Util.isStructureWithoutTime( aggregateSignal )



numSignals = length( aggregateSignal.signals );

elseif iofile.Util.isValidTimeExpression( aggregateSignal )



numSignals = length( strfind( aggregateSignal, ',' ) ) + 1;

elseif iofile.Util.isValidSignalDataArray( aggregateSignal )



dim = size( aggregateSignal );
numSignals = dim( 2 ) - 1;
end 

if numSignals ~= numPortsInModel
isGood = false;
end 

end 

function dataOnSource = lFilterDataByMappingMode( dataOnSource, mappingMode )


[ isAvailableForMode ] = isSignalAvailableForMapping( dataOnSource.Data,  ...
mappingMode );


dataOnSource.Data( ~isAvailableForMode ) = [  ];
dataOnSource.Names( ~isAvailableForMode ) = [  ];

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZxs4Lf.p.
% Please follow local copyright laws when handling this file.

