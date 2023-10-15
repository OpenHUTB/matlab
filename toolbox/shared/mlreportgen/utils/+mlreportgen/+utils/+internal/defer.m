function defer( fcn, options )

arguments
    fcn( 1, 1 )function_handle
    options.StartDelay = 0.1;
end

t = timer(  );
t.ExecutionMode = 'singleShot';
t.TimerFcn = @( ~, ~ )feval( fcn );
t.StopFcn = @( t, ~ )delete( t );
t.StartDelay = options.StartDelay;
t.start(  );
end
