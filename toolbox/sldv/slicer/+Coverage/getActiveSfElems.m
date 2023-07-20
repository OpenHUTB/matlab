function[activeIds,atomicChartStruct]=getActiveSfElems(cvd,chart,...
    actionsToMark,...
    context,...
    firstEntry,...
    markOnlyFcns)













    atomicChartStruct=[];

    if nargin<4
        context=[];
    end

    if nargin<5
        firstEntry=true;
    end
    if nargin<6
        markOnlyFcns=false;
    end
    enterMap=containers.Map('KeyType','double','ValueType','int8');
    execMap=containers.Map('KeyType','double','ValueType','int8');
    exitMap=containers.Map('KeyType','double','ValueType','int8');

    subchartMap=containers.Map('KeyType','double','ValueType','int8');
    visitMaps=struct('enterMap',enterMap,...
    'execMap',execMap,...
    'exitMap',exitMap,...
    'subchartMap',subchartMap,...
    'isFirstEntry',false,...
    'context',context);

    checkEntry=actionsToMark(1);
    checkExec=actionsToMark(2);
    checkExit=actionsToMark(3);

    if isempty(cvd)

        activeIds=[getAllElems(chart);chart.Id]';
    else
        substates=getSfElements(chart);
        slMlFcns=removeCommented(chart.find('-isa','Stateflow.SLFunction','-or',...
        '-isa','Stateflow.EMFunction'));
        if~markOnlyFcns


            if checkEntry||isempty(substates)


                visitMaps.isFirstEntry=firstEntry;
                markEntry(chart,cvd,visitMaps);
            end

            if checkExec

                markExecution(chart,cvd,visitMaps);
            end

            if checkExit
                markExit(chart,cvd,visitMaps);
            end


            addMissingParentActivity(chart,visitMaps);
        end

        Stateflow.internal.UsesDatabase.RehashUsesInObject(chart.Id);



        addActiveGraphFncs(chart,cvd,visitMaps);



        addMissingTransitions(chart,cvd,visitMaps);


        fcnIds=arrayfun(@(obj)obj.Id,slMlFcns)';

        activeIds=unique([getActiveIds(visitMaps.execMap)...
        ,getActiveIds(visitMaps.enterMap),getActiveIds(visitMaps.exitMap),fcnIds]);
    end

    allSubcharts=chart.find('-isa','Stateflow.AtomicSubchart');
    for i=1:length(allSubcharts)
        atomicChartObj=allSubcharts(i);
        id=atomicChartObj.Id;
        atomicChartContext=modelslicerprivate('buildSubChartContext',...
        atomicChartObj,context,chart);
        subchart=atomicChartObj.Subchart;
        if isKey(visitMaps.subchartMap,id)&&visitMaps.subchartMap(id)>0
            if~isempty(cvd)
                checkSubChartEntered=isKey(visitMaps.enterMap,id);
                checkSubChartExecuted=~(visitMaps.subchartMap(id)==int8(2))...
                &&isKey(visitMaps.execMap,id);

                checkSubChartExited=isKey(visitMaps.exitMap,id);
            else
                checkSubChartEntered=true;
                checkSubChartExecuted=true;
                checkSubChartExited=true;
            end
            actionsToMarkSubchart=[checkSubChartEntered;...
            checkSubChartExecuted;...
            checkSubChartExited];
            onlyFcn=false;
        else
            actionsToMarkSubchart=[false;false;false];
            onlyFcn=true;
        end

        [childIDs,subChildStruct]=Coverage.getActiveSfElems(cvd,subchart,...
        actionsToMarkSubchart,...
        atomicChartContext,...
        firstEntry,...
        onlyFcn);
        s=struct('AtomicSubID',id,'Context',atomicChartContext,'childIDs',childIDs);

        atomicChartStruct=[atomicChartStruct,s,subChildStruct];%#ok<AGROW>
    end
end

