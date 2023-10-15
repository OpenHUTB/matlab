function typename = generateTypeName( aASTType, parameterPrefix )







arguments
    aASTType( 1, 1 )internal.cxxfe.ast.types.Type
    parameterPrefix( 1, 1 )string = ""
end

unqualifiedType = internal.cxxfe.ast.types.Type.skipQualifiers( aASTType );

if unqualifiedType.isPointerType(  ) && unqualifiedType.Type.isFunctionType(  )


    retType = aASTType.Type.RetType;
    returnType = retType.generateSignature;
    formalArgs = aASTType.Type.ParamTypes.toArray;
    argumentsTypeList = "";
    if ~isempty( formalArgs )
        argumentsTypeList = arrayfun( @( x )string( x.generateSignature ), formalArgs );
        argumentsTypeList = argumentsTypeList.join( ", " );
    end
    typename = returnType + "( * " + parameterPrefix + " )(" + argumentsTypeList + ")";
else
    keyword = getKeyword( unqualifiedType );
    typename = keyword + " " + string( internal.cxxfe.ast.types.Type.generateTypeName( aASTType, parameterPrefix ) );
end
end


function keyword = getKeyword( anUnqualifiedType )
arguments
    anUnqualifiedType( 1, 1 )internal.cxxfe.ast.types.Type
end
keyword = "";
if anUnqualifiedType.isStructType(  )
    keyword = "struct";
    return ;
end
if anUnqualifiedType.isUnionType(  )
    keyword = "union";
    return ;
end
if anUnqualifiedType.isEnumType(  )
    keyword = "enum";
    return ;
end
if anUnqualifiedType.isPointerType(  )

    unqualifiedType = internal.cxxfe.ast.types.Type.skipQualifiers( anUnqualifiedType );
    keyword = getKeyword( unqualifiedType.Type );
    return ;
end
end


