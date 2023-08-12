function config = slSingleSelectionActionConfig(  )


















































config = [ 
struct( 'name', 'SL.SSA.NavigateToAssociated',  ...
'icon', '/toolbox/shared/dastudio/resources/jumpto_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/jumpto_white.svg',  ...
'checker', @SSACanNavigateToAssociated,  ...
'handler', @SSANavigateToAssociated,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSANavigateToAssociatedElement' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.MA.ConfigureCodeSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/add_signal_quickaction_default_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/add_signal_quickaction_hover_16.svg',  ...
'checker', @MACanConfigureSignalsForCode,  ...
'handler', @MAConfigureSignal,  ...
'tooltip', DAStudio.message( 'coderdictionary:mapping:CodeMapping_AddSignal_Tooltip' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.MA.StopConfiguringCodeSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/remove_signal_quickaction_default_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/remove_signal_quickaction_hover_16.svg',  ...
'checker', @MACanStopConfiguringSignalsForCode,  ...
'handler', @MAStopConfiguringSignal,  ...
'tooltip', DAStudio.message( 'coderdictionary:mapping:CodeMapping_RemoveSignal_Tooltip' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.WidgetEditMode',  ...
'icon', '/toolbox/shared/dastudio/resources/singleSelectWidgetEditModeWhiteBack.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/singleSelectWidgetEditModeBlueBack.png',  ...
'checker', @MACanEnterWidgetEditMode,  ...
'handler', @MAEnterWidgetEditMode,  ...
'tooltip', DAStudio.message( 'CustomWebBlocks:messages:ToggleWidgetEditMode' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.BindModeExit',  ...
'icon', '/toolbox/shared/dastudio/resources/connect_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/connect_white.svg',  ...
'checker', @MAIsConnectExitButtonRequired,  ...
'handler', @MAConnectExitButtonClick,  ...
'tooltip', DAStudio.message( 'SimulinkHMI:HMIBindMode:ExitBindMode' ),  ...
'priority', 'alert' ),  ...
struct( 'name', 'SL.SSA.BindModeToggle',  ...
'icon', '/toolbox/shared/dastudio/resources/connect_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/connect_white.svg',  ...
'checker', @MAIsConnectToggleButtonRequired,  ...
'handler', @MAConnectButtonClick,  ...
'tooltip', DAStudio.message( 'SimulinkHMI:HMIBindMode:ConnectBlock' ),  ...
'priority', 'alert' ),  ...
struct( 'name', 'SL.SSA.BindModeHover',  ...
'icon', '/toolbox/shared/dastudio/resources/connect_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/connect_white.svg',  ...
'checker', @MAIsConnectHoverButtonRequired,  ...
'handler', @MAConnectButtonClick,  ...
'tooltip', DAStudio.message( 'SimulinkHMI:HMIBindMode:ConnectBlock' ),  ...
'priority', 'alert' ),  ...
struct( 'name', 'SL.SSA.BindMode',  ...
'icon', '/toolbox/shared/dastudio/resources/connect_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/connect_white.svg',  ...
'checker', @MAIsConnectButtonRequired,  ...
'handler', @MAConnectButtonClick,  ...
'tooltip', DAStudio.message( 'SimulinkHMI:HMIBindMode:ConnectBlock' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.TraceToCode',  ...
'icon', '/toolbox/shared/dastudio/resources/C_Code_16x16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/C_Code_16x16.svg',  ...
'checker', @MACanTraceToCode,  ...
'handler', @MATraceToCode,  ...
'tooltip', message( 'SimulinkCoderApp:codeperspective:SA_NavigateToCode' ).getString,  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.ShowFullName',  ...
'icon', '/toolbox/shared/dastudio/resources/expanded_notation.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/expanded_notation.svg',  ...
'checker', @MACanShowExpandedNotation,  ...
'handler', @MAShowExpandedNotation,  ...
'tooltip', DAStudio.message( 'Simulink:BusElPorts:ShowExpandedNotation' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.ShowCompactName',  ...
'icon', '/toolbox/shared/dastudio/resources/compact_notation.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/compact_notation.svg',  ...
'checker', @MACanShowCompactNotation,  ...
'handler', @MAShowCompactNotation,  ...
'tooltip', DAStudio.message( 'Simulink:BusElPorts:ShowCompactNotation' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.ParentLayerBindingButton',  ...
'icon', '/toolbox/shared/dastudio/resources/arrow_blue_up.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/arrow_white_up.svg',  ...
'checker', @MAIsParentLayerBindingButtonRequired,  ...
'handler', @MAParentLayerBindingButtonClick,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MABindingIndicator' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.DefaultBindingButton',  ...
'icon', '/toolbox/shared/dastudio/resources/jumpto_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/jumpto_white.svg',  ...
'checker', @MAIsDefaultBindingButtonRequired,  ...
'handler', @MADefaultBindingButtonClick,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MABindingIndicator' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.Comment',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'checker', @MACanComment,  ...
'handler', @MAComment,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAComment' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.Uncomment',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-comment-16.svg',  ...
'checker', @MACanUncomment,  ...
'handler', @MAUncomment,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAUncomment' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.ShowBlockName',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-block-name-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-block-name-16.svg',  ...
'checker', @MACanShowBlockName,  ...
'handler', @MAShowBlockName,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAShowBlockName' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.HideBlockName',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-block-name-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-block-name-16.svg',  ...
'checker', @MACanHideBlockName,  ...
'handler', @MAHideBlockName,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAHideBlockName' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.BlockFitToContent',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-fit-to-content-16.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-fit-to-content-16.png',  ...
'checker', @MABlockNeedsResizeToFitContent,  ...
'handler', @MAResizeBlockToFitContent,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MABlockToFitContent' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.Route',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-16.svg',  ...
'checker', @MACanRoute,  ...
'handler', @MARoute,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MARoute' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.RouteSegmentsOfBlock',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',  ...
'checker', @MACanRouteSegmentsOfBlock,  ...
'handler', @MARouteSegmentsOfBlock,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MARouteLines' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.StreamSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'checker', @MACanStreamSignals,  ...
'handler', @MAStreamSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStreamSignals' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.StopStreamingSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/stream_signals_action.svg',  ...
'checker', @MACanStopStreamingSignals,  ...
'handler', @MAStopStreamingSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStopStreamingSignals' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.JetstreamStreamSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'checker', @MACanStreamSignalsJetstream,  ...
'handler', @MAStreamSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAEnableLogging' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.JetstreamStopStreamingSignals',  ...
'icon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/indicators/JetstreamSignalLog.svg',  ...
'checker', @MACanStopStreamingSignalsJetstream,  ...
'handler', @MAStopStreamingSignals,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MADisableLogging' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.ObserveSignal',  ...
'icon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'hoverIcon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'checker', @MACanObserveSignal,  ...
'handler', @MAObserveSignal,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAObserveSignal' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.SendToObserver',  ...
'icon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'hoverIcon', '/toolbox/shared/simulinktest/resources/icons/icon-enable-observer.svg',  ...
'checker', @MACanSendToObserver,  ...
'handler', @MASendToObserver,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MASendToObserver' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.InjectSignal',  ...
'icon', '/toolbox/shared/simulinktest/resources/icons/injector-quickaction.png',  ...
'hoverIcon', '/toolbox/shared/simulinktest/resources/icons/injector-quickaction-highlight.png',  ...
'checker', @MACanFaultSignal,  ...
'handler', @MAAddFaultOnSignal,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAFaultSignal' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.InjectBlock',  ...
'icon', '/toolbox/shared/simulinktest/resources/icons/injector-quickaction.png',  ...
'hoverIcon', '/toolbox/shared/simulinktest/resources/icons/injector-quickaction-highlight.png',  ...
'checker', @MACanFaultBlock,  ...
'handler', @MAAddFaultOnBlock,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAFaultBlock' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'Error',  ...
'icon', '/toolbox/shared/dastudio/resources/error_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/error_16.svg',  ...
'checker', @MAIsEditTimeError,  ...
'handler', @MAEditTimeIssueErrorPopup,  ...
'tooltip', @MAEditTimeIssueErrorTooltip,  ...
'priority', 'alert' ),  ...
struct( 'name', 'Warning',  ...
'icon', '/toolbox/shared/dastudio/resources/warning_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/warning_16.svg',  ...
'checker', @MAIsEditTimeWarning,  ...
'handler', @MAEditTimeIssueWarningPopup,  ...
'tooltip', @MAEditTimeIssueWarningTooltip,  ...
'priority', 'alert' ),  ...
struct( 'name', 'SL.SSA.HighlightSignalToSrc',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-src-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-src-16.svg',  ...
'checker', @SSA_CanHighlightSignalToSrc,  ...
'handler', @SSA_HighlightSignalToSrc,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSA_HighlightSignalToSource' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.HighlightSignalToDst',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-dst-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-dst-16.svg',  ...
'checker', @SSA_CanHighlightSignalToDst,  ...
'handler', @SSA_HighlightSignalToDst,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSA_HighlightSignalToDestination' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.HighlightSignalConnections',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-connections-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-connections-16.svg',  ...
'checker', @SSA_CanHighlightConnections,  ...
'handler', @SSA_HighlightConnections,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSA_HighlightConnections' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.ReplaceSignalWithGotoFrom',  ...
'icon', '/toolbox/shared/dastudio/resources/signal_replace_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/signal_replace_16.svg',  ...
'checker', @SSACanReplaceSignalWithGotoFrom,  ...
'handler', @SSAReplaceSignalWithGotoFrom,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSAReplaceSignal' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.ReplaceGotoFromWithSignal',  ...
'icon', '/toolbox/shared/dastudio/resources/block_replace_16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/block_replace_16.svg',  ...
'checker', @SSACanReplaceGotoFromWithSignal,  ...
'handler', @SSAReplaceGotoFromWithSignal,  ...
'tooltip', DAStudio.message( 'Simulink:studio:SSAReplaceGotoFrom' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.CleanupInterface',  ...
'icon', '/toolbox/shared/dastudio/resources/cleanup_interface.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/cleanup_interface.svg',  ...
'checker', @SSACanCleanupInterface,  ...
'handler', @SSACleanupInterface,  ...
'tooltip', DAStudio.message( 'Simulink:BusElPorts:CleanupInterface' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.FormatPainter',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-format-painter-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-format-painter-16.svg',  ...
'checker', @MACanStartFormatPainting,  ...
'handler', @MAStartFormatPainting,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAFormatPainter' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.SubSystemBindingButton',  ...
'icon', '/toolbox/shared/dastudio/resources/arrow_blue_down.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/arrow_white_down.svg',  ...
'checker', @MAIsSubSystemBindingButtonRequired,  ...
'handler', @MASubSystemBindingButtonClick,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MABindingIndicator' ),  ...
'priority', 'alert' ),  ...
struct( 'name', 'SL.SSA.SignalAttributeMismatchError',  ...
'icon', '/toolbox/shared/dastudio/resources/error_16.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/error_16.png',  ...
'checker', @MAIsEditTimeSignalAttributeMismatchError,  ...
'handler', @MAEditTimeIssueSignalAttributeMismatchErrorPopup,  ...
'tooltip', @MAEditTimeIssueSignalAttributeMismatchErrorTooltip,  ...
'priority', 'alert' ),  ...
struct( 'name', 'DomainPortTypeError',  ...
'icon', '/toolbox/shared/dastudio/resources/error_16.png',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/error_16.png',  ...
'checker', @MAIsDomainPortTypeError,  ...
'handler', @MADomainPortTypeErrorPopup,  ...
'tooltip', @MADomainPortTypeErrorTooltip,  ...
'priority', 'alert' ),  ...
struct( 'name', 'ConvertAnnotationToRequirement',  ...
'icon', '/toolbox/shared/reqmgt/icons/smartActionBadge.png',  ...
'hoverIcon', '/toolbox/shared/reqmgt/icons/smartActionBadgeHover.png',  ...
'checker', @MACanConvertToRequirement,  ...
'handler', @MAConvetToRequirement,  ...
'tooltip', getString( message( 'Slvnv:slreq:ConvertToRequirement' ) ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.StraightenLines',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-straighten-lines-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-straighten-lines-16.svg',  ...
'checker', @MACanStraightenLines,  ...
'handler', @MAStraightenLines,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAStraightenLines' ),  ...
'priority', 'normal' ),  ...
 ...
struct( 'name', 'SL.SSA.DeletePort',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/singleSelectionDeletePort.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/singleSelectionDeletePort.svg',  ...
'checker', @MACanShowDeletePort,  ...
'handler', @MADeletePort,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MADeletePort' ),  ...
'priority', 'high' ),  ...
struct( 'name', 'SL.SSA.PromoteWebBlockToPanel',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/float_blue.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/float_white.svg',  ...
'checker', @MACanPromoteToPanel,  ...
'handler', @MAPromoteWebBlock,  ...
'tooltip', DAStudio.message( 'simulink_ui:webblocks:resources:SSAPromoteBlockToPanel' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.AddBreakpoint',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-breakpoint-16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-breakpoint-16.svg',  ...
'checker', @SLStudio.internal.actions.MACanAddBreakPoint,  ...
'handler', @SLStudio.internal.actions.MAAddBreakPoint,  ...
'tooltip', DAStudio.message( 'Simulink:studio:AddConditionalPause' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.HighlightEquivalentNodes',  ...
'icon', '/toolbox/shared/dastudio/resources/highlight_connected_nodes.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/highlight_connected_nodes.svg',  ...
'checker', @SSACanShowHighlightEquivalentNodes,  ...
'handler', @SSAHighlightEquivalentNodes,  ...
'tooltip', DAStudio.message( 'Simulink:studio:MAHighlightConnectedNodes' ),  ...
'priority', 'normal' ),  ...
struct( 'name', 'SL.SSA.AddComment',  ...
'icon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',  ...
'hoverIcon', '/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',  ...
'checker', @canShowCommentIcon,  ...
'handler', @ShowComment,  ...
'tooltip', DAStudio.message( 'designreview_comments:Command:AddCommentSingleSelect' ),  ...
'priority', 'normal' )



 ];

end 

function result = MACanTraceToCode( editor, element )
a = simulinkcoder.internal.CodePerspective.getInstance;
src = simulinkcoder.internal.util.getSource( editor );

result = a.getStatus( editor ) &&  ...
isa( element, 'SLM3I.Block' ) &&  ...
strcmpi( get_param( src.modelH, 'IsERTTarget' ), 'on' );

end 
function MATraceToCode( editor, element, ~ )
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

if slfeature( 'IntegratedCodeReport' )
simulinkcoder.internal.util.model2code( modelName, element.handle );
cr = simulinkcoder.internal.Report.getInstance;
cr.focus( editor );
else 
rtwtrace( element.handle );
end 
end 

function result = MACanShowExpandedNotation( editor, element )
result = false;
if editor.isLocked
return ;
end 
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
if localIsCompositePortBlock( element.handle )
parentSS = get_param( element.handle, 'Parent' );
show = get_param( parentSS, 'PortBlocksUseCompactNotation' );
result = strcmpi( show, 'on' );
end 
end 
end 


function result = MACanShowCompactNotation( editor, element )
result = false;
if editor.isLocked
return ;
end 
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
if localIsCompositePortBlock( element.handle )
parentSS = get_param( element.handle, 'Parent' );
show = get_param( parentSS, 'PortBlocksUseCompactNotation' );
result = strcmpi( show, 'off' );
end 
end 
end 

function MAShowExpandedNotation( ~, element, ~ )
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
if localIsCompositePortBlock( element.handle )
parentSS = get_param( element.handle, 'Parent' );
set_param( parentSS, 'PortBlocksUseCompactNotation', 'off' );
end 
end 
end 

function MAShowCompactNotation( ~, element, ~ )
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
if localIsCompositePortBlock( element.handle )
parentSS = get_param( element.handle, 'Parent' );
set_param( parentSS, 'PortBlocksUseCompactNotation', 'on' );
end 
end 
end 

function result = SSACanShowHighlightEquivalentNodes( editor, element )
result = false;
if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
blkType = get_param( element.handle, 'BlockType' );
if strcmpi( blkType, 'ConnectionLabel' )
result = true;
end 
end 
end 


function SSAHighlightEquivalentNodes( editor, element, ~ )
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
if strcmpi( get_param( element.handle, 'BlockType' ), 'ConnectionLabel' )
studio = editor.getStudio(  );
loc_highlightEquivalentNodes( studio, element.handle );
end 
end 
end 




function loc_highlightEquivalentNodes( studio, elementHandle )

selectedBlockLabel = get_param( elementHandle, 'Label' );
parentSubsystem = get_param( elementHandle, 'Parent' );


f = Simulink.FindOptions( 'SearchDepth', 1 );

equivalentBlocks = Simulink.findBlocksOfType( parentSubsystem, 'ConnectionLabel', 'Label', selectedBlockLabel, f );

for i = 1:numel( equivalentBlocks )
diagramObj = diagram.resolver.resolve( equivalentBlocks( i ) );
highlightDuration = 5000;
studio.App.hiliteAndFadeObject( diagramObj, highlightDuration );
end 
end 

function result = SSACanNavigateToAssociated( editor, element )
result = false;
if slfeature( 'NavigateToAssociated' ) > 0 && isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
client = editor.getAssociatedObjectHighlighterClient;
result = client.canDoAction( 'SLNavigateToAssociated', element );
end 
end 

function SSANavigateToAssociated( editor, element, position )
if slfeature( 'NavigateToAssociated' ) > 0 && isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
client = editor.getAssociatedObjectHighlighterClient;
result = client.doAction( 'SLNavigateToAssociated', element, position( 1:2 ) );
end 
end 

function result = MAIsEditTimeWarning( ~, element )
if ~SLM3I.Util.isValidDiagramElement( element )
result = false;
return ;
end 

result = false;
if isa( element, 'SLM3I.Block' ) || isa( element, 'SLM3I.Segment' )
stylerName = 'MathWorks.EditTimeCheckingStyler';
styler = diagram.style.getStyler( stylerName );
if isempty( styler )
return ;
end 

if ( styler.hasClass( element.handle, 'Warn' ) )
result = true;
else 
result = false;
end 
end 
end 

function result = MAIsEditTimeError( ~, element )
if ~SLM3I.Util.isValidDiagramElement( element )
result = false;
return ;
end 

result = false;
if isa( element, 'SLM3I.Block' )
stylerName = 'MathWorks.EditTimeCheckingStyler';
styler = diagram.style.getStyler( stylerName );
if isempty( styler )
return ;
end 

if ( styler.hasClass( element.handle, 'Error' ) )
result = true;
else 
result = false;
end 
end 
end 

function MAEditTimeIssueWarningPopup( editor, element, position )
MAEditTimeIssuePopup( editor, element, position, ModelAdvisor.CheckStatus.Warning );
end 

function tooltip = MAEditTimeIssueWarningTooltip( editor, element, ~ )
tooltip = MAEditTimeIssueTooltip( editor, element, ModelAdvisor.CheckStatus.Warning );
end 

function MAEditTimeIssueErrorPopup( editor, element, position )
MAEditTimeIssuePopup( editor, element, position, ModelAdvisor.CheckStatus.Failed );
end 

function tooltip = MAEditTimeIssueErrorTooltip( editor, element, ~ )
tooltip = MAEditTimeIssueTooltip( editor, element, ModelAdvisor.CheckStatus.Failed );
end 

function result = MAIsEditTimeSignalAttributeMismatchError( ~, element )
result = false;
if ~builtin( 'slf_feature', 'get', 'EditTimeMismatchCheck' )
return ;
end 
if ~SLM3I.Util.isValidDiagramElement( element )
return ;
end 

if isa( element, 'SLM3I.Segment' )
stylerName = 'MathWorks.EditTimeMismatchCheckingStyler';
styler = diagram.style.getStyler( stylerName );
if isempty( styler )
return ;
end 

if ( styler.hasClass( element.handle, 'Error' ) )
result = true;
else 
result = false;
end 
end 
end 

function MAEditTimeIssueSignalAttributeMismatchErrorPopup( editor, element, position )
if builtin( 'slf_feature', 'get', 'EditTimeMismatchCheck' ) > 0
p = Simulink.EditTimeMismatchDialog.Popup( bdroot( editor.getName ), element.handle, position );
p.opendlg( p );
end 
end 

function tooltip = MAEditTimeIssueSignalAttributeMismatchErrorTooltip( ~, element, ~ )
if ~builtin( 'slf_feature', 'get', 'EditTimeMismatchCheck' )
tooltip = '';
else 
tooltip = Simulink.EditTimeMismatchUtils.getAttributeMismatchMsg( element.handle );
end 
end 

function MAEditTimeIssuePopup( editor, element, position, type )
edittime.util.showBlockViolations( bdroot( editor.getName ), element.handle, type );
end 

function result = MAIsDomainPortTypeError( ~, element )
result = false;
if ~builtin( 'slf_feature', 'get', 'PHYSMOD_BUSES' )
return ;
end 
if ~SLM3I.Util.isValidDiagramElement( element )
return ;
end 

if isa( element, 'SLM3I.Segment' )
stylerName = 'SimulinkDefaultDomainStyler';
styler = diagram.style.getStyler( stylerName );
if isempty( styler )
return ;
end 

if ( styler.hasClass( element.handle, 'DefaultConnectivityDomain.ErrorPortType' ) )
result = true;
else 
result = false;
end 
end 
end 

function MADomainPortTypeErrorPopup( ~, ~, ~ )
return 
end 

function tooltip = MADomainPortTypeErrorTooltip( ~, element, ~ )
if ~builtin( 'slf_feature', 'get', 'PHYSMOD_BUSES' )
tooltip = '';
else 
tooltip = DAStudio.message( 'sledittimecheck:edittimecheck:mathworks_simulink_domain_resolved_in_error' );
end 
end 

function tooltip = MAEditTimeIssueTooltip( editor, element, type )
tooltip = edittime.util.getTooltip( bdroot( editor.getName ), element.handle, type );
end 

function isCompositePortBlock = localIsCompositePortBlock( blkHandle )
isCompositePortBlock = false;
bt = get_param( blkHandle, 'BlockType' );
if strcmp( bt, 'Inport' ) || strcmp( bt, 'Outport' )
isCompositePortBlock = strcmpi( get_param( blkHandle, 'IsComposite' ), 'on' );
end 
end 

function result = loc_insideVariantSS( element )
result = false;

ssBlock = element.container.getOwningBlock;
if ssBlock.isvalid && ( ssBlock.getSubsystemType == SLM3I.SubsystemType.VARIANT )
result = true;
end 
end 

function result = MACanComment( editor, element )
result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element ) &&  ...
~localIsCompositePortBlock( element.handle ) && ~loc_insideVariantSS( element )
commented = get_param( element.handle, 'Commented' );
result = ~strcmpi( commented, 'on' );
end 
end 


function result = MACanUncomment( editor, element )
result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element ) &&  ...
~localIsCompositePortBlock( element.handle ) && ~loc_insideVariantSS( element )
commented = get_param( element.handle, 'Commented' );
result = strcmpi( commented, 'on' );
end 
end 

function MAComment( editor, element, ~ )
MAParamsToggleHelper( element, { 'Commented', 'on' },  ...
'Simulink:studio:MAComment', DAStudio.message( 'Simulink:studio:MAComment' ),  ...
DAStudio.message( 'Simulink:studio:CommentNotSupported' ),  ...
editor );
end 


function MAUncomment( editor, element, ~ )
MAParamsToggleHelper( element, { 'Commented', 'off' },  ...
'Simulink:studio:MAUncomment', DAStudio.message( 'Simulink:studio:MAUncomment' ),  ...
DAStudio.message( 'Simulink:studio:UncommentNotSupported' ),  ...
editor );
end 


function result = MACanShowBlockName( editor, element )

result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
show = get_param( element.handle, 'ShowName' );
if strcmpi( show, 'off' ) || simulink.diagram.internal.isNameHiddenAutomatically( element.handle )
result = true;
end 
end 
end 

function result = MACanHideBlockName( editor, element )

result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
show = get_param( element.handle, 'ShowName' );
if strcmpi( show, 'on' ) && ~simulink.diagram.internal.isNameHiddenAutomatically( element.handle )
result = true;
end 
end 
end 

function MAShowBlockName( editor, element, ~ )

MAParamsToggleHelper( element,  ...
{ 'ShowName', 'on', 'HideAutomaticName', 'off' },  ...
'Simulink:studio:MAShowBlockName', DAStudio.message( 'Simulink:studio:MAShowBlockName' ),  ...
DAStudio.message( 'Simulink:studio:MAShowBlockNameNotSupported' ),  ...
editor );
end 


function MAHideBlockName( editor, element, ~ )

MAParamsToggleHelper( element,  ...
{ 'ShowName', 'off', 'HideAutomaticName', 'on' },  ...
'Simulink:studio:MAHideBlockName', DAStudio.message( 'Simulink:studio:MAHideBlockName' ),  ...
DAStudio.message( 'Simulink:studio:MAHideBlockNameNotSupported' ),  ...
editor );
end 

function result = canShowCommentIcon( editor, element, ~ )
result = false;
if ( slfeature( 'DesignReview_Comments' ) > 0 && simulink.designreview.DesignReviewApp.getInstance(  ).isCommentsAppOpen( bdroot( editor.getName ) ) )
if ( isa( element, 'SLM3I.Block' ) ...
 && SLM3I.Util.isValidDiagramElement( element ) ...
 && simulink.designreview.Util.isCommentsSupportedInEditor( editor ) )
result = true;
end 
end 
end 

function ShowComment( editor, ~, ~ )
blk = simulink.designreview.Util.getSelectedBlock( editor );
model = get_param( editor.getStudio.App.blockDiagramHandle, 'Name' );
simulink.designreview.CommentsApi.addCommentForSingleSelect( model, blk );
end 

function result = MABlockNeedsResizeToFitContent( editor, element )
result = false;
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
result = SLM3I.SLDomain.blockNeedsResizeToFitContent( editor, element );
end 
end 

function MAResizeBlockToFitContent( editor, element, ~ )
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element )
SLM3I.SLDomain.resizeBlockToFitContent( editor, element );
end 
end 

function result = MACanRoute( editor, element )
result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element ) && ~loc_insideVariantSS( element.container )
result = true;
end 
end 

function MARoute( editor, element, ~ )
if MACanRoute( editor, element )
SLM3I.SLDomain.routeSegment( editor, element );
end 
end 


function result = MACanRouteSegmentsOfBlock( editor, element )
result = false;

if ~builtin( 'slf_feature', 'get', 'ChannelRoutingActions' )
return ;
end 

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element ) && ~loc_insideVariantSS( element )
if ~element.inputPort.isEmpty || ~element.outputPort.isEmpty
result = true;
end 
end 
end 

function MARouteSegmentsOfBlock( editor, element, ~ )
if MACanRouteSegmentsOfBlock( editor, element )
SLM3I.SLDomain.routeSegmentsOfBlock( editor, element );
end 
end 

function result = MACanStreamSignals( ~, ~ )

result = false;
end 

function result = MACanConfigureSignalsForCode( editor, element )
result = MACanConfigureSignalsForCodeImpl( editor, element, 'connect' );
end 

function result = MACanStopConfiguringSignalsForCode( editor, element )
result = MACanConfigureSignalsForCodeImpl( editor, element, 'disconnect' );
end 

function result = MACanConfigureSignalsForCodeImpl( editor, element, action )
result = false;
model = get( bdroot( editor.getDiagram.handle ), 'object' );
cp = simulinkcoder.internal.CodePerspective.getInstance;
if cp.isInPerspective( model.handle ) &&  ...
isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port )
if ~simulinkcoder.internal.util.CanvasElementSelection.isValidMappingType( model.handle )
result = false;
return ;
end 

configured = simulinkcoder.internal.util.CanvasElementSelection.isConfiguredForCode( model.handle, port.handle );
if strcmp( action, 'connect' )
result = ~configured;
elseif strcmp( action, 'disconnect' )
result = configured;
end 
end 
end 





end 

function MAConfigureSignal( editor, element, ~ )
model = get( bdroot( editor.getDiagram.handle ), 'Handle' );
port = SLStudio.internal.actions.findSegmentOutputPort( element );
simulinkcoder.internal.util.CanvasElementSelection.addSignal( model, port.handle );
end 

function MAStopConfiguringSignal( editor, element, ~ )
model = get( bdroot( editor.getDiagram.handle ), 'Handle' );
port = SLStudio.internal.actions.findSegmentOutputPort( element );
simulinkcoder.internal.util.CanvasElementSelection.removeSignal( model, port.handle );
end 

function result = MACanStreamSignalsJetstream( editor, element )
result = MACanStreamSignalsImpl( editor, element, 'connect' );
end 

function MAStreamSignals( editor, element, ~ )
if MACanStreamSignals( editor, element ) || MACanStreamSignalsJetstream( editor, element )
MAStreamSignalsImpl( editor, element, 'connect' );
end 
end 

function result = MACanStopStreamingSignals( ~, ~ )

result = false;
end 

function result = MACanStopStreamingSignalsJetstream( editor, element )
result = MACanStreamSignalsImpl( editor, element, 'disconnect' );
end 

function MAStopStreamingSignals( editor, element, ~ )
if MACanStopStreamingSignals( editor, element ) || MACanStopStreamingSignalsJetstream( editor, element )
MAStreamSignalsImpl( editor, element, 'disconnect' );
end 
end 

function result = MACanStreamSignalsImpl( editor, element, action )
result = false;
model = get( editor.getStudio(  ).App.blockDiagramHandle, 'object' );
if isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port )
streamed = Simulink.sdi.internal.SignalObserverMenu.hasVisuOnPort( port.handle, model.Name );
if strcmp( action, 'connect' )
result = ~streamed;
elseif strcmp( action, 'disconnect' )
result = streamed;
end 
end 
end 


if result && editor.isLocked
result = strcmpi( get_param( model.handle, 'LibraryType' ), 'None' );
end 
end 

function MAStreamSignalsImpl( editor, element, action )
model = get( bdroot( editor.getDiagram.handle ), 'object' );
cbinfo.isContextMenu = false;
cbinfo.uiObject = element;
cbinfo.model = model;
cbinfo.userdata.model = model.name;
cbinfo.userdata.action = action;
port = SLStudio.internal.actions.findSegmentOutputPort( element );
cbinfo.userdata.portHs = [ port.handle ];
Simulink.sdi.internal.SignalObserverMenu.ConnectSignal( cbinfo );
end 

function result = MACanEnterWidgetEditMode( editor, element )
result = false;
if editor.isLocked
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if ( BindMode.BindMode.isEnabled( model ) )
return ;
end 
if isprop( element, 'type' )
result = strcmp( element.type, 'CustomWebBlock' ) ||  ...
strcmp( element.type, 'CustomTuningWebBlock' ) ||  ...
strcmp( element.type, 'CustomStandaloneWebBlock' );
end 
end 

function MAEnterWidgetEditMode( editor, element, ~ )
if utils.isWebBlock( element.handle )
SLM3I.SLCommonDomain.setWidgetEditModeForEditor( editor, element.handle, true );
end 
end 

function result = MACanObserveSignal( editor, element )
result = false;

if ~builtin( 'slf_feature', 'get', 'SimHarnessObserver' ) ||  ...
~Simulink.harness.internal.isInstalled ||  ...
~Simulink.harness.internal.licenseTest
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port ) && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
result = true;
end 
end 
end 

function MAObserveSignal( ~, element, ~ )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if port.handle ~=  - 1 && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
try 
Simulink.observer.internal.createObserverMdlAndAddSpecificPorts( gcs, port.handle, true );
catch ME
Simulink.observer.internal.error( ME, true, 'Simulink:Observer:ObserverStage', getfullname( gcs ) );
end 
end 
end 

function result = MACanSendToObserver( editor, element )
result = false;
if ~builtin( 'slf_feature', 'get', 'SimHarnessObserver' ) ||  ...
~Simulink.harness.internal.isInstalled ||  ...
~Simulink.harness.internal.licenseTest
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
portHandles = get_param( element.handle, 'PortHandles' );
blkType = get_param( element.handle, 'BlockType' );
result = sltest.internal.menus.isBlockCompatibleForSendToObserver( portHandles, blkType );
end 
end 

function MASendToObserver( ~, element, ~ )
try 
Simulink.observer.internal.sendBlockToObserver( element.handle, '', true );
catch ME
Simulink.observer.internal.error( ME, true, 'Simulink:Observer:ObserverStage', getfullname( gcs ) );
end 
end 


function result = MACanFaultSignal( editor, element )
result = false;

if ~builtin( 'slf_feature', 'get', 'SLTInjector' )
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if isa( port, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( port ) && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
result = true;
end 
end 
end 

function MAAddFaultOnSignal( editor, element, ~ )
port = SLStudio.internal.actions.findSegmentOutputPort( element );
if port.handle ~=  - 1 && strcmp( get_param( port.handle, 'PortType' ), 'outport' )
topModelHandle = editor.getStudio(  ).App.blockDiagramHandle;
safety.gui.dialog.createFaultDialog.create( topModelHandle, port.handle );
end 
end 

function result = MACanFaultBlock( editor, element )
result = false;

if ~builtin( 'slf_feature', 'get', 'SLTBlockInjector' )
return ;
end 

model = get( bdroot( editor.getDiagram.handle ), 'object' );
if isa( element, 'SLM3I.Block' ) && SLM3I.Util.isValidDiagramElement( element ) && ~SLM3I.SLDomain.isBdContainingGraphCompiled( model.handle ) ...
 && ( element.isModelReference || ( element.isSubsystem && strcmp( get_param( element.handle, 'TreatAsAtomicUnit' ), 'on' ) ) )
portHandles = get_param( element.handle, 'PortHandles' );
prtArrayOut = [ portHandles.Outport, portHandles.State ];
if ~isempty( prtArrayOut )
result = true;
end 
end 
end 

function MAAddFaultOnBlock( editor, element, ~ )
topModelHandle = editor.getStudio(  ).App.blockDiagramHandle;
safety.gui.dialog.createFaultDialog.create( topModelHandle, element.handle );
end 

function MAParamsToggleHelper( element, paramNameValues, commandName, commandNameTranslated, errorMsg, editor )
editorDomain = [  ];
if builtin( 'slf_feature', 'get', 'SelectiveParamUndoRedo' ) > 0
if ( ~isempty( editor ) )
editorDomain = editor.getStudio.getActiveDomain;
end 
end 

if ~isempty( editorDomain )

editorDomain.createParamChangesCommand(  ...
editor,  ...
commandName,  ...
commandNameTranslated,  ...
@MAParamsToggleHelperImpl,  ...
{ element, paramNameValues, errorMsg, editorDomain },  ...
false,  ...
false,  ...
false,  ...
true,  ...
true );
else 
MAParamsToggleHelperImpl( element, paramNameValues, errorMsg, [  ] );
end 
end 

function [ success, noop ] = MAParamsToggleHelperImpl( element, paramNameValues, errorMsg, editorDomain )
success = true;
noop = false;

handle = element.handle;
block = element;
if isa( element, 'SLM3I.Port' )
block = element.container;
end 

try 
if ( ~isempty( editorDomain ) )
editorDomain.paramChangesCommandAddObject( block.handle );
end 
set_param( handle, paramNameValues{ : } );
catch 
message = [ errorMsg, newline, newline ];
message = [ message, strrep( getfullname( block.handle ), newline, ' ' ), newline ];
title = DAStudio.message( 'Simulink:editor:DialogWarning' );
d = DAStudio.DialogProvider;
d.warndlg( message, title, true );
noop = true;
end 

end 

function result = SSA_CanHighlightSignalToSrc( ~, element )
result = SSA_CanHighlightSignal( element );
end 

function result = SSA_CanHighlightSignalToDst( ~, element )
result = SSA_CanHighlightSignal( element );
end 

function result = SSA_CanHighlightSignal( element )
if ~isa( element, 'SLM3I.Segment' ) ||  ...
get_param( loc_getRoot( element.handle ), 'ModelSlicerActive' )
result = false;
return 
end 

result = strcmpi( get_param( element.handle, 'LineType' ), 'signal' );
end 

function result = SSA_CanHighlightConnections( ~, element )
if ~isa( element, 'SLM3I.Segment' )
result = false;
return 
end 

result = strcmpi( get_param( element.handle, 'LineType' ), 'connection' );
end 

function SSA_HighlightSignalToSrc( ~, element, ~ )
Simulink.Structure.HiliteTool.AppManager.HighlightSignalToSource( element.handle );
end 

function SSA_HighlightSignalToDst( ~, element, ~ )
Simulink.Structure.HiliteTool.AppManager.HighlightSignalToDestination( element.handle );
end 

function SSA_HighlightConnections( editor, element, ~ )
bdHandle = loc_getRoot( editor.getDiagram.handle );
SLStudio.Utils.RemoveHighlighting( bdHandle );

elements = builtin( '_connection_line_tracing', [ element.handle ] );

SLStudio.EmphasisStyleSheet.applyStyler( bdHandle, elements );
end 

function loc_doHighlight( studio, hiliteInfo, bdHandle )
hiliteMap = hiliteInfo.graphHighlightMap;
participatingGraphHandles = [ hiliteMap{ :, 1 } ];
termGraphHandle = hiliteInfo.termGraphHandle;

allElements = [  ];

for i = 1:length( participatingGraphHandles )
uddObj = get( participatingGraphHandles( i ), 'Object' );
sysName = uddObj.getFullName;
editors = GLUE2.Util.findAllEditors( sysName );

if ( participatingGraphHandles( i ) == termGraphHandle )
if ( loc_ShowGraphContents( participatingGraphHandles( i ) ) )
if ( isempty( editors ) )
studio.App.setEditorOpenType( 'NEW_TAB' );
load_system( sysName );
diagramInfo = SLM3I.Util.getDiagram( sysName );
studio.App.openEditor( diagramInfo.diagram );
studio.App.restoreEditorOpenType;
editors = GLUE2.Util.findEditor( sysName, studio );
assert( ~isempty( editors ) );
else 
diffStudio = [  ];
for j = 1:length( editors )
e = editors( j );
s = e.getStudio;
if ( s.isComponentVisible( e ) && ( s ~= studio ) )
diffStudio = s;
end 
end 
if ( ~isempty( diffStudio ) )
diffStudio.App.openEditor( editors( 1 ).getDiagram );
else 
studio.App.setEditorOpenType( 'NEW_TAB' );
studio.App.openEditor( editors( 1 ).getDiagram );
studio.App.restoreEditorOpenType;
end 
end 
end 
end 



if ( loc_ShowGraphContents( participatingGraphHandles( i ) ) )
allElements = [ allElements, hiliteMap{ i, 2 } ];%#ok<AGROW>
end 
end 

SLStudio.EmphasisStyleSheet.applyStyler( bdHandle, allElements );
end 

function result = SSACanReplaceSignalWithGotoFrom( editor, element )
result = false;
if slfeature( 'ReplaceSignalWithFromAndGoto' ) > 0 && SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Segment' )
client = editor.getAssociatedObjectHighlighterClient;
result = client.canDoAction( 'ReplaceSignalWithFromAndGoto', element );
end 
end 

function SSAReplaceSignalWithGotoFrom( editor, element, ~ )
if slfeature( 'ReplaceSignalWithFromAndGoto' ) > 0 && SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Segment' )
client = editor.getAssociatedObjectHighlighterClient;
result = client.doAction( 'ReplaceSignalWithFromAndGoto', element );
end 
end 

function result = SSACanReplaceGotoFromWithSignal( editor, element )
result = false;
if slfeature( 'ReplaceSignalWithFromAndGoto' ) > 0 && SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Block' )
blkType = get_param( element.handle, 'BlockType' );
if strcmp( blkType, 'From' ) || strcmp( blkType, 'Goto' )
client = editor.getAssociatedObjectHighlighterClient;
result = client.canDoAction( 'ReplaceFromOrGotoWithSignal', element );
end 
end 
end 

function SSAReplaceGotoFromWithSignal( editor, element, ~ )
if slfeature( 'ReplaceSignalWithFromAndGoto' ) > 0 && SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Block' )
client = editor.getAssociatedObjectHighlighterClient;
result = client.doAction( 'ReplaceFromOrGotoWithSignal', element );
end 
end 

function ret = loc_ShowGraphContents( graphHandle )
ret = true;


if ( ~strcmpi( get( graphHandle, 'Type' ), 'block' ) )
return ;
end 



if ( strcmpi( get( graphHandle, 'MaskHideContents' ), 'on' ) )
ret = false;
end 

end 

function bdHandle = loc_getRoot( initialHandle )
bdHandle = initialHandle;

done = false;
while ~done
parent = get_param( bdHandle, 'Parent' );

if strcmp( parent, '' )
done = true;
else 
done = false;
bdHandle = get_param( parent, 'handle' );
end 
end 
end 

function result = SSACanCleanupInterface( editor, element, ~ )
result = false;

if editor.isLocked
return ;
end 

if SLM3I.Util.isValidDiagramElement( element )
seq = GLUE2.SequenceOfDiagramElement.makeUnique( editor.getDiagram.model );
seq.append( element );
instance = Simulink.internal.CompositePorts.CleanupInterfaceWrapper( editor, seq );
result = instance.canExecute(  );
end 
end 

function SSACleanupInterface( editor, element, ~ )
seq = GLUE2.SequenceOfDiagramElement.makeUnique( editor.getDiagram.model );
seq.append( element );
instance = Simulink.internal.CompositePorts.CleanupInterfaceWrapper( editor, seq );
editor.createMCommand( 'Simulink:BusElPorts:CleanupInterface', DAStudio.message( 'Simulink:BusElPorts:CleanupInterface' ), @instance.execute, {  } );
end 

function result = MACanStartFormatPainting( editor, element )
result = false;

if editor.isLocked
return ;
end 

if SLM3I.Util.isValidDiagramElement( element ) && SLM3I.SLDomain.hasFormattingData( element )
result = true;
end 
end 

function MAStartFormatPainting( editor, element, ~ )
editor.sendMessageToToolsWithDiagramElement( 'SLInitiateFormatPainting', element );
end 

function result = MAIsSubSystemBindingButtonRequired( editor, element )


result = false;
if ( SLM3I.Util.isValidDiagramElement( element ) && isa( element, 'SLM3I.Block' ) )
if ( strcmp( get_param( element.handle, 'BlockType' ), 'SubSystem' ) )
if ( strcmp( get_param( element.handle, 'IsWebBlock' ), 'off' ) )
model = get( bdroot( editor.getDiagram.handle ), 'object' );
result = Simulink.HMI.hasBoundElementInSubsystem( model.handle, element.handle );
end 
end 
end 
end 

function MASubSystemBindingButtonClick( editor, element, ~ )
isSubsystem = true;
utils.jumpToBoundElement( editor, element, isSubsystem );
end 

function result = MAIsParentLayerBindingButtonRequired( editor, element )


result = false;
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( isa( element, 'SLM3I.Block' ) || isa( element, 'SLM3I.Segment' ) )
model = get( bdroot( editor.getDiagram.handle ), 'object' );
modelHandle = model.Handle;
boundElemHandle = Simulink.HMI.getParentLayerBoundElem( modelHandle, element.handle );
if ( boundElemHandle ~=  - 1 )
result = true;
end 
end 
end 
end 

function MAParentLayerBindingButtonClick( editor, element, ~ )
utils.jumpToBoundElement( editor, element );
end 

function result = MAIsDefaultBindingButtonRequired( editor, element )


result = false;
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( isa( element, 'SLM3I.Block' ) || isa( element, 'SLM3I.Segment' ) )
model = get( bdroot( editor.getDiagram.handle ), 'object' );
modelHandle = model.Handle;
if ( Simulink.HMI.getParentLayerBoundElem( modelHandle, element.handle ) ==  - 1 &&  ...
Simulink.HMI.getDefaultBoundElement( modelHandle, element.handle ) ~=  - 1 )
result = true;
end 
end 
end 
end 

function MADefaultBindingButtonClick( editor, element, ~ )
utils.jumpToBoundElement( editor, element );
end 

function result = MAIsConnectExitButtonRequired( editor, element )
result = false;
if ( ~BindMode.BindMode.isEnabledForEditor( editor ) )
return ;
end 
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( isa( element, 'SLM3I.Block' ) )
if ( utils.isWebBlock( element.handle ) )
bindModeObj = BindMode.BindMode.getInstance;
if ( ~isempty( bindModeObj ) )
bindModeSourceElementHandle = bindModeObj.bindModeSourceDataObj.sourceElementHandle;
if ( bindModeSourceElementHandle == element.handle )
result = true;
end 
end 
end 
end 
end 
end 

function MAConnectExitButtonClick( editor, ~, ~ )
model = get_param( editor.getStudio(  ).App.blockDiagramHandle, 'object' );
BindMode.BindMode.disableBindMode( model );
end 

function result = MAIsConnectToggleButtonRequired( editor, element )
result = false;
if ( ~BindMode.BindMode.isEnabledForEditor( editor ) )
return ;
end 
model = get( bdroot( editor.getDiagram.handle ), 'object' );
if ( Simulink.HMI.isLibrary( model.Name ) || utils.isLockedLibrary( model.Name ) )
return ;
end 

if ( ~isequal( model.SimulationStatus, 'stopped' ) )
return ;
end 
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( isa( element, 'SLM3I.Block' ) )
if ( utils.isWebBlock( element.handle ) )
bindingType = utils.getWidgetBindingType( element.handle );
if ( ~strcmp( bindingType, 'Standalone' ) && ~strcmp( bindingType, 'unknown' ) )
bindModeObj = BindMode.BindMode.getInstance;
if ( ~isempty( bindModeObj ) )
bindModeSourceElementHandle = bindModeObj.bindModeSourceDataObj.sourceElementHandle;
if ( bindModeSourceElementHandle ~= element.handle )
result = true;
end 
end 
end 
end 
end 
end 
end 

function result = MAIsConnectHoverButtonRequired( editor, element )

result = false;
model = get( bdroot( editor.getDiagram.handle ), 'object' );
if ( isequal( model.SimulationStatus, 'running' ) || Simulink.HMI.isLibrary( model.Name ) || utils.isLockedLibrary( model.Name ) )
return ;
end 

if ( ~isequal( model.SimulationStatus, 'stopped' ) )
return ;
end 
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( ~BindMode.BindMode.isEnabledForEditor( editor ) )
if ( isa( element, 'SLM3I.Block' ) )
if ( utils.isWebBlock( element.handle ) )
bindingType = utils.getWidgetBindingType( element.handle );
if ( ~strcmp( bindingType, 'Standalone' ) && ~strcmp( bindingType, 'unknown' ) )
if ( ~utils.isBound( element.handle ) )
result = true;
end 
end 
end 
end 
end 
end 
end 

function result = MAIsConnectButtonRequired( editor, element )

result = false;
model = get( bdroot( editor.getDiagram.handle ), 'object' );
if ( Simulink.HMI.isLibrary( model.Name ) || utils.isLockedLibrary( model.Name ) )
return ;
end 

if ( ~isequal( model.SimulationStatus, 'stopped' ) )
return ;
end 
if ( SLM3I.Util.isValidDiagramElement( element ) )
if ( ~BindMode.BindMode.isEnabledForEditor( editor ) )
if ( isa( element, 'SLM3I.Block' ) )
if ( utils.isWebBlock( element.handle ) )
bindingType = utils.getWidgetBindingType( element.handle );
if ( ~strcmp( bindingType, 'Standalone' ) && ~strcmp( bindingType, 'unknown' ) )
if ( utils.isBound( element.handle ) )
result = true;
end 
end 
end 
end 
end 
end 
end 

function MAConnectButtonClick( editor, element, ~ )
utils.HMIBindMode.toggleBindMode( editor, element );
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
 && ~strcmpi( element.Type.toString, 'AREA_ANNOTATION' ) ...
 && ~strcmp( element.Type.toString, 'IMAGE_ANNOTATION' )

result = true;
break ;
end 
end 
end 

function MAConvetToRequirement( editor, ~, ~ )
slreq.internal.AnnotationConversionHandler.menuCallback( editor );
end 

function result = MACanStraightenLines( editor, element )
result = false;

if ~bitand( builtin( 'slf_feature', 'get', 'SLLineStraightening' ), 2 ^ 0 )
return ;
end 

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Segment' ) && SLM3I.Util.isValidDiagramElement( element )
result = true;
end 
end 

function MAStraightenLines( editor, element, ~ )
if MACanStraightenLines( editor, element )
diagram.connector.straighten.sl.straightenDiagramElement( editor, element );
end 
end 



function result = MACanPromoteToPanel( editor, element )
result = false;


if ( ~SLM3I.SLDomain.areWebPanelsEnabled )
return ;
end 


if ( BindMode.BindMode.isEnabledForEditor( editor ) )
return ;
end 



if ( isempty( editor ) || editor.isLocked ||  ...
~SLM3I.Util.isValidDiagramElement( element ) || ~isa( element, 'SLM3I.Block' ) )
return ;
end 

if ( strcmp( get_param( element.handle, 'isCoreWebBlock' ), 'on' ) )
result = true;
end 
end 



function MAPromoteWebBlock( editor, element, ~ )
if MACanPromoteToPanel( editor, element )
elements = { element };
promoteBlocksToWebPanel( editor, elements );
end 
end 

function result = MACanShowDeletePort( editor, element )
result = false;

if editor.isLocked
return ;
end 

if isa( element, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( element ) && slfeature( 'PortSingleSelectionAction' )
block = get_param( element.handle, 'parent' );
if strcmp( get_param( get_param( block, 'Handle' ), 'BlockType' ), 'SimscapeBus' ) && SLM3I.Util.isPortDeleteable( element )
result = true;
end 
elseif isa( element, 'SLM3I.Port' ) && SLM3I.Util.isValidDiagramElement( element ) && slfeature( 'PortSelection' )
block = get_param( element.handle, 'parent' );
if strcmp( get_param( get_param( block, 'Handle' ), 'BlockType' ), 'SubSystem' )
result = true;
end 
end 
end 

function MADeletePort( editor, element, ~ )
if MACanShowDeletePort( editor, element )
block = get_param( element.handle, 'parent' );
if strcmp( get_param( get_param( block, 'Handle' ), 'BlockType' ), 'SimscapeBus' )
editor.sendMessageToToolsWithDiagramElement( 'SLPreDeletePort', element );
SLM3I.Util.deletePortOnBlock( element.handle );
elseif strcmp( get_param( get_param( block, 'Handle' ), 'BlockType' ), 'SubSystem' )
editor.sendMessageToToolsWithDiagramElement( 'SLPortDeletionSingleSelectionAction', element );
end 

end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpnsp3By.p.
% Please follow local copyright laws when handling this file.

