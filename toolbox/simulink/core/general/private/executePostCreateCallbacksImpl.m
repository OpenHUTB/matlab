function executePostCreateCallbacksImpl( ~, bdname )













callbacks = get_param( 0, 'RootCallbacks' );
if isempty( callbacks )
return ;
end 
assert( isstruct( callbacks ) );


ids = sort( fieldnames( callbacks ) );
for i = 1:numel( ids )
i_execute( ids{ i }, callbacks.( ids{ i } ), bdname );
end 
end 


function i_execute( id, fcn, bdname )
try 
fcn( bdname );
catch E
MSLDiagnostic( 'Simulink:utility:BlockDiagramExecutionError',  ...
'PostCreate', id, bdname, E.message ).reportAsWarning;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfbbsJB.p.
% Please follow local copyright laws when handling this file.

