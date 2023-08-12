function subsystem_configuration( Action, varargin )


































































if nargin < 1
Action = 'new';
end 
if nargin < 2
varargin{ 1 } = gcb;
end 

curFig = [  ];
curPointerData = { 'arrow', ones( 16, 16 ) };
if ~isempty( gcbf ), 
curFig = gcbf;
curPointerData = get( curFig, { 'Pointer', 'PointerShapeCData' } );
set( curFig, 'Pointer', 'watch' );
end 

switch Action, 

case 'new'
locOpenBlockDialog

case 'establish'
if strcmp( varargin{ 1 }, 'apply' )
locApplyLibraryName( 'apply' );
else 
locApplyLibraryName( 'eval' );
end 

case 'initFcn', 
ConfigBlockStatus = get_param( gcb, 'UserData' );
ConfigBlockStatus.allData = evalin( 'base', 'who' );
ConfigBlockStatus.Initializing = logical( 1 );

set_param( gcb, 'UserData', ConfigBlockStatus );

case 'reestablish'

if nargin > 2, 
locNewLibraryName( varargin{ 1 }, logical( 1 ) )
else , 
locNewLibraryName( varargin{ 1 }, logical( 0 ) )
end 

case 'copy'
locCopyConfiguration

case 'update'
locUpdateConfiguration( varargin{ 1 } )

ConfigBlockStatus = get_param( varargin{ 1 }, 'UserData' );
ConfigBlockStatus.Initializing = logical( 0 );
set_param( varargin{ 1 }, 'UserData', ConfigBlockStatus );


case 'updateDialog', 
locUpdateConfiguration( varargin{ 1 }, logical( 1 ) )

otherwise 
errordlg( DAStudio.message( 'Simulink:blocks:SubsysconfigInvalidArg' ) );
end 


if ishandle( curFig ), 
set( curFig, { 'Pointer', 'PointerShapeCData' }, curPointerData );
end 




function locApplyLibraryName( evalApply )














f = gcbf;
D = get( f, 'Userdata' );
LibraryName = get( D.LibEdit, 'string' );
ConfigBlock = D.ConfigBlock;
mdlName = strtok( LibraryName, '/' );

if ~isempty( mdlName ) & isequal( exist( mdlName ), 4 ), 
existFlag = 0;

load_system( mdlName );

if ~strcmp( mdlName, LibraryName )


all_sys = find_system( mdlName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'lookundermasks', 'all' );
if isempty( find( strcmp( all_sys, LibraryName ) ) )
errordlg( DAStudio.message( 'Simulink:blocks:MissingLibraryNameInModel', LibraryName, mdlName ) );

elseif length( find_system( LibraryName, 'searchdepth', 1, 'type', 'block' ) ) == 1

errordlg( DAStudio.message( 'Simulink:blocks:SubsysNotALib', LibraryName ) );
else , 
existFlag = 1;
end 
else 
existFlag = 1;

end 

if existFlag == 1, 

if strcmp( evalApply, 'eval' ), 
close( f )
end 



status = locSetupBlockInfo( ConfigBlock, LibraryName, mdlName, logical( 0 ) );
if strcmp( evalApply, 'eval' ), 
deleteFcn = '';
else , 
status.fig = f;
deleteFcn = 'close(getfield(get_param(gcb, ''UserData''),''fig''))';
end 

set_param( ConfigBlock,  ...
'UserData', status,  ...
'DeleteFcn', deleteFcn ...
 )
end 

else 

errordlg( DAStudio.message( 'Simulink:blocks:LibraryNotFound', LibraryName ) );
end 




function str = locCell2SepStr( array, sep )



str = '';
for i = 1:length( array )
str = [ str, array{ i }, sep ];
end 
str( end  ) = [  ];





function sty = locConvertToMaskStyles( type, enum )









sty = {  };

for i = 1:length( type )

switch type{ i }
case 'string'
sty{ i } = 'edit';

case 'boolean'
sty{ i } = 'checkbox';

case 'enum'
Str = '';
specEnum = enum{ i };
for j = 1:length( specEnum )
Str = [ Str, specEnum{ j }, '|' ];
end 
Str( end  ) = [  ];
sty{ i } = [ 'popup(', Str, ')' ];

end 
end 




function locCopyConfiguration



ConfigBlock = gcb;

if strcmp( get_param( ConfigBlock, 'linkstatus' ), 'resolved' )
set_param( ConfigBlock, 'linkstatus', 'none' );
eval( 'delete_block([ConfigBlock ''/EmptySubsystem''])', '' );
end 





function array = locDelimitString( str, sep )



array = {  };
while ~isempty( str )
[ array{ length( array ) + 1 }, str ] = strtok( str, '|' );
end 




function locEstablishInports( ConfigBlock, Parent )













