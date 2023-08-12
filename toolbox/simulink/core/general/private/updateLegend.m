function updateLegend( mdlName )



studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;


if ( ~isempty( studios ) )
st = studios( 1 );
stApp = st.App;
activeEditor = stApp.getActiveEditor;
blockDiagramHandle = activeEditor.blockDiagramHandle;
if ~blockDiagramHandle
return ;
end 
currentLevelModel = getfullname( blockDiagramHandle );


if strcmp( get_param( mdlName, 'isObserverBD' ), 'on' )
currentLevelModel = mdlName;
end 
topLevelModel = getfullname( stApp.topLevelDiagram.handle );

if ( ~strcmp( currentLevelModel, mdlName ) )
return ;
end 
end 

hlocal = Simulink.SampleTimeLegend;
tab_cont = strmatch( mdlName, hlocal.modelList, 'exact' );

if ( ~isempty( tab_cont ) && length( hlocal.modelLegendState ) >= tab_cont ...
 && isequal( hlocal.modelLegendState{ tab_cont }, 'on' ) )
hlocal.showLegend( mdlName );
end 




if ( ~isempty( studios ) &&  ...
slfeature( 'TaskBasedSorting' ) > 0 &&  ...
isequal( get_param( topLevelModel, 'ExecutionOrderLegendDisplay' ), 'on' ) &&  ...
isequal( mdlName, currentLevelModel ) )

warningStruct = warning( 'off', 'Simulink:Engine:CompileNeededForSampleTimes' );
LegendData = get_param( mdlName, 'SampleTimes' );
warning( warningStruct.state, 'Simulink:Engine:CompileNeededForSampleTimes' );

if ( ~isempty( LegendData ) )
hlocal.clearHilite( mdlName, 'task' );
Simulink.STOSpreadSheet.SortedOrder.launchExecutionOrderViewer( st );
else 
set_param( topLevelModel, 'ExecutionOrderLegendDisplay', 'off' );
end 
end 




if ( ~isempty( studios ) && isequal( get_param( topLevelModel, 'NVBlockReducedDisplay' ), 'on' ) )
st = studios( 1 );
stApp = st.App;
activeEditor = stApp.getActiveEditor;
blockDiagramHandle = activeEditor.blockDiagramHandle;
if ~blockDiagramHandle
return ;
end 
blks = get_param( topLevelModel, 'ReducedNonVirtualBlockList' );
cbinfo.studio = st;
Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.HighlightElements( cbinfo, stApp.topLevelDiagram.handle, blockDiagramHandle, blks );
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVfHDcH.p.
% Please follow local copyright laws when handling this file.

