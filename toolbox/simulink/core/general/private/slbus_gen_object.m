function [ ioBusInfo, bclist, busIdx ] = slbus_gen_object( ioBusInfo,  ...
setSampletime,  ...
isConvertingSubsystemToModelButNotExportFunctionModel,  ...
bclist,  ...
busIdx,  ...
scope, varargin )









































if nargin < 2
setSampletime = false;
end 

if nargin < 3
isConvertingSubsystemToModelButNotExportFunctionModel = false;
end 

if nargin < 4
bclist = [  ];
end 

if nargin < 5
busIdx = 0;
end 

if nargin < 6
scope = Simulink.data.BaseWorkspace;
end 

if nargin < 7
verbose = true;
else 
verbose = varargin{ 1 };
end 


wStates = [ warning;warning( 'query', 'backtrace' ) ];
warning off backtrace;
cleanupObj = onCleanup( @(  )warning( wStates ) );
sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );
deleteSess = onCleanup( @(  )delete( sess ) );
try 
for i = 1:length( ioBusInfo )
busName = [  ];
busObj = [  ];

portObj = get_param( ioBusInfo( i ).port, 'Object' );

isPureVirtualBus = strcmpi( portObj.CompiledBusType, 'VIRTUAL_BUS' ) ...
 && slInternal( 'isPureVirtualBus', ioBusInfo( i ).port );



blockType = get_param( ioBusInfo( i ).block( 1 ), 'BlockType' );
if ( strcmp( blockType, 'Goto' ) || strcmp( blockType, 'From' ) )
ioBusInfo( i ).canExpand = ( sum( portObj.CompiledPortDimensionsMode ) == 0 && isPureVirtualBus ) &&  ...
isConvertingSubsystemToModelButNotExportFunctionModel;
else 
ioBusInfo( i ).canExpand = ( sum( portObj.CompiledPortDimensionsMode ) == 0 && isPureVirtualBus ) &&  ...
( isConvertingSubsystemToModelButNotExportFunctionModel && ~any( startsWith( get_param( ioBusInfo( i ).block, 'OutDataTypeStr' ), 'Bus:' ) ) );
end 

elemAttributes = [  ];

if is_a_bus_signal_l( ioBusInfo( i ).bus )
[ busName, busObj, bclist, busIdx, ioBusInfo( i ).bus, elemAttributes ] = generate_bus_object_l( ioBusInfo( i ).canExpand,  ...
ioBusInfo( i ).bus, bclist, busIdx, setSampletime, scope, verbose, elemAttributes, [  ], isConvertingSubsystemToModelButNotExportFunctionModel );

end 

if ~ioBusInfo( i ).canExpand
ioBusInfo( i ).busName = busName;
else 
ioBusInfo( i ).busName = '';
end 
ioBusInfo( i ).busObject = busObj;
ioBusInfo( i ).isPureVirtualBus = isPureVirtualBus;
ioBusInfo( i ).elemAttributes = elemAttributes;
end 
catch me
rethrow( me );
end 



function [ busName, busObj, bclist, busIdx, busInfo, elemAttributes ] = generate_bus_object_l( canExpand,  ...
busInfo, bclist, busIdx, setSampletime, scope, verbose, elemAttributes, signalPath, isConvertingSubsystemToModel )

busName = '';%#ok
busObj = [  ];
assert( is_a_bus_signal_l( busInfo ),  ...
'Input to generate_bus_object_l function must be a bus signal' );

if ~isempty( busInfo.busObjectName )
busName = busInfo.busObjectName;
else 


busName = get_bus_name_from_bclist( bclist, busInfo.src );
end 
busName = Simulink.ModelReference.Conversion.RightClickBuild.getBusObjectNameFromDTOPrefixDecorationName( busName );

if ~isempty( busName )
indicesIO = [  ];
[ s, cmpMsg ] = slbus_compare_signal_names( busName,  ...
busInfo, indicesIO, scope );
if ~s
DAStudio.error( 'Simulink:utility:slUtilityCompBusSignalNameMismatch',  ...
cmpMsg );
end 
elem_names = {  };
for ii = 1:length( busInfo.signals )
elem = Simulink.BusElement;

match = strcmp( busInfo.signals( ii ).name, elem_names );
if any( match )

blkName = getfullname( busInfo.src );
DAStudio.error( 'Simulink:utility:slUtilityCompBusInvalidElementNameUnique',  ...
blkName, busInfo.signals( ii ).name );
else 
elem_names{ end  + 1 } = busInfo.signals( ii ).name;%#ok
end 

