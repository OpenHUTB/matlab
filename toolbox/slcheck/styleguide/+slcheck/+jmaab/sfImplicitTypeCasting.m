classdef sfImplicitTypeCasting<slcheck.subcheck
    methods
        function obj=sfImplicitTypeCasting(initParams)
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID=initParams.Name;
        end

        function result=run(this)

            result=false;

            uddObj=this.getEntity();

            if isempty(uddObj)
                return;
            end

            if isempty(uddObj.LabelString)
                return;
            end

            [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(uddObj);
            if isempty(asts)
                return;
            end

            roots=cellfun(@(x)x.roots,asts.sections,'UniformOutput',false);

            roots=roots(~cellfun('isempty',roots));

            if isempty(roots)
                return;
            end

            system=uddObj.Chart.Machine.Name;
            langM=Advisor.Utils.Stateflow.isActionLanguageM(uddObj.Chart);
            langC=Advisor.Utils.Stateflow.isActionLanguageC(uddObj.Chart);
            indices=[];
            indicesUnknown=[];

            for iroot=1:length(roots)
                if langM
                    [ind,indUnknown]=iVerifyComparisonsM(system,roots{iroot},resolvedSymbolIds);
                elseif langC
                    [ind,indUnknown]=iVerifyActionLanguageC(system,roots{iroot},uddObj.Chart);
                end
                indices=[indices,ind];
                indicesUnknown=[indicesUnknown,indUnknown];
            end








            indices=[indices(:);indicesUnknown(:)]';

            if~isempty(indices)



                indices=sort(indices);

                highlighted=uddObj.LabelString;
                addLength=0;

                for idx=1:size(indices)
                    highlighted=Advisor.Utils.Naming.formatFlaggedName(...
                    highlighted,false,indices(idx,:)+addLength,'');
                    addLength=addLength+13;
                end

                MAText=ModelAdvisor.Text(highlighted);
                MAText.RetainReturn=true;
                MAText.RetainSpaceReturn=true;

                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',uddObj,'Expression',MAText.emitHTML);

                result=this.setResult(vObj);
            end
        end
    end
end


function dataTypes=getDataTypesInputByFunctionName(funcName,chartObj)
    dataTypes={};



    sfFunc=chartObj.find('-isa','Stateflow.Function',...
    '-or','-isa','Stateflow.SLFunction');
    sfFunc=sfFunc(arrayfun(@(x)strcmp(x.Name,funcName),sfFunc));

    if isempty(sfFunc)
        return;
    end

    funcData=sfFunc.find('-isa','Stateflow.Data');
    if isempty(funcData)
        return;
    end

    for idx=1:length(funcData)
        if strcmp(funcData(idx).Scope,'Input')
            if contains(funcData(idx).DataType,'Bus:')
                type=extractAfter(funcData(idx).DataType,'Bus: ');
            else
                type=funcData(idx).DataType;
            end

            dataTypes=[dataTypes;type];%#ok<AGROW>
        end
    end
end


function[indices,indicesUnknown]=iVerifyActionLanguageC(system,aSynTree,chartObj)


    if iscell(aSynTree)
        aSynTree=aSynTree{:};
    end
    allAstNodes=[{aSynTree},aSynTree.children];
    currIndex=2;

    while currIndex<=length(allAstNodes)
        allAstNodes=[allAstNodes,allAstNodes{currIndex}.children];%#ok<AGROW>
        currIndex=currIndex+1;
    end

    indices=[];
    indicesUnknown=[];

    for idx=1:length(allAstNodes)
        ast=allAstNodes{idx};

        if(shouldConsiderOperator(allAstNodes{idx}))
            l_DataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
            r_DataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,chartObj);

            UnaryMinusWithUint=(isa(ast.lhs,'Stateflow.Ast.Uminus')&&...
            contains(r_DataType,'uint'))||...
            (isa(ast.rhs,'Stateflow.Ast.Uminus')&&...
            contains(l_DataType,'uint'));
            if(strcmp(l_DataType,'unknown')||strcmp(r_DataType,'unknown'))

                indicesUnknown=[indicesUnknown;getOperatorIndices(ast)];%#ok<AGROW>
            elseif~strcmp(l_DataType,r_DataType)||UnaryMinusWithUint

                indices=[indices;getOperatorIndices(ast)];%#ok<AGROW>
            end

        elseif isa(ast,'Stateflow.Ast.UserFunction')
            children=ast.children;
            dataTypes={};
            for idxChildren=1:length(children)
                dataTypes=[dataTypes;Advisor.Utils.Stateflow.getAstDataType(...
                system,children{idxChildren},chartObj)];%#ok<AGROW>
            end
            if~isempty(dataTypes)
                funcName=strtrim(regexprep(ast.sourceSnippet,'\(.*\)',''));
                dataTypesActualFunc=getDataTypesInputByFunctionName(funcName,chartObj);




                if~isempty(setdiff(dataTypesActualFunc,dataTypes))
                    indicesUnknown=[indicesUnknown;[ast.treeStart,ast.treeEnd]];%#ok<AGROW>
                end
            end
        elseif isa(ast,'Stateflow.Ast.MultiOutputFunctionCall')




            input_arg=ast.inputs;

            inpdataTypes={};
            for idxinparg=1:length(input_arg)
                inpdataTypes=[inpdataTypes;Advisor.Utils.Stateflow.getAstDataType(...
                system,input_arg{idxinparg},chartObj)];%#ok<AGROW>
            end
            if~isempty(inpdataTypes)
                [~,func]=strtok(ast.sourceSnippet,'=');
                func=regexprep(func,'=','');
                funcName=strtrim(regexprep(func,'\(.*\)',''));
                dataTypesActualFunc=getDataTypesInputByFunctionName(funcName,chartObj);


                if~isempty(setdiff(dataTypesActualFunc,inpdataTypes))
                    indicesUnknown=[indicesUnknown;[ast.treeStart,ast.treeEnd]];%#ok<AGROW>
                end
            end
        end
    end

    function operatorIndices=getOperatorIndices(ast_)
        children_=ast_.children;
        operatorIndices=[children_{1}.treeEnd+1,children_{2}.treeStart-1];
    end
