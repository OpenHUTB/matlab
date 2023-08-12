function Aeroblks( obj )





if obj.ver.isReleaseOrEarlier( 'R2021a' )

blk3DOF = locFindBlock( obj.modelName, 'BlockType', 'EOM3DOF' );
for i = 1:length( blk3DOF )
axes = get_param( blk3DOF{ i }, 'axes' );
mtype = get_param( blk3DOF{ i }, 'mtype' );
if strcmp( axes, 'Body' )
if strcmp( mtype, 'Fixed' )
locReplace3DOFBlock( blk3DOF{ i }, 'aerolibobsolete/3DOF (Body Axes)' )
elseif strcmp( mtype, 'Simple Variable' )
locReplace3DOFBlock( blk3DOF{ i }, sprintf( 'aerolibobsolete/Simple Variable Mass 3DOF \n(Body Axes)' ) );
elseif strcmp( mtype, 'Custom Variable' )
locReplace3DOFBlock( blk3DOF{ i }, sprintf( 'aerolibobsolete/Custom Variable Mass 3DOF \n(Body Axes)' ) );
end 
elseif strcmp( axes, 'Wind' )
if strcmp( mtype, 'Fixed' )
locReplace3DOFBlock( blk3DOF{ i }, 'aerolibobsolete/3DOF (Wind Axes)' );
elseif strcmp( mtype, 'Simple Variable' )
locReplace3DOFBlock( blk3DOF{ i }, sprintf( 'aerolibobsolete/Simple Variable Mass 3DOF\n(Wind Axes)' ) );
elseif strcmp( mtype, 'Custom Variable' )
locReplace3DOFBlock( blk3DOF{ i }, sprintf( 'aerolibobsolete/Custom Variable Mass 3DOF\n(Wind Axes)' ) );
end 
end 
end 
end 

if obj.ver.isReleaseOrEarlier( 'R2020b' )

blkSHG = locFindBlock( obj.modelName, 'BlockType', 'SHGravity' );
if ~isempty( blkSHG )

useOld = false( 1, length( blkSHG ) );
clnup = onCleanup( @(  )cleanupTerm( obj ) );
feval( obj.modelName, [  ], [  ], [  ], 'compile' );
for i = 1:length( blkSHG )

portH = get_param( blkSHG{ i }, 'PortHandles' );
dims = get_param( portH.Inport, 'CompiledPortDimensions' );
if dims( 1 ) == 1 || dims( 2 ) == 1
useOld( i ) = true;
end 
end 
feval( obj.modelName, [  ], [  ], [  ], 'term' );

for i = 1:length( blkSHG )
if useOld( i )

blkHandle = getSimulinkBlockHandle( blkSHG{ i } );


units = get_param( blkHandle, 'units' );
action = get_param( blkHandle, 'action' );
ptype = get_param( blkHandle, 'ptype' );
degree = get_param( blkHandle, 'degree' );
datafile = get_param( blkHandle, 'datafile' );
locReplaceBlock( obj, blkSHG{ i }, 'aerolibgravity/Spherical Harmonic Gravity' );


set_param( blkSHG{ i }, 'units', units, 'action', action, 'ptype', ptype,  ...
'degree', degree, 'datafile', sprintf( '''%s''', char( datafile ) ) );
else 

obj.replaceWithEmptySubsystem( blkSHG{ i } );
end 
end 
end 
end 

if obj.ver.isReleaseOrEarlier( 'R2020a' )

blkGeoc2Geod = locFindBlock( obj.modelName, 'BlockType', 'Geoc2Geod' );
if ~isempty( blkGeoc2Geod )
for i = 1:length( blkGeoc2Geod )

set_param( blkGeoc2Geod{ i }, 'outputAltitude', 'off' );
end 
end 

blkGeod2Geoc = locFindBlock( obj.modelName, 'BlockType', 'Geod2Geoc' );
if ~isempty( blkGeod2Geoc )
for i = 1:length( blkGeod2Geoc )

set_param( blkGeod2Geoc{ i }, 'outputRadius', 'off' );
end 
end 
end 

if obj.ver.isReleaseOrEarlier( 'R2019b' )

blkWMM = locFindBlock( obj.modelName, 'ReferenceBlock',  ...
'aerolibgravity2/World Magnetic Model' );
if ~isempty( blkWMM )
for i = 1:length( blkWMM )
MaskNames = get_param( blkWMM{ i }, 'MaskNames' );
MaskVal = get_param( blkWMM{ i }, 'MaskValues' );

