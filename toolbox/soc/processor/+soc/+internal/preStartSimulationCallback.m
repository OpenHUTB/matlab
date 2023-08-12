function preStartSimulationCallback( mdlName, isModelRef, varargin )






if isModelRef
return ;
end 
if strcmp( get_param( mdlName, 'SimulationMode' ), 'external' )
return ;
end 
if ~isempty( get_param( mdlName, 'RTWBuildArgs' ) )
return ;
end 

if strcmpi( get_param( mdlName, 'HardwareBoard' ), 'None' ) &&  ...
strcmpi( get_param( mdlName, 'ProdHWDeviceType' ), 'ASIC/FPGA->ASIC/FPGA' )
return ;
end 

tskMgrs = soc.internal.connectivity.getTaskManagerBlock( mdlName,  ...
'overrideAssert' );
memCh = locGetMemChannelBlock( mdlName );
memCtrl = locGetMemControllerBlock( mdlName );
intCh = locGetIntChannelBlock( mdlName );

if isempty( tskMgrs ) && isempty( memCh ) && isempty( memCtrl ) && isempty( intCh ) &&  ...
isempty( soc.util.getHSBSubsystem( mdlName ) )
return ;
end 

locCheckMultiProcSettings( mdlName, tskMgrs );
locCheckProcessingUnitSettings( mdlName );

solverType = get_param( mdlName, 'SolverType' );
if ~strcmp( solverType, 'Variable-step' )
error( message( 'soc:scheduler:UnsupportedSolver',  ...
get_param( mdlName, 'Name' ), solverType ) );
end 

end 


function locCheckMultiProcSettings( mdlName, mgrs )
if ~isempty( mgrs ) && iscell( mgrs ) && numel( mgrs ) > 1
hCS = getActiveConfigSet( mdlName );
board = get_param( hCS, 'HardwareBoard' );


if isequal( board, 'Custom Hardware Board' ), return ;end 
if ~codertarget.targethardware.hasMultipleProcessingUnits( hCS )
error( message( 'soc:scheduler:MultiprocOnePUOnly', mdlName, board ) );
end 
for i = 1:numel( mgrs )
refMdl =  ...
soc.internal.connectivity.getModelConnectedToTaskManager( mgrs{ i } );
refMdlNames{ i } = get_param( refMdl, 'ModelName' );%#ok<AGROW> 
hCS = getActiveConfigSet( refMdlNames{ i } );
allPUs{ i } = codertarget.targethardware.getProcessingUnitName( hCS );%#ok<AGROW>
end 
idxMdlSetToNone = contains( allPUs, 'None' );
if any( idxMdlSetToNone )
error( message( 'soc:scheduler:RefModelSetToNone', refMdlNames{ idxMdlSetToNone } ) );
end 
for i = 1:numel( allPUs )
thisPU = allPUs{ i };
foundIndices = cell2mat( strfind( allPUs, thisPU ) );
if isvector( foundIndices ) && numel( foundIndices ) > 1
error( message( 'soc:scheduler:MultiprocUsingSamePU',  ...
mdlName, thisPU ) );
end 
end 
end 
end 


function locCheckProcessingUnitSettings( modelName )
import soc.internal.connectivity.*
mobj = get_param( modelName, 'object' );
if ~mobj.isHierarchyBuilding
hCS = getActiveConfigSet( modelName );


if codertarget.utils.isMdlConfiguredForSoC( hCS ) &&  ...
codertarget.data.isValidParameter( hCS, 'ESB.ProcessingUnit' ) &&  ...
codertarget.targethardware.hasMultipleProcessingUnits( hCS )
pu = codertarget.data.getParameterValue( hCS, 'ESB.ProcessingUnit' );
if ~isequal( pu, 'None' )
error( message( 'soc:scheduler:ProcUnitTopMdlInvalid', modelName ) );
end 
end 
end 
end 


function memCh = locGetMemChannelBlock( mdl )


memCh = [ find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/Memory Channel' ); ...
find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/AXI4-Stream to Software' ); ...
find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/Software to AXI4-Stream' ); ...
find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/AXI4 Random Access Memory' ); ...
find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/AXI4 Video Frame Buffer' ) ];
if ~isempty( memCh )
if iscell( memCh ) && isequal( numel( memCh ), 1 )
memCh = memCh{ 1 };
end 
end 
end 


function memCtrl = locGetMemControllerBlock( mdl )


memCtrl = [ find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/Memory Controller' ); ...
find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib_internal/Memory Controller' ) ];
if ~isempty( memCtrl )
if iscell( memCtrl ) && isequal( numel( memCtrl ), 1 )
memCtrl = memCtrl{ 1 };
end 
end 
end 


function intCh = locGetIntChannelBlock( mdl )


intCh = find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'socmemlib/Interrupt Channel' );
if ~isempty( intCh )
if iscell( intCh ) && isequal( numel( intCh ), 1 )
intCh = intCh{ 1 };
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0zo_Qz.p.
% Please follow local copyright laws when handling this file.

