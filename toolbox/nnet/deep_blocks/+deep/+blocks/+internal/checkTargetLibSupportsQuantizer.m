function tf = checkTargetLibSupportsQuantizer( targetlib )

R36
targetlib( 1, : )char{ mustBeText }

end 

tf = any( strcmpi( targetlib, { 'cudnn', 'arm-compute' } ) );

end 



