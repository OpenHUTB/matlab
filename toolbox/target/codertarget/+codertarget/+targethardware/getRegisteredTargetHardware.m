function targets = getRegisteredTargetHardware( varargin )




if nargin > 0 && isequal( varargin{ 1 }, 'matlab' )
RTW.TargetRegistry.getInstance( 'coder' );
reg = codertarget.TargetBoardRegistry.manageInstance( 'get', 'CoderTargetBoard' );
targets = reg.TargetBoards;
else 
if codertarget.TargetBoardRegistry.isSimulinkInstalled(  ) &&  ...
~codertarget.TargetBoardRegistry.getSlTargetsLoadedState(  )
sl_refresh_customizations;
end 
reg = codertarget.TargetBoardRegistry.manageInstance( 'get', 'CoderTargetBoard' );
regSL = codertarget.TargetBoardRegistry.manageInstance( 'get', 'CoderTargetBoardSL' );
targets = [ reg.TargetBoards, regSL.TargetBoards ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPjoRZi.p.
% Please follow local copyright laws when handling this file.

