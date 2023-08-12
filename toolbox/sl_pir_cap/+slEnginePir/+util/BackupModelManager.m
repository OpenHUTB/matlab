


classdef BackupModelManager < handle

properties 
TopModel
BackupPrefix
LoadedModels
fRefMdls
fLibMdls
fLinkedBlks
fLinkedSubsysRefs
fSubsysRefs
fMdlRefs
fMdlRefInLibMap
fMdl
end 

properties ( Hidden )
cleanup;
end 

methods 
function classObject = BackupModelManager( topModel, backupPrefix )
R36
topModel
backupPrefix = 'backup_'
end 
classObject.TopModel = topModel;
classObject.BackupPrefix = backupPrefix;

classObject.fMdl = classObject.TopModel;
classObject.LoadedModels = {  };

classObject.fMdlRefs = [  ];
classObject.fRefMdls = [  ];
classObject.fLinkedBlks = [  ];
classObject.fLinkedSubsysRefs = [  ];
classObject.fSubsysRefs = {  };
classObject.fLibMdls = [  ];
classObject.fMdlRefInLibMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );

fSimModeMap = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );


hiliteData1 = struct( 'HiliteType', 'user1', 'ForegroundColor', 'black', 'BackgroundColor', 'yellow' );
hiliteData2 = struct( 'HiliteType', 'user2', 'ForegroundColor', 'black', 'BackgroundColor', 'lightBlue' );
set_param( 0, 'HiliteAncestorsData', hiliteData1 );
set_param( 0, 'HiliteAncestorsData', hiliteData2 );


if ~bdIsLoaded( classObject.TopModel )
load_system( classObject.TopModel );
classObject.LoadedModels =  ...
[ classObject.LoadedModels;{ classObject.TopModel } ];
end 


classObject.getAllMdlRefAndLibBlks( classObject.TopModel, [  ], {  } );
if ~isempty( classObject.fLinkedBlks )
classObject.fLibMdls = unique( { classObject.fLinkedBlks.lib } );
end 
if ~isempty( classObject.fLinkedSubsysRefs )
classObject.fSubsysRefs = unique( { classObject.fLinkedSubsysRefs.subsystem } );
end 

for lIdx = 1:length( classObject.fLibMdls )
if ~bdIsLoaded( classObject.fLibMdls{ lIdx } )
load_system( classObject.fLibMdls{ lIdx } );
classObject.LoadedModels =  ...
[ classObject.LoadedModels;classObject.fLibMdls( lIdx ) ];
end 
end 

for lIdx = 1:length( classObject.fSubsysRefs )
if ~bdIsLoaded( classObject.fSubsysRefs{ lIdx } )
load_system( classObject.fSubsysRefs{ lIdx } );
classObject.LoadedModels =  ...
[ classObject.LoadedModels;classObject.fSubsysRefs( lIdx ) ];
end 
end 

fSess = Simulink.CMI.CompiledSession( Simulink.EngineInterfaceVal.byFiat );
fBd = Simulink.CMI.CompiledBlockDiagram( fSess, classObject.fMdl );


mdls = [ { classObject.fMdl }, classObject.fRefMdls ];
classObject.clearPIRs( mdls );


mdlRefBlks = [  ];
if ~isempty( classObject.fRefMdls )
mdlRefBlks = { classObject.fMdlRefs.block };
end 

classObject.cleanup = onCleanup( @(  )BaseCleanupFcn( classObject, fBd, mdls, mdlRefBlks, fSimModeMap ) );
end 

function fXformedMdl = createBackupModel( classObject )
backupDir = [ 'm2m_', classObject.TopModel, '/' ];
if exist( backupDir, 'dir' ) == 0
mkdir( backupDir );
end 


mdls = { classObject.TopModel };
mdls = [ mdls, classObject.fRefMdls, classObject.fLibMdls, classObject.fSubsysRefs ];
fXformedLibs = {  };
fXformedSubsystems = {  };

for m = 1:length( mdls )
if ~strcmpi( mdls{ m }, 'simulink' )
close_system( [ classObject.BackupPrefix, mdls{ m } ], 0 );
mdlfullname = which( mdls{ m } );
[ ~, ~, ext ] = fileparts( mdlfullname );

