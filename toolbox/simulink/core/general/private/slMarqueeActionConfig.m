function config = slMarqueeActionConfig(  )










































config = [ 
struct( 'name', 'SL.MA.ConfigureCodeSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/add_signal_quickaction_default_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/add_signal_quickaction_hover_16.svg',  ...
'checker', @MACanConfigureSignalsForCode,  ...
'handler', @MAConfigureSignal,  ...
'tooltip', DAStudio.message( 'coderdictionary:mapping:CodeMapping_AddSignal_Tooltip' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StopConfiguringCodeSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/remove_signal_quickaction_default_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/remove_signal_quickaction_hover_16.svg',  ...
'checker', @MACanStopConfiguringSignalsForCode,  ...
'handler', @MAStopConfiguringSignal,  ...
'tooltip', DAStudio.message( 'coderdictionary:mapping:CodeMapping_RemoveSignal_Tooltip' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.TraceToCode',  ...
'icon', '/toolbox/shared/dastudio/resources/C_Code_16x16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/C_Code_16x16.svg',  ...
'checker', @MACanTraceToCode,  ...
'handler', @MATraceToCode,  ...
'tooltip', message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCode' ).getString,  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.CreateSubsystem',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-16.svg',  ...
'checker', @MACanCreateSubsystem,  ...
'handler', @MACreateSubsystem,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MACreateSubsystem' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.CreateEnabledSubsystem',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-enabled-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-enabled-16.svg',  ...
'checker', @MACanCreateEnabledSubsystem,  ...
'handler', @MACreateEnabledSubsystem,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MACreateEnabledSubsystem' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.CreateTriggeredSubsystem',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-triggered-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-triggered-16.svg',  ...
'checker', @MACanCreateTriggeredSubsystem,  ...
'handler', @MACreateTriggeredSubsystem,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MACreateTriggeredSubsystem' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.CreateFunctionCallSubsystem',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-fncall-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-fncall-16.svg',  ...
'checker', @MACanCreateFunctionCallSubsystem,  ...
'handler', @MACreateFunctionCallSubsystem,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MACreateFunctionCallSubsystem' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.Comment',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'checker', @MACanComment,  ...
'handler', @MAComment,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAComment' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.Uncomment',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'checker', @MACanUncomment,  ...
'handler', @MAUncomment,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAUncomment' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.CreateBus',  ...
'icon', '/toolbox/shared/dastudio/resources/create_bus_cue_16.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/create_bus_cue_16_hover.png',  ...
'checker', @MACanCreateBus,  ...
'handler', @MACreateBus,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MACreateBus' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.RefactorInterface',  ...
'icon', '/toolbox/shared/dastudio/resources/refactor_interface.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/refactor_interface.svg',  ...
'checker', @MACanRefactorInterface,  ...
'handler', @MARefactorInterface,  ...
'tooltip', DAStudio.message( 'Simulink:BusElPorts:RefactorInterface' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.AreaCreationToolCreateArea',  ...
'icon', '/toolbox/shared/dastudio/resources/create_area_cue_16.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/create_area_cue_16_hover.png',  ...
'checker', @MACanCreateRectangularObject,  ...
'handler', @MACreateArea,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SLAreaCreationToolCreateArea' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.RouteLines',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',  ...
'checker', @MACanRouteLines,  ...
'handler', @MARouteLines,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MARouteLines' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StreamSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'checker', @MACanStreamSignals,  ...
'handler', @MAStreamSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStreamSignals' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StopStreamingSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'checker', @MACanStopStreamingSignals,  ...
'handler', @MAStopStreamingSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStopStreamingSignals' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StreamSignalsJetstream',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'checker', @MACanStreamSignalsJetstream,  ...
'handler', @MAStreamSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAEnableLogging' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StopStreamingSignalsJetstream',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'checker', @MACanStopStreamingSignalsJetstream,  ...
'handler', @MAStopStreamingSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MADisableLogging' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.ObserveSignals',  ...
'icon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'hoverIcon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'checker', @MACanObserveSignals,  ...
'handler', @MAObserveSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAObserveSignal' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'ConvertAnnotationToRequirement',  ...
'icon', '/toolbox/shared/reqmgt/icons/smartActionBadge.png',  ...
'hoverIcon', '/toolbox/shared/reqmgt/icons/smartActionBadgeHover.png',  ...
'checker', @MACanConvertToRequirement,  ...
'handler', @MAConvetToRequirement,  ...
'tooltip', getString( message( 'Slvnv:slreq:ConvertToRequirement' ) ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.StraightenLines',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-straighten-lines-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-straighten-lines-16.svg',  ...
'checker', @MACanStraightenLines,  ...
'handler', @MAStraightenLines,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStraightenLines' ),  ...
'priority', 'normal' ) ...
 ...
, struct( 'name', 'SL.MA.PromoteWebBlocksToPanel',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/float_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/float_white.svg',  ...
'checker', @MACanPromoteToPanel,  ...
'handler', @MAPromoteWebBlocks,  ...
'tooltip', DAStudio.message( 'simulink_ui:webblocks:resources:MSAPromoteBlocksToPanel' ),  ...
'priority', 'normal' ),  ...
 ];

end 

function result = MACanTraceToCode( editor, ~ )
includeBlock = false;
elements = editor.getSelection;
for i = 1:elements.size
element = elements.at( i );
if isa( element, 'SLM3I.Block' )
includeBlock = true;
break ;
end 
end 

if ~includeBlock
result = false;
return ;
end 

a = simulinkcoder.internal.CodePerspective.getInstance;
src = simulinkcoder.internal.util.getSource( editor );

result = a.getStatus( editor ) &&  ...
strcmpi( get_param( src.modelH, 'IsERTTarget' ), 'on' );

end 
function MATraceToCode( editor, ~ )
src = simulinkcoder.internal.util.getSource( editor );
modelName = src.modelName;
codeExist = coder.internal.slcoderReport( 'existTrace', modelName );

if ~codeExist

warndlg( message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCode_CodeNotExist_Warning' ).getString,  ...
message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCodeWarningTitle' ).getString, 'modal' );
return ;
end 

if ~slfeature( 'IntegratedCodeReport' ) &&  ...
~strcmpi( get_param( src.modelH, 'GenerateTraceInfo' ), 'on' )

warndlg( message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCode_TraceInfoOff_Warning' ).getString,  ...
message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCodeWarningTitle' ).getString, 'modal' );
return ;
end 

handles = [  ];
elements = editor.getSelection;
for i = 1:elements.size
element = elements.at( i );
if isa( element, 'SLM3I.Block' )
handles( end  + 1 ) = element.handle;%#ok<AGROW>
end 
end 

if slfeature( 'IntegratedCodeReport' )
simulinkcoder.internal.util.model2code( modelName, handles );
cr = simulinkcoder.internal.Report.getInstance;
cr.focus( editor );
else 
rtwtrace( handles );
end 
end 


function result = MACanStreamSignals( ~, ~ )

result = false;
end 

function result = MACanStreamSignalsJetstream( editor, ~ )
result = MACanStreamSignalsImpl( editor, 'connect' );
end 

function MAStreamSignals( editor, marqueeBounds )
if MACanStreamSignals( editor, marqueeBounds ) || MACanStreamSignalsJetstream( editor, marqueeBounds )
MAStreamSignalsImpl( editor, 'connect' );
end 
end 

function result = MACanStopStreamingSignals( ~, ~ )

result = false;
end 

function result = MACanStopStreamingSignalsJetstream( editor, ~ )
result = MACanStreamSignalsImpl( editor, 'disconnect' );
end 

function MAStopStreamingSignals( editor, marqueeBounds )
if MACanStopStreamingSignals( editor, marqueeBounds ) || MACanStopStreamingSignalsJetstream( editor, marqueeBounds )
MAStreamSignalsImpl( editor, 'disconnect' );
end 
end 

function result = MACanStreamSignalsImpl( editor, action )
cbinfo.isContextMenu = false;
cbinfo.uiObject = get( editor.getDiagram.handle, 'object' );



app = editor.getStudio.App;
cbinfo.model = get( bdroot( app.blockDiagramHandle ), 'object' );
cbinfo.editorModel = get( bdroot( editor.blockDiagramHandle ), 'object' );
if ( app.blockDiagramHandle ~= editor.blockDiagramHandle )
cbinfo.referencedModel = cbinfo.editorModel;
else 
cbinfo.referencedModel = [  ];
end 
schema = Simulink.sdi.internal.SignalObserverMenu.getSimulinkSchema( cbinfo, '', '', '', '', false );

result = false;
if strcmp( schema.state, 'Enabled' ) && strcmp( schema.userdata.action, action )
result = true;
end 


if result && editor.isLocked
result = strcmpi( get_param( bdroot( editor.getDiagram.handle ), 'LibraryType' ), 'None' );
end 
end 

function MAStreamSignalsImpl( editor, action )
cbinfo.isContextMenu = false;
cbinfo.uiObject = get( editor.getDiagram.handle, 'object' );


cbinfo.model = get( bdroot( editor.getDiagram.handle ), 'object' );
cbinfo.userdata.model = cbinfo.model.name;

validSrcPortHs = Simulink.sdi.internal.SignalObserverMenu.locGetValidSrcPortHandles( cbinfo );
[ ~, IA ] = unique( validSrcPortHs );
cbinfo.userdata.portHs = validSrcPortHs( IA );
cbinfo.userdata.action = action;

Simulink.sdi.internal.SignalObserverMenu.ConnectSignal( cbinfo );
end 


function result = MACanConfigureSignalsForCode( editor, ~ )
result = MACanConfigureSignalsImpl( editor, 'connect' );
end 

function MAConfigureSignal( editor, ~ )
bd = get( bdroot( editor.getDiagram.handle ), 'object' );
simulinkcoder.internal.util.CanvasElementSelection.addSelectedSignals( bd.handle );
end 

function result = MACanStopConfiguringSignalsForCode( editor, ~ )
result = MACanConfigureSignalsImpl( editor, 'disconnect' );
end 

function MAStopConfiguringSignal( editor, ~ )
bd = get( bdroot( editor.getDiagram.handle ), 'object' );
simulinkcoder.internal.util.CanvasElementSelection.removeSelectedSignals( bd.handle );
end 

function result = MACanConfigureSignalsImpl( editor, action )

result = false;

bd = get( bdroot( editor.getDiagram.handle ), 'object' );
cp = simulinkcoder.internal.CodePerspective.getInstance;
if ~cp.isInPerspective( bd.handle )
result = false;
return ;
end 

if ~simulinkcoder.internal.util.CanvasElementSelection.isValidMappingType( bd.handle )
result = false;
return ;
end 

[ configured, selected ] = simulinkcoder.internal.util.CanvasElementSelection.areAnySelectedSignalsNotConfigured( bd.handle );
if ~selected
result = false;
return ;
end 

if strcmp( action, 'connect' )
result = configured;
elseif strcmp( action, 'disconnect' )
result = ~configured;
end 





end 


function result = MACanObserveSignals( editor, ~ )
result = false;

if ~builtin( 'slf_feature', 'get', 'SimHarnessObserver' ) ||  ...
~Simulink.harness.internal.isInstalled ||  ...
~Simulink.harness.internal.licenseTest
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
return ;
end 

selection = editor.getSelection;
if selection.size == 0
return ;
end 
hasSrcPort = false;
for i = 1:selection.size
if ~( isa( selection.at( i ), 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( selection.at( i ) ) )
return ;
else 
port = findSegmentOutputPort( selection.at( i ) );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port ) && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
hasSrcPort = true;
end 
end 
end 

result = hasSrcPort;
end 

function MAObserveSignals( editor, ~ )
selection = editor.getSelection;
prtHdls = zeros( 1, selection.size );
for i = 1:selection.size
port = findSegmentOutputPort( selection.at( i ) );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port ) && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
prtHdls( i ) = port.handle;
end 
end 
prtHdls = setdiff( unique( prtHdls ), 0 );
if isempty( prtHdls )
return ;
end 
Simulink.observer.internal.createObserverMdlAndAddSpecificPorts( gcs, prtHdls, true );
end 


function result = loc_editingVariantSS( editor )
result = false;

ssBlock = editor.getDiagram.getOwningBlock;
if ssBlock.isvalid && ( ssBlock.getSubsystemType == SLM3I.SubsystemType.VARIANT )
result = true;
end 
end 


function result = loc_editingVariantAssembly( editor )
result = false;
if ~loc_editingVariantSS( editor )
return ;
end 
ssBlockHandle = editor.getDiagram.getOwningBlock.handle;
choiceSelector = get_param( ssBlockHandle, DAStudio.message( 'Simulink:VariantBlockPrompts:ChoiceSelectorParamName' ) );
result = ~isempty( choiceSelector );
end 


function result = MACanCreateRectangularObject( editor, marqueeBounds )%#ok<INUSD>
result = false;
if ~editor.isLocked
selection = editor.getSelection;
for i = 1:selection.size
currentItem = selection.at( i );
if ( isa( currentItem, 'SLM3I.Block' ) || isa( currentItem, 'SLM3I.Annotation' ) ) ...
 && SLM3I.Util.isValidDiagramElement( currentItem )
result = true;
break ;
end 
end 
end 
end 

function result = MACanCreateSubsystem( editor, marqueeBounds )
result = MACanCreateRectangularObject( editor, marqueeBounds ) && ~loc_editingVariantAssembly( editor );
end 

function result = MACanCreateEnabledSubsystem( editor, marqueeBounds )
result = MACanCreateRectangularObject( editor, marqueeBounds ) && ~loc_editingVariantSS( editor ) && ~loc_editingVariantAssembly( editor );
end 

function result = MACanCreateTriggeredSubsystem( editor, marqueeBounds )
result = MACanCreateRectangularObject( editor, marqueeBounds ) && ~loc_editingVariantSS( editor ) && ~loc_editingVariantAssembly( editor );
end 

function result = MACanCreateFunctionCallSubsystem( editor, marqueeBounds )
result = MACanCreateRectangularObject( editor, marqueeBounds ) && ~loc_editingVariantSS( editor ) && ~loc_editingVariantAssembly( editor );
end 

function MACreateSubsystem( editor, marqueeBounds )
if MACanCreateSubsystem( editor, marqueeBounds )

SLM3I.SLDomain.createSubsystem( editor, editor.getSelection );
end 
end 

function MACreateEnabledSubsystem( editor, marqueeBounds )
if MACanCreateEnabledSubsystem( editor, marqueeBounds )
SLM3I.SLDomain.createSubsystemWithNewBlock( editor, editor.getSelection,  ...
'simulink/Ports & Subsystems/Enable' );
end 
end 


function MACreateTriggeredSubsystem( editor, marqueeBounds )
if MACanCreateTriggeredSubsystem( editor, marqueeBounds )
SLM3I.SLDomain.createSubsystemWithNewBlock( editor, editor.getSelection,  ...
'simulink/Ports & Subsystems/Trigger' );
end 
end 


function MACreateFunctionCallSubsystem( editor, marqueeBounds )
if MACanCreateFunctionCallSubsystem( editor, marqueeBounds )
SLM3I.SLDomain.createSubsystemWithNewBlock( editor, editor.getSelection,  ...
'simulink/Ports & Subsystems/Function-Call Subsystem/function' );
end 
end 


function [ hasBlock, hasCommentedBlock ] = MAHasCommentedBlock( selection )
hasBlock = false;
hasCommentedBlock = false;
for i = 1:selection.size
if isa( selection.at( i ), 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( selection.at( i ) )
hasBlock = true;
block = selection.at( i );
commented = get_param( block.handle, 'Commented' );
if strcmpi( commented, 'on' )
hasCommentedBlock = true;
break ;
end 
end 
end 
end 


function result = MACanComment( editor, marqueeBounds )%#ok<INUSD>
if editor.isLocked
result = false;
return ;
end 

[ hasBlock, hasCommentedBlock ] = MAHasCommentedBlock( editor.getSelection );
result = hasBlock && ~hasCommentedBlock && ~loc_editingVariantSS( editor );
end 


function result = MACanUncomment( editor, marqueeBounds )%#ok<INUSD>
if editor.isLocked
result = false;
return ;
end 

[ ~, hasCommentedBlock ] = MAHasCommentedBlock( editor.getSelection );
result = hasCommentedBlock && ~loc_editingVariantSS( editor );
end 


function MAComment( editor, marqueeBounds )%#ok<INUSD>
MACommentUncommentHelper( editor.getSelection, true, editor );
end 


function MAUncomment( editor, marqueeBounds )%#ok<INUSD>
MACommentUncommentHelper( editor.getSelection, false, editor );
end 


function MACommentUncommentHelper( selection, comment, editor )
editorDomain = [  ];
if builtin( 'slf_feature', 'get', 'SelectiveParamUndoRedo' ) > 0
if ( ~isempty( editor ) )
editorDomain = editor.getStudio.getActiveDomain;
end 
end 

if ~isempty( editorDomain )

editorDomain.createParamChangesCommand(  ...
editor,  ...
'Simulink:studio:BlockCommenting',  ...
DAStudio.message( 'Simulink:studio:BlockCommenting' ),  ...
@MACommentUncommentHelper_Impl,  ...
{ selection, comment, editorDomain },  ...
false,  ...
false,  ...
false,  ...
true,  ...
true );
else 
MACommentUncommentHelper_Impl( selection, comment, [  ] );
end 
end 

function [ success, noop ] = MACommentUncommentHelper_Impl( selection, comment, editorDomain )
success = true;
noop = false;%#ok
errBlkH = [  ];

numBlks = 0;
for i = 1:selection.size
if isa( selection.at( i ), 'SLM3I.Block' )
numBlks = numBlks + 1;
block = selection.at( i );
blockH = block.handle;
commented = get_param( blockH, 'Commented' );
if strcmpi( commented, 'off' ) && comment
commented = 'on';
elseif strcmpi( commented, 'on' ) && ~comment
commented = 'off';
else 
continue ;
end 

try 
if ( ~isempty( editorDomain ) )
editorDomain.paramChangesCommandAddObject( blockH );
end 

set_param( blockH, 'Commented', commented );
catch 
errBlkH( end  + 1 ) = blockH;%#ok
end 
end 
end 


if ~isempty( errBlkH )
message = [ DAStudio.message( 'Simulink:studio:CommentNotSupported' ), newline, newline ];
for index = 1:length( errBlkH )
message = [ message, strrep( getfullname( errBlkH( index ) ), sprintf( '\n' ), ' ' ), sprintf( '\n' ) ];%#ok
end 
warndlg( message );
end 

noop = ( length( errBlkH ) == numBlks );
end 

function result = MACanCreateBus( editor, ~ )
instance = Simulink.internal.CompositePorts.CreateBusWrapper( editor, editor.getSelection );
result = instance.canExecute;
end 


function MACreateBus( editor, ~ )
instance = Simulink.internal.CompositePorts.CreateBusWrapper( editor, editor.getSelection );
editor.createMCommand( 'Simulink:studio:MACreateBus', DAStudio.message( 'Simulink:studio:MACreateBus' ), @instance.execute, {  } );
end 


function result = MACanRefactorInterface( editor, ~ )
instance = Simulink.internal.CompositePorts.RefactorInterfaceWrapper( editor, editor.getSelection );
result = instance.canExecute;
end 


function MARefactorInterface( editor, ~ )
instance = Simulink.internal.CompositePorts.RefactorInterfaceWrapper( editor, editor.getSelection );
editor.createMCommandWithAdditionalModels( 'Simulink:BusElPorts:RefactorInterface', DAStudio.message( 'Simulink:BusElPorts:RefactorInterface' ), @instance.execute, {  }, instance.getAdditionalModels );
end 

function MACreateArea( editor, marqueeBounds )
if MACanCreateRectangularObject( editor, marqueeBounds )
SLM3I.SLDomain.createArea( editor, marqueeBounds );
end 
end 

function result = MACanRouteLines( editor, marqueeBounds )%#ok<INUSD>
result = false;

if ~builtin( 'slf_feature', 'get', 'ChannelRoutingActions' )
return ;
end 

if editor.isLocked
return ;
end 

selection = editor.getSelection;
for i = 1:selection.size
if ( isa( selection.at( i ), 'SLM3I.Segment' ) )
result = true;
break ;
end 
end 
end 


function MARouteLines( editor, marqueeBounds )
if MACanRouteLines( editor, marqueeBounds )
SLM3I.SLDomain.routeSegments( editor, editor.getSelection, true );
end 
end 

function port = findSegmentEndOutputPort( element, startSegment )
if isa( element, 'SLM3I.Port' ) && strcmp( element.type, 'Out Port' )
port = element;
elseif isa( element, 'SLM3I.SolderJoint' )
inEdges = element.inEdge;
for i = 1:inEdges.size
edge = inEdges.at( i );
if isa( edge, 'SLM3I.Segment' ) && edge ~= startSegment
port = findSegmentOutputPortFromEndpoint( edge, element );
if isa( port, 'SLM3I.Port' )
return ;
end 
end 
end 

outEdges = element.outEdge;
for i = 1:outEdges.size
edge = outEdges.at( i );
if isa( edge, 'SLM3I.Segment' ) && edge ~= startSegment
port = findSegmentOutputPortFromEndpoint( edge, element );
if isa( port, 'SLM3I.Port' )
return ;
end 
end 
end 
else 
port = [  ];
end 
end 

function port = findSegmentOutputPortFromEndpoint( segment, startEndpoint )
port = [  ];
if segment.srcElement ~= startEndpoint
port = findSegmentEndOutputPort( segment.srcElement, segment );
end 
if ~isa( port, 'SLM3I.Port' ) && segment.dstElement ~= startEndpoint
port = findSegmentEndOutputPort( segment.dstElement, segment );
end 
end 

function port = findSegmentOutputPort( segment )
port = findSegmentEndOutputPort( segment.srcElement, segment );
if ~isa( port, 'SLM3I.Port' )
port = findSegmentEndOutputPort( segment.dstElement, segment );
end 
end 

function result = MACanConvertToRequirement( editor, ~ )




result = false;
modelH = bdroot( editor.getDiagram.handle );
if ~dig.isProductInstalled( 'Requirements Toolbox' ) ...
 || ~slreq.utils.isInPerspective( modelH )
result = false;
return ;
end 
elements = editor.getSelection;
for i = 1:elements.size
element = elements.at( i );
if isa( element, 'SLM3I.Annotation' ) ...
 && ~strcmp( element.Type.toString, 'AREA_ANNOTATION' ) ...
 && ~strcmp( element.Type.toString, 'IMAGE_ANNOTATION' )
result = true;
break ;
end 
end 
end 

function MAConvetToRequirement( editor, ~ )
slreq.internal.AnnotationConversionHandler.menuCallback( editor );
end 

function result = MACanStraightenLines( editor, ~ )
result = false;

if ~bitand( slfeature( 'SLLineStraightening' ), 2 ^ 1 )
return ;
end 

if editor.isLocked
return ;
end 

selection = editor.getSelection;
for ii = 1:selection.size
element = selection.at( ii );
if ( isa( element, 'SLM3I.Segment' ) ||  ...
isa( element, 'SLM3I.Block' ) &&  ...
SLM3I.Util.isValidDiagramElement( element ) )
result = true;
break ;
end 
end 
end 

function MAStraightenLines( editor, marqueeBounds )
if MACanStraightenLines( editor, marqueeBounds )
diagram.connector.straighten.sl.straightenSelection( editor, editor.getSelection );
end 
end 


function handles = loc_getBlockHandlesFromSelection( editor )
elements = editor.getSelection;
count = 0;
for i = 1:elements.size
element = elements.at( i );
if isa( element, 'SLM3I.Block' )
count = count + 1;
handles( count ) = element.handle;
end 
end 
end 




function result = MACanPromoteToPanel( editor, ~ )
result = false;


if ( ~SLM3I.SLDomain.areWebPanelsEnabled )
return ;
end 


if ( BindMode.BindMode.isEnabledForEditor( editor ) )
return ;
end 


if ( isempty( editor ) || editor.isLocked )
return ;
end 


elements = editor.getSelection;
for i = 1:elements.size
element = elements.at( i );
if ( SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Block' ) &&  ...
strcmp( get_param( element.handle, 'isCoreWebBlock' ), 'on' ) )
result = true;
return ;
end 
end 
end 



function MAPromoteWebBlocks( editor, ~ )
if MACanPromoteToPanel( editor )
selectedElements = editor.getSelection;
elements = cell( [ 1, selectedElements.size ] );
for i = 1:length( elements )
elements{ i } = selectedElements.at( i );
end 
promoteBlocksToWebPanel( editor, elements );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpilVAgb.p.
% Please follow local copyright laws when handling this file.

