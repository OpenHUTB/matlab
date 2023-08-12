function x0 = getInitialState( mdl )






mdl = get_param( mdl, 'Name' );

needTerm = false;
err = '';

if isequal( get_param( mdl, 'SimulationStatus' ), 'stopped' )
try 
feval( mdl, 'init' );
needTerm = true;
catch err
end 
end 

if isempty( err )
try 
if isequal( get_param( mdl, 'SimulationStatus' ), 'paused' )







feval( mdl, [  ], [  ], [  ], 'outputs' );
end 
x0 = feval( mdl, 'get', 'state' );
catch err
end 
end 

if needTerm
feval( mdl, 'term' );
end 

if ~isempty( err )
rethrow( err );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3UUXUM.p.
% Please follow local copyright laws when handling this file.

