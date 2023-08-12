function enumValues = pmsl_rtmpreferences( doPad )












narginchk( 0, 1 );

loadModelInSpecifiedModeMsg = message( 'physmod:pm_sli:rtm:LoadModelInSpecifiedMode' );
loadUseModeMsg = message( 'physmod:pm_sli:rtm:LoadUsingMode' );

enumValues = {  ...
LOAD_MODEL_SPECIFIED_MODE, loadModelInSpecifiedModeMsg.getString(  ),  ...
LOAD_USING_MODE, loadUseModeMsg.getString(  ),  ...
 };

if nargin == 0
doPad = false;
end 

if doPad
enumValues{ end  + 1 } = enumValues{ 1 };
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpozI1pi.p.
% Please follow local copyright laws when handling this file.

