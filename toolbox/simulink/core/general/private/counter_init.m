function nbits = counter_init( uplimit, blockHandle )




upMax = max( uplimit );

model = bdroot( blockHandle );

if isRunning( model )

portHandles = get_param( blockHandle, 'PortHandles' );
outDataType = get_param( portHandles.Outport, 'CompiledPortDataType' );

switch outDataType
case { 'double', 'single' }

blk = gcb;
drProp_blk = sprintf( '%s/Data Type\nPropagation', blk );
dtProp_vars = get_param( drProp_blk, 'MaskWSVariables' );

dtProp = dtProp_vars( strcmp( { dtProp_vars.Name }, 'PropDataType' ) );
nbits = dtProp.Value.WordLength;

otherwise 

typeInfo = fixdt( outDataType );
nbits = typeInfo.WordLength;


if upMax > ( 2 ^ nbits - 1 )
DAStudio.error( 'Simulink:blocks:slBlocksCannotChangeDatatypeDuringSim', uplimit );
end 
end 
else 

nbits = get_nbits( upMax );
end 


function runs = isRunning( model )

switch lower( get_param( model, 'SimulationStatus' ) )
case { 'running', 'paused', 'external' }
runs = true;
otherwise 
runs = false;
end 


function nbits = get_nbits( upMax )

if upMax <= ( 2 ^ 8 - 1 )
nbits = 8;
elseif upMax <= ( 2 ^ 16 - 1 )
nbits = 16;
elseif upMax <= ( 2 ^ 32 - 1 )
nbits = 32;
elseif upMax <= ( 2 ^ 64 - 1 )
nbits = 64;
else 
nbits = 128;
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpQIgW8W.p.
% Please follow local copyright laws when handling this file.

