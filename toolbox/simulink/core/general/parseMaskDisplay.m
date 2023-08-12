




function [ out, wsDependent, funcDependent ] = parseMaskDisplay( slInternal_xxx_mask_display_string_to_be_parsed, slInternal_xxx_wsVars, slInternal_xxx_cmdList, slInternal_xxx_parseType )

mlock;

out = [  ];%#ok<NASGU>
wsDependent = false;
funcDependent = false;

plot = @subfun_plot;%#ok<NASGU>
port_label = @subfun_port_label;%#ok<NASGU>
color = @subfun_color;%#ok<NASGU>
image = @subfun_image;%#ok<NASGU>
disp = @subfun_disp;%#ok<NASGU>
interactive_disp = @subfun_interactive_disp;%#ok<NASGU>
fprintf = @subfun_fprintf;%#ok<NASGU>
text = @subfun_text;%#ok<NASGU>
droots = @subfun_droots;%#ok<NASGU>
dpoly = @subfun_dpoly;%#ok<NASGU>
patch = @subfun_patch;%#ok<NASGU>
block_icon = @subfun_block_icon;%#ok<NASGU>
hide_arrows = @subfun_hide_arrows;%#ok<NASGU>


try 

for slInternal_xxx_counter_for_ws_variables = 1:slInternal_xxx_getLength( slInternal_xxx_wsVars )
eval( [ slInternal_xxx_wsVars( slInternal_xxx_counter_for_ws_variables ).Name, ' = slInternal_xxx_wsVars(slInternal_xxx_counter_for_ws_variables).Value;' ] )
end 

slInternal_xxx_dependent = slInternal( 'MaskEvalCmd', slInternal_xxx_mask_display_string_to_be_parsed );

switch slInternal_xxx_parseType
case 'parseForCommands'
otherwise 



if slInternal_xxx_dependent
slInternal_xxx_wsVarNames = [  ];
if ~isempty( slInternal_xxx_wsVars )
slInternal_xxx_wsVarNames = { slInternal_xxx_wsVars.Name };
end 

[ wsDependent, funcDependent ] = parseDisplayString( mtree( slInternal_xxx_mask_display_string_to_be_parsed ), slInternal_xxx_wsVarNames, slInternal_xxx_cmdList, false );
end 
end 
catch me
out = updateCommand;%#ok - done to clear cache of parsed commands
wsDependent = true;%#ok<NASGU>
funcDependent = true;%#ok<NASGU>
rethrow( me );
end 


out = updateCommand;
end 



function out = slInternal_xxx_getLength( in )
out = length( in );
end 


function [ bContains ] = i_Contains( aContainer, aElement )
for i = 1:length( aContainer )
bContains = strcmp( aElement, aContainer{ i } );
if bContains
return ;
end 
end 

bContains = false;
end 

function [ bHasDependency ] = i_GetWorkspaceDependency( aTree, aWSVars )
bHasDependency = false;

if isempty( aWSVars )
return ;
end 


aNodes = mtfind( aTree, 'Kind', 'ID' );
aVarNames = strings( aNodes );


for iVarIdx = 1:length( aVarNames )
bHasDependency = i_Contains( aWSVars, aVarNames{ iVarIdx } );
if bHasDependency
return ;
end 
end 
end 

function [ bHasDependency ] = i_GetFunctionalDependency( aCallNodes, aCmdList )
bHasDependency = false;

aNodes = mtfind( aCallNodes, 'Right.Null', false );
aFcnNames = strings( Left( aNodes ) );



for iFcnIdx = 1:length( aFcnNames )
if ~i_Contains( aCmdList, aFcnNames{ iFcnIdx } )
bHasDependency = true;
return ;
end 
end 
end 

function [ wsDependency, functionalDependency ] = parseDisplayString( tree, wsVars, cmdList, isFile )

wsDependency = false;
functionalDependency = false;%#ok<NASGU>

if ( isnull( tree ) || ( isFile && iskind( root( tree ), 'FUNCTION' ) ) )
functionalDependency = true;
return ;
end 


wsDependency = i_GetWorkspaceDependency( tree, wsVars );



aCallNodes = mtfind( tree, 'Kind', { 'CALL', 'DCALL' } );

functionalDependency = i_GetFunctionalDependency( aCallNodes, cmdList );

if ~( wsDependency && functionalDependency )


aNodes = mtfind( aCallNodes, 'Right.Null', true );
if isnull( aNodes )



if ~functionalDependency
functionalDependency = anykind( tree, 'DOT' );
end 
return ;
end 

aFcnNames = strings( Left( aNodes ) );

for index = 1:length( aFcnNames )
aFcnName = aFcnNames{ index };


if ( i_Contains( wsVars, aFcnName ) || ( exist( aFcnName, 'file' ) ~= 2 ) )
continue ;
end 


try 
aFilePath = which( aFcnName );
[ tempWsDependency, tempFuncDependency ] = parseDisplayString( mtree( aFilePath, '-file' ), wsVars, cmdList, true );
catch 
tempWsDependency = false;
tempFuncDependency = true;
end 

wsDependency = wsDependency | tempWsDependency;
functionalDependency = functionalDependency | tempFuncDependency;

if wsDependency && functionalDependency
break ;
end 
end 
end 
end 


function subfun_plot( varargin )
updateCommand( 'plot', nargin, varargin );
end 


function subfun_port_label( varargin )
updateCommand( 'port_label', nargin, varargin );
end 


function subfun_color( varargin )
updateCommand( 'color', nargin, varargin );
end 


function subfun_image( varargin )
updateCommand( 'image', nargin, varargin );
end 


function subfun_interactive_disp( varargin )
updateCommand( 'interactive_disp', nargin, varargin );
end 


function subfun_disp( varargin )
updateCommand( 'disp', nargin, varargin );
end 


function subfun_fprintf( varargin )
updateCommand( 'fprintf', nargin, varargin );
end 


function subfun_text( varargin )
updateCommand( 'text', nargin, varargin );
end 


function subfun_droots( varargin )
updateCommand( 'droots', nargin, varargin );
end 


function subfun_dpoly( varargin )
updateCommand( 'dpoly', nargin, varargin );
end 


function subfun_patch( varargin )
updateCommand( 'patch', nargin, varargin );
end 


function subfun_block_icon( varargin )
updateCommand( 'block_icon', nargin, varargin );
end 


function subfun_hide_arrows( varargin )
updateCommand( 'hide_arrows', nargin, varargin );
end 

function C = updateCommand( command, nrhs, prhs )
persistent CommandList;
if nargin > 0
idx = length( CommandList ) + 1;
CommandList( idx ).command = command;
CommandList( idx ).nrhs = nrhs;
CommandList( idx ).prhs = prhs;
elseif isempty( CommandList )
C = struct( 'command', {  }, 'nrhs', {  }, 'prhs', {  } );
else 
C = CommandList;
CommandList = [  ];
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp9VT0aE.p.
% Please follow local copyright laws when handling this file.

