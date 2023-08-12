
function targetType = mdlRefGetTopModelTargetForInfoMATFileMgr( iMdlRefTargetType,  ...
iUpdateTopModelRefTarget,  ...
iSimModeParent )










if ( ( isequal( iMdlRefTargetType, 'RTW' ) ) &&  ...
( ~iUpdateTopModelRefTarget ) )
targetType = 'NONE';
elseif ( ( isequal( iMdlRefTargetType, 'SIM' ) ) &&  ...
( isequal( iSimModeParent, 'accelerator' ) ) )
targetType = 'SIM-ACCEL';
else 
targetType = iMdlRefTargetType;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIleMvs.p.
% Please follow local copyright laws when handling this file.