if strcmp( cell2mat( MaskVal( strcmp( MaskNames, 'model' ) ) ),  ...
getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2020' ),  ...
matlab.internal.i18n.locale( 'en_US' ) ) )
locReplaceBlock( obj, blkWMM{ i } );
obj.incrementReplacedBlockCount;
end 
end 
end 


blkLLAtoFlatEarth = locFindBlock( obj.modelName, 'ReferenceBlock',  ...
'aerolibtransform2/LLA to Flat Earth' );
if ~isempty( blkLLAtoFlatEarth )
for i = 1:length( blkLLAtoFlatEarth )

set_param( blkLLAtoFlatEarth{ i }, 'refPosPort', 'off' )
end 
end 


blkFlatEarthtoLLA = locFindBlock( obj.modelName, 'ReferenceBlock',  ...
'aerolibtransform2/Flat Earth to LLA' );
if ~isempty( blkFlatEarthtoLLA )
for i = 1:length( blkFlatEarthtoLLA )

set_param( blkFlatEarthtoLLA{ i }, 'refPosPort', 'off' )
end 
end 
end 
if obj.ver.isReleaseOrEarlier( 'R2019a' )

blkWMM = locFindBlock( obj.modelName, 'ReferenceBlock',  ...
'aerolibgravity2/World Magnetic Model' );
if ~isempty( blkWMM )
for i = 1:length( blkWMM )
MaskNames = get_param( blkWMM{ i }, 'MaskNames' );
MaskVal = get_param( blkWMM{ i }, 'MaskValues' );

switch cell2mat( MaskVal( strcmp( MaskNames, 'model' ) ) )
case getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2000' ),  ...
matlab.internal.i18n.locale( 'en_US' ) )
locReplaceBlock( obj, blkWMM{ i }, 'aerolibobsolete/World Magnetic Model 2000' );
case getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2005' ),  ...
matlab.internal.i18n.locale( 'en_US' ) )
locReplaceBlock( obj, blkWMM{ i }, 'aerolibobsolete/World Magnetic Model 2005' );
case getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2010' ),  ...
matlab.internal.i18n.locale( 'en_US' ) )
locReplaceBlock( obj, blkWMM{ i }, 'aerolibobsolete/World Magnetic Model 2010' );
case { getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2015v1' ),  ...
matlab.internal.i18n.locale( 'en_US' ) ),  ...
getString( message( 'aeroblks:aeroblkgravity:blockWorldMagneticModelWMMModel2015v2' ),  ...
matlab.internal.i18n.locale( 'en_US' ) ) }
locReplaceBlock( obj, blkWMM{ i }, 'aerolibobsolete/World Magnetic Model 2015' );
otherwise 
locReplaceBlock( obj, blkWMM{ i } );
obj.incrementReplacedBlockCount;
break ;
end 

if strcmpi( MaskVal( strcmp( MaskNames, 'time_in' ) ), 'on' )
epochstr = extractBetween( MaskVal( strcmp( MaskNames, 'model' ) ), 'WMM', ' ' );
epoch = str2double( epochstr{ 1 } );
dt = str2double( MaskVal( strcmp( MaskNames, 'year' ) ) ) - epoch;
if dt < 0.0 || dt > 5.0
MaskVal( strcmp( MaskNames, 'year' ) ) = epochstr( 1 );
end 
end 

MaskVal( any( [ strcmp( MaskNames, 'model' ), strcmp( MaskNames, 'customFile' ) ], 2 ) ) = [  ];

set_param( blkWMM{ i }, 'MaskValues', MaskVal );
end 
end 
end 


if obj.ver.isReleaseOrEarlier( 'R2018b' )
locReplaceBlockOfType( obj, 'AirspeedIndicatorBlock' );
locReplaceBlockOfType( obj, 'AltimeterBlock' );
locReplaceBlockOfType( obj, 'ClimbIndicatorBlock' );
locReplaceBlockOfType( obj, 'EGTIndicatorBlock' );
locReplaceBlockOfType( obj, 'HeadingIndicatorBlock' );
locReplaceBlockOfType( obj, 'RPMIndicatorBlock' );
locReplaceBlockOfType( obj, 'ArtificialHorizonBlock' );
locReplaceBlockOfType( obj, 'TurnCoordinatorBlock' );






locReplaceStreamingClients( obj );
end 





