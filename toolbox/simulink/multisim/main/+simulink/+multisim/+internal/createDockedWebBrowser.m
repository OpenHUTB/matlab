function dockedComponent = createDockedWebBrowser( url, modelName, componentName, title, dockPosition, dockOption, namedargs )





R36
url( 1, 1 )string
modelName( 1, 1 )string = bdroot
componentName( 1, 1 )string = ""
title( 1, 1 )string = ""
dockPosition( 1, 1 )string = "left"
dockOption( 1, 1 )string = "stacked"
namedargs.Config( 1, 1 )simulink.multisim.internal.DockableWebBrowserConfig = simulink.multisim.internal.DockableWebBrowserConfig
end 

config = namedargs.Config;

studios = config.ModelStudioGetter( modelName );
assert( ~isempty( studios ) );

studio = studios( 1 );
dockedComponent = studio.getComponent( "GLUE2:DDG Component", componentName );
assert( isempty( dockedComponent ) );

schema = config.SchemaConstructor( url );
dockedComponent = config.DDGComponentConstructor( studio, componentName, schema );
dockedComponent.DestroyOnHide = true;
studio.registerComponent( dockedComponent );
studio.moveComponentToDock( dockedComponent, title, dockPosition, dockOption );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjeu3a6.p.
% Please follow local copyright laws when handling this file.

