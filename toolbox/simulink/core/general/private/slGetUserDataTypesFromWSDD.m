




















function [ dtvarnames, dtmark ] = slGetUserDataTypesFromWSDD( hProxy, filter, caps, refresh )

if nargin < 4
refresh = false;
end 
blockDiagramHandle = [  ];
mdlHasBWSAccess = false;
if ( isa( hProxy, 'Simulink.SlidDAProxy' ) )
slidObject = hProxy.getObject(  );
if ~isempty( slidObject.findprop( 'System' ) )
slidSystem = slidObject.System;
if ~isempty( slidSystem )
blockDiagramHandle = slidSystem.Handle;
end 
end 
hCaller = slidObject.WorkspaceObjectSharedCopy;
else 
hCaller = hProxy;
end 

dtvarnames = {  };
dtmark.hasBus = false;
if slfeature( 'CUSTOM_BUSES' ) == 1
dtmark.hasConnectionBus = false;
end 
if slfeature( 'ClientServerInterfaceEditor' ) == 1
dtmark.hasServiceBus = false;
end 
if slfeature( 'SLValueType' ) == 1
dtmark.hasValueType = false;
end 
dtmark.hasEnum = false;



dataSources = '';
if isa( hProxy, 'Simulink.Block' ) ||  ...
isa( hProxy, 'Simulink.BlockDiagram' ) ||  ...
isa( hProxy, 'Simulink.SLDialogSource' ) ||  ...
isa( hProxy, 'Stateflow.Data' ) ||  ...
isa( hProxy, 'Simulink.SlidDAProxy' )

try 

if isa( hCaller, 'Simulink.Block' ) || isa( hProxy, 'Simulink.BlockDiagram' )

obj = hCaller;
elseif isa( hCaller, 'Simulink.SLDialogSource' )

obj = hCaller.getBlock;
elseif ( isa( hProxy, 'Simulink.SlidDAProxy' ) )
slidObject = hProxy.getObject(  );
if ~isempty( slidObject.System )
obj = get_param( slidObject.System.Handle, 'Object' );
else 
return ;
end 
else 

obj = hCaller.getParent;
end 


while true
parentBlk = obj.getParent;

if isempty( parentBlk )

return ;
end 

if isa( parentBlk, 'Simulink.Root' )
break ;
end 
obj = parentBlk;
end 
assert( isa( obj, 'Simulink.BlockDiagram' ) );
mdlHasBWSAccess = strcmp( obj.HasAccessToBaseWorkspace, 'on' );
blockDiagramHandle = obj.Handle;

visibleDDs = getAllDictionariesOfLibrary( obj.Name );
mdlLinkedDD = obj.DataDictionary;
if ~isempty( mdlLinkedDD )
visibleDDs{ end  + 1 } = mdlLinkedDD;
end 
if ~isempty( visibleDDs )

dataSources = cell( length( visibleDDs ), 1 );
for n = 1:length( visibleDDs )
dataSources{ n } = Simulink.dd.open( visibleDDs{ n } );
assert( dataSources{ n }.isOpen );
end 
end 
catch e
warning( e.message );
return ;
end 
else 

cachedDataSource = slprivate( 'slUpdateDataTypeListSource', 'get' );

if ~isempty( cachedDataSource )
dataSources = cachedDataSource;
assert( isa( dataSources, 'Simulink.dd.Connection' ) );
assert( dataSources.isOpen );
end 
end 


if ( strcmp( dataSources, '' ) )
dtvars = getDataTypeVarsFromSource( '', filter, refresh );
else 
if isa( dataSources, 'Simulink.dd.Connection' )
dataSources = { dataSources };
end 
dtvars = [  ];
ddHasAccessToBWS = false;
for n = 1:length( dataSources )
ddHasAccessToBWS = ddHasAccessToBWS || dataSources{ n }.HasAccessToBaseWorkspace;
dtvarLoc = getDataTypeVarsFromSource( dataSources{ n }, filter, refresh );
dtvars = [ dtvars;dtvarLoc ];
end 
if ( ddHasAccessToBWS || mdlHasBWSAccess )
dtvarsBW = getDataTypeVarsFromSource( '', filter, refresh );
dtvars = [ dtvars;dtvarsBW ];
end 
dtvars = dtvars';
end 

if ~isempty( blockDiagramHandle )
dtvarsModelBroker = getDataTypeVarsFromSource( blockDiagramHandle, filter, refresh );
dtvars = [ dtvars( : );dtvarsModelBroker( : ) ];
dtvars = dtvars';
end 

