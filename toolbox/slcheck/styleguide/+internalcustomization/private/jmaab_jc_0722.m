function jmaab_jc_0722

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0722');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0722_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0722';
    rec.setCallbackFcn(@CheckCallBackFcn,'none','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0722_tip');
    rec.setLicense({styleguide_license,'Stateflow'});

    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function ElementResults=CheckCallBackFcn(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultData=checkAlgo(system);
    [bResultStatus,ElementResults]=Advisor.Utils.getTwoColumnReport...
    ('ModelAdvisor:jmaab:jc_0722',resultData.failedCharts);
    if resultData.noStatesFound
        ElementResults.setSubResultStatusText(DAStudio.message...
        ('ModelAdvisor:jmaab:jc_0722_no_stateflow_chart'));
    end
    mdlAdvObj.setCheckResultStatus(bResultStatus);
end



function[resultData]=checkAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    sfDecompParallel=Advisor.Utils.Stateflow...
    .sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,...
    {'Decomposition','PARALLEL_AND'});
    failedObjs=[];
    if~isempty(sfDecompParallel)
        sfDecompParallel=mdladvObj.filterResultWithExclusion(sfDecompParallel);
        for c1=1:length(sfDecompParallel)
            failedData=checkRule(sfDecompParallel{c1});
            if~isempty(failedData)
                failedObjs=[failedObjs;...
                {Advisor.Utils.Simulink.getObjHyperLink(sfDecompParallel{c1})...
                ,failedData}];
            end
        end
        resultData.noStatesFound=false;
        resultData.failedCharts=failedObjs;
    else
        resultData.noStatesFound=true;
        resultData.failedCharts=[];
    end
end



function failedData=checkRule(sfDecompParallel)
























    failedData=[];
    usedData=[];
    sfParallel=sfDecompParallel.find('-isa','Stateflow.State','Type','AND','-depth',1);

    for c1=1:numel(sfParallel)
        usedDataPerPstate=getDataWithHigherScope(sfParallel(c1));
        if~isempty(usedDataPerPstate)
            usedData=[usedData,usedDataPerPstate];
        end
    end

    [uniqueData,~,index]=unique(usedData,'stable');
    countOfData=arrayfun(@(x)sum(ismember(usedData,x)),uniqueData,'UniformOutput',false);
    uniqueDataIndex=find([countOfData{:}]==1);

    for count=1:length(uniqueDataIndex)
        logicalIndex=index==uniqueDataIndex(count);
        sfFlaggedDataObj=idToHandle(sfroot,usedData(logicalIndex));
        sfLinks=Advisor.Utils.Simulink.getObjHyperLink(sfFlaggedDataObj);
        failedData=[failedData;...
        Advisor.Utils.getTableOfConflicts(sfLinks)];
    end
end

function sfUsedData=getDataWithHigherScope(sfState)



    sfSDataObj=sfState.find('-isa','Stateflow.Data');
    sfSDataId=arrayfun(@(x)x.Id,sfSDataObj,'UniformOutput',false);

    sfSUsedDataId=getUsedData(sfState);
    sfUsedData=setdiff([sfSUsedDataId{:}],[sfSDataId{:}]);

end


function usedDataId=getUsedData(sfState)

















    scopeType=struct('Local',1);
    sfHDataObj=[Advisor.Utils.Stateflow.getDataDefinedInHierarchy(sfState,scopeType.Local);...
    sfState.find('-isa','Stateflow.Data')];
    sfHData=arrayfun(@(x)x.Name,sfHDataObj,'UniformOutput',false);
    sfHDataId=arrayfun(@(x)x.Id,sfHDataObj,'UniformOutput',false);





    sfObjs=sfState.find('-isa','Stateflow.State',...
    '-or','-isa','Stateflow.Transition');

    usedData=zeros(1,length(sfHData));
    for c1=1:length(sfObjs)
        sfCode=sfObjs(c1).LabelString;
        if isempty(sfCode)
            continue;
        end
        dIndex=cellfun(@(x)contains(sfCode,x),sfHData,'UniformOutput',false);
        usedData=usedData|[dIndex{:}];
    end
    usedDataId=sfHDataId(usedData);
end

