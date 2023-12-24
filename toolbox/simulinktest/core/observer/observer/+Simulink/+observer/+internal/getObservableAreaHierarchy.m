function obsHier=getObservableAreaHierarchy(obsRefHdl)
    obsHier=Simulink.observer.internal.getObservableAreaHierarchyInternal(obsRefHdl);

    if slfeature('ObserverSFSupport')==0
        return;
    end

    SFLoc=find(strcmp('Stateflow',{obsHier.Type}));
    nSFLoc=numel(SFLoc);
    for j=nSFLoc:-1:1
        currLoc=SFLoc(j)+1;
        while currLoc<=numel(obsHier)&&strncmp(obsHier(currLoc).Type,'Outport',7)
            currLoc=currLoc+1;
        end
        path=obsHier(SFLoc(j)).Path;
        sfId=sfprivate('block2chart',obsHier(SFLoc(j)).Handle);
        if sfId~=0
            chartHdl=idToHandle(sfroot,sfId);
            if isa(chartHdl,'Stateflow.Chart')||isa(chartHdl,'Stateflow.ReactiveTestingTableChart')...
                ||isa(chartHdl,'Stateflow.StateTransitionTableChart')||isa(chartHdl,'Stateflow.TruthTableChart')
                if isa(chartHdl,'Stateflow.TruthTableChart')
                    type='TruthTable';
                else
                    type='Chart';
                end
                obsHier(SFLoc(j)).Type=type;
                obsHier=[obsHier(1:currLoc-1);getStateflowChartHierarchy(obsHier,obsRefHdl,path,chartHdl,false);obsHier(currLoc:end)];
            end
        end
    end

end


