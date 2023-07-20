function jmaab_jc_0735





    checkID='jc_0735';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0735');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip']);
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;

    rec.setLicense({styleguide_license});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.ColSpan=[3,4];

    inputParamList={paramFollowLinks,paramLookUnderMasks};

    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);

    rec.setCallbackFcn(@(system,checkObj)...
    Advisor.Utils.genericCheckCallback(...
    system,...
    checkObj,...
    'ModelAdvisor:jmaab:jc_0735',...
    @checkAlgo),...
    'None','DetailStyle');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    mdladvRoot.publish(rec,sg_jmaab_group);
end


function FailingExpressions=checkAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');

    FailingExpressions=[];

    allStates=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks.Value,...
    LookUnderMasks.Value,{'-isa','Stateflow.State'});


    allStates=mdlAdvObj.filterResultWithExclusion(allStates);

    for idx=1:length(allStates)
        state=allStates{idx};
        if state.isCommented();continue;end

        bActionLanguageC=Advisor.Utils.Stateflow.isActionLanguageC(state);

        labelStr=strtrim(state.LabelString);
        if isempty(labelStr)||isequal(labelStr,'?')
            continue;
        end

        [asts]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(state);
        if isempty(asts);continue;end

        sections=asts.sections;
        for i=1:length(sections)
            roots=sections{i}.roots;
            failures=[];
            for j=1:length(roots)
                sourceSnippet=strtrim(roots{j}.sourceSnippet);
                if isempty(sourceSnippet)
                    continue;
                end

                if bActionLanguageC
                    failures=[failures,verifyCodeC(sourceSnippet,state,sections{i})];%#ok<AGROW>
                else
                    failures=[failures,verifyCodeM(sourceSnippet,state,sections{i})];%#ok<AGROW>
                end

            end
            if~isempty(failures)
                FailingExpressions=[FailingExpressions,failures];%#ok<AGROW>
            end
        end
    end
end


function failures=verifyCodeM(sourceSnippet,state,section)
    failures=[];
    T=mtree(sourceSnippet);
    nodes=T.mtfind('Kind','PRINT');
    for i=indices(nodes)
        k=nodes.select(i);
        tempObj=ModelAdvisor.ResultDetail;
        str=ModelAdvisor.Text(k.Arg.tree2str,{'bold'});
        str=[getSectionName(section),str.emitHTML];
        ModelAdvisor.ResultDetail.setData(tempObj,'SID',state,'Expression',str);
        failures=[failures,tempObj];%#ok<AGROW>
    end

end

function failures=verifyCodeC(sourceSnippet,state,section)
    failures=[];
    if~analyzeSnippet(sourceSnippet)
        failures=ModelAdvisor.ResultDetail;
        str=ModelAdvisor.Text(sourceSnippet,{'bold'});
        str=[getSectionName(section),str.emitHTML];
        ModelAdvisor.ResultDetail.setData(failures,'SID',state,'Expression',str);
    end
end


function bResult=analyzeSnippet(snippet)
    bResult=true;

    commentIndex=regexp(snippet,'%|//|/*','once');
    if~isempty(commentIndex)
        snippet=snippet(1:commentIndex-1);
    end

    snippet=strtrim(snippet);

    if isempty(snippet)
        return;
    end

    if~isequal(snippet(end),';')
        bResult=false;
        return;
    end

    text=regexprep(snippet,'\s*','');
    if~isempty(regexp(text,'(\w+=\w+,)|(\w+\(.+\),)','once'))
        bResult=false;
    end
end

function res=getSectionName(section)
    switch class(section)
    case 'Stateflow.Ast.EntrySection'
        res='en: ';
    case 'Stateflow.Ast.DuringSection'
        res='du: ';
    case 'Stateflow.Ast.ExitSection'
        res='ex: ';
    otherwise
        res='';
    end
end