end


function[indices,indicesUnknown]=iVerifyComparisonsM(system,ast,resolvedSymbolIds)

    indices=[];
    indicesUnknown=[];

    if iscell(ast)
        ast=ast{:};
    end
    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(...
    codeFragment,resolvedSymbolIds);

    nodesToConsider=mtreeObject.mtfind('Kind',{'EQ','NE','GE','LE','GT','LT','EQUALS'});
    for index=nodesToConsider.indices
        thisNode=nodesToConsider.select(index);

        leftType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,...
        thisNode.Left,resolvedSymbolIds);
        rightType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,...
        thisNode.Right,resolvedSymbolIds);

        if strcmp(leftType,'unknown')||strcmp(rightType,'unknown')



            indicesUnknown=[indicesUnknown;getOperatorIndices(ast.treeStart,thisNode)];%#ok<AGROW>
        elseif~strcmp(leftType,rightType)



            indices=[indices;getOperatorIndices(ast.treeStart,thisNode)];%#ok<AGROW>
        end

    end

    function operatorIndices=getOperatorIndices(startIdx,node)
        right=node.Right;
        left=node.Left;
        operatorIndices=[(startIdx+left.righttreepos),right.lefttreepos];
    end

end

function chk=shouldConsiderOperator(ast)


    switch(class(ast))
    case{'Stateflow.Ast.IsEqual',...
        'Stateflow.Ast.IsNotEqual',...
        'Stateflow.Ast.NegEqual',...
        'Stateflow.Ast.LesserThanGreaterThan',...
        'Stateflow.Ast.GreaterThanOrEqual',...
        'Stateflow.Ast.LesserThanOrEqual',...
        'Stateflow.Ast.LesserThan',...
        'Stateflow.Ast.GreaterThan',...
        'Stateflow.Ast.OldLesserThan',...
        'Stateflow.Ast.OldLesserThanOrEqual',...
        'Stateflow.Ast.OldGreaterThan',...
        'Stateflow.Ast.OldGreaterThanOrEqual',...
        'Stateflow.Ast.EqualAssignment'}
        chk=true;
    otherwise
        chk=false;
    end
end
