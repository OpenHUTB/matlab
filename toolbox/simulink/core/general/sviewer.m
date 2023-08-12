function varargout = sviewer( varargin )







LookUnderMasks_str = 'off';
FollowLinks_str = 'off';
Warning_str = 'Wrong argument # %d passed to <sviewer.m> - Ignored';
Dialog_name = 'Signal Viewer';
ShowModelRefs = false;





if nargin > 2, 
if strcmp( varargin{ 3 }, 'off' ) || strcmp( varargin{ 3 }, 'all' ), 
LookUnderMasks_str = varargin{ 3 };
else 
warndlg( sprintf( Warning_str, 3 ), [ Dialog_name, ' Warning' ], 'modal' );
end 
end 
if nargin > 3, 
if strcmp( varargin{ 4 }, 'off' ) || strcmp( varargin{ 4 }, 'on' ), 
FollowLinks_str = varargin{ 4 };
else 
warndlg( sprintf( Warning_str, 4 ), [ Dialog_name, ' Warning' ], 'modal' );
end 
end 

Action = varargin{ 1 };
switch Action, 

case 'GetModel', 




if ( ~strcmp( varargin{ 2 }, '' ) ), 
varargout{ 2 } = varargin{ 2 };
else 
varargout{ 2 } = bdroot;
end 

varargout{ 1 } = LocalGetModel( varargout{ 2 } );

filter_active = varargin{ 5 }{ 1 };

if ( filter_active )
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, varargin{ 6 } );
else 
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str );
end 


ShowModelRefs = boolean( varargin{ 5 }{ 2 } );
varargout{ 4 } = LocalHasSubsystems( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, ShowModelRefs );

varargout{ 5 } =  - 1 * ones( 1, length( varargout{ 1 } ) );
case 'GetAllBlockDiagrams', 










varargout{ 1 } = find_system( 0, 'Type', 'block_diagram' );
if nargout > 1, 
varargout{ 2 } = get_param( varargout{ 1 }, 'Name' );

filter_active = varargin{ 5 }{ 1 };

if ( filter_active )
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, varargin{ 6 } );
else 
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str );
end 


ShowModelRefs = boolean( varargin{ 5 }{ 2 } );
varargout{ 4 } = LocalHasSubsystems( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, ShowModelRefs );
varargout{ 5 } =  - 1 * ones( 1, length( varargout{ 1 } ) );
end 

case 'GetSignalName', 




[ varargout{ 1 }, varargout{ 2 } ] = LocalGetSignalName( varargin{ 2 } );

case 'GetSubsystemLayer', 




ShowModelRefs = varargin{ 5 };
parentModelRefBlockHandle = varargin{ 6 }{ 1 };
rest = char( varargin{ 6 }{ 2 } );
rootH = varargin{ 6 }{ 3 };
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 }, varargout{ 4 }, varargout{ 5 }, varargout{ 6 } ] =  ...
LocalGetSubsystemLayer( varargin{ 2 }, LookUnderMasks_str, FollowLinks_str,  ...
ShowModelRefs, parentModelRefBlockHandle, rest, rootH );

case 'GetBlockLayer', 




if ( ~varargin{ 5 } ), 
varargout{ 1 } = LocalGetBlockLayer( varargin{ 2 }, LookUnderMasks_str, FollowLinks_str );
else 
varargout{ 1 } = LocalGetBlockLayer( varargin{ 2 }, LookUnderMasks_str, FollowLinks_str, varargin{ 6 } );
end 
if nargout > 1, 
varargout{ 2 } = get_param( varargout{ 1 }, 'Name' );


if ( varargin{ 5 } ), 
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, varargin{ 6 } );
else 
varargout{ 3 } = LocalIsEmpty( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str );
end 


varargout{ 4 } = LocalIsASubsystem( varargout{ 1 } );
varargout{ 5 } =  - 1 * ones( 1, length( varargout{ 1 } ) );
end 

case 'GetSignalLayer', 









[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 }, varargout{ 4 }, varargout{ 5 } ] = LocalGetSignalLayer( varargin{ 2 } );

case 'GetBlockDialogParameters', 




varargout{ 1 } = LocalGetBlockDialogParameters( varargin{ 2 } );

