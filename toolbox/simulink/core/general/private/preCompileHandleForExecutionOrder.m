function preCompileHandleForExecutionOrder( mdlName )


studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
hlocal = Simulink.SampleTimeLegend;

if ( ~isempty( studios ) )
st = studios( 1 );
stApp = st.App;
activeEditor = stApp.getActiveEditor;
blockDiagramHandle = activeEditor.blockDiagramHandle;
if ~blockDiagramHandle
return ;
end 
currentLevelModel = getfullname( blockDiagramHandle );
topLevelModel = getfullname( stApp.topLevelDiagram.handle );

if ( slfeature( 'TaskBasedSorting' ) > 0 &&  ...
isequal( get_param( topLevelModel, 'ExecutionOrderLegendDisplay' ), 'on' ) &&  ...
isequal( mdlName, currentLevelModel ) )
hlocal.clearHilite( mdlName, 'task' );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjJutar.p.
% Please follow local copyright laws when handling this file.