inportnames = unique( get_param( find_system( Parent, 'lookundermasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on', 'searchdepth', 2, 'blocktype', 'Inport' ), 'name' ) );
Nin = length( inportnames );





maxportsize = locMaxPorts( Parent );

shellports = get_param( [ ConfigBlock, '/shell' ], 'ports' );
while length( inportnames ) < max( maxportsize( 1 ), shellports( 1 ) )
Nin = Nin + 1;

inportnames = cat( 1, inportnames, { [ 'in', num2str( Nin ) ] } );
end 


cb_inports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Inport' );
cb_inportnames = get_param( cb_inports, 'name' );


extras = setdiff( cb_inportnames, inportnames );
for i = 1:length( extras )
delete_block( char( find_system( ConfigBlock, 'lookundermasks', 'all',  ...
'searchdepth', 1, 'blocktype', 'Inport', 'name', extras{ i } ) ) )
end 


locPlaceAndAdd( ConfigBlock, inportnames, cb_inports, cb_inportnames, 'in' )




function locEstablishOutports( ConfigBlock, Parent )













outportnames = unique( get_param( find_system( Parent, 'lookundermasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on', 'searchdepth', 2, 'blocktype', 'Outport' ), 'name' ) );





maxportsize = locMaxPorts( Parent );


shellports = get_param( [ ConfigBlock, '/shell' ], 'ports' );
while length( outportnames ) < max( maxportsize( 2 ), shellports( 2 ) )
newnum = length( outportnames ) + 1;

outportnames{ newnum } = [ 'out', num2str( newnum ) ];
end 


cb_outports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Outport' );
cb_outportnames = get_param( cb_outports, 'name' );


extras = setdiff( cb_outportnames, outportnames );
for i = 1:length( extras )
delete_block( char( find_system( ConfigBlock, 'lookundermasks', 'all',  ...
'searchdepth', 1, 'blocktype', 'Outport', 'name', extras{ i } ) ) )
end 


locPlaceAndAdd( ConfigBlock, outportnames, cb_outports, cb_outportnames, 'out' )



function maxportsize = locMaxPorts( Parent )









blocks = find_system( Parent,  ...
'lookundermasks', 'all',  ...
'FollowLinks', 'on',  ...
'searchdepth', 1,  ...
'type', 'block' );


if strcmp( Parent, blocks( 1 ) )
blocks( 1 ) = [  ];
end 


ports = get_param( blocks, 'ports' );
ports = cat( 1, ports{ : } );
maxportsize = max( ports, [  ], 1 );



function locNewBlockChoice( ConfigBlock, BlockChoice, BadLink )










ShellBlock = [ ConfigBlock, '/shell' ];
BlockPosition = get_param( ConfigBlock, 'position' );
blockWidth = BlockPosition( 3 ) - BlockPosition( 1 );
blockHeight = BlockPosition( 4 ) - BlockPosition( 2 );
BlockPosition = [ 200, 100, 200 + blockWidth, 100 + blockHeight ];

if BadLink == 0
load_system( bdroot( BlockChoice ) );
add_block( BlockChoice, ShellBlock, 'position', BlockPosition )


shouldopen = get_param( ConfigBlock, 'shouldOpen' );
blocktype = get_param( BlockChoice, 'BlockType' );

Data = get_param( ConfigBlock, 'UserData' );
if isstruct( Data ), 
if isfield( Data, 'Initializing' ), 
Initializing = Data.Initializing;
else , 
Initializing = logical( 0 );
end 
else , 
Initializing = logical( 0 );
end 

if strcmp( shouldopen, 'on' ) &  ...
( hasmask( BlockChoice ) ~= 2 ) &  ...
strcmp( blocktype, 'SubSystem' ) &  ...
~Initializing,  ...
open_system( ShellBlock );
end 

else 
add_block( 'built-in/reference', ShellBlock, 'position', BlockPosition,  ...
'SourceBlock', BlockChoice )
end 




function locNewLibraryName( ConfigBlock, maskInitFlag )










LibraryName = get_param( ConfigBlock, 'LibraryName' );
status = get_param( ConfigBlock, 'UserData' );


if ~isfield( status, 'LibraryName' )
status.LibraryName = LibraryName;
status.Choice = get_param( ConfigBlock, 'Choice' );
status.shouldOpen = get_param( ConfigBlock, 'shouldOpen' );
status.values = get_param( ConfigBlock, 'MaskValues' );
status.allData = {  };
set_param( ConfigBlock, 'UserData', status );
end 

if ~isfield( status, 'dlgOnlyUpdated' ), 
status.dlgOnlyUpdated = logical( 0 );
end 


if isstruct( status ), 
if strcmp( LibraryName, status.LibraryName ) & ~status.dlgOnlyUpdated, 
return 


end 
end 
mdlName = strtok( LibraryName, '/' );

if isequal( exist( mdlName ), 4 ), 

load_system( mdlName );

if ~strcmp( mdlName, LibraryName )