function entered=markEntry(stateOrChart,cvd,visitMaps)

    entered=true;

    Q={stateOrChart};
    while~isempty(Q)
        node=Q{1};
        Q(1)=[];
        if isCommentedOut(node)||isKey(visitMaps.enterMap,node.Id)
            continue;
        end
        visitMaps.enterMap(node.Id)=int8(1);

        if isa(node,'Stateflow.AtomicSubchart')
            if~isKey(visitMaps.subchartMap,node.Id)
                visitMaps.subchartMap(node.Id)=int8(1);
            end
            continue;
        end






        historyMetric=getHistoryMetric(cvd);
        [activeStates,hasHistory]=getExecInfoFromCov(cvd,node,historyMetric,visitMaps.context);






        if~hasHistory

            checkDefaultTrans=true;
        else



            checkDefaultTrans=isWindowBeforeCovStart(cvd,node,visitMaps.context);
        end

        if checkDefaultTrans||visitMaps.isFirstEntry
            trans=node.defaultTransitions;
            if~isempty(trans)
                exploreTransitions(trans,cvd,visitMaps,node);
            end
        end

        for i=1:length(activeStates)
            Q{end+1}=activeStates(i);%#ok<AGROW>
        end
    end
end


function markExecution(stateOrChart,cvd,visitMaps)

    Q={stateOrChart};
    while~isempty(Q)
        node=Q{1};
        Q(1)=[];
        if isCommentedOut(node)||isKey(visitMaps.execMap,node.Id)
            continue;
        end
        visitMaps.execMap(node.Id)=int8(1);
        if isa(node,'Stateflow.Chart')||isa(node,'Stateflow.State')||...
            isa(node,'Stateflow.StateTransitionTableChart')||isa(node,'Stateflow.Function')






            execMetric=getExecMetric(cvd);
            activeStates=getExecInfoFromCov(cvd,node,execMetric,visitMaps.context);

            if isa(node,'Stateflow.State')
                outerTrans=removeCommented(node.outerTransitions);
                innerTrans=removeCommented(node.innerTransitions);

                [exit,stopTraversal]=exploreTransitions(outerTrans,cvd,visitMaps,node);
                if exit
                    markExit(node,cvd,visitMaps);
                end



                if~(stopTraversal)
                    [exit,~]=exploreTransitions(innerTrans,cvd,visitMaps);
                    if exit
                        markExit(node,cvd,visitMaps);
                    end
                end
            end



            for i=1:length(activeStates)
                Q{end+1}=activeStates(i);%#ok<AGROW>
            end
        elseif isa(node,'Stateflow.AtomicSubchart')
            rt=sfroot;
            trans=rt.find('-isa','Stateflow.Transition','Source',node);
            trans=removeCommented(trans);
            [exit,alwaysExit]=exploreTransitions(trans,cvd,visitMaps,node);
            if exit
                markExit(node,cvd,visitMaps);
            end
            visitMaps.subchartMap(node.Id)=int8(1)+int8(alwaysExit);
        end
    end
end

function markExit(stateOrchart,cvd,visitMaps)

    Q={stateOrchart};
    while~isempty(Q)
        node=Q{1};
        Q(1)=[];
        if isCommentedOut(node)||isKey(visitMaps.exitMap,node.Id)
            continue;
        end
        visitMaps.exitMap(node.Id)=int8(1);
        if isa(node,'Stateflow.AtomicSubchart')
            if~isKey(visitMaps.subchartMap,node.Id)
                visitMaps.subchartMap(node.Id)=int8(1);
            end
            continue;
        end

        if isa(node,'Stateflow.Chart')




            exitMetric=getExecMetric(cvd);
        else

            exitMetric=getExitMetric(cvd);
        end
        exitedStates=getExecInfoFromCov(cvd,node,exitMetric,visitMaps.context);
        for i=1:length(exitedStates)
            Q{end+1}=exitedStates(i);%#ok<AGROW>
        end
    end
end

function[activeStates,hasMetric]=getExecInfoFromCov(cvd,node,metric,context)










    activeStates=[];
    hasMetric=false;

    if~(isa(node,'Stateflow.Chart')||...
        isa(node,'Stateflow.State')||...
        isa(node,'Stateflow.StateTransitionTableChart'))
        return;
    end

    substates=getSfElements(node);
    if strcmp(node.Decomposition,'PARALLEL_AND')||length(substates)==1
        activeStates=substates;
        return;
    end

    if nargin>3&&~isempty(context)
        sfObj={context,node};
    else
        sfObj=node;
    end
    if isa(cvd,'Coverage.CovData')

        [~,detail]=getCoverageInfo(cvd,sfObj,'decision');
        if~(isempty(detail)||~isfield(detail,'decision'))
            idx=Coverage.CovData.getDecStructIdx(detail,metric);
            if isempty(idx)
                return;
            end
            hasMetric=true;
            stateNames=cvd.getActiveStatesFromDec(sfObj,idx);
            for i=1:length(substates)
                if ismember(substates(i).name,stateNames)
                    activeStates=[activeStates,substates(i)];%#ok<AGROW>
                end
            end
        end
    else
        [activeStates,hasMetric]=cvd.getActiveStates(sfObj,metric,substates);
    end
