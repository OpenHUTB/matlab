function tf = checkTargetLibSupportsQuantizer( targetlib )






R36
targetlib( 1, : )char{ mustBeText }

end 

tf = any( strcmpi( targetlib, { 'cudnn', 'arm-compute' } ) );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKHVo4R.p.
% Please follow local copyright laws when handling this file.

