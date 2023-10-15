function sig = generateFunctionSignature( aASTFun, parameterPrefix )

arguments
    aASTFun( 1, 1 )internal.cxxfe.ast.Function
    parameterPrefix( 1, 1 )string = ""
end

functionName = aASTFun.Name;
retType = aASTFun.Type.RetType;
retTypeIsFcnPtr = retType.isPointerType && retType.Type.isFunctionType;
returnTypeName = polyspace.internal.codeinsight.CodeInfo.generateTypeName( retType, "$tempName$" );
if retTypeIsFcnPtr
    returnType = returnTypeName;
else
    returnType = returnTypeName.replace( "$tempName$", "" );
end
formalArgs = aASTFun.Params.toArray;
argsTypeAndName = string.empty;
if ~isempty( formalArgs )
    formalArgsType = [ formalArgs.Type ];
    formalArgsName = string( { formalArgs.Name } );
    argsTypeAndName = arrayfun( @( x )polyspace.internal.codeinsight.CodeInfo.generateTypeName( x, "$paramName$" ), formalArgsType );
end

sig = functionName + "(";

nArgs = numel( argsTypeAndName );
if nArgs > 0
    for idx = 1:nArgs
        if strcmp( parameterPrefix, "" )

            argsTypeAndName( idx ) = argsTypeAndName( idx ).replace( "$paramName$", formalArgsName( idx ) );
        else
            argsTypeAndName( idx ) = argsTypeAndName( idx ).replace( "$paramName$", parameterPrefix + idx );
        end
    end
    if aASTFun.IsVariadic
        argsTypeAndName( end  + 1 ) = "...";
    end
    sig = sig + argsTypeAndName.join( ", " );
else
    sig = sig + "void";
end

sig = sig + ")";
if retTypeIsFcnPtr
    sig = returnType.replace( "$tempName$", sig );
else
    sig = returnType + " " + sig;
end
end
