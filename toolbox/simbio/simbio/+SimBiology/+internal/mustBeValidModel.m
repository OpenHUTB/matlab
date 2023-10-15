function mustBeValidModel( model, msgId )
arguments
    model
    msgId = 'SimBiology:validation:InvalidModel'
end
if ~( isa( model, "SimBiology.Model" ) && isscalar( model ) && isvalid( model ) )
    error( message( msgId ) )
end
end