end

function[entered,foundLastTrue]=exploreTransitions(trans,cvd,visitMaps,sourceState)
















    foundLastTrue=false;
    entered=false;
    if isempty(trans)
        return;
    end

    if nargin<4
        sourceState=[];
    end

    trans=hSortTransitions(trans);
    for i=1:length(trans)
        t=trans(i);
        [exitTrans,lastTrue]=traverseTransition(t,cvd,visitMaps,sourceState);
        foundLastTrue=foundLastTrue||lastTrue;
        entered=entered||exitTrans;
        if(foundLastTrue)
            break;
        end
    end
end

function val=getTransitionActivity(t,cvd,context)





    if nargin>2&&~isempty(context)
        sfObj={context,t};
    else
        sfObj=t;
    end
    [~,detail]=getDecisionInfo(cvd,sfObj);
    if~isempty(detail)
        if detail.decision.outcome(2).executionCount

            val=int8(1)+int8(detail.decision.outcome(1).executionCount==0);
        else
            val=int8(0);
        end
    else
        val=int8(2);
    end
end

function[entered,lastTrue]=traverseTransition(trans,cvd,visitMaps,sourceState)




    if nargin<4
        sourceState=[];
    end

    entered=false;
    lastTrue=false;
    tId=trans.Id;

    if isKey(visitMaps.execMap,tId)
        entered=visitMaps.execMap(tId)>0;
        lastTrue=visitMaps.execMap(tId)>1;

        return;
    end

    val=getTransitionActivity(trans,cvd,visitMaps.context);
    visitMaps.execMap(tId)=val;


    linkId=sf('get',tId,'.subLink.next');
    while linkId~=0
        visitMaps.execMap(linkId)=val;
        linkId=sf('get',linkId,'.subLink.next');
    end

    if~val
        return;
    else
        if(val==int8(2))
            lastTrue=true;
        end
    end

    dst=trans.Destination;
    if isa(dst,'Stateflow.State')||isa(dst,'Stateflow.AtomicSubchart')
        entered=true;


        addParallelAncestorsForSupertransition(sourceState,dst,cvd,visitMaps);
        markEntry(dst,cvd,visitMaps);
    elseif isa(dst,'Stateflow.Junction')
        visitMaps.execMap(dst.Id)=int8(1);
        trans=removeCommented(dst.sourcedTransitions);
        if isempty(trans)
            if strcmp(dst.Type,'HISTORY')


                dstState=dst.getParent;
                entered=true;


                addParallelAncestorsForSupertransition(sourceState,dstState,cvd,visitMaps);
                markEntry(dstState,cvd,visitMaps);
            else

                entered=false;
            end
        else
            [entered,nextTrue]=exploreTransitions(trans,cvd,visitMaps,sourceState);
            lastTrue=lastTrue&&nextTrue;
        end
    end
    visitMaps.execMap(tId)=int8(1+lastTrue);
end


function addParallelAncestorsForSupertransition(srcState,dstState,cvd,visitMaps)








    if~isempty(srcState)&&...
        (isa(srcState,'Stateflow.State')||isa(srcState,'Stateflow.AtomicSubchart'))
        srcAncestors=sf('AllAncestorsOf',srcState.Id);
        dstAncestors=sf('AllAncestorsOf',dstState.Id);

        srcDepth=length(srcAncestors);
        dstDepth=length(dstAncestors);

        if dstDepth>srcDepth
            srcAncestors=[zeros(1,dstDepth-srcDepth),srcAncestors];
        elseif srcDepth>dstDepth
            dstAncestors=[zeros(1,srcDepth-dstDepth),dstAncestors];
        end

        commonIdx=find(srcAncestors==dstAncestors);
        ancestorsToConsider=dstAncestors(1:commonIdx(1)-1);
    else
        ancestorsToConsider=sf('AllAncestorsOf',dstState.Id);
    end

    for i=1:length(ancestorsToConsider)
        parent=idToHandle(sfroot,ancestorsToConsider(i));
        if isa(parent,'Stateflow.State')&&strcmp(parent.Decomposition,'PARALLEL_AND')
            substateIds=sf('SubstatesOf',ancestorsToConsider(i));


            substateIds=setdiff(substateIds,[ancestorsToConsider,dstState.Id]);
            for j=1:length(substateIds)
                substateObj=idToHandle(sfroot,substateIds(j));
                markEntry(substateObj,cvd,visitMaps);
            end
        end
    end