try 
elem.Name = busInfo.signals( ii ).name;
catch me
if ~isConvertingSubsystemToModel || ( isConvertingSubsystemToModel && ~canExpand )
blkName = getfullname( busInfo.signals( ii ).src );
DAStudio.error( 'Simulink:utility:slUtilityCompBusInvalidElementName',  ...
busInfo.signals( ii ).name,  ...
busInfo.signals( ii ).srcPort + 1, blkName, me.message );
end 
end 

if ( is_a_bus_signal_l( busInfo.signals( ii ) ) )
[ subBusName, ~, bclist, busIdx, busInfo.signals( ii ), elemAttributes ] = generate_bus_object_l( canExpand,  ...
busInfo.signals( ii ), bclist, busIdx, setSampletime, scope, verbose, elemAttributes, busInfo.signals( ii ).name, isConvertingSubsystemToModel );

elem.DataType = subBusName;
src = busInfo.signals( ii ).src;
srcPort = busInfo.signals( ii ).srcPort;
blkPortH = get_param( src, 'PortHandles' );
blkOutPort = [ blkPortH.Outport, blkPortH.State ];
pHandle = blkOutPort( srcPort + 1 );
try 
cInfo = Simulink.CompiledPortInfo( pHandle );
if cInfo.IsStructBus
elem.Dimensions = cInfo.Dimensions;
end 
catch me %#ok<NASGU>


end 
else 
if ~isempty( busInfo.signals( ii ).parentBusObjectName )

if isConvertingSubsystemToModel
parentBusName = busInfo.signals( ii ).parentBusObjectName;
parentBus = getBusObjectByScope( parentBusName, scope );
found = false;
for j = 1:length( parentBus.Elements )
if strcmp( parentBus.Elements( j ).Name, busInfo.signals( ii ).srcSignalName )
elem = parentBus.Elements( j );
elem.Name = busInfo.signals( ii ).name;
found = true;
break ;
end 
end 
assert( found, 'Bus component doesn''t belong to the claimed bus object which doesn''t exist.\n' );
end 
else 
elem = getDataForElement( elem, scope, busInfo, ii, setSampletime && canExpand );
end 

if ~isempty( signalPath )
SignalPath = [ signalPath, '.', elem.Name ];
else 
SignalPath = elem.Name;
end 

Elem.Attribute = elem;
Elem.signalPath = SignalPath;

elemAttributes = [ elemAttributes, Elem ];%#ok
end 
end 

return ;
end 

clear elems;


elem_names = {  };
for i = 1:length( busInfo.signals )
elem = Simulink.BusElement;

match = strcmp( busInfo.signals( i ).name, elem_names );
if any( match )

blkName = getfullname( busInfo.src );
msg = message( 'Simulink:utility:slUtilityCompBusInvalidElementNameUnique',  ...
blkName, busInfo.signals( i ).name );
ME = MSLException( msg );
ME.throw(  );
else 
elem_names{ end  + 1 } = busInfo.signals( i ).name;%#ok
end 

try 
elem.Name = busInfo.signals( i ).name;
catch me
if ~isConvertingSubsystemToModel || ( isConvertingSubsystemToModel && ~canExpand )
blkName = getfullname( busInfo.signals( i ).src );
msg = message( 'Simulink:utility:slUtilityCompBusInvalidElementName',  ...
busInfo.signals( i ).name,  ...
busInfo.signals( i ).srcPort + 1, blkName, me.message );
E = MSLException( msg );
E.throw(  );
end 
end 

if ( is_a_bus_signal_l( busInfo.signals( i ) ) )

[ subBusName, ~, bclist, busIdx, busInfo.signals( i ), elemAttributes ] = generate_bus_object_l( canExpand,  ...
busInfo.signals( i ), bclist, busIdx, setSampletime, scope, verbose, elemAttributes, busInfo.signals( i ).name, isConvertingSubsystemToModel );

elem.DataType = subBusName;
src = busInfo.signals( i ).src;
srcPort = busInfo.signals( i ).srcPort;
blkPortH = get_param( src, 'PortHandles' );
blkOutPort = [ blkPortH.Outport, blkPortH.State ];
pHandle = blkOutPort( srcPort + 1 );
try 
cInfo = Simulink.CompiledPortInfo( pHandle );
if cInfo.IsStructBus
elem.Dimensions = cInfo.Dimensions;
end 
catch me %#ok<NASGU>


end 
else 
if ~isempty( busInfo.signals( i ).parentBusObjectName )

parentBusName = busInfo.signals( i ).parentBusObjectName;
parentBus = getBusObjectByScope( parentBusName, scope );
found = false;
for j = 1:length( parentBus.Elements )
if strcmp( parentBus.Elements( j ).Name, busInfo.signals( i ).srcSignalName )
elem = parentBus.Elements( j );
elem.Name = busInfo.signals( i ).name;
found = true;
break ;
end 
end 
assert( found );
else 
elem = getDataForElement( elem, scope, busInfo, i, setSampletime && canExpand );
end 