case 'Has_Subsystems', 





varargout{ 1 } = LocalHasSubsystems( varargin{ 2 }, LookUnderMasks_str, FollowLinks_str, ShowModelRefs );

case 'Is_A_Subsystem', 





varargout{ 1 } = LocalIsASubsystem( varargin{ 2 } );

case 'Is_Empty', 





if nargin < 4, 
varargout{ 1 } = LocalIsEmpty( varargin{ 2 }, LookUnderMasks_str, FollowLinks_str );
else 
varargout{ 1 } = LocalIsEmpty( varargin{ 2:end  } );
end 

otherwise 


end 














function ModelHandle = LocalGetModel( ModelName )

ModelHandle = [  ];

try 
ModelHandle = get_param( ModelName, 'Handle' );
catch %#ok
end 

if isempty( ModelHandle )

ModelHandle = find_system( 0, 'type', 'block_diagram', 'Name', ModelName );

if isempty( ModelHandle )

load_system( ModelName );
ModelHandle = get_param( ModelName, 'Handle' );
end 
end 







function [ SignalString, TestPointFlag ] = LocalGetSignalName( SignalHandle )
SignalSrcPort = get_param( SignalHandle, 'SrcPortHandle' );
SignalName = get_param( SignalSrcPort, 'Name' );
SignalSrcBlock = get_param( SignalSrcPort, 'Parent' );

if ( isempty( SignalName ) ), 
SignalName = strcat( get_param( SignalSrcBlock, 'Name' ), '_Port',  ...
num2str( get_param( SignalSrcPort, 'PortNumber' ) ) );
end , 
SignalString = strcat( SignalSrcBlock, '/', SignalName );
TestPointFlag = get_param( SignalSrcPort, 'TestPoint' );





function varargout = LocalGetSubsystemLayer( sysHandle, LookUnderMasks_str, FollowLinks_str,  ...
ShowModelRefs, pMRBlkHandle, rest, rootH )

parentBlockModel =  - 1;
if ( sysHandle == rootH )
isSysHandleModelBlock = 0;
else 
isSysHandleModelBlock = 1;
end 

if ( strcmp( get_param( sysHandle, 'Type' ), 'block' ) )
if ( strcmp( get_param( sysHandle, 'BlockType' ), 'ModelReference' ) )
mdlName = get_param( sysHandle, 'ModelName' );
try 
load_system( mdlName )
subMdlHandle = get_param( mdlName, 'Handle' );
parentBlockModel = sysHandle;
sysHandle = subMdlHandle;
catch %#ok
end 
end 
end 
varargout{ 1 } = find_system( sysHandle,  ...
'SearchDepth', 1,  ...
'LookUnderMasks', LookUnderMasks_str,  ...
'FollowLinks', FollowLinks_str,  ...
'BlockType', 'SubSystem',  ...
'Parent', getfullname( sysHandle ) );

v = { 'false', 'true' };
isModelRefBlk = zeros( 1, length( varargout{ 1 } ) );
ModelRefFlag = v( isModelRefBlk + 1 );

if ( ShowModelRefs )
mRefBlocks = find_system( sysHandle,  ...
'SearchDepth', 1,  ...
'LookUnderMasks', LookUnderMasks_str,  ...
'FollowLinks', FollowLinks_str,  ...
'BlockType', 'ModelReference',  ...
'Parent', getfullname( sysHandle ) );
if ( ~isempty( mRefBlocks ) )
for k = 1:length( mRefBlocks )
varargout{ 1 }( end  + 1 ) = mRefBlocks( k );
ModelRefFlag{ end  + 1 } = 'true';%#ok<AGROW>
end 
end 
end 

if nargout > 1, 
varargout{ 2 } = get_param( varargout{ 1 }, 'Name' );

appendModelFlag = strcmp( get_param( varargout{ 1 }, 'BlockType' ), 'ModelReference' );


appendSFFlag = strcmp( get_param( varargout{ 1 }, 'Type' ), 'block' ) &  ...
slprivate( 'is_stateflow_based_block', varargout{ 1 } );

blkNames = varargout{ 2 };
if ( ~iscell( blkNames ) )
blkNames = { blkNames };
end 