if isR2015bOrEarlier( obj.ver )
blockList = { 'headingindicator', 'altimeter', 'climbindicator',  ...
'artificialhorizon', 'egtindicator', 'rpmindicator',  ...
'airspeedindicator', 'turncoordinator' };
blockListName = { 'Heading Indicator', 'Altimeter', 'Climb Rate Indicator',  ...
'Artificial Horizon', 'EGT Indicator', 'RPM Indicator',  ...
'Airspeed Indicator', 'Turn Coordinator' };
for k = 1:length( blockList )
blks = find_system( obj.modelName,  ...
MatchFilter = @Simulink.match.allVariants,  ...
LookUnderMasks = 'all',  ...
IncludeCommented = 'on',  ...
WebBlockType = blockList{ k } );
obj.replaceWithEmptySubsystem( blks, [ 'aerolibhmi/', blockListName{ k } ] );
end 

end 

end 


function locReplaceBlockOfType( obj, blockType )



blks = find_system(  ...
obj.modelName,  ...
MatchFilter = @Simulink.match.allVariants,  ...
BlockType = blockType );

if ~isempty( blks )

legacyType = locGetOldBlockType( blockType );
for idx = 1:length( blks )


handle = get_param( blks{ idx }, 'Handle' );


cachedCoreBlockParameters = locCacheCoreBlockParameters( blks{ idx } );


replace_block( obj.modelName, 'Handle', handle,  ...
'built-in/SubSystem', 'noprompt' );


locPrepareLegacyBlock( obj, blks{ idx }, legacyType, cachedCoreBlockParameters );
end 
end 
end 

function oldBlockType = locGetOldBlockType( blockType )
switch blockType
case 'AirspeedIndicatorBlock'
oldBlockType = 'AirspeedIndicator';
case 'AltimeterBlock'
oldBlockType = 'Altimeter';
case 'ArtificialHorizonBlock'
oldBlockType = 'ArtificialHorizon';
case 'ClimbIndicatorBlock'
oldBlockType = 'ClimbIndicator';
case 'EGTIndicatorBlock'
oldBlockType = 'EGTIndicator';
case 'HeadingIndicatorBlock'
oldBlockType = 'HeadingIndicator';
case 'RPMIndicatorBlock'
oldBlockType = 'RPMIndicator';
case 'TurnCoordinatorBlock'
oldBlockType = 'TurnCoordinator';
otherwise 
end 
end 

function cache = locCacheCoreBlockParameters( coreBlock )
cache = struct(  );

blockType = get_param( coreBlock, 'BlockType' );
location = get_param( coreBlock, 'Position' );
binding = get_param( coreBlock, 'Binding' );

cache.labelPosition = get_param( coreBlock, 'LabelPosition' );
cache.width = location( 3 ) - location( 1 );
cache.height = location( 4 ) - location( 2 );
cache.location = { location( 1 ), location( 2 ) };
cache.binding = binding;
cache.blockPath = coreBlock;
cache.position = location;
cache.referenceBlock = get_param( coreBlock, 'ReferenceBlock' );

switch blockType
case { 'AirspeedIndicatorBlock', 'EGTIndicatorBlock' }
cache.ScaleMin = str2double( get_param( coreBlock, 'ScaleMin' ) );
cache.ScaleMax = str2double( get_param( coreBlock, 'ScaleMax' ) );
cache.ScaleColors = get_param( coreBlock, 'ScaleColors' );
case 'RPMIndicatorBlock'
cache.ScaleColors = get_param( coreBlock, 'ScaleColors' );
case { 'ClimbIndicatorBlock' }
cache.ScaleMax = str2double( get_param( coreBlock, 'ScaleMax' ) );
otherwise 


end 
end 

function locPrepareLegacyBlock( obj, blk, legacyType, cachedProperties )

modelHandle = get_param( obj.modelName, 'Handle' );


id = sdi.Repository.generateUUID(  );


p = Simulink.Mask.get( blk );
if isempty( p )
p = Simulink.Mask.create( blk );
end 


set_param( blk, 'Position', cachedProperties.position );


set_param( blk, 'DialogControllerArgs', { legacyType } );
set_param( blk, 'DialogController', 'aeroblksHMICreateDDGDialog' );
set_param( blk, 'MaskType', 'MWDashboardBlock' );
set_param( blk, 'MaskDescription', locGetLegacyblockDesc( legacyType ) );
set_param( blk, 'MaskDisplay', sprintf( 'if strcmp(get_param(bdroot(gcb),''BlockDiagramType''), ''library'')\n image([(matlabroot) ''/toolbox/aeroblks/aeroblks/hmi/icons/%sIcon.svg''])\nend', legacyType ) );
set_param( blk, 'MaskHelp', sprintf( 'asbhmihelp(''%s'')', lower( legacyType ) ) );
set_param( blk, 'MaskIconFrame', 'off' );
set_param( blk, 'ShowName', 'off' );