if ~isempty( signalPath )
SignalPath = [ signalPath, '.', elem.Name ];
else 
SignalPath = elem.Name;
end 
Elem.Attribute = elem;
Elem.signalPath = SignalPath;

elemAttributes = [ elemAttributes, Elem ];%#ok
end 

elems( i ) = elem;%#ok
end 

if ~canExpand
busObj = Simulink.Bus;
busObj.Elements = elems;
end 



busName = busInfo.name;
useDefault = false;
postfix = '';

if ~isvarname( busName )
useDefault = true;
if isempty( busName )
busName = '';
end 
else 
if ~canExpand
isOk = check_bus_object_name_l( busName, busObj, scope );
if ~isOk
useDefault = true;


postfix = [ '_', busName ];
end 
end 

end 

if useDefault
if ~canExpand
inc = busIdx;

needNewName = true;
while needNewName
inc = inc + 1;
defaultBusName = [ 'slBus', num2str( inc ), postfix ];

isOk = check_bus_object_name_l( defaultBusName, busObj, scope );
if isOk
needNewName = false;
end 

end 

if verbose
MSLDiagnostic( 'Simulink:utility:slUtilityCompBusCannotUseSignalNameForBusName',  ...
busName, getfullname( busInfo.src ), defaultBusName ).reportAsWarning;
end 
busName = defaultBusName;
busIdx = inc;
end 
end 

if ~canExpand
assignIn( scope, busName, busObj );

bclist = add_to_bclist( bclist, busInfo.src, busName );
end 



function bclist = add_to_bclist( bclist, busSrc, busName )
if isempty( bclist )

bclist.busName = busName;
bclist.block = busSrc;
else 

bclist( end  + 1 ).busName = busName;
bclist( end  ).block = busSrc;
end 



function busName = get_bus_name_from_bclist( bclist, busSrc )

busName = '';

blkType = get_param( busSrc, 'BlockType' );
if ~strcmp( blkType, 'BusCreator' ) && ~strcmp( blkType, 'BusSelector' )
return 
end 

for i = 1:length( bclist )
if bclist( i ).block == busSrc
busName = bclist( i ).busName;
break ;
end 
end 







function dtypeNameio = create_dtype_object_if_needed_l( scope, pHandle, dtypeNameio )




if ~sldtype_is_builtin( dtypeNameio )

if fixed.internal.type.isNameOfTraditionalFixedPointType( dtypeNameio )






[ dInfo, ScaledDouble ] = fixdt( dtypeNameio );%#ok



if ( ScaledDouble )
portIdx = get_param( pHandle, 'portNumber' );
msg = message( 'Simulink:utility:slUtilityCompBusUnsupportedScaledDoubleDataType',  ...
get_param( pHandle, 'Parent' ), num2str( portIdx ),  ...
dtypeNameio );
ME = MSLException( msg );
ME.throw(  );
end 


newTypeName = [ 'slnum_', dtypeNameio ];
assignIn( scope, newTypeName, fixdt( dtypeNameio ) );
dtypeNameio = newTypeName;
end 
end 






function dtExpr = fix_dtype_for_enumerated_types_l( dtExpr )

if Simulink.data.isSupportedEnumClass( dtExpr )
dtExpr = [ 'Enum: ', dtExpr ];
return ;
end 







function dtExpr_string = fix_dtype_for_string_types_l( dtExpr_string )
if ( strncmp( dtExpr_string, 'str', 3 ) && ~isnan( str2double( dtExpr_string( 4:end  ) ) ) )
dtExpr_string = [ 'stringtype(', dtExpr_string( 4:end  ), ')' ];
return ;
end 








function retVal = is_a_bus_signal_l( busInfo )
retVal = ~isempty( busInfo ) &&  ...
( ~isempty( busInfo.signals ) || ~isempty( busInfo.busObjectName ) );







function isOk = check_bus_object_name_l( name, busObj, dataSource )
nameExists = false;
nameExistsButCanReuse = false;
elems = busObj.Elements;

if isa( dataSource, 'Simulink.data.DataAccessor' )
dataAccessor = dataSource;
varId = dataAccessor.name2UniqueIdWithCheck( name );
if ~isempty( varId )
nameExists = true;
existingBusObject = dataAccessor.getVariable( varId );
end 
else 
nameExists = dataSource.exist( name );
if nameExists
existingBusObject = dataSource.get( name );
end 
end 

