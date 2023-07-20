function[dataType,bNeedsFlag]=getAstDataType(system,ast,chartObj)














    bNeedsFlag=false;
    rt=sfroot;
    switch class(ast)
    case 'Stateflow.Ast.UserFunction'
        if(ast.id~=0)
            fn=rt.idToHandle(ast.id);
            fObj=fn.find('-isa','Stateflow.Data','Scope','Output');
            if~isempty(fObj)
                dataType=fObj(1).CompiledType;
            else


                dataType='unknown';
            end
        else
            dataType='unknown';
        end
    case 'Stateflow.Ast.ComplexFunction'
        dataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case 'Stateflow.Ast.RealFunction'
        dataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case 'Stateflow.Ast.ImaginaryFunction'
        dataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case 'Stateflow.Ast.InFunction'
        dataType='boolean';
    case 'Stateflow.Ast.Identifier'
        if(ast.id~=0)
            dataObject=rt.idToHandle(ast.id);
            dataType=dataObject.CompiledType;

            if strcmp(Advisor.Utils.Stateflow.getBuiltInDataType(system,dataType),'unknown')

                if contains(dataObject.DataType,'Enum:')...
                    ||contains(dataObject.DataType,'Inherit:')...
                    ||~isempty(dataObject.Props.Type.EnumType)...
                    ||~isempty(dataObject.Props.Type.Hybrid)
                    ens=enumeration(dataType);
                    if~isempty(ens)
                        meta=metaclass(ens(1));
                        dataType=getTopLevelSuperClassName(meta);
                    end
                end
            end
        elseif strcmp(ast.sourceSnippet,'true')||strcmp(ast.sourceSnippet,'false')
            dataType='boolean';
        else
            dataType='unknown';
        end
    case 'Stateflow.Ast.StructMember'



        baseType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);

        baseObj=Advisor.Utils.safeEvalinGlobalScope(system,baseType);

        if~isempty(baseObj)&&isa(baseObj,'Simulink.Bus')
            dataObj=baseObj.Elements(arrayfun(@(x)strcmp(x.Name,ast.children{2}.sourceSnippet),baseObj.Elements));
            if isempty(dataObj)
                dataType=baseType;
            else
                dataType=dataObj.DataType;
            end
            dataType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,dataType);
            dataType=dataType{1};
            dataType=Advisor.Utils.Stateflow.getBuiltInDataType(system,dataType);
            if strcmp(dataType,'unknown')
                dataType='unknown';
            end
        else
            dataType='unknown';
        end

    case 'Stateflow.Ast.QualifiedId'
        if(ast.id~=0)
            dataObject=rt.idToHandle(ast.id);
            dataType=dataObject.CompiledType;
        else













            sourceSnippetType=Advisor.Utils.safeEvalinGlobalScope(system,ast.sourceSnippet);

            if~isempty(sourceSnippetType)
                meta=metaclass(sourceSnippetType);
                dataType=getTopLevelSuperClassName(meta);
            else
                dataType='unknown';
            end
        end
    case 'Stateflow.Ast.FloatNum'
        dataType='double';
        bNeedsFlag=true;
    case 'Stateflow.Ast.IntegerNum'
        dataType='int32';
        bNeedsFlag=true;
    case 'Stateflow.Ast.Uminus'
        [dataType,bNeedsFlag]=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case{'Stateflow.Ast.Negate','Stateflow.Ast.Not'}
        dataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case 'Stateflow.Ast.Array'
        dataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    case 'Stateflow.Ast.ExplicitTypeCast'
        idx=strfind(ast.sourceSnippet,'(');
        dataType=ast.sourceSnippet(1:idx(1)-1);
    case 'Stateflow.Ast.BinaryExpression'
        if(Advisor.Utils.Stateflow.IsAComparison(ast)||isa(ast,'Stateflow.Ast.Not'))
            dataType='boolean';
        else
            dataType='unknown';
        end
    case 'Stateflow.Ast.CastFunction'
        if~isempty(regexp(ast.children{2}.sourceSnippet,'type','match','once'))
            dataType=getCastType(ast.children{2},chartObj);
        else
            dataType=ast.children{2}.sourceSnippet;
        end
    case{'Stateflow.Ast.Plus','Stateflow.Ast.Minus',...
        'Stateflow.Ast.Times','Stateflow.Ast.Divide',...
        'Stateflow.Ast.LogicalAnd','Stateflow.Ast.LogicalOr',...
        'Stateflow.Ast.Modulus','Stateflow.Ast.Pow',...
        'Stateflow.Ast.ShiftLeft','Stateflow.Ast.ShiftRight'}
        [dataType,bNeedsFlag]=getArithCastType(system,ast,chartObj);
    case{'Stateflow.Ast.IsEqual','Stateflow.Ast.IsNotEqual',...
        'Stateflow.Ast.NegEqual','Stateflow.Ast.LesserThanGreaterThan',...
        'Stateflow.Ast.GreaterThanOrEqual','Stateflow.Ast.LesserThanOrEqual',...
        'Stateflow.Ast.LesserThan','Stateflow.Ast.GreaterThan',...
        'Stateflow.Ast.OldLesserThan','Stateflow.Ast.OldLesserThanOrEqual',...
        'Stateflow.Ast.OldGreaterThan','Stateflow.Ast.OldGreaterThanOrEqual'}
        dataType='boolean';
    otherwise
        dataType='unknown';
    end
    dataType=strtrim(dataType);
end

function dt=getCastType(astNode,chartObj)
    dataName=astNode.children{1}.sourceSnippet;
    fObj=chartObj.find('-isa','Stateflow.Data','Name',dataName);
    if~isempty(fObj)
        dt=fObj(1).CompiledType;
    else
        dt='unknown';
    end
end

function[dataType,bNeedsFlag]=getArithCastType(system,ast,chartObj)
    bNeedsFlag=false;
    [lType,l_bNeedsFlag]=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
    [rType,r_bNeedsFlag]=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{2},chartObj);







    if strcmp('unknown',lType)||strcmp('unknown',rType)
        dataType='unknown';

    elseif strcmp(lType,rType)&&~l_bNeedsFlag&&~r_bNeedsFlag
        dataType=lType;
    else







        if Advisor.Utils.Stateflow.getDataBitwidth(lType)>Advisor.Utils.Stateflow.getDataBitwidth(rType)
            dataType=lType;
        else
            dataType=rType;
        end
        bNeedsFlag=true;
    end
end

function metaName=getTopLevelSuperClassName(metaclass)
    if~isempty(metaclass.SuperclassList)
        metaName=getTopLevelSuperClassName(metaclass.SuperclassList(1));
    else
        metaName=metaclass.Name;
    end
end
