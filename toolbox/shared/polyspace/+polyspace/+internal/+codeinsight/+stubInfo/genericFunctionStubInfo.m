classdef genericFunctionStubInfo < polyspace.internal.codeinsight.stubInfo.functionStubInfo






methods 
function self = genericFunctionStubInfo( funInfo )
R36
funInfo( 1, 1 )internal.cxxfe.ast.codeinsight.FunctionInfo
end 
self.useMemCpy = false;
self.extraGlobal = [  ];
functionName = funInfo.Function.Name;
self.Name = functionName;
retType = funInfo.Function.Type.RetType;
returnUnderlayingType = internal.cxxfe.ast.types.Type.getUnderlyingType( retType );
returnStubTypeName = polyspace.internal.codeinsight.CodeInfo.generateTypeName( retType, "$stubvar$" );
returnExpr = returnStubTypeName.replace( "$stubvar$", "ret" );
if returnUnderlayingType.isStructType || returnUnderlayingType.isArrayType

returnExpr = returnExpr + " = {0};";
else 

returnExpr = returnExpr + " = (" + returnStubTypeName.replace( "$stubvar$", "" ) + ")(0);";
end 

formalArgs = funInfo.Function.Params.toArray;
nArgs = numel( formalArgs );


self.Signature = polyspace.internal.codeinsight.CodeInfo.generateFunctionSignature( funInfo.Function, "p" );


self.Body = "";
indent = "  ";


if nArgs > 0
assignParams = strings( 1, nArgs );
for idx = 1:nArgs
assignParams( idx ) = "(void)(p" + idx + ");";
end 

if ~isempty( assignParams )
self.Body = self.Body + join( assignParams, newline );
end 
end 
if ~retType.isVoidType(  )
self.Body = self.Body + newline +  ...
indent + returnExpr + newline +  ...
indent + "return ret;";
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmlfPW_.p.
% Please follow local copyright laws when handling this file.

