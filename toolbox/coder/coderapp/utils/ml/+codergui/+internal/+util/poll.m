function completed = poll( passCondition, opts )
arguments
    passCondition( 1, 1 )function_handle
    opts.Timeout( 1, 1 )uint32 = 0
    opts.Interval( 1, 1 )double = 0.25
    opts.BreakCondition function_handle{ mustBeScalarOrEmpty( opts.BreakCondition ) } = function_handle.empty(  )
end

timeout = opts.Timeout;
interval = opts.Interval;
breakCondition = opts.BreakCondition;
completed = passCondition(  );
startTime = tic(  );

while ~completed && ( isempty( breakCondition ) || ~breakCondition(  ) )
    if timeout > 0 && toc( startTime ) > timeout
        break
    end
    drawnow(  );
    pause( interval );
    completed = passCondition(  );
end
end


