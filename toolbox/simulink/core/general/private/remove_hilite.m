function remove_hilite( model )











mdl = get_param( model, 'Object' );
if ~isa( mdl, 'Simulink.BlockDiagram' )
return 
end 

if strcmp( get_param( model, 'ReqHilite' ), 'on' )



set_param( model, 'ReqHilite', 'off' );
return ;
end 


if exist( 'vnvcallback', 'file' )
vnvcallback( 'unhighlight', model );
end 


if exist( 'exectime_profiling_callback', 'file' )
coder.profile.AnnotateManager.tearDownIntegratedView( mdl.Name );
end 


am = Advisor.Manager.getInstance;
allApplications = am.ApplicationObjMap.values;
for i = 1:length( allApplications )
mdladvObj = allApplications{ i }.getRootMAObj(  );
if isa( mdladvObj, 'Simulink.ModelAdvisor' ) && isprop( mdladvObj, 'ResultGUI' ) && isa( mdladvObj.ResultGUI, 'DAStudio.Informer' ) ...
 && strcmp( bdroot( mdladvObj.SystemName ), bdroot( getfullname( model ) ) )
modeladvisorprivate( 'modeladvisorutil2', 'CloseResultGUI', mdladvObj.SystemName );
break ;
end 
end 


set_param( model, 'HiliteAncestors', 'off' );


hlocal = Simulink.SampleTimeLegend;
modelIndex = find( strcmp( mdl.Name, hlocal.modelList ) );
if ( ~isempty( modelIndex ) )
modelIndex = modelIndex( 1 );
end 

if ( ~isempty( modelIndex ) && length( hlocal.modelLegendState ) >= modelIndex &&  ...
isequal( hlocal.modelLegendState{ modelIndex }, 'on' ) )
studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
if ( ~isempty( studios ) )
st = studios( 1 );
stApp = st.App;
activeEditor = stApp.getActiveEditor;
blockDiagramHandle = activeEditor.blockDiagramHandle;
currentLevelModel = getfullname( blockDiagramHandle );
hlocal.clearHilite( currentLevelModel );
end 
end 



sltp.internal.clear_hilite( mdl.Handle );


if SLM3I.SLCommonDomain.isStateflowLoaded(  )
sfprivate( 'sf_remove_hilite', mdl.Name );
end 


h = mdl.find( '-isa', 'Simulink.Annotation' );
set( h, 'HiliteAncestors', 0 );


slprivate( 'open_and_hilite_port_hyperlink', 'clear', model )






Simulink.ID.hilite( '' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJS1G2B.p.
% Please follow local copyright laws when handling this file.

