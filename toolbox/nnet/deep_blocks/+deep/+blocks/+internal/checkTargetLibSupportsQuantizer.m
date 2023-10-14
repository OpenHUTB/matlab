function tf = checkTargetLibSupportsQuantizer( targetlib )

arguments
    targetlib( 1, : )char{ mustBeText }

end

tf = any( strcmpi( targetlib, { 'cudnn', 'arm-compute' } ) );

end



