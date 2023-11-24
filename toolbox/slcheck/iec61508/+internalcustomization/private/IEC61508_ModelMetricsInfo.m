
function rec=IEC61508_ModelMetricsInfo

    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:ModelMetricsInfoTitle');
    rec.TitleID='mathworks.iec61508.MdlMetricsInfo';
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:ModelMetricsInfoTip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@ModelMetricsInfoCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=iec61508_group;
    rec.LicenseName={iec61508_license,'Stateflow'};
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.CSHParameters.TopicID='com.mw.slvnv.iec61508ModelMetricsInfo';
end




function result=ModelMetricsInfoCallback(system)
    result=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);






    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('ModelAdvisor:iec61508:ModelMetricsInfoTip'));
    ft.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:ModelMetricsTitleSubCheck1'));
    ft.setInformation(DAStudio.message('ModelAdvisor:iec61508:ModelMetricsInfoSubCheck1'));


    ft.setSubBar(0);
    info={};





    isSubSystem=false;
    if strcmp(bdroot(system),system)==false
        isSubSystem=true;
    end

    try
        blkList.BlockTypeName=[];
        blkList.BlockTypeCount=[];



        allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','FindAll','on','LookUnderMasks','all','Type','block');
        allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);
        allBlocks=filterStateflowBlocks(allBlocks);
        allBlocks=filterInsideBuiltInBlocks(allBlocks);
        if isSubSystem
            allBlocks(1)=[];
        end
        typeBlocks=get_param(allBlocks,'BlockType');



        EMLFuncVec=arrayfun(@(x)isEMChart(x),allBlocks);
        [typeBlocks{EMLFuncVec}]=deal('MATLAB Function Block');

        if~iscell(typeBlocks)
            typeBlocks={typeBlocks};
        end
        for i=1:length(typeBlocks)
            index=find(strcmp(typeBlocks(i),blkList.BlockTypeName));
            if~isempty(index)

                blkList.BlockTypeCount(index)=blkList.BlockTypeCount(index)+1;
            else

                blkList.BlockTypeName=[blkList.BlockTypeName,typeBlocks(i)];
                blkList.BlockTypeCount=[blkList.BlockTypeCount,1];
            end
        end



        m=get_param(system,'Object');

        chartArray=m.find('-isa','Stateflow.Chart');

        [linkCharts,allChartInstances]=ModelAdvisor.Common.find_LinkChart(m);
        countSF=length(chartArray)+length(allChartInstances);

        blocksSummaryTable={'Inport','Outport','SubSystem','Stateflow','MATLAB Function'};

        countSummary=zeros(numel(blocksSummaryTable),1);

        countSummary(4)=countSF;

        if~isempty(blkList.BlockTypeCount)
            ft.setColTitles({DAStudio.message('ModelAdvisor:iec61508:TableElementType'),...
            DAStudio.message('ModelAdvisor:iec61508:TableBlkCount')});
            ft.setTableTitle(DAStudio.message('ModelAdvisor:iec61508:Table1Heading'));
            [~,sortIdx]=sort(blkList.BlockTypeCount,'Descend');

            for idx=1:length(blkList.BlockTypeCount)
                if(strcmp(blkList.BlockTypeName{idx},'Inport'))
                    countSummary(1)=blkList.BlockTypeCount(idx);
                elseif(strcmp(blkList.BlockTypeName{idx},'Outport'))
                    countSummary(2)=blkList.BlockTypeCount(idx);
                elseif(strcmp(blkList.BlockTypeName{idx},'SubSystem'))
                    countSummary(3)=blkList.BlockTypeCount(idx);
                elseif(strcmp(blkList.BlockTypeName{idx},'MATLAB Function Block'))
                    countSummary(5)=blkList.BlockTypeCount(idx);
                end
            end

            for idx=1:numel(countSummary)
                if countSummary(idx)~=0
                    info=[info;{blocksSummaryTable{idx},...
                    sprintf('%5d',countSummary(idx))}];%#ok<AGROW>
                end
            end
            if~isempty(info)
                ft.setTableInfo(info);
                result{end+1}=ft;
            end

            ft=ModelAdvisor.FormatTemplate('TableTemplate');
            info={};
            ft.setColTitles({DAStudio.message('ModelAdvisor:iec61508:TableBlkType'),...
            DAStudio.message('ModelAdvisor:iec61508:TableBlkCount')});
            ft.setTableTitle(DAStudio.message('ModelAdvisor:iec61508:Table2Heading'));
            ft.setSubBar(0);
            for i=1:length(blkList.BlockTypeCount)
                if blkList.BlockTypeCount(sortIdx(i))~=0
                    info=[info;{blkList.BlockTypeName{sortIdx(i)},...
                    sprintf('%5d',blkList.BlockTypeCount(sortIdx(i)))}];%#ok<AGROW>
                end
            end
            if~isempty(info)
                ft.setTableInfo(info);
                result{end+1}=ft;
            end
        end











        otherList.BlockTypeName={};
        otherList.BlockTypeCount=[];

        stateArray=m.find('-isa','Stateflow.State');
        transitionArray=m.find('-isa','Stateflow.Transition');
        junctionArray=m.find('-isa','Stateflow.Junction');
        eventArray=m.find('-isa','Stateflow.Event');
        dataArray=m.find('-isa','Stateflow.Data');
        parameterArray=m.find('-isa','Stateflow.Parameter');
        for i=1:length(linkCharts)
            stateArray=[stateArray;linkCharts(i).find('-isa','Stateflow.State')];%#ok<AGROW>
            transitionArray=[transitionArray;linkCharts(i).find('-isa','Stateflow.Transition')];%#ok<AGROW>
            junctionArray=[junctionArray;linkCharts(i).find('-isa','Stateflow.Junction')];%#ok<AGROW>
            eventArray=[eventArray;linkCharts(i).find('-isa','Stateflow.Event')];%#ok<AGROW>
            dataArray=[dataArray;linkCharts(i).find('-isa','Stateflow.Data')];%#ok<AGROW>
            parameterArray=[parameterArray;linkCharts(i).find('-isa','Stateflow.Parameter')];%#ok<AGROW>
        end


        chartArray=[chartArray(:);linkCharts(:)];

        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Charts'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(chartArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow States'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(stateArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Transitions'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(transitionArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Junctions'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(junctionArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Events'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(eventArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Data'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(dataArray)];


        otherList.BlockTypeName=[otherList.BlockTypeName,'Stateflow Parameters'];
        otherList.BlockTypeCount=[otherList.BlockTypeCount,length(parameterArray)];



        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        info={};

        if~isempty(otherList.BlockTypeCount)&&sum(otherList.BlockTypeCount)
            ft.setTableTitle(DAStudio.message('ModelAdvisor:iec61508:Table3Heading'));
            ft.setColTitles({DAStudio.message('ModelAdvisor:iec61508:TableType'),...
            DAStudio.message('ModelAdvisor:iec61508:TableCount')});

            [~,sortIdx]=sort(otherList.BlockTypeCount,'Descend');

            for i=1:length(otherList.BlockTypeCount)
                if otherList.BlockTypeCount(sortIdx(i))~=0
                    info=[info;{otherList.BlockTypeName{sortIdx(i)},...
                    sprintf('%5d',otherList.BlockTypeCount(sortIdx(i)))}];%#ok<AGROW>
                end
            end
            if~isempty(info)
                ft.setTableInfo(info);
                result{end+1}=ft;
            end
        end


















        depth=0;
        level=1;
        ssList={};


        ssBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','SubSystem');
        ssBlocks=filterStateflowBlocks(ssBlocks);
        ssBlocks=filterInsideBuiltInBlocks(ssBlocks);


        if isSubSystem
            ssBlocks(1)=[];
        end
        for i=1:length(ssBlocks)
            ssEntry.Name=ssBlocks{i};
            ssEntry.Level=1;
            ssEntry.Depth=0;
            ssList{end+1}=ssEntry;%#ok<AGROW>
            index=length(ssList);
            [localDepth,ssList]=RecurseSubSystems(ssBlocks(i),ssList,level);
            depth=max(depth,localDepth);
            ssList{index}.Depth=localDepth;
        end








        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        ft.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:ModelMetricsTitleSubCheck2'));

        ft.setInformation(DAStudio.message('ModelAdvisor:iec61508:ModelMetricsInfoSubCheck2'));
        ft.setSubBar(0);
        info={};

        if~isempty(ssList)

            ft.setTableTitle([DAStudio.message('ModelAdvisor:iec61508:ReportTopLevel',depth+1),'<br /><br />',DAStudio.message('ModelAdvisor:iec61508:TableSSDepth')]);
            ft.setColTitles({DAStudio.message('ModelAdvisor:iec61508:TableSSName'),...
            DAStudio.message('ModelAdvisor:iec61508:TableLevel'),...
            DAStudio.message('ModelAdvisor:iec61508:TableDepth')
            });

            info=cell(length(ssList),3);
            for i=1:length(ssList)
                info{i,1}=ssList{i}.Name;
                info{i,2}=sprintf('%5d',ssList{i}.Level);
                info{i,3}=sprintf('%5d',ssList{i}.Depth);
            end

            ft.setTableInfo(info);
            result{end+1}=ft;
            result{end+1}=ModelAdvisor.LineBreak;
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:iec61508:ReportNoSubsystems'));

            result{end+1}=ft;
        end
        mdladvObj.setCheckResultStatus(true);
    catch E %#ok<NASGU>
        result{end+1}=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:iec61508:TryCatchError'),{'fail'});
        mdladvObj.setCheckResultStatus(false);
    end

end



function[depth,ssList]=RecurseSubSystems(ssBlock,ssList,ssLevel)
    depth=0;


    ssBlocks=find_system(ssBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','SubSystem');
    ssBlocks=filterStateflowBlocks(ssBlocks);
    ssBlocks=filterInsideBuiltInBlocks(ssBlocks);



    for i=2:length(ssBlocks)
        ssEntry.Name=ssBlocks{i};
        ssEntry.Level=ssLevel+1;
        ssEntry.Depth=0;
        ssList{end+1}=ssEntry;%#ok<AGROW>
        index=length(ssList);
        [localDepth,ssList]=RecurseSubSystems(ssBlocks(i),ssList,ssLevel+1);
        depth=max(depth,localDepth);
        ssList{index}.Depth=localDepth;
    end
    depth=depth+1;
end

function filteredssBlocks=filterStateflowBlocks(ssBlocks)

    if iscell(ssBlocks)
        filteredssBlocks={};
    else
        filteredssBlocks=[];
    end

    for i=1:length(ssBlocks)

        if isSFBlock(ssBlocks(i))
            continue;
        end

        if iscell(ssBlocks(i))
            filteredssBlocks{end+1}=ssBlocks{i};
        else
            filteredssBlocks(end+1)=ssBlocks(i);
        end

    end
end

function flag=isSFBlock(ssBlk)






    if iscell(ssBlk)
        ssBlk=ssBlk{1};
    end

    flag=false;
    ssParent=get_param(ssBlk,'Parent');

    if slprivate('is_stateflow_based_block',ssParent)
        flag=true;
        return;
    end

    if slprivate('is_stateflow_based_block',ssBlk)

        if~isEMChart(ssBlk)
            flag=true;
            return;
        end

    end

end

function flag=isEMChart(ssBlk)


    flag=false;

    if~slprivate('is_stateflow_based_block',ssBlk)
        return;
    end

    cId=sfprivate('block2chart',ssBlk);
    c=idToHandle(sfroot,cId);

    if~c.isa('Stateflow.EMChart')
        return;
    end

    flag=true;

end


function allBlocks=filterInsideBuiltInBlocks(allBlocks)
    if iscell(allBlocks)
        builtInBlocks=zeros(size(allBlocks));
        for i=1:length(allBlocks)
            builtIn=isInsideBuiltInBlock(allBlocks{i});
            if builtIn
                builtInBlocks(i)=true;
            end
        end
        allBlocks(builtInBlocks(:)==1)=[];
    else
        builtInBlocks=zeros(size(allBlocks));
        for i=1:length(allBlocks)
            builtIn=isInsideBuiltInBlock(allBlocks(i));
            if builtIn
                builtInBlocks(i)=true;
            end
        end
        allBlocks(builtInBlocks(:)==1)=[];
    end
end

function InsidebuiltIn=isInsideBuiltInBlock(obj)
    InsidebuiltIn=false;
    obj=get_param(obj,'Object');
    [~,IsbuiltIn]=isLinkedObj(obj);
    if IsbuiltIn
        return
    end
    while~isa(obj,'Simulink.BlockDiagram')
        obj=obj.getParent;
        [~,IsbuiltIn]=isLinkedObj(obj);
        if IsbuiltIn
            InsidebuiltIn=true;
            return
        end
    end
end




function[isLinked,builtIn]=isLinkedObj(obj)
    isLinked=false;
    builtIn=false;


    if isa(obj,'Simulink.BlockDiagram')
        return;
    end

    className=class(obj);
    refBlock='';

    if strncmp('Simulink',className,8)
        if strcmpi(obj.LinkStatus,'resolved')
            isLinked=true;
            refBlock=obj.ReferenceBlock;
        end
    elseif strncmp('Stateflow',className,9)
        if isa(obj,'Stateflow.Chart')||isa(obj,'Stateflow.LinkChart')
            chartObj=obj;
        else
            chartObj=obj.Chart;
        end
        if strcmpi(get_param(chartObj.Path,'LinkStatus'),'resolved')
            isLinked=true;
            refBlock=get_param(chartObj.Path,'ReferenceBlock');
        end
    else
        isLinked=false;
    end

    if isLinked&&~isempty(refBlock)





        libName=strtok(refBlock,'/');

        [libfile,resolved]=sls_resolvename(libName);



        testroot=fullfile(matlabroot,'test');

        if resolved
            if(~strncmp(matlabroot,libfile,length(matlabroot))||...
                strncmp(testroot,libfile,length(testroot)))
                builtIn=false;
            else
                builtIn=true;
            end
        else

            isLinked=false;
        end
    else
        isLinked=false;
    end
end
