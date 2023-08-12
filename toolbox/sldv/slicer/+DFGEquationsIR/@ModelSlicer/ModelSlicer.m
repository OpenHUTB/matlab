

classdef ModelSlicer < ModelSlicer




properties ( Access = public, Hidden = true )
msSession = [  ];

allSrcP = [  ];
allDstP = [  ];
allLineHandles = [  ];


allBlkHs = [  ];
allNVBlkHs = [  ];
end 

properties ( Dependent = true, SetAccess = private, GetAccess = public, Hidden = true )
obsMdlToRefBlk
end 

methods 
function createIR( obj )
mdlH = get_param( obj.model, 'handle' );
obj.msSession = slicer.frontend.Session( mdlH );
obj.msSession.translate(  );
obj.populateMdlStructureInfo(  );
end 

function populateMdlStructureInfo( obj )

values = obj.msSession.getRefMdlBlkValues(  );
keys = obj.msSession.getRefMdlBlkKeys(  );
if ~isempty( keys )
refMdlToMdlBlk = containers.Map( keys, values );
else 
refMdlToMdlBlk = containers.Map( 'KeyType', 'double',  ...
'ValueType', 'double' );
end 

mdlH = get_param( obj.model, 'handle' );
allMdlHs = [ mdlH, reshape( keys, 1, [  ] ) ];
findOpts = Simulink.FindOptions( 'LookUnderMasks', 'all', 'FollowLinks', true );
hdls = [  ];
for aMdlH = allMdlHs
hdls = [ hdls;Simulink.findBlocks( aMdlH, findOpts ) ];%#ok<AGROW>
end 


inportBHs = Simulink.findBlocksOfType( mdlH, 'Inport',  ...
Simulink.FindOptions( 'SearchDepth', 1 ) );


signalObservers = Analysis.getSignalObserversForModel( allMdlHs, hdls );

obj.allBlkHs = hdls;
obj.allNVBlkHs = [ hdls( strcmpi( get_param( hdls, 'Virtual' ), 'off' ) ); ...
inportBHs ];


globalDsmNames = obj.msSession.getGlobalDsmNames(  );
dsmHandles = obj.allNVBlkHs( arrayfun( @( b ) ...
strcmpi( get_param( b, 'BlockType' ), 'DataStoreMemory' ),  ...
obj.allNVBlkHs ) );

modelElements = struct( 'rootInportHandles', inportBHs,  ...
'signalObservers', signalObservers,  ...
'dsmHandles', dsmHandles );
modelElements.globalDsmNames = globalDsmNames;

obsRefBlks =  ...
Simulink.observer.internal.getObserverRefBlocksInBD( mdlH );
if ~isempty( obsRefBlks )
obsRefMdlHs = arrayfun( @( b )get_param(  ...
get_param( b, 'ObserverModelName' ), 'handle' ), obsRefBlks );
obsMdlToRefBlk = containers.Map( obsRefMdlHs, obsRefBlks );%#ok<PROP>
else 
obsMdlToRefBlk = containers.Map( 'KeyType', 'double',  ...
'ValueType', 'double' );%#ok<PROP>
end 

obj.mdlStructureInfo =  ...
slslicer.internal.MdlStructureInfo( mdlH,  ...
refMdlToMdlBlk, modelElements, obsMdlToRefBlk );%#ok<PROP>
end 

function performPreCompileOperations( obj )

performPreCompileOperations@ModelSlicer( obj );


[ observerModels, ~, errMsg ] =  ...
Simulink.observer.internal.loadObserverModelsForBD( obj.modelH );
if ~isempty( errMsg )
ModelSlicer.setModelsCreatingIR( observerModels, true );
end 
end 

function [ inactiveInH, inactiveHdls ] = identifyInactiveElements( obj, groups )


import Analysis.*;
mdl = obj.model;

sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>


analysisData = obj.getAnalysisData(  );
assert( ~isempty( analysisData ) );

getAllTransforms( obj );

transforms = obj.transforms;
for i = 1:length( transforms )
transforms( i ).reset;
end 

inactiveHdls = [  ];
inactiveInH = [  ];

