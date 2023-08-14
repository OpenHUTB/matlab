function jmaab_jm_0012





    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jm_0012',false,@CheckAlgo,'None');
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});


    entries={
    ['jm_0012_a1: ',DAStudio.message('ModelAdvisor:jmaab:jm_0012_a1_subtitle')],...
    ['jm_0012_a2: ',DAStudio.message('ModelAdvisor:jmaab:jm_0012_a2_subtitle')],...
    ['jm_0012_a3: ',DAStudio.message('ModelAdvisor:jmaab:jm_0012_a3_subtitle')]};

    ipA=ModelAdvisor.InputParameter;
    ipA.ColSpan=[1,4];
    ipA.RowSpan=[1,5];
    ipA.Name=DAStudio.message('ModelAdvisor:jmaab:jm_0012_a_group_title');
    ipA.Entries=entries;
    ipA.Value=0;
    ipA.Type='RadioButton';
    ipA.Visible=false;

    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');

    paramFollowLinks.RowSpan=[6,6];
    paramFollowLinks.ColSpan=[1,2];

    paramLookUnderMasks.RowSpan=[6,6];
    paramLookUnderMasks.ColSpan=[3,4];

    rec.setInputParametersLayoutGrid([6,4]);
    rec.setInputParameters({ipA,paramFollowLinks,paramLookUnderMasks});
    rec.setInputParametersCallbackFcn(...
    @(taskobj,tag,handle)slcheck.Check.defaultInputParamCallback...
    (taskobj,tag,handle));


    rec.setLicense({styleguide_license,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_jmaab_group,sg_maab_group});

end


function violations=CheckAlgo(system)


    violations=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    ip=collectInputParameters(mdladvObj);


    chartArray=Advisor.Utils.Stateflow.sfFindSys(system,ip.FL,ip.LUM,{'-isa','Stateflow.Chart'});
    chartArray=mdladvObj.filterResultWithExclusion(chartArray);

    for idx=1:length(chartArray)
        chartObj=chartArray{idx};




        events=chartObj.find('-isa','Stateflow.Event');

        if isempty(events)
            continue;
        end

        if ip.A1
            failures=arrayfun(@(x)strcmp(x.scope,'Output'),events);
            failures=arrayfun(@(x)createResultDetailSFData(x,'a1'),events(~failures));
            violations=[violations;failures];%#ok<AGROW>
            continue;
        end


        statesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');

        for jdx=1:length(statesTransitions)
            sfitem=statesTransitions(jdx);


            [ast,~]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfitem);

            if isempty(ast)
                continue;
            end


            result=[];
            treeStart=[];

            sections=ast.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)
                    root=roots{j};


                    if ismember(root.treeStart,treeStart)
                        continue;
                    else
                        treeStart=[treeStart;root.treeStart];%#ok<AGROW>
                        if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                            result=[result;iCheckEventBroadcastC(roots{j},events,ip)];%#ok<AGROW>
                        elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                            result=[result;iCheckEventBroadcastM(roots{j},events,ip)];%#ok<AGROW>
                        end
                    end
                end
            end


            for i=1:length(result)
                current=result(i);
                violations=[violations;createResultDetail(sfitem,current.subcheck,...
                sfitem.LabelString,current.indices(1),current.indices(2))];%#ok<AGROW>
            end
        end
    end
end


function result=iCheckEventBroadcastC(ast,events,ip)


    result=[];

    if(isa(ast,'Stateflow.Ast.SendFunction'))

        inputs=ast.children;
        if(isa(inputs{1},'Stateflow.Ast.ExplicitEvent'))

            if ip.A2&&(length(inputs)~=2)&&isLocalEvent(inputs{1}.sourceSnippet,events)



                res.indices=[ast.treeStart,ast.treeEnd];
                res.subcheck='a2';
                result=[result,res];
            end

            if ip.A3


                dot=regexp(inputs{1}.sourceSnippet,'\.','once');
                if(isempty(dot)&&isLocalEvent(inputs{1}.sourceSnippet,events))
                    res.indices=[ast.treeStart,ast.treeEnd];
                    res.subcheck='a3';
                    result=[result,res];
                end
            end
        end
    elseif(isa(ast,'Stateflow.Ast.EventBroadcastAction'))


        event=ast.children{1};
        if(isa(event,'Stateflow.Ast.ExplicitEvent'))


            if ip.A3||(ip.A2&&isLocalEvent(event.sourceSnippet,events))
                res.indices=[event.treeStart,event.treeEnd];
                res.subcheck=ip.subcheck;
                result=[result,res];
            end
        end
    end


    children=ast.children;
    for i=1:length(children)
        result=[result;iCheckEventBroadcastC(children{i},events,ip)];%#ok<AGROW>
    end
