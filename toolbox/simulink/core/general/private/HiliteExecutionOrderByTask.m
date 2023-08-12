
function ret = HiliteExecutionOrderByTask( taskId )

ret = [  ];

studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

if ( ~isempty( studios ) )
st = studios( 1 );
stApp = st.App;
activeEditor = stApp.getActiveEditor;
blockDiagramHandle = activeEditor.blockDiagramHandle;
currentLevelModel = getfullname( blockDiagramHandle );
topLevelModel = getfullname( stApp.topLevelDiagram.handle );
end 


if ( ~isempty( studios ) &&  ...
slfeature( 'TaskBasedSorting' ) > 0 &&  ...
isequal( get_param( topLevelModel, 'ExecutionOrderLegendDisplay' ), 'on' ) )

compName = char( st.getStudioTag + "ssTaskLegend" );
ssComp = st.getComponent( 'GLUE2:SpreadSheet', compName );


if ( ~isempty( ssComp ) && ssComp.isvalid )
ssComp.view( {  } );
ssSource = ssComp.getSource;
ssComp.setComponentUserData( ssSource );

if ( taskId ==  - 2 )
taskId = ssSource.mTaskData( end  ).taskIdx;
end 
for idx = 1:length( ssSource.mTaskData )
if isequal( ssSource.mTaskData( idx ).taskIdx, taskId )
ret = ssSource.handleSelectionChange( ssComp, ssSource.mTaskData( idx ) );
break ;
end 
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvNHtUt.p.
% Please follow local copyright laws when handling this file.

