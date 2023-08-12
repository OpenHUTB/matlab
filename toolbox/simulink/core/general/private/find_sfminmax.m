function rtnList = find_sfminmax( sfBlkUdi, prmType )





assert( sfBlkUdi.isa( 'Simulink.Block' ) );
assert( strcmpi( prmType, 'DesignMin' ) || strcmpi( prmType, 'DesignMax' ) );

rtnList = [  ];
dataList = [  ];

try 
dataList = sfBlkUdi.find( '-isa', 'Stateflow.Data' );
catch 
end 

for i = 1:length( dataList )
data = dataList( i );

if ~doesStateflowDataMinMaxApply( data )
continue ;
end 

rtnList = [ rtnList, data ];
end 

return ;
end 


function doesApply = doesStateflowDataMinMaxApply( data )




isConstantOrParameter = false;
isOpaqueSize = false;
switch lower( data.Scope )
case { 'constant', 'parameter' }
isConstantOrParameter = true;
case 'data store memory'
isOpaqueSize = true;
case { 'output', 'input', 'local' }

end 

bindToSignalApply = isValidProperty( data, 'Resolve Signal' );
isBindToSignal = bindToSignalApply && data.Props.ResolveToSignalObject;

if ( strcmpi( data.Props.Type.Method, 'built-in' ) &&  ...
strcmpi( data.Props.Type.Primitive, 'ml' ) )
isOpaqueSize = true;
end 

isTypeModeBus = strcmpi( data.Props.Type.Method, 'bus object' );
isTypeModeEnum = strcmpi( data.Props.Type.Method, 'enum type' );

minMaxDoesntApply = isOpaqueSize || isConstantOrParameter ||  ...
isTypeModeBus || isTypeModeEnum || isBindToSignal;

doesApply = ~minMaxDoesntApply;
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpo_9ZDv.p.
% Please follow local copyright laws when handling this file.

