function styleguide_jc_0521






    rec=ModelAdvisor.Check('mathworks.maab.jc_0521');



    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0521Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0521Tip');
    rec.setCallbackFcn(@jc_0521_StyleOneCallback,'None','StyleOne');
    rec.Value=true;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0521';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function ResultDescription=jc_0521_StyleOneCallback(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jc_0521'];
    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:jc0521CheckText'));
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jc0521ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:jc0521ColTitle2')});

    tableInfo={};
    ResultDescription={};
    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        funcList=chartObj.find('-isa','Stateflow.Function');
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end
            info={};

            indices=[];


            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)

                    if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        indices=[indices;...
                        iVerifyComparisonsC(roots{j},funcList)];%#ok<AGROW>
                    elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        indices=[indices;...
                        iVerifyComparisonsM(roots{j},funcList)];%#ok<AGROW>                
                    end

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
                info=[info;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indices(i,:)),linkStr}];%#ok<AGROW>

            end
            tableInfo=[tableInfo;info];%#ok<AGROW>
        end
    end
    if(isempty(tableInfo))
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0521PassMsg'));
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0521FailMsg'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:jc0521RecAction'));
        ft.setTableInfo(tableInfo);
    end
    ResultDescription{1}=ft;
end

function indices=iVerifyComparisonsC(ast,funcList)


    indices=[];
    if(isaComparisonC(ast))


        isLeftFn=isa(ast.lhs,'Stateflow.Ast.UserFunction');
        isRightFn=isa(ast.rhs,'Stateflow.Ast.UserFunction');

        if isLeftFn
            if ast.lhs.id>0&&isa(idToHandle(sfroot,ast.lhs.id),'Stateflow.Function')
                indices=[indices;[ast.treeStart,ast.treeEnd]];
            end
        end
        if isRightFn
            if ast.rhs.id>0&&isa(idToHandle(sfroot,ast.rhs.id),'Stateflow.Function')
                indices=[indices;[ast.treeStart,ast.treeEnd]];
            end
        end
    end

    children=ast.children;
    for i=1:length(children)
        indices=[indices;iVerifyComparisonsC(children{i},funcList)];%#ok<AGROW>
    end
end

function indices=iVerifyComparisonsM(ast,funcList)
    indices=[];
    mtreeObject=mtree(ast.sourceSnippet);
    callTrees=mtreeObject.mtfind('Kind','CALL');
    for index=callTrees.indices
        thisCall=callTrees.select(index);
        for i=1:length(funcList)
            if strcmp(thisCall.Left.string,funcList(i).Name)==1
                if isaComparisonM(thisCall.Parent)
                    leftIndex=ast.treeStart+thisCall.lefttreepos-1;
                    rightIndex=ast.treeStart+thisCall.righttreepos-1;
                    indices=[indices;[leftIndex,rightIndex]];%#ok<AGROW>
                end
            end
        end
    end
end

function chk=isaComparisonC(ast)


    switch(class(ast))
    case 'Stateflow.Ast.IsEqual',chk=true;
    case 'Stateflow.Ast.IsNotEqual',chk=true;
    case 'Stateflow.Ast.NegEqual',chk=true;
    case 'Stateflow.Ast.LesserThanGreaterThan',chk=true;
    case 'Stateflow.Ast.GreaterThanOrEqual',chk=true;
    case 'Stateflow.Ast.LesserThanOrEqual',chk=true;
    case 'Stateflow.Ast.LesserThan',chk=true;
    case 'Stateflow.Ast.GreaterThan',chk=true;
    case 'Stateflow.Ast.OldLesserThan',chk=true;
    case 'Stateflow.Ast.OldLesserThanOrEqual',chk=true;
    case 'Stateflow.Ast.OldGreaterThan',chk=true;
    case 'Stateflow.Ast.OldGreaterThanOrEqual',chk=true;
    otherwise,chk=false;
    end
end

function result=isaComparisonM(treeNode)
    switch treeNode.kind
    case 'EQ',result=true;
    case 'NE',result=true;
    case 'GE',result=true;
    case 'LE',result=true;
    case 'GT',result=true;
    case 'LT',result=true;
    otherwise,result=false;
    end
end

