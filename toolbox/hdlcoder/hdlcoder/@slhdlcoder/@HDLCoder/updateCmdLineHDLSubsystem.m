function updateCmdLineHDLSubsystem( this, newHDLSubsystem )

params = this.getCmdLineParams;
ssidx = find( strcmp( params, 'HDLSubsystem' ), 1 );
if isempty( ssidx )
params = [ { 'HDLSubsystem' }, { newHDLSubsystem }, params ];
else 
params{ ssidx + 1 } = newHDLSubsystem;
end 
this.setCmdLineParams( params );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpsmFGah.p.
% Please follow local copyright laws when handling this file.