function sfHier=getStateflowChartHierarchy(obsHier,obsRefHdl,parentPath,sfHdl,showSelf)

    sfHier=[];
    sfId=sfHdl.Id;
    chartBlkH=sfprivate('chart2block',sfId);


    dataIds=sf('DataIn',sfId);
    localDataIds=sf('find',dataIds,'.scope','LOCAL_DATA');
    localDataIds=filterSimulinkStateData(localDataIds);
    localDataHdls=idToHandle(sfroot,localDataIds);
    idx=arrayfun(@(x)~strcmp(x.Name,'sf_internal_action_state_placeholder_data'),localDataHdls);
    localDataIds=localDataIds(idx);
    localDataHdls=localDataHdls(idx);
    localDataStruct=struct('Path','','Handle',num2cell(localDataIds'),'Type','');
    for j=1:numel(localDataStruct)
        localDataStruct(j).Path=[parentPath,newline,localDataHdls(j).Name];
        ssid=num2str(localDataHdls(j).SSIdNumber);
        mdlRefHdls=getMdlRefHdlsFromPath(obsHier,parentPath);
        if Simulink.observer.internal.isHierSFDataObservedInObserver(obsRefHdl,mdlRefHdls,chartBlkH,ssid)
            localDataStruct(j).Type='SFData-Observed';
        else
            localDataStruct(j).Type='SFData-Unobserved';
        end
    end
    sfHier=[sfHier;localDataStruct];
    paramIds=sf('find',dataIds,'.scope','PARAMETER');
    paramIds=filterSimulinkStateData(paramIds);
    paramHdls=idToHandle(sfroot,paramIds);
    paramStruct=struct('Path','','Handle',num2cell(paramIds'),'Type','');
    for j=1:numel(paramStruct)
        paramStruct(j).Path=[parentPath,newline,paramHdls(j).Name];
        ssid=num2str(paramHdls(j).SSIdNumber);
        mdlRefHdls=getMdlRefHdlsFromPath(obsHier,parentPath);
        if Simulink.observer.internal.isHierSFDataObservedInObserver(obsRefHdl,mdlRefHdls,chartBlkH,ssid)
            paramStruct(j).Type='SFParam-Observed';
        else
            paramStruct(j).Type='SFParam-Unobserved';
        end
    end
    sfHier=[sfHier;paramStruct];

    if isa(sfHdl,'Stateflow.TruthTableChart')
        return;
    end

    if isa(sfHdl,'Stateflow.ReactiveTestingTableChart')
        if slfeature('ObserverSFChildLeafSupport')
            sfHier=[sfHier;...
            getStateActivityStruct(obsHier,obsRefHdl,parentPath,sfHdl,'Leaf')];
        end
        return;
    end

    if showSelf
        sfHier=[sfHier;...
        getStateActivityStruct(obsHier,obsRefHdl,parentPath,sfHdl,'Self')];
    end

    if slfeature('ObserverSFChildLeafSupport')&&strcmp(sfHdl.Decomposition,'EXCLUSIVE_OR')
        sfHier=[sfHier;...
        getStateActivityStruct(obsHier,obsRefHdl,parentPath,sfHdl,'Child');...
        getStateActivityStruct(obsHier,obsRefHdl,parentPath,sfHdl,'Leaf')];
    end

    stateIds=sf('SubstatesOfInSortedOrder',sfId);
    for j=1:numel(stateIds)
        sfHier=[sfHier;getStateflowStateHierarchy(obsHier,obsRefHdl,parentPath,idToHandle(sfroot,stateIds(j)))];%#ok<AGROW>
    end

end


function sfHier=getStateflowStateHierarchy(obsHier,obsRefHdl,parentPath,sfHdl)
    sfHier=[];
    sfId=sfHdl.Id;
    newPath=[parentPath,newline,sfHdl.Name];
    if isa(sfHdl,'Stateflow.State')
        sfHier=[struct('Path',newPath,'Handle',sfId,'Type','State');...
        getStateActivityStruct(obsHier,obsRefHdl,newPath,sfHdl,'Self')];
        if slfeature('ObserverSFChildLeafSupport')&&strcmp(sfHdl.Decomposition,'EXCLUSIVE_OR')
            sfHier=[sfHier;...
            getStateActivityStruct(obsHier,obsRefHdl,newPath,sfHdl,'Child');...
            getStateActivityStruct(obsHier,obsRefHdl,newPath,sfHdl,'Leaf')];
        end
        stateIds=sf('SubstatesOfInSortedOrder',sfId);
        for j=1:numel(stateIds)
            sfHier=[sfHier;getStateflowStateHierarchy(obsHier,obsRefHdl,newPath,idToHandle(sfroot,stateIds(j)))];%#ok<AGROW>
        end
    elseif isa(sfHdl,'Stateflow.SimulinkBasedState')
        sfHier=[struct('Path',newPath,'Handle',sfId,'Type','SLState');...
        getStateActivityStruct(obsHier,obsRefHdl,newPath,sfHdl,'Self')];
    elseif isa(sfHdl,'Stateflow.AtomicSubchart')

        sfHier=[struct('Path',newPath,'Handle',sfId,'Type','Chart');...
        getStateActivityStruct(obsHier,obsRefHdl,newPath,sfHdl,'Self');...

        ];
    end

end


function sfHier=getStateActivityStruct(obsHier,obsRefHdl,parentPath,sfHdl,actType)

    switch actType
    case 'Self'
        pathStr='Self activity';
        typeStr='SFStateSelf';
    case 'Child'
        pathStr='Child activity';
        typeStr='SFStateChild';
    case 'Leaf'
        pathStr='Leaf state activity';
        typeStr='SFStateLeaf';
    end

    if isa(sfHdl,'Stateflow.Chart')||isa(sfHdl,'Stateflow.ReactiveTestingTableChart')||isa(sfHdl,'Stateflow.StateTransitionTableChart')

        chartBlkH=sfprivate('chart2block',sfHdl.Id);
        ssid='';
    elseif isa(sfHdl,'Stateflow.AtomicSubchart')

        chartBlkH=sfprivate('chart2block',sfHdl.Chart.Id);
        ssid=num2str(sfHdl.SSIdNumber);
    else
        chartBlkH=sfprivate('chart2block',sfHdl.Chart.Id);
        ssid=num2str(sfHdl.SSIdNumber);
    end
    mdlRefHdls=getMdlRefHdlsFromPath(obsHier,parentPath);
    if Simulink.observer.internal.isHierSFStateObservedInObserver(obsRefHdl,mdlRefHdls,chartBlkH,ssid,actType)
        typeStr=[typeStr,'-Observed'];
    else
        typeStr=[typeStr,'-Unobserved'];
    end
    if isa(sfHdl,'Stateflow.Chart')||isa(sfHdl,'Stateflow.ReactiveTestingTableChart')||isa(sfHdl,'Stateflow.StateTransitionTableChart')
        sfHier=struct('Path',[parentPath,newline,pathStr],'Handle',chartBlkH,'Type',typeStr);
    else
        sfHier=struct('Path',[parentPath,newline,pathStr],'Handle',sfHdl.Id,'Type',typeStr);
    end

end


function mdlRefHdls=getMdlRefHdlsFromPath(obsHier,path)
    newlines=strfind(path,newline);
    mdlRefHdls=[];
    pathVec={obsHier.Path};
    for j=1:numel(newlines)
        [~,loc]=ismember(path(1:newlines(j)-1),pathVec);
        if loc~=0
            if strcmp(obsHier(loc).Type,'MdlRefLoaded')
                mdlRefHdls=[mdlRefHdls,obsHier(loc).Handle];
            end
        end
    end
end


function goodDataIds=filterSimulinkStateData(allDataIds)
    allDataHdls=idToHandle(sfroot,allDataIds);
    goodDataIds=[];

    for i=1:length(allDataHdls)
        if~isa(allDataHdls(i).getParent,'Stateflow.SimulinkBasedState')
            goodDataIds=[goodDataIds,allDataIds(i)];
        end
    end
end
