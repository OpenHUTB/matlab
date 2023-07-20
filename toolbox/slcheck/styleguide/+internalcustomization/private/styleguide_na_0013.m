function styleguide_na_0013








    rec=ModelAdvisor.Check('mathworks.maab.na_0013');



    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na0013Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na0013Tip');
    rec.setCallbackFcn(@na_0013_StyleOneCallback,'PostCompile','StyleOne');
    rec.Value=false;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0013';
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
    rec.SupportExclusion=true;
end

function ResultDescription=na_0013_StyleOneCallback(system)

    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': na_0013'];

    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:na0013CheckText'));
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na0013ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:na0013ColTitle2')});
    tableInfo={};tableInfoUnknown={};
    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or',...
        '-isa','Stateflow.Transition');
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end

            indices=[];indicesUnknown=[];
            info={};infoUnknown={};

            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)

                    if Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        [indicesTemp,indicesUnknownTemp]=...
                        iVerifyComparisonsM(system,roots{j},resolvedSymbolIds);
                    elseif Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        [indicesTemp,indicesUnknownTemp]=...
                        iVerifyComparisonsC(system,roots{j},chartObj);
                    end

                    indices=[indices;indicesTemp];%#ok<AGROW>
                    indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
                end
            end
            for i=1:size(indices,1)

                obj=mdladvObj.filterResultWithExclusion(obj);
                if isempty(obj)
                    continue;
                end
                if isa(obj,'Stateflow.State')
                    linkStr=ModelAdvisor.Text([obj.Path,'/',obj.Name]);
                else
                    linkStr=ModelAdvisor.Text(obj.Path);
                end
                objID=Simulink.ID.getSID(obj);
                linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
                info=[info;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indices(i,:)),linkStr}];
            end
            tableInfo=[tableInfo;info];%#ok<AGROW>
            for i=1:size(indicesUnknown,1)

                obj=mdladvObj.filterResultWithExclusion(obj);
                if isempty(obj)
                    continue;
                end
                if isa(obj,'Stateflow.State')
                    linkStr=ModelAdvisor.Text([obj.Path,'/',obj.Name]);
                else
                    linkStr=ModelAdvisor.Text(obj.Path);
                end
                objID=Simulink.ID.getSID(obj);
                linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
                infoUnknown=[infoUnknown;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indicesUnknown(i,:)),linkStr}];
            end
            tableInfoUnknown=[tableInfoUnknown;infoUnknown];%#ok<AGROW>
        end
    end
    if isempty(tableInfo)
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatus('pass');
        if~isempty(tableInfoUnknown)
            inconclusiveMsg=[ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:na0013PassMsg'))...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoteMessage'),{'bold'})...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:na0013InconclusiveMsg1'))...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:na0013InconclusiveMsg2'))];
            ft.setSubResultStatusText(inconclusiveMsg);
            ft.setTableInfo(tableInfoUnknown);
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0013PassMsg'));
        end
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0013FailMsg'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na0013RecAction'));
        ft.setTableInfo(tableInfo);
    end
    ResultDescription{end+1}=ft;
end

function[indices,indicesUnknown]=iVerifyComparisonsC(system,ast,chartObj)



    allAstNodes=[{ast},ast.children];
    currIndex=2;

    while currIndex<=length(allAstNodes)
        allAstNodes=[allAstNodes,allAstNodes{currIndex}.children];%#ok<AGROW>
        currIndex=currIndex+1;
    end

    indices=[];
    indicesUnknown=[];

    for idx=1:length(allAstNodes)
        ast=allAstNodes{idx};
        if(isaComparison(allAstNodes{idx}))
            l_DataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
            r_DataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,chartObj);

            UnaryMinusWithUint=(isa(ast.lhs,'Stateflow.Ast.Uminus')&&...
            contains(r_DataType,'uint'))||...
            (isa(ast.rhs,'Stateflow.Ast.Uminus')&&...
            contains(l_DataType,'uint'));
            if(strcmp(l_DataType,'unknown')||strcmp(r_DataType,'unknown'))
                indicesUnknown=[indicesUnknown;[ast.treeStart,ast.treeEnd]];%#ok<AGROW>
            elseif~strcmp(l_DataType,r_DataType)||UnaryMinusWithUint
                indices=[indices;[ast.treeStart,ast.treeEnd]];%#ok<AGROW>
            end
        end
    end

end


function[indices,indicesUnknown]=iVerifyComparisonsM(system,ast,resolvedSymbolIds)

    indices=[];
    indicesUnknown=[];
    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(...
    codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Kind',{'EQ','NE','GE','LE','GT','LT'});
    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        leftType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,...
        thisNode.Left,resolvedSymbolIds);
        rightType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,...
        thisNode.Right,resolvedSymbolIds);

        if strcmp(leftType,'unknown')||strcmp(rightType,'unknown')
            leftIndex=ast.treeStart+thisNode.lefttreepos-1;
            rightIndex=ast.treeStart+thisNode.righttreepos-1;
            indicesUnknown=[indicesUnknown;[leftIndex,rightIndex]];%#ok<AGROW>
        elseif~strcmp(leftType,rightType)
            leftIndex=ast.treeStart+thisNode.lefttreepos-1;
            rightIndex=ast.treeStart+thisNode.righttreepos-1;
            indices=[indices;[leftIndex,rightIndex]];%#ok<AGROW>      
        end

    end

end

function chk=isaComparison(ast)


    switch(class(ast))
    case 'Stateflow.Ast.IsEqual'
        chk=true;
    case 'Stateflow.Ast.IsNotEqual'
        chk=true;
    case 'Stateflow.Ast.NegEqual'
        chk=true;
    case 'Stateflow.Ast.LesserThanGreaterThan'
        chk=true;
    case 'Stateflow.Ast.GreaterThanOrEqual'
        chk=true;
    case 'Stateflow.Ast.LesserThanOrEqual'
        chk=true;
    case 'Stateflow.Ast.LesserThan'
        chk=true;
    case 'Stateflow.Ast.GreaterThan'
        chk=true;
    case 'Stateflow.Ast.OldLesserThan'
        chk=true;
    case 'Stateflow.Ast.OldLesserThanOrEqual'
        chk=true;
    case 'Stateflow.Ast.OldGreaterThan'
        chk=true;
    case 'Stateflow.Ast.OldGreaterThanOrEqual'
        chk=true;
    otherwise
        chk=false;
    end
end

