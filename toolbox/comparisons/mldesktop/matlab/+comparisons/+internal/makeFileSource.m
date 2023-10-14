function fileSource = makeFileSource( filePath, optArgs )

arguments
    filePath{ mustBeTextScalar }
    optArgs.Title{ mustBeTextScalar } = ""
    optArgs.TitleLabel{ mustBeTextScalar } = ""
    optArgs.Properties( :, 1 ){ mustBeStruct, propertiesMustHaveTextNameAndValueFields } = struct.empty(  )
end

optArgs.Properties = convertToStringVector( optArgs.Properties );
fileSource = comparisons.internal.FileSource(  ...
    filePath, optArgs.Title, optArgs.TitleLabel, optArgs.Properties );
end

function mustBeStruct( arg )
mustBeA( arg, 'struct' );
end

function propertiesMustHaveTextNameAndValueFields( properties )
try
    if isempty( properties )
        return ;
    end
    arrayfun( @( prop )mustBeTextScalar( prop.name ), properties );
    arrayfun( @( prop )mustBeTextScalar( prop.value ), properties );
catch
    exID = 'comparisons:mldesktop:InvalidFileSourceProperty';
    exStr = [ 'A comparisons.internal.FileSource property must be a ',  ...
        'struct with text scalar "name" and "value" fields.' ];
    throw( MException( exID, exStr ) );
end
end

function strVec = convertToStringVector( structArr )
strMat = string( struct2cell( structArr ) );
strVec = strMat( : );
end


