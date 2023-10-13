function namevalueStruct = setNameValueFromPositional( namevalueStruct, name, positional )

arguments
    namevalueStruct struct
    name( 1, 1 ){ mustBeNonzeroLengthText }
    positional
end

if ~isfield( namevalueStruct, name )
    namevalueStruct.( name ) = positional;
end

end



