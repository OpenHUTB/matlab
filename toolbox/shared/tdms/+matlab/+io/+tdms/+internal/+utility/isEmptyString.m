function isEmpty = isEmptyString( str )

arguments
    str string
end
isEmpty = all( isempty( str ) | ismissing( str ) | str == "" );
end