blkTypeMap = obj.mdlStructureInfo.getTransformBlkMap( transforms );

allForEachSubsys = obj.allNVBlkHs( arrayfun( @( h ) ...
Simulink.SubsystemType( h ).isForEachSubsystem, obj.allNVBlkHs ) );

forEachAncestors = obj.gatherAncestors( allForEachSubsys );
noForEach = isempty( allForEachSubsys );

for i = 1:length( transforms )

hdls = blkTypeMap( transforms( i ).pivotBlockType );
for j = 1:length( hdls )
bh = hdls( j );
if ~ismember( bh, obj.designInterests.blocks ) ...
 && ~groups.toParent.isKey( bh )
if transforms( i ).applicable( bh, analysisData )
try 
if noForEach || ~hasForEach( bh, forEachAncestors )
if isa( analysisData, 'Sldv.DeadLogicData' )
if ~analysisData.hasAnalysisData( bh )
continue ;
end 
end 
[ v, vIn, ~ ] = transforms( i ).analyze( bh, mdl, analysisData,  ...
obj.mdlStructureInfo );
if ~isempty( v )
assert( size( v, 2 ) == 1 );
inactiveHdls = [ inactiveHdls;v ];%#ok<AGROW>
end 
if ~isempty( vIn )
assert( size( vIn, 2 ) == 1 );
inactiveInH = [ inactiveInH;vIn ];%#ok<AGROW>
end 
end 
catch Mex



end 
end 
end 
end 
end 

function yesno = hasForEach( bh, ancestors )
blocks = [  ];
if any( strcmp( get_param( bh, 'BlockType' ), { 'If', 'SwitchCase' } ) )
outports = get_param( bh, 'PortHandles' ).Outport;
for jdx = 1:length( outports )
pObj = get( outports( jdx ), 'Object' );
aDst = pObj.getActualDst;
for idx = 1:size( aDst, 1 )
blocks( end  + 1 ) = get( aDst( idx, 1 ), 'ParentHandle' );%#ok<AGROW>
end 
end 
end 
yesno = ~isempty( intersect( blocks, ancestors ) );
end 


if obj.inSteppingMode && obj.showCtrlDep
inactiveInH = removeCtrlPorts( inactiveInH );
end 
end 

function [ signalPaths, handles ] = computeDependence( obj )
obj.checkOutLicense(  );

sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>


dir = obj.dir;

src = [  ];
dst = [  ];
handles = [  ];




idx = arrayfun( @( b ) ...
( Simulink.SubsystemType( b ).isSubsystem ||  ...
Simulink.SubsystemType.isModelBlock( b ) ),  ...
obj.designInterests.blocks );
activeCtxs = reshape( obj.designInterests.blocks( idx ), 1, [  ] );

if dir == "back" || dir == "either"

obj.msSession.resetState(  );
obj.msSession.backwardDependence(  );
handles = obj.msSession.activeHandles(  );
src = obj.msSession.getActiveSrcs(  );
dst = obj.msSession.getActiveDsts(  );
end 

if dir == "forward" || dir == "either"
obj.msSession.resetState(  );
obj.msSession.forwardDependence(  );
handles = [ handles, obj.msSession.activeHandles(  ) ];
src = [ src, obj.msSession.getActiveSrcs(  ) ];
dst = [ dst, obj.msSession.getActiveDsts(  ) ];



activeCtxs = [ activeCtxs, obj.msSession.getActiveContexts(  ) ];
end 