encodedBlockFullPath = getfullname( varargout{ 1 } );
[ encodedBlockFullPath ] = LocalGetEncodedBlockFullPath( encodedBlockFullPath,  ...
rest, isSysHandleModelBlock );

for k = 1:length( appendModelFlag )
if ( appendModelFlag( k ) )
blkNames{ k } = [ blkNames{ k }, '(', get_param( varargout{ 1 }( k ), 'ModelName' ), ')' ];
end 
end 
for k = 1:length( appendSFFlag )
if ( appendSFFlag( k ) )
blkNames{ k } = [ blkNames{ k }, '(StateflowChart)' ];
end 
end 

varargout{ 2 } = blkNames;


varargout{ 3 } = LocalHasSubsystems( varargout{ 1 }, LookUnderMasks_str, FollowLinks_str, ShowModelRefs );

varargout{ 4 } = ModelRefFlag;
parentBlockModelArray =  - 1 * ones( 1, length( varargout{ 1 } ) );

if ( pMRBlkHandle < 0 )

parentBlockModelArray( 1:end  ) = parentBlockModel;
else 

parentBlockModelArray( 1:end  ) = pMRBlkHandle;
end 
varargout{ 5 } = parentBlockModelArray;
varargout{ 6 } = encodedBlockFullPath;

end , 




function [ encodedBlockFullPath ] = LocalGetEncodedBlockFullPath( encodedBlockFullPath, rest, isSysHandleModelBlock )


if ( ~iscell( encodedBlockFullPath ) )
encodedBlockFullPath = { encodedBlockFullPath };
end 

appendSFFlag = strcmp( get_param( encodedBlockFullPath, 'Type' ), 'block' ) &  ...
slprivate( 'is_stateflow_based_block', encodedBlockFullPath );

lenRest = length( rest );
okTogo = true;

if ( lenRest < length( encodedBlockFullPath{ 1 } ) )
if ( ~strcmp( rest, encodedBlockFullPath{ 1 }( 1:length( rest ) ) ) )
okTogo = true;
else 

okTogo = false;
end 
end 

if ( okTogo )
for k = 1:length( encodedBlockFullPath )
appendModelName = 0;
if ( strcmp( get_param( encodedBlockFullPath{ k }, 'BlockType' ), 'ModelReference' ) )

appendModelName = 1;
encPathModelName = [ get_param( encodedBlockFullPath{ k }, 'ModelName' ) ];%#ok<NBRAK>
end 

if ( isSysHandleModelBlock )






idx = regexp( rest, '\|' );
if ~( isempty( idx ) )
rest = rest( 1:idx( end  ) - 1 );
end 
encodedBlockFullPath{ k } = [ rest, '|', encodedBlockFullPath{ k } ];
else 
rest = slprivate( 'decpath', rest );
encodedBlockFullPath{ k } = slprivate( 'encpath', rest, encodedBlockFullPath{ k }, '', 'modelref' );
end 

if ( appendModelName )
encodedBlockFullPath{ k } = [ encodedBlockFullPath{ k }, '|', encPathModelName ];
end 
end 
else 
for k = 1:length( encodedBlockFullPath )
if ( strcmp( get_param( encodedBlockFullPath{ k }, 'BlockType' ), 'ModelReference' ) )
encodedBlockFullPath{ k } = slprivate( 'encpath', encodedBlockFullPath{ k },  ...
get_param( encodedBlockFullPath{ k }, 'ModelName' ),  ...
'', 'modelref' );
else 
encodedBlockFullPath{ k } = slprivate( 'encpath', encodedBlockFullPath{ k }, '', '', 'none' );
end 
end 
end 

for k = 1:length( appendSFFlag )
if ( appendSFFlag( k ) )
encodedBlockFullPath{ k } = [ encodedBlockFullPath{ k }, '@', 'StateflowChart' ];
end 
end 





function BlockHandles = LocalGetBlockLayer( ParentHandle, LookUnderMasksStr, FollowLinksStr, FilterStr )



fsArgs = { ParentHandle,  ...
'SearchDepth', 1,  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'Type', 'block',  ...
'Parent', getfullname( ParentHandle ) };