end

function yesno=isWindowBeforeCovStart(cvd,node,context)
    yesno=true;
    if~isa(cvd,'Coverage.CovData')
        return;
    end
    if nargin>2&&~isempty(context)
        sfObj={context,node};
    else
        sfObj=node;
    end
    decIds=getCovIdx(cvd,sfObj,'decision');
    for dId=decIds
        pos=cvd.covStreamMap.Idx(dId,:);
        if isempty(pos)||isequal(pos,[0,0])
            continue;
        end
        constrTimeintervals=cvd.getConstraintTimeIntervals;
        covStartTime=cvd.covStreamMap.Data(pos(1),1);

        if isempty(constrTimeintervals)
            setStartTime=cvd.startTime;
        else
            setStartTime=constrTimeintervals(1,1);
        end
        yesno=yesno&&(covStartTime>setStartTime);
    end
end

function activeIds=getActiveIds(map)
    keys=map.keys;
    values=map.values;
    values=[values{:}];
    activeIds=[keys{:}];
    activeIds=activeIds((values>0&values<3));
end

function trans=hSortTransitions(trans)
    execOrder=arrayfun(@(t)t.ExecutionOrder,trans);
    [~,sortOrder]=sort(execOrder);
    trans=trans(sortOrder);
end

function statesOrCharts=getSfElements(parent)




    children=parent.getHierarchicalChildren;

    states=children(arrayfun(@(c)isa(c,'Stateflow.State'),children));
    if isa(parent,'Stateflow.Chart')
        atomicSubCharts=parent.find('-isa','Stateflow.AtomicSubchart','Path',parent.Path);
    else
        atomicSubCharts=parent.find('-isa','Stateflow.AtomicSubchart','Path',[parent.Path,'/',parent.Name]);
    end
    linkCharts=children(arrayfun(@(c)isa(c,'Stateflow.LinkChart'),children));
    subCharts=arrayfun(@(l)Stateflow.SLINSF.SubchartMan.getSubchartState(l),linkCharts,'uni',false);
    subCharts=[subCharts{:}];
    statesOrCharts=unique([reshape(states,1,length(states))...
    ,reshape(subCharts,1,length(subCharts))...
    ,reshape(atomicSubCharts,1,length(atomicSubCharts))]);

    boxes=children(arrayfun(@(c)isa(c,'Stateflow.Box'),children));
    for i=1:length(boxes)
        statesOrCharts=[statesOrCharts,getSfElements(boxes(i))];%#ok<AGROW>
    end
    statesOrCharts=removeCommented(statesOrCharts);
end

function addMissingTransitions(chart,cvd,visitMaps)



    if~isa(cvd,'Coverage.CovData')
        return;
    end
    transitions=chart.find('-isa','Stateflow.Transition');
    for i=1:length(transitions)
        trans=transitions(i);
        idx=cvd.getCovIdx(trans,'decision');


        if~isempty(idx)&&...
            ~isKey(visitMaps.execMap,trans.Id)
            val=getTransitionActivity(trans,cvd,visitMaps.context);


            if(val>0)
                owner=trans.getParent;
                traverseTransition(trans,cvd,visitMaps,owner);
            end
        end
    end
end

function addMissingParentActivity(chart,visitMaps)

    addParentsToMap(visitMaps.enterMap);
    addParentsToMap(visitMaps.execMap);

    function addParentsToMap(map)
        Ids=getActiveIds(map);
        for id=Ids
            obj=idToHandle(sfroot,id);
            if~(isa(obj,'Stateflow.State')||...
                isa(obj,'Stateflow.AtomicSubchart')||...
                isa(obj,'Stateflow.Transition'))
                continue;
            end
            parent=obj.getParent;

            while~isKey(map,parent.Id)
                if parent==chart
                    break;
                end
                map(parent.Id)=int8(1);
                parent=parent.getParent;
            end
        end
    end

end

