function LibData = libinfo( Sys, varargin )


























CellBlocks = find_system( Sys,  ...
'LookUnderMasks', 'all',  ...
'FollowLinks', 'on',  ...
varargin{ : },  ...
'Type', 'block' ...
 );


LinkStatus = get_param( CellBlocks, 'StaticLinkStatus' );
IDX1 = strcmp( LinkStatus, 'none' ) | strcmp( LinkStatus, 'implicit' );

CellBlocksCpy = CellBlocks;

CellBlocks( IDX1 ) = [  ];
Blocks = get_param( CellBlocks, 'Handle' );
if iscell( Blocks )
Blocks = [ Blocks{ : } ]';
end 


LinkStatus( IDX1 ) = [  ];
if ~iscell( LinkStatus )
LinkStatus = { LinkStatus };
end 

if ~isempty( CellBlocks )
if isnumeric( CellBlocks )
CellBlocks = num2cell( CellBlocks );


elseif ~iscell( CellBlocks )
CellBlocks = cellstr( CellBlocks );
end 


CellBlocks = CellBlocks( : );
ReferenceBlock = get_param( Blocks, 'ReferenceBlock' );
AncestorBlock = get_param( Blocks, 'AncestorBlock' );

if ~isempty( ReferenceBlock ) || ~isempty( AncestorBlock )
if iscell( ReferenceBlock )
idx = find( strcmp( ReferenceBlock, '' ) );
ReferenceBlock( idx ) = AncestorBlock( idx );
else 
if isempty( ReferenceBlock )
ReferenceBlock = AncestorBlock;
end 
end 
end 

if ~isempty( ReferenceBlock )
if iscell( ReferenceBlock )
ReferenceBlock = ReferenceBlock( : );
else 
ReferenceBlock = { ReferenceBlock };
end 
end 

aBadLinkLoc = strcmp( LinkStatus, 'unresolved' );
aBadLinkBlocks = Blocks( aBadLinkLoc );

try 
aSourceBlocks = get_param( aBadLinkBlocks, 'SourceBlock' );
catch 

aSourceBlocks = cell( length( aBadLinkBlocks ) );
aInportOutportBlockTypes = { 'Inport', 'Outport' };

for i = 1:length( aBadLinkBlocks )
aBlockType = get_param( aBadLinkBlocks( i ), 'BlockType' );
if contains( aBlockType, aInportOutportBlockTypes )
aSourceBlocks{ i } = get_param( aBadLinkBlocks( i ), 'LibraryBlock' );
else 
aSourceBlocks{ i } = get_param( aBadLinkBlocks( i ), 'SourceBlock' );
end 
end 
end 

if ~isempty( ReferenceBlock )
ReferenceBlock( aBadLinkLoc ) = cellstr( aSourceBlocks );
else 
ReferenceBlock = cellstr( aSourceBlocks );
ReferenceBlock = ReferenceBlock( : );
end 


Library = strtok( ReferenceBlock, '/' );


else 
CellBlocks = {  };
Library = {  };
ReferenceBlock = {  };
LinkStatus = {  };
end 



subSysIdx = strcmp( get_param( CellBlocksCpy, 'BlockType' ), 'SubSystem' );
subSysBlks = CellBlocksCpy( subSysIdx );
















cssBlksIdx = ~strcmp( get_param( subSysBlks, 'TemplateBlock' ), '' ) & ~strcmp( get_param( subSysBlks, 'TemplateBlock' ), 'self' ) & ~strcmp( get_param( subSysBlks, 'TemplateBlock' ), 'master' );
cssBlks = subSysBlks( cssBlksIdx );



cssBlksHndls = get_param( cssBlks, 'Handle' );
if iscell( cssBlksHndls )
cssBlksHndls = [ cssBlksHndls{ : } ]';
end 

if ~isempty( cssBlks )

if isnumeric( cssBlks )
cssBlks = num2cell( cssBlks );


elseif ~iscell( cssBlks )
cssBlks = cellstr( cssBlks );
end 

cssBlks = cssBlks( : );

CellBlocks = [ CellBlocks;cssBlks ];


cssTmpBlks = get_param( cssBlksHndls, 'TemplateBlock' );


if iscell( cssTmpBlks )
cssTmpBlks = cssTmpBlks( : );
else 
cssTmpBlks = { cssTmpBlks };
end 

cssTmpLibs = strtok( cssTmpBlks, '/' );


Library = [ Library;cssTmpLibs ];

ReferenceBlock = [ ReferenceBlock;cssTmpBlks ];

LinkStats = get_param( cssBlksHndls, 'StaticLinkStatus' );

LinkStatus = [ LinkStatus;LinkStats ];

end 





LibData = struct( 'Block', CellBlocks,  ...
'Library', Library,  ...
'ReferenceBlock', ReferenceBlock,  ...
'LinkStatus', LinkStatus ...
 );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFlsFHk.p.
% Please follow local copyright laws when handling this file.

