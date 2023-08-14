function result=path2handle(sfPathName)




    result=-1;


    sfObj=resolveState(sfPathName);


    if isempty(sfObj)
        sfObj=resolveTransition(sfPathName);
    end;


    if~isempty(sfObj)
        result=sfObj(1).Id;
    end
end


function result=resolveTransition(transPath)


    [labelStr,fromStr,toStr]=rmisf.parse_trans_path(transPath);


    fromObj=resolveState(fromStr);
    toObj=resolveState(toStr);


    fromID=-1;
    toID=-1;
    if~isempty(fromObj)
        fromID=fromObj.Id;
    end
    if~isempty(toObj)
        toID=toObj.Id;
    end


    resolvedChart=[];
    if~isempty(fromObj)
        resolvedChart=fromObj.Chart;
    elseif~isempty(toObj)
        resolvedChart=toObj.Chart;
    elseif isempty(labelStr)

        result=[];
        return;
    end;


    if isempty(resolvedChart)
        searchRoot=sfroot;
    else
        searchRoot=resolvedChart;
    end;


    func=@(obj)transFindFunc(obj,labelStr,fromID,toID,true);
    result=find(searchRoot,'-isa','Stateflow.Transition','-and','-function',func);%#ok<GTARG>

    if isempty(result)


        func=@(obj)transFindFunc(obj,labelStr,fromID,toID,false);
        result=find(searchRoot,'-isa','Stateflow.Transition','-and','-function',func);%#ok<GTARG>
    end
end

function result=transFindFunc(obj,labelStr,fromID,toID,strict)


    objFromID=-1;
    objToID=-1;


    if~isempty(obj.Source)
        objFromID=obj.Source.Id;
    end;
    if~isempty(obj.Destination)
        objToID=obj.Destination.Id;
    end;


    objLabelStr=strtrim(strrep(obj.LabelString,char(10),' '));






    fromMatch=isSuperState(fromID,objFromID);
    toMatch=isSuperState(toID,objToID);
    labelMatch=strcmp(objLabelStr,labelStr);
    if strict
        result=fromMatch&&toMatch&&labelMatch;
    else
        result=(fromMatch||toMatch)&&labelMatch;
    end
end

function result=isSuperState(topId,downId)
    result=false;

    if(topId==downId)
        result=true;
        return;
    end

    if(downId==-1)
        return;
    end

    h=idToHandle(sfroot,downId);
    while(h.isa('Stateflow.Object'))
        if h.Id==topId
            result=true;
            break;
        end

        h=h.up;
    end
end

function result=resolveState(statePath)


    result=[];


    rt=sfroot;


    [sfMachineName]=strtok(statePath,'/');
    sfMachine=rt.find('-isa','Stateflow.Machine','-and','Name',sfMachineName);
    if isempty(sfMachine)
        return;
    end




    matchPath=[statePath,'/'];
    sfCharts=sfMachine.find('-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.TruthTable','-or',...
    '-isa','Stateflow.StateTransitionTableChart','-or',...
    '-isa','Stateflow.ReactiveTestingTableChart');
    chartCnt=length(sfCharts);
    chartPaths=cell(1,chartCnt);
    chartPathL=zeros(1,chartCnt);

    for idx=1:chartCnt
        chartPaths{idx}=[sfCharts(idx).getFullName,'/'];
        chartPathL(idx)=length(chartPaths{idx});
    end

    [~,sortIdx]=sort(chartPathL);
    resolvedChart=[];



    match=regexp(statePath,'\(#(\d+)\)$','tokens');
    if~isempty(match)

        sfCharts=sfCharts(sortIdx);
        parentChartSid=findMyChart(sfCharts,statePath);
        sid=sprintf('%s:%s',parentChartSid,match{1}{1});
        result=Simulink.ID.getHandle(sid);
    else

        sortIdx=fliplr(sortIdx);
        sfCharts=sfCharts(sortIdx);
        chartPaths=chartPaths(sortIdx);
        for i=1:chartCnt
            if strfind(matchPath,chartPaths{i})==1
                resolvedChart=sfCharts(i);
                break;
            end
        end

        if isempty(resolvedChart)
            return;
        end
        func=@(obj)(strcmp(obj.getFullName,statePath));
        result=resolvedChart.find('-function',func);
    end
end

function chartSID=findMyChart(allCharts,myPath)

    slashIdx=find(myPath=='/');
    chartBlockH=get_param(myPath(1:slashIdx(2)-1),'Handle');
    chartSID=Simulink.ID.getSID(chartBlockH);

    for i=1:length(allCharts)
        thisChart=allCharts(i);
        chartBlockH=sf('Private','chart2block',thisChart.Id);
        if isempty(chartBlockH)
            continue;
        end
        if~isempty(strfind(myPath,thisChart.Path))
            chartSID=Simulink.ID.getSID(chartBlockH);


        end
    end
end