function addActiveGraphFncs(chart,cvd,visitMaps)

    graphFcns=chart.find('-isa','Stateflow.Function');
    atomicBoxes=chart.find('-isa','Stateflow.AtomicBox');
    boxParent=containers.Map('keyType','double','valueType','double');

    for i=1:length(atomicBoxes)
        fcns=atomicBoxes(i).Subchart.find('-isa','Stateflow.Function');
        for j=1:length(fcns)
            boxParent(fcns(j).Id)=atomicBoxes(i).Id;
        end
        graphFcns=[graphFcns;fcns];%#ok<AGROW>
    end

    while~isempty(graphFcns)
        fcnObj=graphFcns(1);
        graphFcns(1)=[];
        [isFcnActive,reAnalyze]=isGrFunctionActive(fcnObj);
        if isFcnActive
            markEntry(fcnObj,cvd,visitMaps);
            parent=fcnObj.getParent;
            while isa(parent,'Stateflow.Box')&&~isKey(visitMaps.enterMap,parent.Id)
                visitMaps.enterMap(parent.Id)=int8(1);
                parent=parent.getParent;
            end
            if isKey(boxParent,fcnObj.Id)
                parentId=boxParent(fcnObj.Id);
                if~isKey(visitMaps.enterMap,parentId)
                    visitMaps.enterMap(parentId)=int8(1);
                end
            end
        else
            if reAnalyze

                graphFcns(end+1)=fcnObj;
            else

                visitMaps.enterMap(fcnObj.Id)=int8(0);
            end
        end
    end

    function[yesno,reAnalyze]=isGrFunctionActive(fcnObj)



        useStruct=Stateflow.internal.UsesDatabase.GetAllUsesOfObject(fcnObj.Id);
        yesno=false;



        reAnalyze=false;

        if isempty(useStruct)
            return;
        end
        useIds=arrayfun(@(s)s.idWhereUsed,useStruct);
        for k=1:length(useIds)
            userId=useIds(k);
            used=isKey(visitMaps.execMap,userId)||...
            isKey(visitMaps.enterMap,userId)||...
            isKey(visitMaps.exitMap,userId);
            if~used
                userObj=idToHandle(sfroot,userId);



                if isa(userObj,'Stateflow.Transition')
                    ancestors=[userObj.getParent.Id,sf('AllAncestorsOf',userObj.getParent.Id)];

                    callerFcnId=ancestors(find(arrayfun(@(id)sf('get',id,'.type')==2,ancestors),1));
                    if~isempty(callerFcnId)
                        if~isKey(visitMaps.enterMap,callerFcnId)

                            reAnalyze=true;
                        else


                            reAnalyze=reAnalyze||(visitMaps.enterMap(callerFcnId)==int8(1));
                        end
                    end
                end



                try
                    if userObj.Chart.Id~=fcnObj.Chart.Id
                        used=true;
                    end
                catch mex
                end
            end

            yesno=yesno||used;
            if yesno
                return;
            end
        end
    end
end

function allIds=getAllElems(chart)
    allElems=chart.find('-isa','Stateflow.State','-or',...
    '-isa','Stateflow.Transition','-or',...
    '-isa','Stateflow.LinkChart','-or',...
    '-isa','Stateflow.AtomicSubchart','-or',...
    '-isa','Stateflow.Function','-or',...
    '-isa','Stateflow.Junction','-or',...
    '-isa','Stateflow.SLFunction','-or',...
    '-isa','Stateflow.EMFunction','-or',...
    '-isa','Stateflow.Box');
    atomicBoxes=chart.find('-isa','Stateflow.AtomicBox');
    boxIds=[];
    for i=1:length(atomicBoxes)
        boxIds=[boxIds;getAllElems(atomicBoxes(i).Subchart)];
    end
    allElems=removeCommented([allElems;atomicBoxes]);
    allIds=arrayfun(@(obj)obj.Id,allElems);
    allIds=[allIds;boxIds];
end

function activeObjs=removeCommented(obj)
    activeObjs=[];
    if isempty(obj)
        return;
    end
    activeObjs=obj(arrayfun(@(t)~isCommentedOut(t),obj));
end

function yesno=isCommentedOut(obj)
    try
        yesno=obj.IsExplicitlyCommented||obj.IsImplicitlyCommented;
    catch mex
        yesno=false;
    end
end

function str=getExecMetric(cvd)
    if isa(cvd,'Coverage.CovData')
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_ACTIVE_CHILD_CALL_S'));
    else
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_ACTIVE_CHILD_CALL_D'));
    end
end

function str=getExitMetric(cvd)
    if isa(cvd,'Coverage.CovData')
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_INACTIVE_BEFORE_EXIT_S'));
    else
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_INACTIVE_BEFORE_EXIT_D'));
    end
end

function str=getHistoryMetric(cvd)
    if isa(cvd,'Coverage.CovData')
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_HIST_CHILD_CALL_S'));
    else
        str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SF_HIST_CHILD_CALL_D'));
    end
end