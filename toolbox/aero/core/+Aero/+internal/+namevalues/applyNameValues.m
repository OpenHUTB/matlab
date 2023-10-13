function obj = applyNameValues( obj, NameValues )

arguments
    obj( 1, 1 )
    NameValues( 1, 1 )struct
end

for f = string( fields( NameValues ) ).'
    obj.( f ) = NameValues.( f );
end
end


