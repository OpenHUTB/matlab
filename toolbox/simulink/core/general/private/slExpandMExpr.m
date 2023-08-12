function slExpandMExpr( mexpr, contextHandle, x, y )









setupML2SL(  );
addpath( [ matlabroot, '/test/toolbox/hdlcoder/emlcoder/fixptconversion/mathlib/SmartEdit/src' ] );
SLSmartEdit.mlSmartEdit( mexpr, contextHandle, x, y, true, false );
rmpath( [ matlabroot, '/test/toolbox/hdlcoder/emlcoder/fixptconversion/mathlib/SmartEdit/src' ] );
clearML2SLPath(  );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp95Sg5O.p.
% Please follow local copyright laws when handling this file.

