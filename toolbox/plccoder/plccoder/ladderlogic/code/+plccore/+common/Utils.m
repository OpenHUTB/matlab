classdef Utils





    methods(Static)
        function typeStr=ladderType2Str(ldType)

            if isempty(ldType)
                assert(false);
            end

            switch(class(ldType))
            case 'plccore.type.ArrayType'
                typeStr=ldType.elem_type.toString;
            case 'plccore.type.BitFieldType'
                ldbool=plccore.type.BOOLType;
                typeStr=ldbool.toString;
            case 'plccore.type.NamedType'
                typeStr=ldType.name;
            case 'plccore.type.POUType'
                typeStr=ldType.toString;
            case 'plccore.type.StructType'
                assert(false)
            otherwise
                if isa(ldType,'plccore.type.AbstractType')
                    typeStr=ldType.toString;
                else
                    assert(false)
                end
            end
        end

        function[var,varscope]=getVarInstance(varName,ctx,pou,allowUnknownExpr)


            import plccore.common.Utils;
            import plccore.util.ScopeTypes;
            var=Utils.getVarFromScope(varName,pou.localScope);
            if~isempty(var)
                varscope=ScopeTypes.localScope;
                return;
            end

            var=Utils.getVarFromScope(varName,pou.inputScope);
            if~isempty(var)
                varscope=ScopeTypes.inputScope;
                return;
            end


            var=Utils.getVarFromScope(varName,pou.outputScope);
            if~isempty(var)
                varscope=ScopeTypes.outputScope;
                return;
            end


            var=Utils.getVarFromScope(varName,pou.inOutScope);
            if~isempty(var)
                varscope=ScopeTypes.inOutScope;
                return;
            end

            if~isempty(ctx)
                assert(~isempty(ctx)&&isa(ctx,'plccore.common.Context'),...
                'Invalid ctx object');
                var=Utils.getVarFromScope(varName,ctx.configuration.globalScope);
                if~isempty(var)
                    varscope=ScopeTypes.globalScope;
                    return;
                end
            end

            if nargin<4
                allowUnknownExpr=false;
            end

            if isempty(var)&&~allowUnknownExpr
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:VarNotFoundInAnyScope',varName);
            else


            end
        end

        function var=getVarFromScope(varName,scope)

            var=[];
            if scope.hasSymbol(varName)
                var=scope.getSymbol(varName);
            end
        end

        function[type,aliasFound,unknownTypeFound]=getTypeFromExpr(ctx,pou,expr,exprDepth)

            if nargin<4
                exprDepth=0;
            end
            aliasFound=false;
            type=plccore.type.AbstractType;
            unknownTypeFound=false;
            import plccore.type.TypeTool;
            import plccore.common.Utils;
            assert(isa(expr,'plccore.expr.AbstractExpr'));
            if isa(pou,'plccore.common.Routine')
                pou=pou.program;
            end
            switch(class(expr))
            case 'plccore.expr.VarExpr'
                var=expr.var;
                varInstance=plccore.common.Utils.getVarInstance(var.name,ctx,pou);
                if isempty(varInstance)
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:VarNotFoundInAnyScope',var.name);
                end
                if isa(var,'plccore.common.AliasInfo')
                    aliasFound=true;

                else
                    type=var.type;
                end

                if TypeTool.isUnknownType(type)
                    unknownTypeFound=true;
                end
            case 'plccore.expr.ConstExpr'
                type=expr.value.type;
            case 'plccore.expr.IntegerBitRefExpr'
                intExpr=expr.integerExpr;
                bitNumber=expr.bitIndex;
                [exprType,aliasFound,unknownTypeFound]=Utils.getTypeFromExpr(ctx,pou,intExpr,exprDepth+1);
                if TypeTool.isUnknownType(exprType)
                    unknownTypeFound=true;
                end
                if aliasFound||unknownTypeFound
                    return;
                end

                assert(isa(exprType,'plccore.type.DINTType')||isa(exprType,'plccore.type.SINTType')||isa(exprType,'plccore.type.INTType'));
                assert(isa(bitNumber,'double'));
                type=plccore.type.BOOLType;
            case 'plccore.expr.StringExpr'

            case 'plccore.expr.StructRefExpr'
                fieldname=expr.fieldName;
                strucExpr=expr.structExpr;
                [structType,aliasFound,unknownTypeFound]=Utils.getTypeFromExpr(ctx,pou,strucExpr,exprDepth+1);
                if TypeTool.isUnknownType(structType)
                    unknownTypeFound=true;
                end
                if aliasFound||unknownTypeFound
                    return;
                end

                if TypeTool.isStructType(structType)
                    if TypeTool.hasStructField(structType,fieldname)
                        type=TypeTool.getStructFieldType(structType,fieldname);
                    else
                        assert(TypeTool.isNamedType(structType),'Type should be a named type');
                        import plccore.common.plcThrowError;
                        plcThrowError('plccoder:plccore:MemberNotFound',fieldname,expr.toString,structType.name);

                    end
                elseif TypeTool.isArrayType(structType)
                    type=structType.elemType;
                elseif TypeTool.isPOU(structType)
                    pou=structType.type;
                    varInstance=plccore.common.Utils.getVarInstance(fieldname,ctx,pou);
                    if isa(varInstance,'plccore.common.AliasInfo')
                        aliasFound=true;

                    else
                        type=varInstance.type;
                    end
                elseif TypeTool.isPOUType(structType)
                    pou=ctx.configuration.globalScope.getSymbol(structType.toString);
                    varInstance=plccore.common.Utils.getVarInstance(fieldname,ctx,pou);
                    if isa(varInstance,'plccore.common.AliasInfo')
                        aliasFound=true;
                    else
                        type=varInstance.type;
                    end
                end
            case 'plccore.expr.ArrayRefExpr'
                arrayExpr=expr.arrayExpr;
                [arraytype,aliasFound,unknownTypeFound]=Utils.getTypeFromExpr(ctx,pou,arrayExpr,exprDepth+1);
                if TypeTool.isUnknownType(arraytype)
                    unknownTypeFound=true;
                end
                if aliasFound||unknownTypeFound
                    return;
                end
                if TypeTool.isUnknownType(arraytype)
                    arraytype=TypeTool.getUnknownType(arraytype,ctx);
                end
                if TypeTool.isArrayType(arraytype)
                    type=arraytype.elemType;
                else
                    type=arraytype;
                end
            case 'plccore.expr.UnknownExpr'
            case 'plccore.expr.WildCardExpr'
            otherwise
                assert(false);
            end
        end

        function[subOperand,endindex]=getSubTextTillDotOrBrace(text)
            dotIndices=regexp(text,'\.');
            openBraceIndices=regexp(text,'\[');

            endindex=length(text);
            if~isempty(dotIndices)&&~isempty(openBraceIndices)
                if dotIndices(1)<openBraceIndices(1)
                    endindex=dotIndices(1)-1;
                else
                    endindex=openBraceIndices(1)-1;
                end
            elseif~isempty(dotIndices)
                endindex=dotIndices(1)-1;
            elseif~isempty(openBraceIndices)
                endindex=openBraceIndices(1)-1;
            end

            subOperand=text(1:endindex);
        end
    end
end