all_sys = find_system( mdlName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'lookundermasks', 'all' );
if isempty( find( strcmp( all_sys, LibraryName ) ) )
errordlg( DAStudio.message( 'Simulink:blocks:MissingLibraryNameInModel', LibraryName, mdlName ) );
elseif length( find_system( LibraryName, 'searchdepth', 1, 'type', 'block' ) ) == 1

errordlg( DAStudio.message( 'Simulink:blocks:SubsysNotALib', LibraryName ) );
else 


locShellEmpty( ConfigBlock );

status = locSetupBlockInfo( ConfigBlock, LibraryName, mdlName, maskInitFlag );
set_param( ConfigBlock, 'UserData', status )
end 
else 


locShellEmpty( ConfigBlock );



status = locSetupBlockInfo( ConfigBlock, LibraryName, mdlName, maskInitFlag );
set_param( ConfigBlock, 'UserData', status )
end 

else 

errordlg( DAStudio.message( 'Simulink:blocks:LibraryNotFound', LibraryName ) );

end 




function [ MaskPrompts, MaskStyles, MaskValues ] = locParamInfo(  ...
BlockList, LibraryName, ConfigBlock )










MaskPrompts = { 'Block choice:', 'Number of parameters:', 'Library name',  ...
'Open subsystems when selected' };
BlockNames = get_param( BlockList, 'name' );

BlockNames = strrep( BlockNames, sprintf( '\n' ), ' ' );
MaskStyles = { [ 'popup(', locCell2SepStr( BlockNames, '|' ), ')' ],  ...
'edit', 'edit', 'checkbox' };


name = BlockNames{ 1 };
try , 
name = get_param( ConfigBlock, 'Choice' );
if ~any( strcmp( BlockNames, name ) ), 
name = BlockNames{ 1 };
end 
end 
MaskValues = { name, '', LibraryName, 'on' };


for i = 1:length( BlockList )


PromptList = get_param( BlockList{ i }, 'MaskPrompts' );

if isempty( PromptList ) &  ...
~strcmp( get_param( BlockList{ i }, 'BlockType' ), 'SubSystem' ), 
dp = get_param( BlockList{ i }, 'dialogparameters' );
if ~isempty( dp )
PromptList = fieldnames( dp );
TypeList = {  };
EnumList = {  };
ValueList = {  };

for j = 1:length( PromptList )
TypeList{ j } = getfield( dp, PromptList{ j }, 'Type' );
EnumList{ j } = getfield( dp, PromptList{ j }, 'Enum' );
ValueList{ j } = get_param( BlockList{ i }, PromptList{ j } );
end 
StyleList = locConvertToMaskStyles( TypeList, EnumList );
else 
PromptList = {  };
StyleList = {  };
ValueList = {  };
end 
else 

StyleList = get_param( BlockList{ i }, 'MaskStyles' );
ValueList = get_param( BlockList{ i }, 'MaskValues' );
end 


MaskPrompts = [ cat( 1, MaskPrompts( : ), PromptList( : ) ) ];
ParamLengths( i ) = length( PromptList );
MaskStyles = [ cat( 1, MaskStyles( : ), StyleList( : ) ) ];
MaskValues = [ cat( 1, MaskValues( : ), ValueList( : ) ) ];
end 

MaskValues{ 2 } = mat2str( ParamLengths );




function locPlaceAndAdd( ConfigBlock, portnames, cb_ports, cb_portnames, porttype )













PortHeight = 20;
PortWidth = 20;
ShellBlock = [ ConfigBlock, '/shell' ];
sb_position = get_param( ShellBlock, 'Position' );
if strcmp( porttype, 'in' )
blocktype = 'Inport';
libport = 'built-in/inport';
x = sb_position( 1 ) - PortWidth - 80;
if x < 5, 
x = sb_position( 1 ) / 4;

end 
else 
blocktype = 'Outport';
libport = 'built-in/outport';
x = sb_position( 3 ) + 5 * PortWidth;
end 


sb_ports = find_system( ShellBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'FollowLinks', 'on',  ...
'blocktype', blocktype );
sb_portnames = get_param( sb_ports, 'name' );
Nsb = length( sb_portnames );
sb_pc = get_param( ShellBlock, 'PortConnectivity' );
sb_ppos = cat( 1, sb_pc.Position );


portnames = cat( 1, sb_portnames, setdiff( portnames, sb_portnames ) );
Npn = length( portnames );



if isequal( Nsb, 0 ), 
y = sb_position( 2 ) + 3 * PortHeight / 2 + 2 * PortHeight * [ 0:( Npn - 1 ) ]';
else , 
y = sb_ppos( 1, 2 ) + 2 * PortHeight * [ 0:( Npn - 1 ) ]';
end 




allpresent = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1 );
allnames = get_param( allpresent, 'name' );
for i = 1:length( portnames )
cb_index = find( strcmp( portnames{ i }, cb_portnames ) );
if isempty( cb_index )


