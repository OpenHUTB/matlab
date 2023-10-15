function bool = isMdlRefHarness( model, harness )

arguments
    model( 1, 1 )string;
    harness( 1, 1 )string;
end

bool = false;
try
    load_system( model );
    s = sltest.harness.find( model, 'Name', harness );
    bool = ~isempty( s ) && s.ownerType == "Simulink.ModelReference";
catch
end
end