p.addParameter( 'Type', 'edit', 'Name', 'webBlockId',  ...
'Prompt', 'WebBlock Id', 'Value', id,  ...
'Evaluate', 'off', 'Tunable', 'off',  ...
'ReadOnly', 'off', 'Hidden', 'on', 'NeverSave', 'off' );

p.addParameter( 'Type', 'edit', 'Name', 'webBlockType',  ...
'Prompt', 'WebBlock Type', 'Value', lower( legacyType ),  ...
'Evaluate', 'off', 'Tunable', 'off', 'ReadOnly', 'on',  ...
'Hidden', 'on', 'NeverSave', 'off' );

p.addParameter( 'Type', 'checkbox', 'Name', 'ShowInLibBrowser', 'Value', 'on',  ...
'Evaluate', 'off', 'Tunable', 'off', 'ReadOnly', 'on', 'Hidden', 'on',  ...
'NeverSave', 'off' );

p.addParameter( 'Type', 'checkbox', 'Name', 'ShowInitialText', 'Value', 'on',  ...
'Evaluate', 'off', 'Tunable', 'off', 'ReadOnly', 'off', 'Hidden', 'on',  ...
'NeverSave', 'off' );

p.addParameter( 'Type', 'edit', 'Name', 'HMISrcModelName', 'Prompt',  ...
'Source Model', 'Value', obj.modelName, 'Evaluate', 'off',  ...
'Tunable', 'off', 'ReadOnly', 'off', 'Hidden', 'on', 'NeverSave', 'on' );



set_param( blk, 'isWebBlock', 'on' );


set_param( blk, 'ReferenceBlock', cachedProperties.referenceBlock );


if isempty( cachedProperties.referenceBlock )


webhmi = Simulink.HMI.WebHMI.getWebHMI( modelHandle );
if isempty( webhmi )
webhmi = Simulink.HMI.WebHMI.createNewWebHMI( modelHandle, obj.modelName );
end 
serializedLegacyBlock = locCreateSerializedBlock( obj, id, legacyType,  ...
cachedProperties );
webhmi.deserialize( serializedLegacyBlock );

end 
end 

function desc = locGetLegacyblockDesc( type )
switch type
case 'AirspeedIndicator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:AirspeedIndicatorDialogDesc' );
case 'Altimeter'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:AltimeterDialogDesc' );
case 'ArtificialHorizon'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:ArtificialHorizonDialogDesc' );
case 'ClimbIndicator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:ClimbIndicatorDialogDesc' );
case 'EGTIndicator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:EGTIndicatorDialogDesc' );
case 'HeadingIndicator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:HeadingIndicatorDialogDesc' );
case 'RPMIndicator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:RPMIndicatorDialogDesc' );
case 'TurnCoordinator'
desc = DAStudio.message( 'aeroblksHMI:aeroblkhmi:TurnCoordinatorDialogDesc' );
otherwise 
end 
end 

function block = locCreateSerializedBlock( obj, id, blockType, cachedProperties )


block = struct(  );
blockPath = erase( cachedProperties.blockPath, [ obj.modelName, '/' ] );
block.BlockPath = Simulink.BlockPath( blockPath );
block.ShowInitialText = false;
if isempty( cachedProperties.binding )
block.ShowInitialText = true;
end 


widget = struct(  );
widget.id = id;
widget.type = lower( blockType );
widget.Enabled = true;
widget.Width = cachedProperties.width;
widget.Height = cachedProperties.height;
widget.Size = { cachedProperties.width, cachedProperties.height };
widget.OuterSize = widget.Size;
widget.Location = cachedProperties.location;
widget.Value = NaN;
widget.LabelPosition = simulink.hmi.getLabelPosition( cachedProperties.labelPosition );
widget = locGetBlockSpecificProperties( widget, cachedProperties, blockType );


block.Widget = jsonencode( widget );


block.Source = locCreatePersistenceObject( obj, cachedProperties.binding );

end 

function locReplaceStreamingClients( obj )


