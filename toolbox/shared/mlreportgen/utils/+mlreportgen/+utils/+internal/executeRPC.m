function varargout = executeRPC( fcn, opts )



















R36
fcn( 1, 1 )function_handle
opts.RetryPreFcn( 1, 1 )function_handle
opts.MaxTries( 1, 1 ){ mustBeNumeric } = 5
end 

tries = 0;
fx = 0;
fy = 1;

hasRetryPreFcn = isfield( opts, "RetryPreFcn" );

while ( tries < opts.MaxTries )
try 
tries = tries + 1;
if ( tries > 1 )
if hasRetryPreFcn
feval( opts.RetryPreFcn );
end 
pause( fx );
end 


fx = fy;
fy = fy + fx;

if ( nargout > 0 )
[ varargout{ 1:nargout } ] = feval( fcn );
else 
feval( fcn );
end 
return 

catch ME
errmsg = lower( ME.message );
if ~( contains( errmsg, "0x80010001" ) || contains( errmsg, "RPC_E_CALL_REJECTED" ) )
baseME = MException( "mlreportgen:utils:warning:retryCallingFunction",  ...
message( "mlreportgen:utils:warning:retryCallingFunction",  ...
compose( "%s", char( fcn ) ),  ...
errmsg ) );
newME = addCause( baseME, ME );
throw( newME );
end 
end 
end 

rethrow( ME );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLB9GrL.p.
% Please follow local copyright laws when handling this file.

