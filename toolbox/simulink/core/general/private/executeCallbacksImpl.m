function executeCallbacksImpl( obj, type, varargin )















if nargin < 3
can_throw = false;

else 
can_throw = varargin{ 1 };
end 

callbacks = get_param( obj.Handle, 'Callbacks' );
assert( isempty( callbacks ) || isstruct( callbacks ) );
if ~isfield( callbacks, type )

return ;
end 





lock_flag = [ 'Executing', type, 'Callbacks' ];
if Simulink.BlockDiagramAssociatedData.isRegistered( obj.Handle, lock_flag )
return ;
else 
Simulink.BlockDiagramAssociatedData.register( obj.Handle, lock_flag, 'int' );
unlock = onCleanup( @(  ) ...
Simulink.BlockDiagramAssociatedData.unregister( obj.Handle, lock_flag ) );
end 

f = callbacks.( type );


ids = sort( fieldnames( f ) );
for i = 1:numel( ids )
i_execute( obj, type, ids{ i }, f.( ids{ i } ), can_throw );
end 

end 


function i_execute( obj, type, id, fcn, can_throw )
try 
fcn(  );
catch E
if can_throw
rethrow( E );
else 
MSLDiagnostic( 'Simulink:utility:BlockDiagramExecutionError',  ...
type, id, obj.Name, E.message ).reportAsWarning;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0QDKZi.p.
% Please follow local copyright laws when handling this file.

