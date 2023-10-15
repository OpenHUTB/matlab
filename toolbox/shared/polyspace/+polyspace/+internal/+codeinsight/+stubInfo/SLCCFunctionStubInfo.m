classdef SLCCFunctionStubInfo < polyspace.internal.codeinsight.stubInfo.functionStubInfo

    methods

        function addExtraGlobal( self, globalDecl, globalDef )
            self.extraGlobal = [ self.extraGlobal, globalDecl ];
            self.extraGlobalDefinitions = [ self.extraGlobalDefinitions, globalDef ];
        end

        function self = SLCCFunctionStubInfo( funInfo )
            arguments
                funInfo( 1, 1 )internal.cxxfe.ast.codeinsight.FunctionInfo
            end

            function res = getStubTypeName( aType )
                unaliasedType = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
                if unaliasedType.isPointerType






                    typeToUse = internal.cxxfe.ast.types.Type.skipQualifiers( unaliasedType.Type );
                else
                    typeToUse = internal.cxxfe.ast.types.Type.skipQualifiers( aType );
                end
                res = polyspace.internal.codeinsight.CodeInfo.generateTypeName( typeToUse, "$stubvar$" );
            end

            function res = typeCanBeAssigned( anUnderlayingType )
                if anUnderlayingType.isVoidType
                    res = false;
                    return ;
                end
                res = true;
                if anUnderlayingType.isStructType

                    mList = anUnderlayingType.Members.toArray;
                    if ~isempty( mList )
                        mTypes = [ mList.Type ];
                        for aMemberType = mTypes
                            if aMemberType.isQualifiedType(  ) && aMemberType.IsConst
                                res = false;
                                break ;
                            end
                        end
                    end
                end
            end

            indent = "  ";
            self.Body = "";
            self.extraGlobal = [  ];
            self.useMemCpy = false;
            functionName = funInfo.Function.Name;
            formalArgs = funInfo.Function.Params.toArray;
            retType = funInfo.Function.Type.RetType;
            returnUnderlayingType = internal.cxxfe.ast.types.Type.getUnderlyingType( retType );
            returnStubTypeName = getStubTypeName( retType );



            self.Name = functionName;
            self.Signature = polyspace.internal.codeinsight.CodeInfo.generateFunctionSignature( funInfo.Function, functionName + "_p" );


            if ~isempty( formalArgs )
                for idx = 1:numel( formalArgs )
                    aFormalArg = formalArgs( idx );
                    argType = aFormalArg.Type;
                    argName = functionName + "_p" + idx;
                    argUnderlayingType = internal.cxxfe.ast.types.Type.getUnderlyingType( argType );
                    argStubTypeName = getStubTypeName( argType );


                    if typeCanBeAssigned( argUnderlayingType )
                        extraGlobalInName = "SLStubIn_" + argName;
                        extraGlobalInDecl = argStubTypeName.replace( "$stubvar$", extraGlobalInName );
                        extraGlobalInDef = extraGlobalInDecl + ";";
                        if polyspace.internal.codeinsight.CodeInfo.isAliasToPointerType( argType )

                            self.Body = self.Body + indent + "SLStubIn_" + argName + " = *" + argName + ";" + newline;
                            if polyspace.internal.codeinsight.CodeInfo.isDereferenceablePointer( argType )
                                extraGlobalOutName = "SLStubOut_" + argName;
                                extraGlobalOutDecl = argStubTypeName.replace( "$stubvar$", extraGlobalOutName ) + ";";
                                self.addExtraGlobal( extraGlobalOutDecl, extraGlobalOutDecl );

                                self.Body = self.Body + indent + "*" + argName + " = " + "SLStubOut_" + argName + ";";
                            end
                        else
                            if polyspace.internal.codeinsight.CodeInfo.isAliasToArrayType( argType )






                                extraGlobalInDef = extraGlobalInDecl + " = {0};";
                                self.Body = self.Body + indent + "memcpy( " + "SLStubIn_" + argName + ", " + argName +  ...
                                    ", sizeof(" + argName + ") );";
                                self.useMemCpy = true;
                            else
                                self.Body = self.Body + indent + "SLStubIn_" + argName + " = " + argName + ";";
                            end
                        end
                        extraGlobalInDecl = extraGlobalInDecl + ";";
                        self.addExtraGlobal( extraGlobalInDecl, extraGlobalInDef );
                    end
                end
            end


            if typeCanBeAssigned( returnUnderlayingType )
                returnDeref = "";
                if polyspace.internal.codeinsight.CodeInfo.isAliasToPointerType( retType )
                    returnDeref = "&";
                end
                self.Body = self.Body + newline +  ...
                    indent + "return " + returnDeref + "SLStubOut_" + functionName + ";";
                extraGlobalReturnName = "SLStubOut_" + functionName;
                returnTypeName = returnStubTypeName.replace( "$stubvar$", extraGlobalReturnName );
                if retType.isArrayType
                    extraGlobalSLStubOutDefinition = returnTypeName + " = {0};";
                else
                    extraGlobalSLStubOutDefinition = returnTypeName + ";";
                end
                extraGlobalSLStubOutDecl = returnTypeName + ";";
                self.addExtraGlobal( extraGlobalSLStubOutDecl, extraGlobalSLStubOutDefinition );
            else
                if ~returnUnderlayingType.isVoidType(  )
                    returnExpr = returnStubTypeName.replace( "$stubvar$", "ret" );
                    if returnUnderlayingType.isStructType || returnUnderlayingType.isArrayType

                        returnExpr = returnExpr + " = {0};";
                    else

                        returnExpr = returnExpr + " = (" + returnStubTypeName.replace( "$stubvar$", "" ) + ")(0);";
                    end
                    self.Body = self.Body + newline +  ...
                        indent + returnExpr + newline +  ...
                        indent + "return ret;";
                end
            end

        end

    end
end

