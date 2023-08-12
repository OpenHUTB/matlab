function register( app )




R36
app( 1, 1 ){ mustBeA( app, 'comparisons.internal.App' ), mustBeNonempty, mustBeValid }
end 

comparisons.internal.appstore.registerImpl( app );
end 

function mustBeValid( app )
if ~app.valid(  )
error( 'appstore:invalidapp', 'App must be valid.' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpaC82DU.p.
% Please follow local copyright laws when handling this file.

