function URL = createDesignSessionURL( sessionIdentifier )




R36
sessionIdentifier( 1, 1 )string
end 

connector.ensureServiceOn(  );

if slsvTestingHook( 'MultipleSimulationsGUIDebug' ) >= 1
index = "index-debug.html";
nonce = "&snc=dev";
else 
index = "index.html";
nonce = "";
end 

URL = string( connector.getUrl( "toolbox/simulink/multisim/specgui/" + index ...
 + "?sessionIdentifier=" + sessionIdentifier ...
 + nonce ) );

if slsvTestingHook( 'MultipleSimulationsGUIDebug' ) >= 1
disp( URL );
if slsvTestingHook( 'MultipleSimulationsGUIDebug' ) >= 2
clipboard( 'copy', URL );
disp( 'URL to the Multiple Simulations GUI was copied to the system clipboard' );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUwYTTB.p.
% Please follow local copyright laws when handling this file.