if exist( [ backupDir, classObject.BackupPrefix, mdls{ m }, ext ], 'file' ) == 2
delete( [ backupDir, classObject.BackupPrefix, mdls{ m }, ext ] );
end 
copyfile( mdlfullname, [ backupDir, classObject.BackupPrefix, mdls{ m }, ext ], 'f' );
fileattrib( [ backupDir, classObject.BackupPrefix, mdls{ m }, ext ], '+w' );
load_system( [ backupDir, classObject.BackupPrefix, mdls{ m } ] );
if strcmpi( get_param( [ classObject.BackupPrefix, mdls{ m } ], 'BlockDiagramType' ), 'library' )
fXformedLibs = [ fXformedLibs, mdls( m ) ];%#ok
set_param( [ classObject.BackupPrefix, mdls{ m } ], 'lock', 'off' );
elseif strcmpi( get_param( [ classObject.BackupPrefix, mdls{ m } ], 'BlockDiagramType' ), 'subsystem' )
fXformedSubsystems = [ fXformedSubsystems, mdls( m ) ];%#ok
set_param( [ classObject.BackupPrefix, mdls{ m } ], 'lock', 'off' );
end 
end 
end 

for m = 1:length( classObject.fMdlRefs )
dlg = bdroot( classObject.fMdlRefs( m ).block );
if ~bdIsLibrary( dlg ) || ~isempty( find( strcmp( fXformedLibs, dlg ), 1 ) )
mdlvariants = get_param( [ classObject.BackupPrefix, classObject.fMdlRefs( m ).block ], 'Variants' );
if strcmpi( get_param( [ classObject.BackupPrefix, classObject.fMdlRefs( m ).block ], 'Variant' ), 'off' ) || isempty( mdlvariants )
set_param( [ classObject.BackupPrefix, classObject.fMdlRefs( m ).block ], 'ModelName', [ classObject.BackupPrefix, classObject.fMdlRefs( m ).refmdl{ 1 } ] );
else 
for ii = 1:length( mdlvariants )
mdlvariants( ii ).ModelName = [ classObject.BackupPrefix, mdlvariants( ii ).ModelName ];
end 
set_param( [ classObject.BackupPrefix, classObject.fMdlRefs( m ).block ], 'Variants', mdlvariants );
end 
end 
end 


fXformedMdl = [ classObject.BackupPrefix, classObject.TopModel ];


for ii = 1:length( classObject.fLinkedBlks )
linkedBlk = classObject.fLinkedBlks( ii ).block;
delete_block( [ classObject.BackupPrefix, linkedBlk ] );
referenceblk = get_param( linkedBlk, 'ReferenceBlock' );
add_block( [ classObject.BackupPrefix, referenceblk ], [ classObject.BackupPrefix, linkedBlk ] );
slEnginePir.util.copyInfoToNewLinkedBlk( [ classObject.BackupPrefix, linkedBlk ], linkedBlk );
end 


for ii = 1:length( classObject.fLinkedSubsysRefs )
linkedBlk = classObject.fLinkedSubsysRefs( ii ).block;
referenceblk = get_param( linkedBlk, 'ReferencedSubsystem' );
set_param( [ classObject.BackupPrefix, linkedBlk ],  ...
'ReferencedSubsystem', [ classObject.BackupPrefix, referenceblk ] );
end 


save_system( [ classObject.BackupPrefix, classObject.TopModel ], [ backupDir, classObject.BackupPrefix, classObject.TopModel ],  ...
'SaveDirtyReferencedModels', 'on' );
for m = 1:length( fXformedLibs )
save_system( [ classObject.BackupPrefix, fXformedLibs{ m } ], [ backupDir, classObject.BackupPrefix, fXformedLibs{ m } ],  ...
'SaveDirtyReferencedModels', 'on' );
end 
for m = 1:length( fXformedSubsystems )
save_system( [ classObject.BackupPrefix, fXformedSubsystems{ m } ], [ backupDir, classObject.BackupPrefix, fXformedSubsystems{ m } ] );
end 
for m = 1:length( classObject.fRefMdls )
save_system( [ classObject.BackupPrefix, classObject.fRefMdls{ m } ], [ backupDir, classObject.BackupPrefix, classObject.fRefMdls{ m } ],  ...
'SaveDirtyReferencedModels', 'on' );
end 


close_system( [ classObject.BackupPrefix, classObject.TopModel ] );
for m = 1:length( fXformedLibs )
close_system( [ classObject.BackupPrefix, fXformedLibs{ m } ], 0 );
end 
for m = 1:length( fXformedSubsystems )
close_system( [ classObject.BackupPrefix, fXformedSubsystems{ m } ], 0 );
end 
for m = 1:length( classObject.fRefMdls )
close_system( [ classObject.BackupPrefix, classObject.fRefMdls{ m } ], 0 );
end 

