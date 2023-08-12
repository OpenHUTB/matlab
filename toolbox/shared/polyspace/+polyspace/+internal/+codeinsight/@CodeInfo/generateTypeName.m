function typename = generateTypeName( aASTType, parameterPrefix )







R36
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
R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpLJdhxf.p.
% Please follow local copyright laws when handling this file.

