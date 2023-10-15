function overrideParameter( model, parameter, value )

arguments
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