if nameExists
nameExistsButCanReuse = isa( existingBusObject, 'Simulink.Bus' ) && isequal( existingBusObject.Elements, elems );
end 





sameAsElmDtype = false;
for idx = 1:length( elems )


if strcmpi( name, elems( idx ).DataType )
sameAsElmDtype = true;
break ;
end 
end 

isOk = ( ~nameExists || nameExistsButCanReuse ) && ~sameAsElmDtype;



function [ elem ] = getDataForElement( elem, scope, busInfo, index, setSampletime )

src = busInfo.signals( index ).src;
srcPort = busInfo.signals( index ).srcPort;
blkPortH = get_param( src, 'PortHandles' );
blkOutPort = [ blkPortH.Outport, blkPortH.State ];
pHandle = blkOutPort( srcPort + 1 );
cInfo = Simulink.CompiledPortInfo( pHandle );

dtExpr = fix_dtype_for_enumerated_types_l( cInfo.DataType );


dtExpr = fix_dtype_for_string_types_l( dtExpr );


dtExpr = create_dtype_object_if_needed_l( scope, pHandle, dtExpr );






if ~any( strcmpi( cInfo.SymbolicDimensions, { 'INHERIT', 'NOSYMBOLIC' } ) )
elem.Dimensions = cInfo.SymbolicDimensions;
else 
elem.Dimensions = cInfo.Dimensions;
end 

elem.DimensionsMode = cInfo.DimensionsMode;
elem.Complexity = cInfo.Complexity;
elem.SamplingMode = cInfo.SamplingMode;
if setSampletime
sampleTimeToSet = cInfo.SampleTime;
if iscell( sampleTimeToSet ) && numel( sampleTimeToSet ) > 1
elem.SampleTime =  - 1;
else 
if isfield( busInfo.signals( index ), 'dstBlock' ) &&  ...
isfield( busInfo.signals( index ), 'dstInport' ) &&  ...
~isempty( busInfo.signals( index ).dstBlock ) &&  ...
~isempty( busInfo.signals( index ).dstInport )




try 
obj = get_param( busInfo.signals( index ).dstBlock, 'Object' );





if ~strcmp( get_param( busInfo.signals( index ).dstBlock, 'BlockType' ), 'Outport' ) && ~( obj.isSynthesized && strcmp( obj.getSyntReason, 'SL_SYNT_BLK_REASON_COMPOSITE_PORT' ) )
dstBlkPortHandles = get_param( busInfo.signals( index ).dstBlock, 'PortHandles' );
port = dstBlkPortHandles.Inport( busInfo.signals( index ).dstInport + 1 );
sampleTimeFromDest = get_param( port, 'CompiledSampleTime' );




if ~iscell( sampleTimeFromDest )
sampleTimeFromSrc = cInfo.SampleTime;



if ~isequal( sampleTimeFromDest, sampleTimeFromSrc )
sampleTimeToSet = sampleTimeFromDest;
end 
end 
end 
catch ME %#ok


end 
end 

if ~( ( length( sampleTimeToSet ) == 2 && sampleTimeToSet( 1 ) ==  - 2 ) || ( length( sampleTimeToSet ) == 2 && sampleTimeToSet( 1 ) ==  - 1 && sampleTimeToSet( 2 ) ~= 0 ) )
elem.SampleTime = sampleTimeToSet;
end 
if elem.SampleTime == Inf
elem.SampleTime =  - 1;
end 
end 
end 
elem.DataType = dtExpr;

function busObj = getBusObjectByScope( busName, scope )
busObj = [  ];
busName = Simulink.ModelReference.Conversion.RightClickBuild.getBusObjectNameFromDTOPrefixDecorationName( busName );
if isa( scope, 'Simulink.data.DataAccessor' )
dataAccessor = scope;
[ varId, ~ ] = dataAccessor.name2UniqueIdWithCheck( busName );
if ~isempty( varId )
busObj = dataAccessor.getVariable( varId );
end 
else 
busObj = scope.evalin( busName );
end 


function assignIn( scope, variableName, variableValue )
if isa( scope, 'Simulink.data.DataAccessor' )
dataAccessor = scope;
[ varId, secondaryVarId ] = dataAccessor.name2UniqueIdWithCheck( variableName );
if isempty( varId )
dataAccessor.createVariableInDefaultSource( variableName, variableValue );
else 




dataAccessor.updateVariable( varId, variableValue );
if ~isempty( secondaryVarId )
dataAccessor.updateVariable( secondaryVarId, variableValue );
end 
end 
else 
scope.assignin( variableName, variableValue );
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpH8HBHp.p.
% Please follow local copyright laws when handling this file.