end


function notOutputEvent=isLocalEvent(flaggedEvent,events)
    notOutputEvent=true;
    for i=1:length(events)
        if strcmp(events(i).Name,flaggedEvent)&&~strcmp(events(i).Scope,'Local')
            notOutputEvent=false;
            return;
        end
    end
end


function result=iCheckEventBroadcastM(astRoot,events,ip)

    result=[];

    if isempty(astRoot.sourceSnippet)
        return;
    end


    treeObject=Advisor.Utils.Stateflow.createMtreeObject(astRoot.sourceSnippet);
    for eventIndex=1:length(events)
        event=events(eventIndex);

        if~strcmp(event.Scope,'Local')
            continue;
        end


        callTrees=treeObject.mtfind('String',event.Name);

        if callTrees.isempty
            continue;
        end


        for treeIndex=callTrees.indices
            thisTree=callTrees.select(treeIndex);
            switch thisTree.Parent.kind
            case 'CALL'








                parObj=thisTree.Parent.Parent.Tree;
                sendFcn=parObj.mtfind('String','send');
                if(~sendFcn.isempty)&&...
                    (isempty(thisTree.Parent.Parent.Right.Next)||strcmp(ip.subcheck,'a3'))
                    leftIndex=astRoot.treeStart+thisTree.Parent.lefttreepos-1;
                    rightIndex=astRoot.treeStart+thisTree.Parent.righttreepos-1;
                    res.indices=[leftIndex,rightIndex];
                    res.subcheck=ip.subcheck;
                    result=[result,res];%#ok<AGROW>
                end
            case 'DOT'
                parent=thisTree.Parent.Parent;
                if~(strcmp(parent.kind,'CALL')&&strcmp(parent.Left.string,'send'))...
                    ||strcmp(ip.subcheck,'a2')
                    leftIndex=astRoot.treeStart+thisTree.lefttreepos-1;
                    rightIndex=astRoot.treeStart+thisTree.righttreepos-1;
                    res.indices=[leftIndex,rightIndex];
                    res.subcheck=ip.subcheck;
                    result=[result,res];%#ok<AGROW>
                end
            case{'EXPR','PRINT'}
                leftIndex=astRoot.treeStart+thisTree.lefttreepos-1;
                rightIndex=astRoot.treeStart+thisTree.righttreepos-1;
                res.indices=[leftIndex,rightIndex];
                res.subcheck=ip.subcheck;
                result=[result,res];%#ok<AGROW>
            end
        end
    end
end


function ip=collectInputParameters(maObj)
    inputParams=maObj.getInputParameters;
    switch inputParams{1}.Value
    case 0
        ip.A1=true;
        ip.A2=false;
        ip.A3=false;
        ip.subcheck='a1';
    case 1
        ip.A1=false;
        ip.A2=true;
        ip.A3=false;
        ip.subcheck='a2';
    case 2
        ip.A1=false;
        ip.A2=false;
        ip.A3=true;
        ip.subcheck='a3';
    otherwise
        ip.A1=false;
        ip.A2=false;
        ip.A3=false;
        ip.subcheck='';
    end

    ip.FL=inputParams{2}.Value;
    ip.LUM=inputParams{3}.Value;
end


function viola=createResultDetail(sfItem,id,sourceSnippet,startIndex,endIndex)
    viola=ModelAdvisor.ResultDetail;

    viola.Title=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_subtitle'));
    viola.Status=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_warn'));
    viola.RecAction=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_rec_action'));
    viola.Description='IGNORE';

    ModelAdvisor.ResultDetail.setData(viola,'SID',sfItem,'Expression',sourceSnippet,'TextStart',startIndex,'TextEnd',endIndex);
end


function viola=createResultDetailSFData(sfItem,id)
    viola=ModelAdvisor.ResultDetail;

    viola.Title=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_subtitle'));
    viola.Status=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_warn'));
    viola.RecAction=DAStudio.message(strcat('ModelAdvisor:jmaab:jm_0012_',id,'_rec_action'));
    viola.Description='IGNORE';

    ModelAdvisor.ResultDetail.setData(viola,'SID',sfItem);
end