if nargin > 3, 
additionalArgs = eval( [ '{', FilterStr, '}' ] );
fsArgs = { fsArgs{ : }, additionalArgs{ : } };%#ok<CCAT>
end 

BlockHandles = find_system( fsArgs{ : } );


if nargin > 3, 
s = find_system( ParentHandle, 'SearchDepth', 1, 'blocktype', 'SubSystem' );
if ( ~isempty( s ) ), 
for i = 1:length( s ), 
if ( isempty( find_system( s( i ), additionalArgs{ : } ) ) ), 

s( i ) = 0;
end ;
end ;
BlockHandles = sort( [ BlockHandles;s( s > 0 ) ] );

if ( ~isempty( BlockHandles ) )
BlockHandles = [ BlockHandles( diff( BlockHandles ) ~= 0 );BlockHandles( end  ) ];
end ;
end ;
end 








function [ SignalHandles, SignalNames, SrcBlockNames, SrcPortNumbers, TestPointFlags ] =  ...
LocalGetSignalLayer( ParentObjectHandle )

OutPortHandles = find_system( ParentObjectHandle,  ...
'FindAll', 'on',  ...
'SearchDepth', 1,  ...
'LookUnderMasks', 'all',  ...
'Type', 'port',  ...
'PortType', 'outport' );



if isempty( OutPortHandles ), 
SignalHandles = [  ];
SignalNames = cell( 0 );
SrcBlockNames = cell( 0 );
SrcPortNumbers = cell( 0 );
TestPointFlags = cell( 0 );
return ;
end , 




if ~strcmp( get_param( ParentObjectHandle, 'type' ), 'block_diagram' ), 
parent_port_numbers = get_param( ParentObjectHandle, 'Ports' );
parent_outport_number = parent_port_numbers( 2 );
OutPortHandles = OutPortHandles( parent_outport_number + 1:length( OutPortHandles ) );
end , 



SignalHandles = get_param( OutPortHandles, 'Line' );

if length( SignalHandles ) > 1, 
SignalHandles = [ SignalHandles{ : } ]';
end , 



SignalNames = get_param( OutPortHandles, 'Name' );



SrcBlockNames = get_param( get_param( OutPortHandles, 'Parent' ), 'Name' );



SrcPortNumbers = get_param( OutPortHandles, 'PortNumber' );

if length( SrcPortNumbers ) > 1, 
SrcPortNumbers = [ SrcPortNumbers{ : } ]';
end , 
SrcPortNumbers = cellstr( strjust( int2str( SrcPortNumbers ), 'left' ) );



TestPointFlags = get_param( OutPortHandles, 'TestPoint' );









function BlockDialogParams = LocalGetBlockDialogParameters( BlockHandle )

if isequal( get_param( BlockHandle, 'Type' ), 'block_diagram' ), 
BlockDialogParams = {  };
return ;
end , 

BlockParamStruct = get_param( BlockHandle, 'MaskPrompts' );
if isempty( BlockParamStruct ), 
BlockParamStruct = get_param( BlockHandle, 'DialogParameters' );
if isempty( BlockParamStruct ), 

BlockDialogParams = [  ];
return ;
else 
BlockParamFieldNames = fieldnames( BlockParamStruct );
BlockEditParamNum = [  ];
j = 1;
for i = 1:length( BlockParamFieldNames ), 
ParamFieldData = getfield( BlockParamStruct, BlockParamFieldNames{ i } );%#ok<GFLD>
paramType = ParamFieldData.Type;
if strcmp( paramType, 'string' ), 
BlockEditParamNum( j ) = i;%#ok<AGROW>
j = j + 1;
end 
end 
end 
else 
BlockParamNameStruct = get_param( BlockHandle, 'MaskNames' );
BlockParamFieldNames = strcat( BlockParamStruct, ' (', BlockParamNameStruct, ')' );
BlockEditParamNum = find( strcmp( get_param( BlockHandle, 'MaskStyles' ), 'edit' ) );
end 

BlockDialogParams = BlockParamFieldNames( BlockEditParamNum );









