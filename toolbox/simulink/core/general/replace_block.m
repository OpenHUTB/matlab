function OldBlocksRet = replace_block( System, varargin )







































if nargin < 3
error( message( 'Simulink:replace_block:InputsProblem' ) );
end 





NumIn = nargin - 1;
NoPromptFlag = 0;
KeepSIDOpt = {  };
if ( ischar( varargin{ end  } ) || isstring( varargin{ end  } ) )
if strcmp( varargin{ end  }, 'noprompt' )
NumIn = NumIn - 1;
NoPromptFlag = 1;
elseif strcmpi( varargin{ end  }, 'keepsid' )
NumIn = NumIn - 1;
NoPromptFlag = 1;
KeepSIDOpt = { 'KeepSID', 'on' };
end 
end 





try 
System = getfullname( System );
catch E
error( message( 'Simulink:replace_block:InvalidSystem' ) );
end 




if NumIn == 2
if ~( ischar( varargin{ 1 } ) || isstring( varargin{ 1 } ) )
error( message( 'Simulink:Commands:InputArgInvalid', 2 ) );
end 


OldBlocks = find_system( System, 'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'BlockType', varargin{ 1 } );
if isempty( OldBlocks )
OldBlocks =  ...
find_system( System, 'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'MaskType', varargin{ 1 } );
end 

elseif NumIn > 2
OldBlocks = find_system( System, 'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
varargin{ 1:NumIn - 1 } );
end 
OldBlocks = LocalPruneSimulinkObjectsInsideStateflowBlocks( OldBlocks );







NewBlock = convertStringsToChars( varargin{ NumIn } );

if isfloat( NewBlock )
NewBlock = getfullname( NewBlock );
end 

if strncmp( NewBlock, 'built-in/', 9 )
NewHandle = LocalCheckBuiltIn( NewBlock );

else 
hassep = any( NewBlock == '/' );
if ~hassep
NewHandle = [ 'built-in/', NewBlock ];
NewHandle = LocalCheckBuiltIn( NewHandle );
else 
try 
NewHandle = find_system( NewBlock, 'SearchDepth', 0 );
catch E %#ok (E unused)
NewHandle = {  };
end 
end 
end 

if isempty( NewHandle )
error( message( 'Simulink:replace_block:InvalidBlockHandle', NewBlock ) ); ...
end 

if ~iscell( NewHandle )
NewHandle = { NewHandle };
end 

if ~iscell( OldBlocks )
TempBlocks = cell( length( OldBlocks ), 1 );

for lp = 1:length( OldBlocks )
TempBlocks{ lp } = getfullname( OldBlocks( lp ) );
end 

OldBlocks = TempBlocks;
end 




if ~isempty( OldBlocks )
OK = 1;
Selection = 1:length( OldBlocks );
if NoPromptFlag == 0
[ Selection, OK ] = listdlg( 'ListString', regexprep( OldBlocks, '\r\n|\n|\r', '' ),  ...
'ListSize', [ 300, 300 ],  ...
'InitialValue', 1:length( OldBlocks ),  ...
'Name', 'Replace Dialog',  ...
'PromptString', 'Select the blocks to replace' );
end 

if OK
OldBlocks = OldBlocks( Selection );
OldHandles = get_param( OldBlocks, 'Handle' );
if strcmp( get_param( bdroot( System ), 'Lock' ), 'on' )
error( message( 'Simulink:replace_block:LockedLibrary' ) );
end 
for lp = 1:length( OldBlocks )
if ishandle( OldHandles{ lp } )
slInternal( 'replace_block', OldHandles{ lp }, NewHandle{ 1 }, KeepSIDOpt{ : } );
end 
end 
end 
end 




if nargout
OldBlocksRet = OldBlocks;
end 






function NewHandle = LocalCheckBuiltIn( NewHandle )
if ~strcmp( NewHandle, 'built-in/Subsystem' )
try 
ValidHandle = get_param( NewHandle, 'Name' );
catch E %#ok (E unused)
ValidHandle = [  ];
end 

if isempty( ValidHandle )
NewHandle = {  };
end 
end 






function OldBlocks = LocalPruneSimulinkObjectsInsideStateflowBlocks( OldBlocks )
OldBlocksHandles = get_param( OldBlocks, 'Handle' );
n = numel( OldBlocksHandles );
discard = false( 1, n );
for i = 1:n
discard( i ) = Stateflow.SLUtils.isChildOfStateflowBlock( OldBlocksHandles{ i } );
end 

OldBlocks( discard ) = [  ];



% Decoded using De-pcode utility v1.2 from file /tmp/tmpNTL9JP.p.
% Please follow local copyright laws when handling this file.

