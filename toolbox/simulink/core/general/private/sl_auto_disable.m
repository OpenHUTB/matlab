function state = sl_auto_disable( cbinfo, level )
state = 'Disabled';



sim_status = get_param( cbinfo.model.Handle, 'SimulationStatus' );
busy = ~strcmpi( sim_status, 'stopped' );

assert( ~isempty( level ), 'DIG Passed an empty value for ''level''!' );

switch level
case 'Locked'






locked = true;

editor = cbinfo.studio.App.getActiveEditor;

if ~Simulink.harness.internal.lockMenus( cbinfo.model.handle ) &&  ...
~isempty( editor ) && isvalid( editor ) && ~editor.isLocked
locked = false;
end 




assert( locked || ~busy, 'Simulink Editor is busy, but not locked.' );

if ~locked && ~busy
state = 'Enabled';
end 
case 'Busy'
if ~busy
state = 'Enabled';
end 
otherwise 
state = 'Enabled';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTDXSTd.p.
% Please follow local copyright laws when handling this file.

