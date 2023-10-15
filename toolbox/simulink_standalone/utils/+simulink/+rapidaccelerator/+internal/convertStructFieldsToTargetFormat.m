function inStruct = convertStructFieldsToTargetFormat( inStruct )

arguments
    inStruct struct
end

fieldNames = fieldnames( inStruct );



for i = 1:numel( fieldNames )
    for j = 1:numel( inStruct )

        field = inStruct( j ).( fieldNames{ i } );

        if ~isstruct( field )
            if isfi( field )
                inStruct( j ).( fieldNames{ i } ) = field.interleavedsimulinkarray(  );
            elseif isa( field, 'half' )
                inStruct( j ).( fieldNames{ i } ) = field.storedInteger;
            elseif isenum( field )
                inStruct( j ).( fieldNames{ i } ) = cast( field, field.underlyingType );
            end
        else

            inStruct( j ).( fieldNames{ i } ) = simulink.rapidaccelerator.internal.convertStructFieldsToTargetFormat( field );
        end

    end
end
end


