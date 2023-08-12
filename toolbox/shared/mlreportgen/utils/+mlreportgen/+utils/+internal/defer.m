function defer( fcn, options )









R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8IFmA1.p.
% Please follow local copyright laws when handling this file.