if ~isempty( find( strcmp( portnames{ i }, allnames ) ) )
errMsg = DAStudio.message( 'Simulink:blocks:BlockNameConflict', blocktype, portnames{ i },  ...
get_param( allpresent{ find( strcmp( portnames{ i }, allnames ) ) }, 'blocktype' ) );
errordlg( errMsg );
close( gcbf )
error( errMsg );
end 


add_block( libport, [ ConfigBlock, '/', strrep( portnames{ i }, '/', '//' ) ],  ...
'name', portnames{ i },  ...
'position',  ...
[ x - PortWidth / 2, y( i ) - PortHeight / 2, x + PortWidth / 2, y( i ) + PortHeight / 2 ] );
else 

set_param( cb_ports{ cb_index },  ...
'position',  ...
[ x - PortWidth / 2, y( i ) - PortHeight / 2, x + PortWidth / 2, y( i ) + PortHeight / 2 ] );
end 
end 




function status = locSetupBlockInfo( ConfigBlock, LibraryName, mdlName, maskInitFlag )

















BlockList = find_system( LibraryName, 'searchdepth', 1, 'type', 'block' );
if ~( strcmp( mdlName, LibraryName ) )
BlockList( 1 ) = [  ];
end 
BlockNames = get_param( BlockList, 'name' );
BlockNames = strrep( BlockNames, sprintf( '\n' ), ' ' );

temp = get_param( ConfigBlock, 'UserData' );
if ~isstruct( temp ) | ~strcmp( LibraryName, temp.LibraryName ), 
maskInitFlag = logical( 0 );
CHOICE = BlockNames{ 1 };
else , 
CHOICE = temp.Choice;
end 


[ MaskPrompts, MaskStyles, MaskValues ] =  ...
locParamInfo( BlockList, LibraryName, ConfigBlock );


MaskVisible{ 1 } = 'on';
MaskVisible{ 2 } = 'off';
MaskVisible{ 3 } = 'off';
notmasked = find( hasmask( BlockList ) ~= 2 );
nmtype = get_param( BlockList( notmasked ), 'blocktype' );
if any( strcmp( nmtype, 'SubSystem' ) )
MaskVisible{ 4 } = 'on';

MaskCallback{ 4 } = 'subsystem_configuration update';
else 
MaskVisible{ 4 } = 'off';
MaskCallback{ 4 } = '';
end 


MaskCallback{ 1 } = 'subsystem_configuration updateDialog';
MaskCallback{ 2 } = '';


MaskCallback{ 3 } = '';

ParamLengths = eval( MaskValues{ 2 } );



index = find( strcmp( BlockNames, CHOICE ) );
range = sum( ParamLengths( 1:( index - 1 ) ) ) + 5:sum( ParamLengths( 1:index ) ) + 4;


for i = 5:( sum( ParamLengths ) + 4 )
if ismember( i, range )
MaskVisible{ i } = 'on';
else 
MaskVisible{ i } = 'off';
end 
MaskCallback{ i } = '';
end 

MaskDescription = [ 'This block is configured to represent any of the top ' ...
, 'level blocks and subsystems in the ''', LibraryName, ''' Library' ];


MaskVariables = 'Choice = @1; lengths = @2; LibraryName = &3; shouldOpen = @4';


if ~maskInitFlag, 
set_param( ConfigBlock,  ...
'MaskType', 'Configuration Block',  ...
'MaskSelfModifiable', 'on',  ...
'MaskDescription', MaskDescription,  ...
'MaskPrompts', MaskPrompts,  ...
'MaskStyles', MaskStyles,  ...
'MaskValues', MaskValues,  ...
'MaskIconFrame', 'on',  ...
'MaskIconOpaque', 'off',  ...
'OpenFcn', '',  ...
'MaskCallbacks', MaskCallback,  ...
'MaskInitialization', '',  ...
'MaskVariables', MaskVariables,  ...
'MaskDisplay', 'disp('''')' );

set_param( ConfigBlock,  ...
'LoadFcn', 'subsystem_configuration(''reestablish'')' )
end 

set_param( ConfigBlock, 'MaskVisibilities', MaskVisible );



locShellFill( ConfigBlock, BlockNames{ 1 }, MaskValues( 5:ParamLengths( 1 ) + 4 ) )
status.LibraryName = LibraryName;
status.Choice = BlockNames{ 1 };
status.shouldOpen = get_param( ConfigBlock, 'shouldOpen' );
status.values = MaskValues;
status.dlgOnlyUpdated = logical( 0 );
status.allData = {  };

if ~maskInitFlag, 
set_param( ConfigBlock,  ...
'MaskInitialization', 'subsystem_configuration_blkinit',  ...
'InitFcn', 'subsystem_configuration(''initFcn'')' );
end 