clients = get_param( obj.modelName, 'StreamingClients' );
if isempty( clients )
return 
end 

origNumClients = clients.Count;
for idx = 1:origNumClients
curClient = get( clients, idx );
if ( strcmp( curClient.ObserverType, 'dashboardblocks_observer' ) || strcmp( curClient.ObserverType, 'aerohmiblocks_observer' ) )
curClient.ObserverType = 'hmi_web_widget_observer';
if locIsClientBoundToCoreBlock( obj, curClient )
add( clients, curClient );
else 
set( clients, idx, curClient );
end 
end 
end 

set_param( obj.modelName, 'StreamingClients', clients );
end 


function widget = locGetBlockSpecificProperties( widget, cachedProperties, type )
switch type
case { 'AirspeedIndicator', 'EGTIndicator' }
widget.ScaleLimits = [ cachedProperties.ScaleMin, cachedProperties.ScaleMax ];
numScales = size( cachedProperties.ScaleColors, 1 );
widget.ScaleColorLimits = zeros( numScales, 2 );
widget.ScaleColors = zeros( numScales, 3 );
for idx = 1:numScales
widget.ScaleColorLimits( idx, : ) =  ...
[ cachedProperties.ScaleColors( idx ).Min ...
, cachedProperties.ScaleColors( idx ).Max ];
widget.ScaleColors( idx, : ) =  ...
round( 255 .* cachedProperties.ScaleColors( idx ).Color );
end 
case { 'RPMIndicator' }
widget.ScaleLimits = [ 0, 110 ];
numScales = size( cachedProperties.ScaleColors, 1 );
widget.ScaleColorLimits = zeros( numScales, 2 );
widget.ScaleColors = zeros( numScales, 3 );
for idx = 1:numScales
widget.ScaleColorLimits( idx, : ) =  ...
[ cachedProperties.ScaleColors( idx ).Min ...
, cachedProperties.ScaleColors( idx ).Max ];
widget.ScaleColors( idx, : ) =  ...
round( 255 .* cachedProperties.ScaleColors( idx ).Color );
end 
case { 'ClimbIndicator' }
widget.ScaleLimits = [ 0, cachedProperties.ScaleMax ];
otherwise 


end 
end 

function source = locCreatePersistenceObject( obj, binding )
source = [  ];
if isempty( binding ) || iscell( binding )
return 
end 

source = struct(  );
blockPath = binding.BlockPath.getBlock( 1 );
try 
sid = get_param( blockPath, 'SID' );
catch me %#ok<NASGU>

sid = '';
end 

blockPath = erase( blockPath, [ obj.modelName, '/' ] );
sid = erase( sid, [ obj.modelName, ':' ] );

source.UUID = binding.UUID;
source.BlockPath = { blockPath };
source.SSID = { sid };

if isprop( binding, 'OutputPortIndex' )
source.Type = 1;
source.SubPath = binding.SubPath_;
source.OutputPortIndex = binding.OutputPortIndex;
source.SignalName = binding.SignalName_;
source.CachedBlockHandle_ = 0;
else 
source.Type = 2;
source.SubPath = '';
source.Label = binding.Label;
source.ParamName = binding.ParamName;
source.VarName = binding.VarName;
source.WksType = binding.WksType;
end 
end 

function ret = locIsClientBoundToCoreBlock( obj, client )
ret = false;
bpath = client.getFullSignalPath(  );
if bpath.getLength(  )
bpath = bpath.getBlock( 1 );
startIdx = length( obj.modelName ) + 2;
bpathWithoutModel = bpath( startIdx:end  );
ret = Simulink.HMI.getIsBoundToDashboardBlock( obj.modelName, bpathWithoutModel );
end 
end 

function foundBlocks = locFindBlock( modelName, varargin )

R36
modelName( 1, 1 )string
end 
R36( Repeating )
varargin
end 

foundBlocks = find_system( modelName,  ...
'LookUnderMasks', 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'IncludeCommented', 'on',  ...
varargin{ : } );
end 

function locReplaceBlock( obj, block, varargin )



if iscell( block )
for i = 1:numel( block )
locReplaceBlock( obj, block{ i } );
end 
return ;
elseif isnumeric( block )
for i = 1:numel( block )
locReplaceBlock( obj, getfullname( block( i ) ) );
end 
return ;
end 

orient = get_param( block, 'Orientation' );
pos = get_param( block, 'Position' );

if nargin < 3



