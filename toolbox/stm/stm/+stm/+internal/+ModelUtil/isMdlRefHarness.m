function bool = isMdlRefHarness( model, harness )

R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4scsR8.p.
% Please follow local copyright laws when handling this file.