for mIndex = 1:length( classObject.LoadedModels )
close_system( classObject.LoadedModels{ mIndex }, 0 );
end 
end 

function BaseCleanupFcn( classObject, aBd, aPIRs, aMdlRefBlks, aSimModeMap )%#ok
for idx = 1:length( aPIRs )
try 
if iskey( aSimModeMap, aPIRs{ idx } ) &&  ...
~strcmpi( get_param( aPIRs{ idx }, 'SimulationMode' ), aSimModeMap( aPIRs{ idx } ) )
set_param( aPIRs{ idx }, 'SimulationMode', aSimModeMap( aPIRs{ idx } ) );
end 
catch 
end 
end 


try 
if ishandle( aBd.Handle ) && strcmpi( get_param( aBd.Handle, 'SimulationStatus' ), 'paused' )
aBd.term;
end 
catch 
end 


modifiedMdls = cell( 1, 0 );
for idx = 1:length( aMdlRefBlks )
try 
if isKey( aSimModeMap, aMdlRefBlks{ idx } )
mdlvariants = get_param( aMdlRefBlks{ idx }, 'variants' );
modelChanged = false;
if ~strcmpi( get_param( aMdlRefBlks{ idx }, 'SimulationMode' ), aSimModeMap( aMdlRefBlks{ idx } ) )
set_param( aMdlRefBlks{ idx }, 'SimulationMode', aSimModeMap( aMdlRefBlks{ idx } ) );
modifiedMdls = unique( [ modifiedMdls, bdroot( aMdlRefBlks{ idx } ) ] );
end 
if ~isempty( mdlvariants )
for mIdx = 1:length( mdlvariants )
if ~strcmpi( mdlvariants( mIdx ).SimulationMode, aSimModeMap( [ mdlvariants( mIdx ).ModelName, '@', aMdlRefBlks{ idx } ] ) )
mdlvariants( mIdx ).SimulationMode = aSimModeMap( [ mdlvariants( mIdx ).ModelName, '@', aMdlRefBlks{ idx } ] );
modelChanged = true;
end 
end 
if ( modelChanged )
set_param( aMdlRefBlks{ idx }, 'variants', mdlvariants );
end 
end 
end 
catch 
end 
end 
for idx = 1:length( modifiedMdls )
save_system( modifiedMdls{ idx } );
end 
end 


function [ trvdMdls ] = getAllMdlRefAndLibBlks( classObject, aMdl, aDir, aTrvdMdls )
trvdMdls = aTrvdMdls;
refedLinkedMdls = cell( 1, 0 );
mdlRefBlks = find_system( aMdl, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants,  ...
'FindAll', 'on', 'BlockType', 'ModelReference', 'Commented', 'off' );
linkedBlks = find_system( aMdl, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants,  ...
'FindAll', 'on', 'LinkStatus', 'resolved', 'BlockType', 'SubSystem', 'Commented', 'off' );
linkedSubsysRefs = find_system( aMdl, 'MatchFilter', @Simulink.match.allVariants, 'RegExp', 'on', 'BlockType', 'SubSystem',  ...
'ReferencedSubsystem', '.' );


mdlRefsInfo = struct( 'block', {  }, 'refmdl', {  } );
for ii = 1:length( mdlRefBlks )
sidMdlrefBlk = Simulink.ID.getSID( mdlRefBlks( ii ) );
mdlRefInfo = struct( 'block', [  ], 'refmdl', [  ] );
if strcmpi( get_param( mdlRefBlks( ii ), 'ProtectedModel' ), 'on' )
DAStudio.error( 'sl_pir_cpp:creator:UnsupportedProtectedModel', getfullname( mdlRefBlks( ii ) ) );
end 
mdlRefInfo.block = getfullname( mdlRefBlks( ii ) );
mdlVariants = get_param( mdlRefBlks( ii ), 'Variants' );
if strcmpi( get_param( mdlRefBlks( ii ), 'Variant' ), 'off' ) || isempty( mdlVariants )
if exist( get_param( mdlRefBlks( ii ), 'ModelName' ), 'file' ) > 0
mdlRefInfo.refmdl = { get_param( mdlRefBlks( ii ), 'ModelName' ) };

