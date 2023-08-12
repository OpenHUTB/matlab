function [ blocksTree, blockNames ] = SigAndScopeMgrLoadLibrary( LibName )






libHandle = LoadSystem( LibName );

BlockFullNames = {  };
[ blocksTree, blockNames ] = FindAllChildren( libHandle, BlockFullNames );









function libH = LoadSystem( lib )

libH = find_system( 0, 'SearchDepth', 0, 'Name', lib );

if isempty( libH ), 



try 
defwarn = warning;
warning( 'off' );
load_system( lib );
end 
warning( defwarn )




libH = find_system( 0, 'SearchDepth', 0, 'CaseSensitive', 'off', 'Name', lib );
if isempty( libH ), 
error( message( 'Simulink:blocks:SSMgrLibraryUnavailable', lib ) );
end 
end 










function [ b, BlockFullNames ] = FindAllChildren( libH, BlockFullNames )

defwarn = warning;
warning( 'off', 'all' );
b = {  };
k = 0;
for i = 1:length( libH )


lib_blocks = find_system( libH( i ), 'SearchDepth', 1,  ...
'LookUnderMasks', 'functional' );
lib_blocks( 1 ) = [  ];


if ~strcmp( get_param( libH( i ), 'Type' ), 'block_diagram' )
if strcmp( get_param( libH( i ), 'BlockType' ), 'SubSystem' )
if ( ~strcmp( get_param( libH( i ), 'TemplateBlock' ), '' ) )
lib_blocks = [  ];
end 
end 
end 

lib_blocks = OrderBlocks( lib_blocks );




if strcmp( get_param( libH( i ), 'Name' ), 'simulink' )
lib_blocks = [ lib_blocks( 2:end  );lib_blocks( 1 ) ];
end 

Name = strrep( get_param( libH( i ), 'Name' ), sprintf( '\n' ), ' ' );

if strcmpi( get_param( libH( i ), 'Type' ), 'block' ), 
OpenFcnStr = get_param( libH( i ), 'OpenFcn' );
else 
OpenFcnStr = '';
end 

prune = 0;
if ~isempty( OpenFcnStr )


OpenFcnStr = strrep( OpenFcnStr, ';', '' );
subsystem = '';


if strncmp( OpenFcnStr, 'load_open_subsystem', 19 )
cmd = strrep( OpenFcnStr, 'load_open_subsystem', 'FindLibAndSubsystem' );
[ OpenFcnStr, subsystem ] = eval( cmd );
end 

if exist( OpenFcnStr, 'file' ) == 4
load_system( OpenFcnStr );
if strcmp( get_param( OpenFcnStr, 'BlockDiagramType' ), 'library' )
if isempty( subsystem )
O_blk = get_param( OpenFcnStr, 'Handle' );
lib_blocks = find_system( O_blk, 'SearchDepth', 1 );
else 
O_blk = get_param( subsystem, 'Handle' );
lib_blocks = find_system( O_blk, 'SearchDepth', 1 );
end 
lib_blocks( 1 ) = [  ];
lib_blocks = OrderBlocks( lib_blocks );
else 
if strcmpi( get_param( OpenFcnStr, 'Open' ), 'off' )
close_system( OpenFcnStr, 0 );
end 

prune = 1;
end 
else 


totalBlocks = find_system( libH( i ), 'SearchDepth', 1,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all' );
totalBlocks( 1 ) = [  ];
if isempty( totalBlocks ) && strcmp( get_param( libH( i ), 'BlockType' ), 'SubSystem' )


if strcmp( get_param( libH( i ), 'Mask' ), 'off' ) ||  ...
isempty( strfind( get_param( libH( i ), 'MaskVariables' ), 'ShowInLibBrowser' ) )
prune = 1;
end 
end 
end 
end 


if ~prune
k = k + 1;
BlockFullNames{ end  + 1 } = getfullname( libH( i ) );

if isempty( lib_blocks )
b{ k, 1 } = Name;
else 
[ blockNames, BlockFullNames ] = FindAllChildren( lib_blocks, BlockFullNames );
b{ k, 1 }{ 1 } = Name;
b{ k, 1 }{ 2 } = blockNames;
end 
end 

end 
warning( defwarn )







function blocks = OrderBlocks( blocksIn )

if strcmpi( get_param( blocksIn, 'Type' ), 'block' ), 






type = get_param( blocksIn, 'BlockType' );
dlg = hasmaskdlg( blocksIn );
diveIn = ~dlg & strcmpi( type, 'Subsystem' );
openFcnStr = get_param( blocksIn, 'OpenFcn' );
if ischar( openFcnStr ), 
openFcnStr = { openFcnStr };
end 
for i = 1:length( openFcnStr ), 
if ~strcmpi( openFcnStr{ i }, '' ), 
openFcnStr{ i } = strrep( openFcnStr{ i }, ';', '' );
if exist( openFcnStr{ i }, 'file' ) ~= 4, 
diveIn( i ) = false;
end 
end 
end 

firsts = find( diveIn == true );
lasts = find( diveIn == false );


last_names = cellstr( get_param( blocksIn( lasts ), 'Name' ) );
last_names = regexprep( last_names, '\s+', ' ' );
[ b, indx ] = sort( lower( last_names ) );%#ok - mlint
lasts = lasts( indx );

first_names = cellstr( get_param( blocksIn( firsts ), 'Name' ) );
first_names = regexprep( first_names, '\s+', ' ' );
[ b, indx ] = sort( lower( first_names ) );%#ok - mlint
firsts = firsts( indx );

blocks = blocksIn( [ firsts;lasts ] );
else 
blocks = blocksIn;
end 









function [ r1, r2 ] = FindLibAndSubsystem( p1, p2 )

r1 = p1;
r2 = p2;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEoqSru.p.
% Please follow local copyright laws when handling this file.

