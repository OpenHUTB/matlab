function paramGroups = getHardwareParameterInfo( hwArg )





R36
hwArg{ mustBeA( hwArg, { 'string', 'char', 'coder.HardwareBase' } ) }
end 

paramGroups = struct( 'name', {  }, 'parameters', {  } );
if isa( hwArg, 'coder.HardwareBase' )
hw = hwArg;
else 
if ~isempty( which( 'emlcprivate' ) )
hw = emlcprivate( 'projectCoderHardware', hwArg );
else 
return 
end 
end 
if ~isa( hw, 'coder.Hardware' )
return 
end 

pInfo = hw.ParameterInfo;
if numel( pInfo.ParameterGroups ) ~= numel( pInfo.Parameter )
error( 'Invalid ParameterInfo specification: ParameterGroups length must match Parameter length' );
end 

[ paramGroups( 1:numel( pInfo.Parameter ) ).name ] = pInfo.ParameterGroups{ : };
for i = 1:numel( pInfo.Parameter )
pDefs = pInfo.Parameter{ i };
paramGroups( i ).parameters = cell( 1, numel( pDefs ) );
for j = 1:numel( pDefs )
paramGroups( i ).parameters{ j } = normalizeParameter( pDefs{ j } );
end 
end 
end 


function out = normalizeParameter( pDef )
out = unstringify( pDef );
if ~isfield( out, 'DoNotStore' )
out.DoNotStore = 0;
end 


if out.DoNotStore
out.Storage = '';
elseif ~isfield( out, 'Storage' ) || isempty( out.Storage )
out.Storage = out.Tag;
end 
end 




function pDef = unstringify( pDef )
fields = [ "RowSpan", "ColSpan", "Alignment", "DialogRefresh", "DoNotStore", "SaveValueAsString" ];
for fieldToEval = fields( isfield( pDef, fields ) )
raw = pDef.( fieldToEval );
if ~isempty( raw )
pDef.( fieldToEval ) = evalin( 'base', raw );
else 
pDef.( fieldToEval ) = [  ];
end 
end 
if isfield( pDef, 'Entries' )
if ~isempty( pDef.Entries )
pDef.Entries = strsplit( pDef.Entries, ';' );
else 
pDef.Entries = {  };
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVMGTNB.p.
% Please follow local copyright laws when handling this file.

