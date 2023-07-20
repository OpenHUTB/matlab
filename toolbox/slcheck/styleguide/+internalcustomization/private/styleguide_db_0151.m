function styleguide_db_0151

    rec=ModelAdvisor.Check('mathworks.maab.db_0151');



    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0151Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0151Tip');
    rec.setCallbackFcn(@db_0151_StyleOneCallback,'None','StyleOne');
    rec.Value=true;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.db_0151';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportsEditTime=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function ResultDescription=db_0151_StyleOneCallback(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');



    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:db0151CheckText'));
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:db0151ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:db0151ColTitle2')});
    ResultDescription={};tableInfo={};
    ObjsTobeHighlited={};
    m=get_param(system,'Object');
    if~isempty(m)
        chartArray=m.find('-isa','Stateflow.Chart');
    end

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        Transitions=chartObj.find('-isa','Stateflow.Transition');
        for jj=1:length(Transitions)
            obj=Transitions(jj);

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end

            indices=[];
            info={};
            label=obj.LabelString;

            sections=asts.sections;
            for i=1:length(sections)
                if isa(sections{i},'Stateflow.Ast.TransitionActionSection')
                    roots=sections{i}.roots;

                    if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        indices=[indices;...
                        verifyTransitionActionC(roots,label)];%#ok<AGROW>
                    elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        indices=[indices;...
                        verifyTransitionActionM(roots)];%#ok<AGROW>
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
                ObjsTobeHighlited{end+1}=obj;%#ok<AGROW>
            end
            tableInfo=[tableInfo;info];%#ok<AGROW>
        end
    end

    if isempty(tableInfo)
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:db0151PassMsg'));
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:db0151FailMsg'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:db0151RecAction'));
        ft.setTableInfo(tableInfo);
        mdladvObj.setCheckResultMap(ObjsTobeHighlited);
    end
    ResultDescription{1}=ft;

end

function indices=verifyTransitionActionC(roots,label)

    indices=zeros(0,2);

    for j=1:length(roots)-1
        if isempty(regexp(label(roots{j}.treeStart:roots{j+1}.treeStart),'\n','once'))
            indices=[indices;[roots{j}.treeStart,roots{j}.treeEnd]];%#ok<AGROW>
        end
    end

end

function indices=verifyTransitionActionM(roots)

    indices=zeros(0,2);

    codeFragment=roots{1}.sourceSnippet;
    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment);
    currentNode=mtreeObject.root;
    while~isempty(currentNode.Next)
        leftIndex=currentNode.lefttreepos;
        rightIndex=currentNode.Next.righttreepos;
        expressionPair=codeFragment(leftIndex:rightIndex);
        if isempty(regexp(expressionPair,'\n','once'))
            startIndex=roots{1}.treeStart-1+currentNode.lefttreepos;
            stopIndex=roots{1}.treeStart-1+currentNode.righttreepos;
            indices=[indices;[startIndex,stopIndex]];%#ok<AGROW>
        end
        currentNode=currentNode.Next;
    end

end