function FlagStrings = LocalHasSubsystems( ReferenceHandles, LookUnderMasksStr, FollowLinksStr, ShowModelRefs )
FlagStrings = cell( size( ReferenceHandles ) );%#ok<NASGU>


tf = { 'false', 'true' };
modelRefName = {  };
for i = 1:length( ReferenceHandles ), 
has_subsystems( i ) = ~isempty( find_system( ReferenceHandles( i ),  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'BlockType', 'SubSystem',  ...
'Parent', getfullname( ReferenceHandles( i ) ) ) );%#ok<AGROW>
end 

if ( ShowModelRefs )
for i = 1:length( ReferenceHandles ), 
has_modelreferences( i ) = ~isempty( find_system( ReferenceHandles( i ),  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'BlockType', 'ModelReference',  ...
'Parent', getfullname( ReferenceHandles( i ) ) ) );%#ok<AGROW>

sub_modelHasSubSys( i ) = 0;%#ok<AGROW>
sub_modelHasModelRef( i ) = 0;%#ok<AGROW>
modelRefName{ i } = '';%#ok<AGROW>
if ( strcmp( get_param( ReferenceHandles( i ), 'Type' ), 'block' ) )
if ( strcmp( get_param( ReferenceHandles( i ), 'BlockType' ), 'ModelReference' ) )
modelRefName{ i } = get_param( ReferenceHandles( i ), 'ModelName' );%#ok<AGROW>
try %#ok<TRYNC>
load_system( modelRefName{ i } )
sub_modelHasSubSys( i ) = ~isempty( find_system( modelRefName{ i },  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'BlockType', 'SubSystem',  ...
'Parent', getfullname( modelRefName{ i } ) ) );%#ok<AGROW>

sub_modelHasModelRef( i ) = ~isempty( find_system( modelRefName{ i },  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'BlockType', 'ModelReference',  ...
'Parent', getfullname( modelRefName{ i } ) ) );%#ok<AGROW>

end 
end 
end 
end 


sub_modelHasSubSys = or( sub_modelHasModelRef, sub_modelHasSubSys );
has_subsystems = or( sub_modelHasSubSys, has_subsystems );
lenSub = length( has_subsystems );
lenMRef = length( has_modelreferences );

if ( lenSub > lenMRef )
has_modelreferences( lenSub ) = 1;
elseif ( lenSub < lenMRef )
has_subsystems( lenMRef ) = 1;
end 

has_subsys_and_modelref = or( has_subsystems, has_modelreferences );
FlagStrings = tf( has_subsys_and_modelref + 1 );
else 
FlagStrings = tf( has_subsystems + 1 );
end 









function FlagStrings = LocalIsASubsystem( ReferenceHandles )
FlagStrings = cell( size( ReferenceHandles ) );%#ok<NASGU>







try 
fsRet = get_param( ReferenceHandles, 'BlockType' );
if ~iscell( fsRet ), fsRet = { fsRet };end ;
is_a_subsystem = strcmp( fsRet, 'SubSystem' );
catch %#ok
is_a_subsystem = zeros( size( ReferenceHandles ) );
end 

tf = { 'false', 'true' };
FlagStrings = tf( is_a_subsystem + 1 );









function FlagStrings = LocalIsEmpty( ReferenceHandles, LookUnderMasksStr, FollowLinksStr, FilterStr )
FlagStrings = cell( size( ReferenceHandles ) );%#ok<NASGU>
is_empty = zeros( size( ReferenceHandles ) );


fsArgs = {  ...
'LookUnderMasks', LookUnderMasksStr,  ...
'FollowLinks', FollowLinksStr,  ...
'Type', 'block' };




if nargin > 3, 
additionalArgs = eval( [ '{', FilterStr, '}' ] );
else 
additionalArgs = {  };
end 




for i = 1:length( ReferenceHandles ), 
is_empty( i ) = ~any( find_system( ReferenceHandles( i ), fsArgs{ : }, additionalArgs{ : } ) ~= ReferenceHandles( i ) );



end 


tf = { 'false', 'true' };
FlagStrings = tf( is_empty + 1 );








% Decoded using De-pcode utility v1.2 from file /tmp/tmpC1Onra.p.
% Please follow local copyright laws when handling this file.