end 
else 
mdlRefInfo.refmdl = [  ];
for m = 1:length( mdlVariants )
[ ~, refmdlName, ~ ] = fileparts( mdlVariants( m ).ModelName );
if exist( refmdlName, 'file' ) > 0
mdlRefInfo.refmdl = [ mdlRefInfo.refmdl, { refmdlName } ];
end 
end 
end 
if ~isempty( mdlRefInfo.refmdl )
mdlRefsInfo = [ mdlRefsInfo, mdlRefInfo ];%#ok
refedLinkedMdls = [ refedLinkedMdls, mdlRefsInfo( ii ).refmdl ];%#ok
rootBd = bdroot( aMdl );
if strcmpi( get_param( rootBd, 'BlockDiagramType' ), 'library' )
for mIdx = 1:length( mdlRefInfo.refmdl )
if isKey( classObject.fMdlRefInLibMap, mdlRefInfo.refmdl{ mIdx } )
classObject.fMdlRefInLibMap( mdlRefInfo.refmdl{ mIdx } ) = [ classObject.fMdlRefInLibMap( mdlRefInfo.refmdl ), sidMdlrefBlk ];
else 
classObject.fMdlRefInLibMap( mdlRefInfo.refmdl{ mIdx } ) = { sidMdlrefBlk };
end 
end 
end 
end 
end 

classObject.fRefMdls = [ classObject.fRefMdls, refedLinkedMdls ];
classObject.fMdlRefs = [ classObject.fMdlRefs, mdlRefsInfo ];


linkedBlksInfo = struct( 'block', {  }, 'lib', {  } );
for ii = 1:length( linkedBlks )
linkedBlkInfo = struct( 'block', [  ], 'lib', [  ] );
refBlock = get_param( linkedBlks( ii ), 'ReferenceBlock' );
Library = strsplit( refBlock, '/' );
if classObject.isSimulinkLibrary( Library{ 1 } )
linkedBlkInfo.block = getfullname( linkedBlks( ii ) );
linkedBlkInfo.lib = Library{ 1 };
refedLinkedMdls = [ refedLinkedMdls, refBlock ];%#ok
linkedBlksInfo = [ linkedBlksInfo, linkedBlkInfo ];%#ok
end 
end 
classObject.fLinkedBlks = [ classObject.fLinkedBlks, linkedBlksInfo ];


linkedSubsysRefsInfo = struct( 'block', {  }, 'subsystem', {  } );
for ii = 1:length( linkedSubsysRefs )
linkedSSBlkInfo = struct( 'block', [  ], 'subsystem', [  ] );
refBlock = get_param( linkedSubsysRefs{ ii }, 'ReferencedSubsystem' );
if ~isempty( refBlock )
SubsystemPath = strsplit( refBlock, '/' );
linkedSSBlkInfo.block = getfullname( linkedSubsysRefs{ ii } );
linkedSSBlkInfo.subsystem = SubsystemPath{ 1 };
linkedSubsysRefsInfo = [ linkedSubsysRefsInfo, linkedSSBlkInfo ];%#ok
end 
end 
classObject.fLinkedSubsysRefs = [ classObject.fLinkedSubsysRefs, linkedSubsysRefsInfo ];



refedLinkedMdls = unique( refedLinkedMdls );
for ii = 1:length( refedLinkedMdls )
if isempty( find( strcmpi( trvdMdls, refedLinkedMdls{ ii } ), 1 ) )
mdlPath = strsplit( refedLinkedMdls{ ii }, '/' );
if ~bdIsLoaded( mdlPath{ 1 } )
if ~isempty( aDir )
load_system( [ aDir, mdlPath{ 1 } ] );
else 
load_system( mdlPath{ 1 } );
end 
classObject.LoadedModels =  ...
[ classObject.LoadedModels;mdlPath( 1 ) ];
end 
trvdMdls = [ trvdMdls, refedLinkedMdls( ii ) ];%#ok
trvdMdls = classObject.getAllMdlRefAndLibBlks( refedLinkedMdls{ ii }, aDir, trvdMdls );
end 
end 
classObject.fRefMdls = unique( classObject.fRefMdls );
end 

function isCandLib = isSimulinkLibrary( ~, aLib )
isCandLib = false;
simulink_library_list = { 'simulink', 'simulink_need_slupdate' };
if isempty( find( strcmpi( simulink_library_list, aLib ), 1 ) ) && exist( aLib, 'file' ) > 0
isCandLib = true;
end 
end 

function clearPIRs( ~, aPIRs )
p = pir;
for idx = 1:length( aPIRs )
p.destroyPirCtx( [ aPIRs{ idx } ] );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpTzND2T.p.
% Please follow local copyright laws when handling this file.

