function url = makeBaseUrl( controller, options )




R36
controller( 1, 1 )dependencies.internal.viewer.Controller;
options.Debug( 1, 1 )logical = false;
options.Themed( 1, 1 )logical = i_getDefaultThemedValue(  );
end 

uuid = controller.View.UUID;

if options.Debug
pageName = "app-debug";
else 
pageName = "app";
end 

url = "/toolbox/matlab/dependency/app/web/" +  ...
pageName + ".html?view=" + uuid + "&themed=" + double( options.Themed );

end 

function value = i_getDefaultThemedValue(  )
import matlab.internal.lang.capability.Capability
isRemoteClient = ~Capability.isSupported( Capability.LocalClient );
isJSD = matlab.internal.feature( 'webui' );

value = isRemoteClient || isJSD;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqlasj2.p.
% Please follow local copyright laws when handling this file.

