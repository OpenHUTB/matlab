function [ isPropagated, convertedModels ] = propagateBDConfigSetImpl( mdl, varargin )



































if nargin > 0
mdl = convertStringsToChars( mdl );
end 

if nargin > 1
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
end 

isPropagated = false;%#ok
convertedModels = [  ];

narginchk( 1, 3 );

loadFlag = false;

if isa( mdl, 'char' )
if bdIsLoaded( mdl )
loadFlag = true;
else 
load_system( mdl );
end 
elseif isa( mdl, 'Simulink.BlockDiagram' )
loadFlag = true;
mdl = mdl.Name;
else 
DAStudio.error( 'configset:util:IncorrectArgument' );
end 

cs = getActiveConfigSet( mdl );

if isa( cs, 'Simulink.ConfigSet' )
configset.util.convertToCSRef( mdl );
end 

if nargin == 2
if strcmp( varargin{ 1 }, 'gui' )
infoStruct = configset.util.Propagation( mdl );
isPropagated = infoStruct.Dialog;
return ;
else 
if ~loadFlag
close_system( mdl, 1 );
end 
DAStudio.error( 'configset:util:IncorrectArgument' );
end 
end 

if nargin == 3
mdls = varargin{ 2 };
n = length( mdls );
if strcmp( varargin{ 1 }, 'include' )
flag = false;
elseif strcmp( varargin{ 1 }, 'exclude' )
flag = true;
else 
if ~loadFlag
close_system( mdl, 1 );
end 
DAStudio.error( 'configset:util:IncorrectArgument' );
end 
h = configset.util.Propagation( mdl, 'nogui' );
h.selectAll( flag );

for i = 1:n
m = mdls{ i };
if h.Map.isKey( m );
v = h.Map( m );
v.select( ~flag );
else 
if ~strcmp( m, mdl )
disp( DAStudio.message( 'configset:util:ModelNotInHierarchy', m ) );
end 
end 
end 
else 
h = configset.util.Propagation( mdl, 'nogui' );
h.selectAll( true );
end 

h.sl_propagate(  );
h.save(  );

vs = h.Map.values;
for i = 1:length( vs )
v = vs{ i };
if strcmp( v.Status, 'Converted' )
convertedModels{ end  + 1 } = v.Name;%#ok
end 
end 
isPropagated = ~isempty( convertedModels );

delete( h );

if ~loadFlag
try 
w = warning( 'off', 'Simulink:Commands:UpgradeToSLXMessage' );
restore_warning = onCleanup( @(  )warning( w ) );
close_system( mdl, 1 );
delete( restore_warning );
catch e
close_system( mdl, 0 );
throw( e );
end 
end 



end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpk_rQ8n.p.
% Please follow local copyright laws when handling this file.