if obj.options.SliceOptions.SignalObservers &&  ...
( dir == "back" || dir == "either" )
[ obsHandles, observerSrc, observerDst ] = obj.getHandlesForSignalObservers( src );
handles = [ handles, obsHandles ];
src = [ src, observerSrc' ];
dst = [ dst, observerDst' ];
end 

[ h, auxSrc, auxDst ] = getAllElementsInContext( obj, activeCtxs );
handles = [ handles, h ];
src = [ src, auxSrc ];
dst = [ dst, auxDst ];

signalPaths = struct( 'src', src,  ...
'dst', dst );
end 

function [ handles, gSrc, gDst ] = getHandlesForSignalObservers( obj, existingSrcs )


signalObserverSrc = [  ];
signalObserverDst = [  ];

handles = [  ];
gSrc = [  ];
gDst = [  ];






for observerIndex = 1:length( obj.mdlStructureInfo.signalObservers )
observerBlockH = obj.mdlStructureInfo.signalObservers( observerIndex );


observerBlkObj = get( observerBlockH, 'Object' );
observerBlkInports = observerBlkObj.PortHandles.Inport;



for inportIndex = 1:length( observerBlkInports )
inportH = observerBlkInports( inportIndex );
inportObj = get_param( inportH, 'Object' );
inportSources = inportObj.getActualSrc;
if ~isempty( inportSources )
inportSources = inportSources( :, 1 );



inportSourceIndex = 1;
while inportSourceIndex <= length( inportSources )
inportSource = inportSources( inportSourceIndex );





inportSourceObj = get( inportSource, 'Object' );
parentObj = get( inportSourceObj.ParentHandle, 'Object' );
if parentObj.isSynthesized &&  ...
strcmp( parentObj.getSyntReason, 'SL_SYNT_BLK_REASON_COMPROOT' )
boundedSources = inportObj.getBoundedSrc;
boundedSources = boundedSources( :, 1 );
inportSources = [ inportSources;boundedSources ];
inportSourceIndex = inportSourceIndex + 1;
continue ;
end 





if any( ismember( existingSrcs, inportSource ) )
handles = [ handles, observerBlockH ];
signalObserverSrc = [ signalObserverSrc, inportSource ];
signalObserverDst = [ signalObserverDst, inportH ];
end 
inportSourceIndex = inportSourceIndex + 1;
end 
end 
end 
end 



if ~isempty( signalObserverSrc ) && ~isempty( signalObserverDst ) ...
 && length( signalObserverSrc ) == length( signalObserverDst )
[ gSrc, gDst, additionalhandles, vBlks ] =  ...
slslicer.internal.getAllSegmentsInPath(  ...
signalObserverSrc, signalObserverDst );
assert( length( gSrc ) == length( gDst ) );
handles = [ handles, additionalhandles' ];
handles = [ handles, vBlks' ];
end 

handles = unique( handles );
end 

function addStartPoints( obj )
starts = [ reshape( obj.designInterests.blocks, 1, [  ] ),  ...
reshape( obj.designInterests.signals, 1, [  ] ) ];

for s = starts
obj.msSession.addStartingPoint( s );
end 

if isfield( obj.designInterests, 'busElements' )
for s = obj.designInterests.busElements
obj.msSession.addStartingPointBusElement(  ...
s.Handle, s.BusElementPath );
end 
end 
end 

function addExclusionPointsFromUser( obj )

exclusions = [ reshape( obj.exc, 1, [  ] ),  ...
reshape( obj.constraints, 1, [  ] ) ];
for e = exclusions
obj.msSession.addExclusionPoint( e );
end 
end 

function addSliceComponent( obj )
if ~isempty( obj.sliceSubSystemH )
sysH = obj.sliceSubSystemH;

obj.msSession.addComponent( sysH );


obj.addDSMBoundariesForComponents( sysH );
end 
end 

function addDSMBoundariesForComponents( obj, sysH )








dir = obj.dir;

sysObj = get( sysH, 'Object' );
isMdlBlk = isa( sysObj, 'Simulink.ModelReference' );
refH = [  ];



if isMdlBlk
mdlBlks = [ sysH, obj.utilGetReferencedModelBlocks( sysH ) ];
refH = arrayfun( @( m )get_param(  ...
get_param( m, 'NormalModeModelName' ),  ...
'handle' ), mdlBlks );
end 

if dir == "back" || dir == "either"
if ~isMdlBlk


dsmMap =  ...
Sldv.SubsystemLogger.deriveDSWExecPriorToSubsystem( sysH );
dsNames = dsmMap.keys;
for i = 1:length( dsNames )
dsrW = dsmMap( dsNames{ i } );
for j = 1:length( dsrW )
p = get( dsrW( j ), 'PortHandles' ).Inport;
obj.msSession.addExclusionPoint( p );
end 
end 
else 



obj.msSession.addGlobalDSMBoundaries( refH, false );
end 
end 

if dir == "forward" || dir == "either"
if ~isMdlBlk



dsmMap =  ...
Transform.SubsystemSliceUtils.deriveDSRExecPosteriorToSubsystem( sysH );
dsNames = dsmMap.keys;
for i = 1:length( dsNames )
dsrH = dsmMap( dsNames{ i } );
for j = 1:length( dsrH )
p = get( dsrH( j ), 'PortHandles' ).Outport;
obj.msSession.addExclusionPoint( p );
end 
end 
else 



obj.msSession.addGlobalDSMBoundaries( refH, true );
end 
end 
end 

function addExclusionPointsFromAnalysis( obj )

obj.atomicGroups = Transform.AtomicGroup( obj.model, obj.options );

analysisData = obj.getAnalysisData(  );
if ~isempty( analysisData )
[ inactiveP, inactiveBlkH ] =  ...
obj.identifyInactiveElements( obj.atomicGroups );

inactiveP = reshape( inactiveP, 1, [  ] );
inactiveBlkH = reshape( inactiveBlkH, 1, [  ] );
obj.inactiveHdls = [ obj.inactiveHdls, inactiveBlkH ];

for i = 1:length( inactiveP )
obj.msSession.addExclusionPoint( inactiveP( i ) );
end 

for i = 1:length( inactiveBlkH )
blkH = inactiveBlkH( i );
btype = string( get_param( blkH, 'BlockType' ) );

if contains( btype, [ "SubSystem", "ModelReference" ] )
obj.msSession.addDecisionConstraints( blkH,  ...
int32( 1 ) );
obj.msSession.addExclusionPoint( blkH );
else 
ports = get_param( blkH, 'PortHandles' );
phs = [ ports.Inport, ports.Outport ];
for ph = phs
obj.msSession.addExclusionPoint( ph );
end 
end 
end 
end 

end 

function addInputsForAnalysis( obj )
obj.msSession.resetInputs(  );


obj.addStartPoints(  );


obj.addExclusionPointsFromUser(  );


obj.addSliceComponent(  );

obj.inactiveHdls = obj.getExcludedSubsys(  );



obj.addExclusionPointsFromAnalysis(  );
end 

function [ signalPaths, blocks ] = analyse( obj )
import slslicer.internal.*;

obj.allLineHandles = [  ];


obj.addInputsForAnalysis(  );


[ signalPaths, activeHandles ] = obj.computeDependence(  );


DependencyHandler.setMSDependencies( obj, signalPaths.src,  ...
signalPaths.dst,  ...
activeHandles );
blocks = activeHandles( strcmpi( get_param( activeHandles, 'type' ), 'block' ) )';



gotoFromBlocks = getBlocksOfType( blocks, [ "Goto", "From" ] );
additionalBlocks = [  ...
obj.gatherDesignInterestAncestors(  ); ...
obj.gatherAncestors( gotoFromBlocks )' ];
blocks = unique( [ blocks;additionalBlocks ] );
end 

status = checkCompatibility( obj, varargin );

function [ hasValidStarts, invalidBlk, invalidSig ] = setAnalysisSeeds( obj, sc )
[ bh, ~ ] = sc.getStartBlockHandles;
ph = sc.getStartSignalHandles;
busElements = sc.getStartBusElements;
obj.designInterests = struct( 'blocks', bh,  ...
'signals', ph,  ...
'busElements', busElements );
obj.sliceSubSystemH = sc.sliceSubSystemH;
obj.exc = sc.getExclusionBlks;
hasValidStarts = ~isempty( sc.getUserStarts(  ) );
invalidBlk = [  ];
invalidSig = [  ];
end 

function yesno = isBlockValidTarget( ~, bh )
yesno = strcmpi( get_param( bh, 'CompiledIsActive' ), 'on' ) &&  ...
strcmp( get_param( bh, 'Commented' ), 'off' );
end 

function yesno = isPortValidTarget( obj, ph )
bh = get_param( ph, 'ParentHandle' );
yesno = obj.isBlockValidTarget( bh );
end 

function yesno = isTerminalBlock( ~, ~ )
yesno = true;
end 

function desH = getSystemAllDescendants( obj )
if strcmpi( get_param( obj.sliceSubSystemH, 'type' ), 'block' ) &&  ...
Simulink.SubsystemType.isModelBlock( obj.sliceSubSystemH )
sysH = get_param(  ...
get_param( obj.sliceSubSystemH, 'NormalModeModelName' ),  ...
'handle' );
else 
sysH = obj.sliceSubSystemH;
end 
desH = Simulink.findBlocks( sysH );
modelBlockH =  ...
desH( strcmpi( get_param( desH, 'BlockType' ), 'ModelReference' ) );
Q = modelBlockH;
while ~isempty( Q )
mdlblkH = Q( 1 );
Q( 1 ) = [  ];

refMdl = get_param( mdlblkH, 'NormalModeModelName' );
desH = [ desH;Simulink.findBlocks( refMdl ) ];%#ok<AGROW>
nextMdlBlkHs = Simulink.findBlocksOfType( refMdl, 'ModelReference' );
if ~isempty( nextMdlBlkHs )
Q = [ Q;nextMdlBlkHs ];%#ok<AGROW>
end 
end 
end 

function getAllTransforms( obj )
getAllTransforms@ModelSlicer( obj );
obj.transforms = [ obj.transforms; ...
Transform.InactiveEnableMdlRef; ...
Transform.InactiveTriggerMdlRef; ...
Transform.InactiveEnableTriggerMdlRef ];
end 

function obsMdlToRefBlk = get.obsMdlToRefBlk( obj )
if ~isempty( obj.mdlStructureInfo )
obsMdlToRefBlk = obj.mdlStructureInfo.obsMdlToRefBlk;
else 
obsMdlToRefBlk = containers.Map( 'keyType', 'double',  ...
'valueType', 'double' );
end 
end 
end 

methods ( Access = public, Hidden = true )
function ancestors = utilGetAncestors( obj, bh )
ancestors = [  ];
parent = get_param( bh, 'Parent' );
while ~isempty( parent )
parentH = get_param( parent, 'handle' );
if Simulink.SubsystemType.isBlockDiagram( parentH )
if isKey( obj.refMdlToMdlBlk, parentH )
parentH = obj.refMdlToMdlBlk( parentH );
elseif isKey( obj.obsMdlToRefBlk, parentH )
parentH = obj.obsMdlToRefBlk( parentH );
end 
end 
if ~Simulink.SubsystemType.isBlockDiagram( parentH )
ancestors( end  + 1 ) = parentH;%#ok<AGROW>
end 
parent = get_param( parentH, 'parent' );
end 
end 

function childComponents = utilGetAllChildComponents( obj )
idx = arrayfun( @( b ) ...
( Simulink.SubsystemType( b ).isSubsystem ||  ...
Simulink.SubsystemType.isModelBlock( b ) ), obj.allNVBlkHs );
childComponents = obj.allNVBlkHs( idx );
end 

function ancestors = utilGetVirtualBlkAncestors( obj )



allseeds = obj.designInterests.blocks;
vseeds = allseeds( arrayfun( @( h )isSubsysPort( h ), allseeds ) );
vseeds = reshape( vseeds, 1, [  ] );
ancestors = [  ];
for vseed = vseeds
ancestors = [ ancestors ...
, get_param( get_param( vseed, 'Parent' ), 'handle' ) ];%#ok<AGROW>
end 
ancestors = unique( ancestors );
end 

function yesno = shouldRetainMdlBlockOutport( obj, blkH, deadBlocks )

yesno = ismember( blkH, obj.designInterests.blocks ) ||  ...
~ismember( blkH, deadBlocks );
end 

function dsmNames = getGlobalDsmNames( obj )
dsmNames = obj.mdlStructureInfo.globalDsmNames;
end 

function dsmHandles = getLocalDsms( obj )
dsmHandles = obj.mdlStructureInfo.dsmHandles;
end 

function resetDependencies( obj )
resetDependencies@ModelSlicer( obj );
obj.allSrcP = [  ];
obj.allDstP = [  ];
obj.allLineHandles = [  ];
end 

function refMdlH = getReferencedModels( obj )
refMdlH = getReferencedModels@ModelSlicer( obj );
refMdlH = [ refMdlH, obj.obsMdlToRefBlk.keys ];
end 
end 

methods ( Access = protected )
function [ hdls, deadBlocksMapped, toRemove, activeH, allNonVirtH, synthDeadBlockH ] = utilGetAllHandles( obj, deadBlocks )
hdls = obj.allBlkHs;
deadBlocksMapped = deadBlocks;
toRemove = deadBlocks;
synthDeadBlockH = [  ];
activeH = setdiff( hdls, toRemove );
allNonVirtH = activeH;
end 

function [ deadBlocks, allDeadBlocks, inactiveV ] = utilComputeDeadBlocks( obj )
allH = obj.allBlkHs;
[ ~, activeH ] = obj.analyse;
deadBlocks = setdiff( allH, activeH );



deadBlocks = filterRequiredBlocks( deadBlocks );
inactiveHdls = filterRequiredBlocks( obj.inactiveHdls );
deadBlocks = [ deadBlocks;reshape( inactiveHdls, [  ], 1 ) ];

transforms = obj.transforms;
keeps = [  ];

for i = 1:length( transforms )
keeps = [ keeps;transforms( i ).filterDeadBlocks( deadBlocks ) ];%#ok<AGROW>
end 


deadBlocks = setdiff( deadBlocks, keeps );

deadBlocks = obj.removeDanglingFromBlocks( activeH, deadBlocks );

allDeadBlocks = deadBlocks;
inactiveV = deadBlocks;

function deadBlocks = filterRequiredBlocks( deadBlocks )
idx = arrayfun( @( h )~isRequiredBlk( h ), deadBlocks );
deadBlocks = deadBlocks( idx );
end 

function yesno = isRequiredBlk( h )
btype = string( get_param( h, 'BlockType' ) );
yesno = contains( btype, [ "ActionPort",  ...
"EnablePort", "TriggerPort", "GotoTagVisibility" ] );
end 
end 

function deadBlocks = removeDanglingFromBlocks( ~, activeBlocks, deadBlocks )



fromBlks = getBlocksOfType( activeBlocks, "From" );
if isempty( fromBlks )
return ;
end 

goToBlks = getBlocksOfType( deadBlocks, "Goto" );
for i = 1:length( fromBlks )

goToHandles = getGotoHandlesForFromBlks( fromBlks( i ) );


deadGoToBlocks = intersect( goToBlks, goToHandles );
if ~isempty( deadGoToBlocks )
deadBlocks = [ deadBlocks;fromBlks( i ) ];
end 
end 
end 

function modelBlockH = utilGetReferencedModelBlocks( ~, sysH )
if strcmpi( get_param( sysH, 'type' ), 'block' ) &&  ...
Simulink.SubsystemType.isModelBlock( sysH )
sysH = get_param(  ...
get_param( sysH, 'NormalModeModelName' ),  ...
'handle' );
end 
findOpts = Simulink.FindOptions( 'FollowLinks', true,  ...
'IncludeCommented', false,  ...
'MatchFilter', @Simulink.match.activeVariants );
modelBlockH = Simulink.findBlocksOfType( sysH, 'ModelReference', findOpts );
Q = modelBlockH;
while ~isempty( Q )
mdlblkH = Q( 1 );
Q( 1 ) = [  ];

refMdl = get_param( mdlblkH, 'NormalModeModelName' );
if ~isempty( refMdl )
nextMdlBlkHs = Simulink.findBlocksOfType( refMdl,  ...
'ModelReference', findOpts );
if ~isempty( nextMdlBlkHs )
modelBlockH = [ modelBlockH;nextMdlBlkHs ];%#ok<AGROW>
Q = [ Q;nextMdlBlkHs ];%#ok<AGROW>
end 
end 
end 
modelBlockH = modelBlockH';
end 

function modifiedSystems = removeUnusedBlocks( obj, sliceXfrmr, sliceMdl, handlesCopy, redundantMerges, handles )
subsysPortIdx = arrayfun( @( h )isSubsysPort( h ), handlesCopy );

sysPortHandlesCopy = handlesCopy( subsysPortIdx );
sysPortHandlesCopy = filterConditionalBlocksWithIC( sysPortHandlesCopy );
handlesCopy = handlesCopy( ~subsysPortIdx );



fromBlks = getBlocksOfType( handlesCopy, "From" );
gotoHandles = getGotoHandlesForFromBlks( fromBlks );


modifiedSystems = Transform.removeNVBlocks( sliceXfrmr, sliceMdl, handlesCopy, false,  ...
[  ], redundantMerges, obj.refMdlToMdlBlk, handles, obj.options );



gotoHandles = gotoHandles( ishandle( gotoHandles ) );
if ~isempty( gotoHandles )
toRemove = arrayfun( @( g ) ...
isempty( get( g, 'FromBlocks' ) ), gotoHandles );
gotoHandles = gotoHandles( toRemove );
end 

sysPortHandlesCopy = sysPortHandlesCopy( ishandle( sysPortHandlesCopy ) );

specialVHandlesToRemove = [ gotoHandles;sysPortHandlesCopy ];

Transform.removeVBlocks( sliceXfrmr, sliceMdl, specialVHandlesToRemove );


Transform.removeRootInportsIfNeeded( sliceXfrmr, obj.model,  ...
sliceMdl, obj.options );

function blks = filterConditionalBlocksWithIC( blks )
blks = blks( arrayfun( @( b )~isConditionalOutportWithIC( b ), blks ) );
end 

function yesno = isConditionalOutportWithIC( bh )
yesno = false;
if strcmpi( get_param( bh, 'BlockType' ), 'Outport' ) &&  ...
isConditionalSubsystem( get_param( bh, 'Parent' ) )
try 
InitialOutput = get_param( bh, 'InitialOutput' );
yesno = ~isempty( InitialOutput ) &&  ...
~isempty( evalin( 'base', InitialOutput ) );
catch 
end 
end 
end 
end 

function utilRemoveBlocks( obj, sliceXfrmr, ~, ~, ~, sldvPassthroughDeadBlocks, ~ )
obj.removeReplacedButUnusedBlocks( sliceXfrmr );
obj.removeSLDVPassthroughBlocks( sliceXfrmr, sldvPassthroughDeadBlocks );
end 

function utilExpandTrivialSubsystems( obj, allNonVirtH, origSys, sliceRootSys, modifiedSystems, sliceXfrmr )
utilExpandTrivialSubsystems@ModelSlicer( obj, allNonVirtH, origSys, sliceRootSys, modifiedSystems, sliceXfrmr )




delete_line( find_system( bdroot( sliceRootSys ),  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FindAll', 'on', 'Type', 'line', 'Connected', 'off' ) );
end 
function hasGlobal = checkHasGlobal( obj )
hasGlobal = ~isempty( obj.getGlobalDsmNames(  ) ) ||  ...
~isempty( obj.getLocalDsms(  ) );
end 

function preSliceSubsysPorts = getSubsysCache( ~, ~ )

preSliceSubsysPorts = [  ];

end 

function postProcessSubsysPorts( ~, ~, ~, ~ )






end 

function ancestors = gatherAncestors( obj, elemHandles )
ancestors = [  ];
for idx = 1:length( elemHandles )
l = obj.utilGetAncestors( elemHandles( idx ) );
ancestors = [ ancestors, l ];%#ok<AGROW>
end 
ancestors = unique( ancestors );
end 

function sysH = getExcludedSubsys( obj )
sysH = [  ];
for idx = 1:length( obj.exc )
e = obj.exc( idx );
if strcmp( get_param( e, 'type' ), 'block' ) &&  ...
strcmp( get_param( e, 'BlockType' ), 'SubSystem' )
sysH( end  + 1 ) = e;
end 
end 
end 

function blocks = gatherDesignInterestAncestors( obj )

startBlks = reshape( obj.designInterests.blocks, [  ], 1 );


signalStartOwners = arrayfun( @( h ) ...
get_param( h, 'ParentHandle' ),  ...
obj.designInterests.signals );

startBlks = [ startBlks;reshape( signalStartOwners, [  ], 1 ) ];


blocks = [ startBlks; ...
obj.gatherAncestors( startBlks )' ];
end 

function [ handles, src, dst ] = getAllElementsInContext( obj, contexts )
handles = [  ];
src = [  ];
dst = [  ];
mdlblks = [  ];

for c = contexts
mdlblks = [ mdlblks, obj.utilGetReferencedModelBlocks( c ) ];%#ok<AGROW>
end 
contexts = [ contexts, mdlblks ];


for idx = 1:length( contexts )
c = contexts( idx );
if strcmpi( get_param( c, 'type' ), 'block' ) &&  ...
Simulink.SubsystemType.isModelBlock( c )
c = get_param(  ...
get_param( c, 'NormalModeModelName' ),  ...
'handle' );
contexts( idx ) = c;
end 
end 

if ~isempty( contexts )



lines = find_system( contexts, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', true,  ...
'LookUnderMasks', 'on',  ...
'type', 'line' );


blocks = find_system( contexts, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', true,  ...
'LookUnderMasks', 'on',  ...
'type', 'block' );


for l = lines'
s = get_param( l, 'SrcPortHandle' );
d = get_param( l, 'DstPortHandle' );
src = [ src, repmat( s, 1, numel( d ) ) ];%#ok<AGROW>
dst = [ dst, reshape( d, 1, [  ] ) ];%#ok<AGROW>
end 
handles = [ blocks', lines' ];
end 
end 
end 
end 

function yesno = isSubsysPort( h )
btype = string( get_param( h, 'BlockType' ) );
ptype = Simulink.SubsystemType( get_param( h, 'Parent' ) );
yesno = ptype.isSubsystem &&  ...
contains( btype, [ "Inport", "Outport" ] );
end 


function inH = removeCtrlPorts( inH )
idx = arrayfun( @( p )~isCtrlPort( p ), inH );
inH = inH( idx );
end 

function yesno = isCtrlPort( ph )
yesno = false;
portType = get_param( ph, 'PortType' );
if any( strcmpi( portType, { 'enable', 'trigger' } ) )
yesno = true;
return ;
elseif ~strcmpi( portType, 'inport' )
return ;
end 
po = get_param( ph, 'Object' );
idx = po.PortNumber;
blkh = get_param( ph, 'ParentHandle' );
bo = get_param( blkh, 'object' );
if ( strcmp( bo.BlockType, 'MultiPortSwitch' ) && idx == 1 ) ||  ...
( strcmp( bo.BlockType, 'Switch' ) && idx == 2 ) ||  ...
( strcmp( bo.BlockType, 'Interpolation_n-D' ) && idx == 1 )
yesno = true;
return 
end 
end 

function out = isConditionalSubsystem( blk )
out = false;
blkH = get_param( blk, 'handle' );
if strcmp( get_param( blkH, 'type' ), 'block' ) &&  ...
strcmp( get_param( blkH, 'BlockType' ), 'SubSystem' )
SS = Simulink.SubsystemType( blkH );
out = SS.isEnabledSubsystem(  ) || SS.isTriggeredSubsystem(  ) ||  ...
SS.isEnabledAndTriggeredSubsystem(  ) || SS.isFunctionCallSubsystem(  ) ||  ...
SS.isForIteratorSubsystem(  ) || SS.isWhileIteratorSubsystem(  );
end 
end 

function filteredBlocks = getBlocksOfType( blks, bTypeList )
R36
blks
bTypeList( 1, : )string
end 
filteredBlocks = blks( arrayfun( @( b )isInterestingBlk( b ), blks ) );
function yesno = isInterestingBlk( h )
btype = string( get_param( h, 'BlockType' ) );
yesno = any( strcmp( btype, bTypeList ) );
end 
end 

function gotoHandles = getGotoHandlesForFromBlks( fromBlks )
gotoHandles = [  ];
if ~isempty( fromBlks )
gotoInfo = get( fromBlks, 'GotoBlock' );
if isstruct( gotoInfo )
gotoHandles = gotoInfo.handle;
else 
gotoHandles = unique( cell2mat(  ...
cellfun( @( g )g.handle, gotoInfo,  ...
'UniformOutput', false ) ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvoBWI4.p.
% Please follow local copyright laws when handling this file.