sys = obj.getTempMdl;
ports = get_param( block, 'Ports' );
RefType = get_param( block, 'ReferenceBlock' );
[ ~, RefBlock ] = fileparts( RefType );
replacement = createEmptySubsystem( obj,  ...
sys,  ...
RefBlock,  ...
ports );
cleanup = onCleanup( @(  )delete_block( replacement ) );
else 

replacement = varargin{ 1 };
end 

delete_block( block );
add_block( replacement, block,  ...
'Orientation', orient,  ...
'Position', pos );

end 

function locReplace3DOFBlock( block, replacement )




hblk = getSimulinkBlockHandle( block );
units = get_param( hblk, 'units' );
axes = get_param( hblk, 'axes' );

v_ini = get_param( hblk, 'v_ini' );
theta_ini = get_param( hblk, 'theta_ini' );
gamma_ini = get_param( hblk, 'gamma_ini' );
q_ini = get_param( hblk, 'q_ini' );
alpha_ini = get_param( hblk, 'alpha_ini' );
pos_ini = get_param( hblk, 'pos_ini' );
mass = get_param( hblk, 'mass' );
mass_e = get_param( hblk, 'mass_e' );
mass_f = get_param( hblk, 'mass_f' );
Iyy = get_param( hblk, 'Iyy' );
Iyy_e = get_param( hblk, 'Iyy_e' );
Iyy_f = get_param( hblk, 'Iyy_f' );
g = get_param( hblk, 'g' );
g_in = get_param( hblk, 'g_in' );
vre_flag = get_param( hblk, 'vre_flag' );

abi_flag = get_param( hblk, 'abi_flag' );
vel_statename = get_param( hblk, 'vel_statename' );
v_statename = get_param( hblk, 'v_statename' );
theta_statename = get_param( hblk, 'theta_statename' );
gamma_statename = get_param( hblk, 'gamma_statename' );
q_statename = get_param( hblk, 'q_statename' );
alpha_statename = get_param( hblk, 'alpha_statename' );
pos_statename = get_param( hblk, 'pos_statename' );
mass_statename = get_param( hblk, 'mass_statename' );
orient = get_param( hblk, 'Orientation' );
pos = get_param( hblk, 'Position' );


[ filepath, ~, ~ ] = fileparts( block );
tempblock = [ filepath, '/TempBlock' ];
handle = 0;
if strcmp( axes, 'Body' )
handle = add_block( replacement, tempblock, 'MakeNameUnique', 'on',  ...
'units', units, 'v_ini', v_ini, 'theta_ini', theta_ini,  ...
'q_ini', q_ini, 'alpha_ini', alpha_ini,  ...
'pos_ini', pos_ini, 'mass', mass, 'mass_e', mass_e, 'mass_f', mass_f,  ...
'Iyy', Iyy, 'Iyy_e', Iyy_e, 'Iyy_f', Iyy_f, 'g', g, 'g_in', g_in,  ...
'vre_flag', vre_flag, 'abi_flag', abi_flag, 'vel_statename', vel_statename,  ...
'theta_statename', theta_statename, 'q_statename', q_statename,  ...
'pos_statename', pos_statename, 'mass_statename', mass_statename );
elseif strcmp( axes, 'Wind' )
handle = add_block( replacement, tempblock, 'MakeNameUnique', 'on',  ...
'units', units, 'V_ini', v_ini,  ...
'gamma_ini', gamma_ini, 'q_ini', q_ini, 'alpha_ini', alpha_ini,  ...
'pos_ini', pos_ini, 'mass', mass, 'mass_e', mass_e, 'mass_f', mass_f,  ...
'Iyy', Iyy, 'Iyy_e', Iyy_e, 'Iyy_f', Iyy_f, 'g', g, 'g_in', g_in,  ...
'vre_flag', vre_flag, 'abi_flag', abi_flag, 'v_statename', v_statename,  ...
'gamma_statename', gamma_statename, 'q_statename', q_statename,  ...
'alpha_statename', alpha_statename, 'pos_statename', pos_statename,  ...
'mass_statename', mass_statename );
end 

newblock = getfullname( handle );
delete_block( block );
add_block( newblock, block, 'Orientation', orient, 'Position', pos );
delete_block( newblock );

end 

function cleanupTerm( obj )

status = get_param( obj.modelName, 'SimulationStatus' );
if strcmp( status, 'paused' )
feval( obj.modelName, [  ], [  ], [  ], 'term' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpN9ShXI.p.
% Please follow local copyright laws when handling this file.

