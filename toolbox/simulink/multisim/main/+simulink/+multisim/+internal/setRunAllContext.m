function setRunAllContext( modelHandle )
R36
modelHandle( 1, 1 )double
end 

isRunAllActive = simulink.multisim.internal.isRunAllActive( modelHandle );
modelName = get_param( modelHandle, "Name" );
studios = simulink.multisim.internal.getAllStudiosForModel( modelName );
for studio = studios
runAllContext = isRunAllActive && isRunAllUserInterfaceVisible( studio );
setRunAllContextForStudio( studio, runAllContext );
end 
end 

function uiIsVisible = isRunAllUserInterfaceVisible( studio )
componentName = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
dockedComponent = studio.getComponent( "GLUE2:DDG Component", componentName );

uiIsVisible = ~isempty( dockedComponent ) && dockedComponent.isVisible;
end 

function setRunAllContextForStudio( studio, runAllContext )
toolStrip = studio.getToolStrip(  );
toolStripActiveContext = toolStrip.ActiveContext;
toolStripActiveContext.setIsOneClickRunAll( runAllContext );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpxbZwEe.p.
% Please follow local copyright laws when handling this file.

