function dockedComponent = createDockedWebBrowserInStudio( studio, url, componentName, title )




R36
studio( 1, 1 )DAS.Studio
url( 1, 1 )string
componentName( 1, 1 )string
title( 1, 1 )string
end 

dockedComponent = studio.getComponent( "GLUE2:DDG Component", componentName );
if ~isempty( dockedComponent )
studio.showComponent( dockedComponent );
return ;
end 

schema = simulink.multisim.internal.WebBrowserSchema( url );
dockedComponent = GLUE2.DDGComponent( studio, componentName, schema );
dockedComponent.setPreferredSize( 300,  - 1 );
dockedComponent.DestroyOnHide = false;
studio.registerComponent( dockedComponent );
studio.moveComponentToDock( dockedComponent, title, "left", "stacked" );
simulink.multisim.internal.resetRunAllContextOnClose( dockedComponent, studio.App.blockDiagramHandle );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzQ1vdU.p.
% Please follow local copyright laws when handling this file.

