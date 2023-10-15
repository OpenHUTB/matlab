function URL = createDesignSessionURL( sessionIdentifier )

arguments
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

