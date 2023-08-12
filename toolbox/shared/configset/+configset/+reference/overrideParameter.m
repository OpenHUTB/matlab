function overrideParameter( model, parameter, value )














R36
model
parameter( 1, 1 )string
value = [  ]
end 

manager = configset.internal.reference.OverrideManager( model );
if nargin > 2
manager.override( parameter, value );
else 
manager.override( parameter );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWnUvqa.p.
% Please follow local copyright laws when handling this file.