[ dtvarnames, dtmark ] = filterDataTypes( hCaller, dtvars, caps );
end 

function dtvars = getDataTypeVarsFromSource( dataSource, filter, refresh )

if isempty( filter )
dtvars = slGetSpecifiedDataTypes( dataSource, refresh );
else 
if isfield( filter, 'supportBuiltins' )
hasAliasOfBuiltins = filter.supportBuiltins;
filter = rmfield( filter, 'supportBuiltins' );
else 
hasAliasOfBuiltins = true;
end 

dtvars = slGetSpecifiedDataTypes( dataSource, refresh, filter );

if ~hasAliasOfBuiltins

for k = length( dtvars ): - 1:1
if strcmp( dtvars( k ).extraInfo.dataTypeClass, 'Builtin' )
dtvars( k ) = [  ];
end 
end 
end 
end 

end 

function [ dtvarnames, dtmark ] = filterDataTypes( hCaller, dtvars, caps )

dtvarnames = {  };
dtmark.hasBus = false;

customBusFeatureOn = ( slfeature( 'CUSTOM_BUSES' ) == 1 );
serviceBusFeatureOn = ( slfeature( 'ClientServerInterfaceEditor' ) == 1 );
if customBusFeatureOn
dtmark.hasConnectionBus = false;
end 
if serviceBusFeatureOn
dtmark.hasServiceBus = false;
end 
if slfeature( 'SLValueType' ) == 1
dtmark.hasValueType = false;
end 
dtmark.hasEnum = false;


if ~isempty( caps )
dtvars = filterNumericAndAliasTypes( dtvars, caps );
end 

if ismember( 'validateDataTypeList', methods( hCaller ) )
dtvars = hCaller.validateDataTypeList( dtvars );
end 

dtvars = struct2cell( dtvars );

if ~isempty( dtvars )

if ismember( 'Simulink.Bus', dtvars( 2, : ) )
dtmark.hasBus = true;
end 


if customBusFeatureOn && ismember( 'Simulink.ConnectionBus', dtvars( 2, : ) )
dtmark.hasConnectionBus = true;
end 


if serviceBusFeatureOn && ismember( 'Simulink.ServiceBus', dtvars( 2, : ) )
dtmark.hasServiceBus = true;
end 


if slfeature( 'SLValueType' ) == 1 && ismember( 'Simulink.ValueType', dtvars( 2, : ) )
dtmark.hasValueType = true;
end 


if ismember( 'Enum', dtvars( 2, : ) )
dtmark.hasEnum = true;
end 
dtvarnames = unique( dtvars( 1, : ) );
end 
end 



function dtvars = filterNumericAndAliasTypes( dtvars, caps )


for k = length( dtvars ): - 1:1
extraInfo = dtvars( k ).extraInfo;




if isfield( caps, 'aliasObjectName' )
objName = caps.aliasObjectName;
else 
objName = '';
end 
if ~isempty( objName )
if strcmp( objName, dtvars( k ).name ) ||  ...
ismember( objName, extraInfo.referencedAliasTypes )
dtvars( k ) = [  ];
continue ;
end 
end 


if strcmp( extraInfo.dataTypeClass, 'Builtin' ) &&  ...
~ismember( extraInfo.dataTypeMode, caps.builtinTypes ) &&  ...
~strcmp( extraInfo.dataTypeMode, 'fixpt' )


dtvars( k ) = [  ];
end 


if strcmp( extraInfo.dataTypeClass, 'Numeric' )
if strcmp( extraInfo.scalingMode, 'NonFixpt' )


if ~ismember( extraInfo.dataTypeMode, caps.builtinTypes )
dtvars( k ) = [  ];
end 
else 

matchScaling = ismember( [ 'UDT', extraInfo.scalingMode, 'Mode' ], caps.scalingModes );
matchSign = ismember( [ 'UDT', extraInfo.signMode, 'Sign' ], caps.signModes );


isInteger = ~strcmp( extraInfo.dataTypeMode, 'fixpt' );
matchBuiltinInt = isInteger && ismember( extraInfo.dataTypeMode, caps.builtinTypes );

bestPrecisionAsInt = strcmp( extraInfo.scalingMode, 'BestPrecision' ) &&  ...
ismember( 'UDTIntegerMode', caps.scalingModes );

matchCaps = ( matchScaling && matchSign ) ||  ...
matchBuiltinInt ||  ...
bestPrecisionAsInt;
if ~matchCaps
dtvars( k ) = [  ];
end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpadzRZX.p.
% Please follow local copyright laws when handling this file.