function locShellDrawIcon( ConfigBlock )









ShellBlock = [ ConfigBlock, '/shell' ];
shellType = get_param( ShellBlock, 'BlockType' );
CBPorts = get_param( ConfigBlock, 'ports' );
portInfo = get_param( [ ConfigBlock, '/shell' ], 'ports' );
shellMaskType = hasmask( ShellBlock );
shellOpaque = get_param( ShellBlock, 'MaskIconOpaque' );

if ( strcmp( shellType, 'SubSystem' ) &  ...
strcmp( get_param( ShellBlock, 'ShowPortLabels' ), 'on' ) &  ...
( isequal( shellMaskType, 0 ) | ( ~isequal( shellMaskType, 0 ) &  ...
strcmp( shellOpaque, 'off' ) ) ) &  ...
( ~isequal( CBPorts( 1:2 ), portInfo( 1:2 ) ) ) );

set_param( ConfigBlock,  ...
'MaskDisplay', 'disp('''')',  ...
'MaskIconOpaque', 'off',  ...
'ShowPortLabels', 'on' )
else 
set_param( ConfigBlock, 'MaskDisplay', 'block_icon(''shell'')' );
end 




function locShellEmpty( ConfigBlock )










ShellBlock = [ ConfigBlock, '/shell' ];
try 
delete_block( ShellBlock )


terminators = find_system( ConfigBlock,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'lookundermasks', 'all',  ...
'blocktype', 'Terminator' );
for i = 1:length( terminators )
delete_block( terminators{ i } )
end 


grounds = find_system( ConfigBlock,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'lookundermasks', 'all',  ...
'blocktype', 'Ground' );
for i = 1:length( grounds )
delete_block( grounds{ i } )
end 
catch 
end 


sl_lines = get_param( ConfigBlock, 'lines' );
for i = 1:length( sl_lines )
delete_line( sl_lines( i ).Handle )
end 




function locShellFill( ConfigBlock, Choice, MV )













BadLink = 0;
try 
Parent = get_param( ConfigBlock, 'LibraryName' );
BlockChoice = [ Parent, '/', Choice ];
catch 
BadLink = 1;
end 


locShellEmpty( ConfigBlock )


locNewBlockChoice( ConfigBlock, BlockChoice, BadLink );


if ~isempty( MV )
locShellParams( ConfigBlock, MV, BadLink )
end 


locEstablishInports( ConfigBlock, Parent );
locEstablishOutports( ConfigBlock, Parent );


portInfo = get_param( [ ConfigBlock, '/shell' ], 'ports' );
locWireInputs( ConfigBlock, portInfo( 1 ) )
locWireOutputs( ConfigBlock, portInfo( 2 ) )
locShellDrawIcon( ConfigBlock );




function locShellParams( ConfigBlock, MV, BadLink )










ShellBlock = [ ConfigBlock, '/shell' ];
if BadLink == 0

if isempty( get_param( ShellBlock, 'MaskValues' ) )

a = get_param( ShellBlock, 'dialogparameters' );
b = fieldnames( a );
if length( b ) ~= length( MV )
disp( 'something is wrong' )
else 
for i = 1:length( b )
set_param( ShellBlock, b{ i }, MV{ i } )
end 
end 
else 
set_param( ShellBlock, 'MaskValues', MV )
end 
end 




function locShellUpdate( ConfigBlock, Choice, MV )



















status = get_param( ConfigBlock, 'UserData' );
if ~strcmp( Choice, status.Choice )

BadLink = 0;
try 
Parent = get_param( ConfigBlock, 'LibraryName' );
BlockChoice = [ Parent, '/', Choice ];
portInfo = get_param( BlockChoice, 'ports' );
catch 
BadLink = 1;
portInfo = [ 0, 0, 0, 0, 0 ];
end 


locShellEmpty( ConfigBlock )


locNewBlockChoice( ConfigBlock, BlockChoice, BadLink );


if ~isempty( MV )
locShellParams( ConfigBlock, MV, BadLink )
end 


portInfo = get_param( [ ConfigBlock, '/shell' ], 'ports' );
locWireInputs( ConfigBlock, portInfo( 1 ) )
locWireOutputs( ConfigBlock, portInfo( 2 ) )
locShellDrawIcon( ConfigBlock );


status.Choice = Choice;
set_param( ConfigBlock, 'UserData', status )
end 




function locUpdateConfiguration( ConfigBlock, dlgOnlyFlag )









if nargin == 1, 
dlgOnlyFlag = logical( 0 );
end 

CHOICE = get_param( ConfigBlock, 'Choice' );
shouldOpen = get_param( ConfigBlock, 'shouldOpen' );
values = get_param( ConfigBlock, 'MaskValues' );
status = get_param( ConfigBlock, 'UserData' );
libName = get_param( ConfigBlock, 'LibraryName' );


if ~isfield( status, 'Choice' )
status.LibraryName = get_param( ConfigBlock, 'LibraryName' );
status.Choice = CHOICE;
status.shouldOpen = shouldOpen;
status.values = values;
set_param( ConfigBlock, 'UserData', status );
end 


if isstruct( status ) & dlgOnlyFlag
if strcmp( CHOICE, status.Choice ) &  ...
strcmp( shouldOpen, status.shouldOpen ) &  ...
strcmp( values, status.values ), 
return 
end 
end 

styles = get_param( ConfigBlock, 'MaskStyles' );
visibilities = get_param( ConfigBlock, 'MaskVisibilities' );


names = styles{ 1 };
names( [ 1:6, end  ] ) = [  ];
NameArray = locDelimitString( names, '|' );
index = find( strcmp( NameArray, CHOICE ) );


NumParams = eval( values{ 2 } );
range = sum( NumParams( 1:( index - 1 ) ) ) + 5:sum( NumParams( 1:index ) ) + 4;




MaskVisible = visibilities( 1:4 );


for i = 5:( sum( NumParams ) + 4 )
if ismember( i, range )
MaskVisible{ i } = 'on';
else 
MaskVisible{ i } = 'off';
end 
end 


status = get_param( ConfigBlock, 'Userdata' );
LibraryName = get_param( ConfigBlock, 'LibraryName' );
status.LibraryName = LibraryName;
status.Choice = CHOICE;
status.shouldOpen = shouldOpen;
status.values = values;

if ~dlgOnlyFlag, 
status.dlgOnlyUpdated = logical( 0 );
else , 
status.dlgOnlyUpdated = logical( 1 );
set_param( ConfigBlock, 'UserData', status,  ...
'MaskVisibilities', MaskVisible )
end 


if ~dlgOnlyFlag, 
locShellUpdate( ConfigBlock, CHOICE, values( range ) )
end 




function locWireInputs( ConfigBlock, Nin )







ShellBlock = [ ConfigBlock, '/shell' ];
sb_inports = find_system( ShellBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'followlinks', 'on',  ...
'blocktype', 'Inport' );
cb_inports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Inport' );
cb_names = get_param( cb_inports, 'name' );



if Nin > length( cb_inports )
Parent = get_param( ConfigBlock, 'LibraryName' );
locEstablishInports( ConfigBlock, Parent );
end 
cb_inports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Inport' );
cb_names = get_param( cb_inports, 'name' );

reorderedIndices = zeros( length( cb_inports ), 1 );

if isempty( sb_inports ) & ( Nin > 0 )
for i = 1:Nin
reorderedIndices( i ) = i;
add_line( ConfigBlock, [ strrep( cb_names{ i }, '/', '//' ), '/1' ],  ...
[ 'shell/', num2str( i ) ] )
end 
else 

sb_names = get_param( sb_inports, 'name' );
for i = 1:Nin
index = find( strcmp( cb_names, sb_names{ i } ) );
reorderedIndices( i ) = index;
add_line( ConfigBlock, [ strrep( cb_names{ index }, '/', '//' ), '/1' ],  ...
[ 'shell/', num2str( i ) ] )
end 
end 


ct = Nin;
for i = 1:length( cb_inports )
if isempty( getfield( get_param( cb_inports{ i }, 'portconnectivity' ),  ...
'DstBlock' ) ), 
ct = ct + 1;
reorderedIndices( ct ) = i;
end 
end 



if length( cb_inports ) > 0, 
inportPositions = get_param( cb_inports, 'Position' );
if iscell( inportPositions ), 
inportPositions = cat( 1, inportPositions{ : } );
end 
[ y, idx ] = sort( inportPositions( :, 2 ) );
inportPositions = inportPositions( idx, : );
inportPositions = num2cell( inportPositions, 2 );
for lp = 1:length( cb_inports ), 
set_param( cb_inports{ reorderedIndices( lp ) }, 'Position', inportPositions{ lp } );
end 
end 

for i = 1:length( cb_inports )
if isempty( getfield( get_param( cb_inports{ i }, 'portconnectivity' ),  ...
'DstBlock' ) ), 
termpos = get_param( cb_inports{ i }, 'position' ) + [ 60, 0, 60, 0 ];
add_block( 'built-in/Terminator', [ ConfigBlock, '/ignore', num2str( i ) ],  ...
'position', termpos, 'ShowName', 'off' );
add_line( ConfigBlock, [ strrep( get_param( cb_inports{ i }, 'name' ),  ...
'/', '//' ), '/1' ], [ 'ignore', num2str( i ), '/1' ] )
end 
end 





function locWireOutputs( ConfigBlock, Nout )








ShellBlock = [ ConfigBlock, '/shell' ];
sb_outports = find_system( ShellBlock,  ...
'lookundermasks', 'all',  ...
'followlinks', 'on',  ...
'searchdepth', 1,  ...
'blocktype', 'Outport' );
cb_outports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Outport' );
cb_names = get_param( cb_outports, 'name' );



if Nout > length( cb_outports )
Parent = get_param( ConfigBlock, 'LibraryName' );
locEstablishOutports( ConfigBlock, Parent );
end 
cb_outports = find_system( ConfigBlock,  ...
'lookundermasks', 'all',  ...
'searchdepth', 1,  ...
'blocktype', 'Outport' );
cb_names = get_param( cb_outports, 'name' );


reorderedIndices = zeros( length( cb_outports ), 1 );
if isempty( sb_outports ) & ( Nout > 0 )
for i = 1:Nout
reorderedIndices( i ) = i;
add_line( ConfigBlock, [ 'shell/', num2str( i ) ],  ...
[ strrep( cb_names{ i }, '/', '//' ), '/1' ] )
end 
else 

sb_names = get_param( sb_outports, 'name' );
for i = 1:Nout
index = find( strcmp( cb_names, sb_names{ i } ) );
reorderedIndices( i ) = index;
add_line( ConfigBlock, [ 'shell/', num2str( i ) ],  ...
[ strrep( cb_names{ index }, '/', '//' ), '/1' ] )
end 
end 


ct = Nout;
for i = 1:length( cb_outports )
if getfield( get_param( cb_outports{ i }, 'portconnectivity' ), 'SrcBlock' ) < 0
ct = ct + 1;
reorderedIndices( ct ) = i;
end 
end 


if ct > 0, 
outportPositions = get_param( cb_outports, 'Position' );
if iscell( outportPositions ), 
outportPositions = cat( 1, outportPositions{ : } );
end 
[ y, idx ] = sort( outportPositions( :, 2 ) );
outportPositions = outportPositions( idx, : );
outportPositions = num2cell( outportPositions, 2 );
for lp = 1:length( cb_outports ), 
set_param( cb_outports{ reorderedIndices( lp ) },  ...
'Position', outportPositions{ lp } );
end 
end 


for i = 1:length( cb_outports )
if getfield( get_param( cb_outports{ i }, 'portconnectivity' ), 'SrcBlock' ) < 0
gndpos = get_param( cb_outports{ i }, 'position' ) - [ 60, 0, 60, 0 ];
add_block( 'built-in/Ground', [ ConfigBlock, '/earth', num2str( i ) ],  ...
'position', gndpos, 'ShowName', 'off' );
add_line( ConfigBlock, [ 'earth', num2str( i ), '/1' ],  ...
[ strrep( get_param( cb_outports{ i }, 'name' ), '/', '//' ), '/1' ] )
end 
end 




function locOpenBlockDialog






ConfigBlock = gcb;

if ( strcmp( get_param( bdroot( ConfigBlock ), 'Lock' ), 'on' ) )
errordlg( DAStudio.message( 'Simulink:blocks:ConfigSubsysNotInModel' ), 'Error', 'modal' );
return 
end 


FigHandle = get_param( ConfigBlock, 'UserData' );
if ishandle( FigHandle )
set( FigHandle, 'visible', 'on' )
figure( FigHandle )
elseif isstruct( FigHandle ) && ishandle( FigHandle.fig )
set( FigHandle.fig, 'visible', 'on' )
figure( FigHandle.fig )
else 

gray = get( 0, 'defaultuicontrolbackgroundcolor' );


dialogPos = [ 1, 1, 300, 150 ];
f = figure(  ...
'Numbertitle', 'off',  ...
'HandleVisibility', 'callback',  ...
'IntegerHandle', 'off',  ...
'Name', get_param( ConfigBlock, 'name' ),  ...
'Menubar', 'none',  ...
'Visible', 'on',  ...
'Color', gray,  ...
'Resize', 'off',  ...
'Tag', 'Configurable Subsystem Figure',  ...
'Units', 'points',  ...
'Position', dialogPos,  ...
'Pointer', 'watch',  ...
'Units', 'characters' ...
 );

f0 = uicontrol( f,  ...
'Style', 'frame',  ...
'Units', 'characters',  ...
'BackgroundColor', gray,  ...
'Tag', 'Top Frame',  ...
'Position', [ 1.25, 6.875, 47.5, 4.375 ] ...
 );

t0 = uicontrol( f,  ...
'Style', 'text',  ...
'Units', 'characters',  ...
'Position', [ 2.5, 10.625, 50, 2 ],  ...
'BackgroundColor', gray,  ...
'Tag', 'Title',  ...
'String', 'Configurable Subsystem:' ...
 );


t0E = get( t0, 'Extent' );
set( t0, 'Position', [ 2.5, 10.625, t0E( 3 ) + 0.5, t0E( 4 ) ] )

DescStr = get_param( ConfigBlock, 'MaskDescription' );

l0 = uicontrol( f,  ...
'Style', 'text',  ...
'Units', 'characters',  ...
'Position', [ 2.5, 7.5, 45, 3.125 ],  ...
'BackgroundColor', gray,  ...
'Max', 2,  ...
'Min', 0,  ...
'HorizontalAlignment', 'left',  ...
'Tag', 'Description',  ...
'Value', [  ],  ...
'String', [ 'This block may be configured to represent any ' ...
, 'of the top-level blocks and subsystems in a ' ...
, 'user-specified Simulink Library.' ] ...
 );


f1 = uicontrol( f,  ...
'Style', 'frame',  ...
'Units', 'characters',  ...
'BackgroundColor', gray,  ...
'Tag', 'Bottom Frame',  ...
'Position', [ 1.25, 3.125, 47.5, 2.8125 ] ...
 );

t1 = uicontrol( f,  ...
'Style', 'text',  ...
'Units', 'characters',  ...
'Position', [ 2.5, 5.15, 11.4, 1.6 ],  ...
'BackgroundColor', gray,  ...
'Tag', 'Prompt Title',  ...
'String', 'Library name:' ...
 );
t1E = get( t1, 'Extent' );
set( t1, 'Position', [ 2.5, 5.15, t1E( 3 ) + 0.5, t1E( 4 ) ] )

D.LibEdit = uicontrol( f,  ...
'Style', 'edit',  ...
'HorizontalAlignment', 'left',  ...
'BackgroundColor', [ 1, 1, 1 ],  ...
'Units', 'characters',  ...
'Tag', 'Edit',  ...
'Position', [ 2.5, 3.75, 45, 1.625 ] ...
 );

D.OkButton = uicontrol( f,  ...
'Style', 'pushbutton',  ...
'String', 'OK',  ...
'BackgroundColor', gray,  ...
'Units', 'characters',  ...
'Position', [ 2.5, 0.5, 10.0, 1.875 ],  ...
'Tag', 'OK',  ...
'Callback', 'subsystem_configuration establish' ...
 );

D.CancelButton = uicontrol( f,  ...
'Style', 'pushbutton',  ...
'String', 'Cancel',  ...
'Backgroundcolor', gray,  ...
'Units', 'characters',  ...
'Position', [ 13.75, 0.5, 10.0, 1.875 ],  ...
'Tag', 'Cancel',  ...
'Callback', 'close(gcbf)' ...
 );

D.HelpButton = uicontrol( f,  ...
'Style', 'pushbutton',  ...
'String', 'Help',  ...
'BackgroundColor', gray,  ...
'Units', 'characters',  ...
'Position', [ 25.0, 0.5, 10.0, 1.875 ],  ...
'Tag', 'Help',  ...
'Callback',  ...
[ 'slhelp(get_param(getfield(get(gcbf,''UserData''),' ...
, '''ConfigBlock''),''handle''))' ] ...
 );

