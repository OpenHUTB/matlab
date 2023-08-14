

classdef db_0129_d<slcheck.subcheck
    methods
        function obj=db_0129_d()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0129_d';
        end
        function result=run(this)
            result=false;
            excludeSelfTrans=true;
            obj=this.getEntity();
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            inputParams=mdladvObj.getInputParameters;
            errFlag=false;



            if inputParams{6}.Value
                excludeSelfTrans=false;
            end



            if(isa(obj,'Stateflow.Transition')&&...
                ~(isa(getParent(obj),'Stateflow.TruthTable')||...
                isa(getParent(obj),'Stateflow.StateTransitionTableChart')))&&...
                (excludeSelfTrans&&...
                ~Advisor.Utils.Stateflow.isSelfTransition(obj))







                if isTransitioninFlowChartLoop(obj)&&...
                    ~isTwoJnLoop(obj)
                    errFlag=~(Advisor.Utils.Stateflow.isTransitionStraight(obj));



                elseif~((Advisor.Utils.Stateflow.isTransitionHorizontal(obj))||...
                    (Advisor.Utils.Stateflow.isTransitionVertical(obj)))&&...
                    ~isTwoJnLoop(obj)
                    errFlag=true;
                end

                if errFlag
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                    result=this.setResult(vObj);
                end
            end
        end
    end
end


function flag=isTransitioninFlowChartLoop(obj)
    flag=false;
    chart=obj.chart;


    excludedTransList=getExcludedTransList(chart);


    if isempty(obj)||~isempty(excludedTransList)&&ismember(obj,excludedTransList)
        return;
    end

    if isTransInLoop(obj)
        flag=true;
    end
end


function flag=isTwoJnLoop(obj)
    flag=false;

    if isempty(obj.Destination)||~isa(obj.Destination,'Stateflow.Junction')
        return;
    end


    secJnTrans=obj.Destination.sourcedTransitions;
    if~isempty(secJnTrans)
        destObj=arrayfun(@(x)x.Destination,secJnTrans,'UniformOutput',false);
    else
        return;
    end



    for i=numel(destObj)
        if ismember(destObj{i},obj.Source)
            if Advisor.Utils.Stateflow.isTransitionStraight(secJnTrans(i))||...
                Advisor.Utils.Stateflow.isTransitionStraight(obj)
                flag=true;
            end
        end
    end
end

function bResult=isTransInLoop(transition)
    bResult=false;
    chart=transition.chart;

    jnList=findCyclesInChart(chart);



    if(~isempty(transition.Source)&&ismember(transition.Source,jnList))&&...
        (ismember(transition.Destination,jnList))
        bResult=true;
    end

end

function cycleJunctionList=findCyclesInChart(chart)


    persistent chartIds;
    persistent juncList;
    persistent chartPath;

    index=find(chartIds==chart.Id,1);
    if isempty(chartIds)||~(~isempty(index)&&strcmp(chartPath{index},chart.Path))
        chartIds(length(chartIds)+1)=chart.Id;
        chartPath{length(chartPath)+1}=chart.Path;


        [adjM,sfJunctionMapInv]=getAdjacencyMat(chart);
        junctions=[];
        if~isempty(adjM)

            [~,cycles]=Advisor.Utils.Graph.findCycles(adjM);
            for c2=1:numel(cycles)

                cycleJunctionIds=arrayfun(@(x)sfJunctionMapInv(x),cycles{c2});

                junctions=[junctions,arrayfun(@(x)idToHandle(sfroot,x),cycleJunctionIds)];
            end
        end
        juncList{end+1}=junctions;
        cycleJunctionList=junctions;


    else

        cycleJunctionList=juncList{index};
    end
end

function transList=getExcludedTransList(chart)
    persistent chartId;
    persistent exclList;


    if isempty(chartId)||isempty(find(chartId==chart.Id,1))
        transList=[];
        chartId(length(chartId)+1)=chart.Id;
        states=chart.find({'-isa','Stateflow.State','-or','-isa','Stateflow.Box'});

        if isempty(states)
            exclList{end+1}=[];
            return;
        end



        for idx=1:numel(states)
            trans=states(idx).sinkedTransitions;
            transList=[transList;getTranstoState(trans,[])];
        end
        exclList{end+1}=transList;
    else

        index=find(chartId==chart.Id,1);
        transList=exclList{index};
    end
end

function list=getTranstoState(trans,list)
    if isempty(trans)
        return;
    end
    travTrans=[];
    for j=1:(numel(trans))

        if~isempty(trans(j).Source)||...
            (~isempty(trans(j).Source)&&~isa(trans(j).Source,'Stateflow.State'))

            srcTrns=trans(j).Source.sinkedTransitions;
            if any(~isempty(srcTrns))
                srcTrns=srcTrns(~ismember(srcTrns,list));
            end
            list=[list;trans(j);srcTrns];
            travTrans=[travTrans;srcTrns];
        end
    end
    trans=travTrans;
    list=getTranstoState(trans,list);
end

function[adjM,sfJunctionMapInv]=getAdjacencyMat(chart)
    adjM=[];
    sfJunctionMapInv=[];
    sfJunctions=chart.find('-isa','Stateflow.Junction');
    sfTransitions=chart.find('-isa','Stateflow.Transition');
    if(isempty(sfTransitions)||isempty(sfJunctions))
        return;
    end
    sfJunctionMap=containers.Map(arrayfun(@(x)x.Id,sfJunctions),1:numel(sfJunctions));
    sfJunctionMapInv=containers.Map(1:numel(sfJunctions),arrayfun(@(x)x.Id,sfJunctions));

    adjM=Advisor.Utils.Graph.getAdjMatFrmTransition(sfJunctionMap,sfTransitions);
end