function handle = getDataStoreHandle( obj )










handle =  - 1;
sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>
try 
if isa( obj, 'Stateflow.Data' )

if ~strcmp( obj.Scope, 'Data Store Memory' )


return ;
end 
dsname = obj.Name;
chartId = sf( 'DataChartParent', obj.Id );
subsysBlkHandle = sf( 'Private', 'chart2block', chartId );
parent = get_param( subsysBlkHandle, 'Parent' );
else 
sid = Simulink.ID.getSID( obj );
dsname = get_param( sid, 'DataStoreName' );
parent = get_param( sid, 'Parent' );
end 

while ~isempty( parent )
if ~strcmpi( get_param( parent, 'type' ), 'block_diagram' )
dsname = Simulink.mapDataStoreName( parent, dsname );
end 
parentObj = get_param( parent, 'Object' );
block_list = parentObj.getCompiledBlockList(  );
dsm = find_system( block_list, 'SearchDepth', 0,  ...
'BlockType', 'DataStoreMemory', 'DataStoreName', dsname );
if ~isempty( dsm )
L = length( dsm );
if L > 1






foundUnsynthsized = false;
for i = 1:L
object = get_param( dsm( i ), 'Object' );
if ~object.isSynthesized
foundUnsynthsized = true;
handle = dsm( i );
break ;
end 
end 
if ~foundUnsynthsized
handle = dsm( 1 );
end 
else 
handle = dsm;
end 

return ;
end 
parent = get_param( parent, 'Parent' );
end 
catch 
handle =  - 1;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5bLdQw.p.
% Please follow local copyright laws when handling this file.