D.ApplyButton = uicontrol( f,  ...
'Style', 'pushbutton',  ...
'String', 'Apply',  ...
'BackgroundColor', gray,  ...
'Units', 'characters',  ...
'Position', [ 36.25, 0.5, 10.0, 1.875 ],  ...
'Tag', 'Apply',  ...
'Callback', 'subsystem_configuration establish apply' ...
 );

D.ConfigBlock = ConfigBlock;

dialogPos = get( f, 'Position' );
ttlPos = get( t0, 'Position' );
frmPos = get( f0, 'Position' );

Temp = get( 0, 'Units' );
set( 0, 'Units', 'pixels' );
screenSize = get( 0, 'ScreenSize' );
set( 0, 'Units', Temp );
bdPos = get_param( bdroot( ConfigBlock ), 'Location' );
hgPos = rectconv( bdPos, 'hg' );
dialogPos( 3 ) = [ frmPos( 3 ) + 2 * frmPos( 1 ) ];
dialogPos( 4 ) = [ sum( ttlPos( [ 2, 4 ] ) ) + 0.25 ];
set( f, 'Position', dialogPos, 'Units', 'pixels' );
dialogPos = get( f, 'Position' );
dialogPos( 1 ) = hgPos( 1 ) + ( hgPos( 3 ) - dialogPos( 3 ) ) / 2;
dialogPos( 2 ) = hgPos( 2 ) + ( hgPos( 4 ) - dialogPos( 4 ) ) / 2;

set( f,  ...
'Position', dialogPos,  ...
'Units', 'characters',  ...
'Userdata', D,  ...
'Pointer', 'arrow',  ...
'CloseRequestFcn',  ...
[ 'set_param(getfield(get(gcf,''UserData''),''ConfigBlock''),' ...
, '''DeleteFcn'','''');' ...
, 'delete(gcf)' ] ...
 );

set_param( ConfigBlock,  ...
'UserData', f,  ...
'DeleteFcn', 'close(get_param(gcb, ''UserData''))' )

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpWbuLc6.p.
% Please follow local copyright laws when handling this file.

