function [ val, isValidProperty ] = getAxesProperty( axesHandle, propName )

arguments
    axesHandle
    propName string
end

val = [  ];
isValidProperty = true;
switch propName
    case "Title"
        axesTitleObj = get( axesHandle, propName );
        val = axesTitleObj.String;

    otherwise
        [ propVal, isInvalid ] = mlreportgen.utils.safeGet( axesHandle, propName );
        if isInvalid
            isValidProperty = false;
        else
            val = propVal{ 1 };
        end
end



if ~isempty( val ) && ~isscalar( val )
    val = mlreportgen.utils.toString( val );
end
end

