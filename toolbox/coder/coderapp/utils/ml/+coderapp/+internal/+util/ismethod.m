function result = ismethod( classOrObj, methodNames, passthroughArgs )
arguments
    classOrObj
    methodNames string
end
arguments( Repeating )
    passthroughArgs
end

if ischar( classOrObj ) || isstring( classOrObj )
    className = classOrObj;
else
    className = class( classOrObj );
end
realMethodNames = coderapp.internal.util.methods( className, passthroughArgs{ : } );
result = ismember( methodNames, realMethodNames );
end


