function PrintMappingData(scope)








    try
        if nargin==0
            scope=[];
        end
        mappingData=getMappingData(scope);
        for i=1:numel(mappingData)
            print(mappingData(i));
        end
    catch ME
        fprintf('Print mapping data exception %s\n',ME.identifier);
    end

end

function mappingData=getMappingData(scope)

    mappingData=[];
    isModel=false;
    isSubsystem=false;
    hModel=0;
    hSubsystem=0;

    if nargin==1
        if~isempty(scope)
            if strcmpi(get_param(scope,'Type'),"block_diagram")
                isModel=true;
                hModel=get_param(scope,'handle');
            end
            if strcmpi(get_param(scope,'Type'),"block")
                if strcmpi(get_param(scope,'BlockType'),"SubSystem")
                    isSubsystem=true;
                    hSubsystem=get_param(scope,'handle');
                    hModel=get_param(bdroot(hSubsystem),'handle');
                end
            end
        end
    end

    if hModel==0
        if isempty(bdroot)
            return;
        end
        hModel=get_param(bdroot,'handle');
        if hModel==0
            return;
        end
        isModel=true;
    end

    ui=get_param(hModel,'DataflowUI');

    if isempty(ui)
        return;
    end


    if isModel
        uiMappingData=ui.MappingData;
        subgraphMappingData=ui.SubgraphMappingData;

        subgraphMappingData=subgraphMappingData(~ismember(subgraphMappingData,uiMappingData));
        mappingData=[uiMappingData,subgraphMappingData];
    end


    if isSubsystem
        mappingData=ui.getBlkMappingData(hSubsystem);
    end
end

function print(mappingData)

    mdata=mappingData.getCacheData;

    costData=mappingData.getCostData;
    cdata=costData.getCacheData;

    opd=costData.getOriginalProfileData;

    totalExec=0;

    maxLenName=5;
    maxLenLat=10;
    maxLenCost=4;
    maxLenUnfo=8;
    blks=[];

    for i=1:numel(mdata.Blocks)
        blks(i).Name=mdata.Blocks(i).Name;
        if length(blks(i).Name)>maxLenName
            maxLenName=length(blks(i).Name);
        end
        blks(i).ThreadID=num2str(mdata.Blocks(i).ThreadID);
        blks(i).PipelineStage=num2str(mdata.Blocks(i).PipelineStage);
        if isempty(mdata.Blocks(i).Latencies)
            blks(i).Latencies='';
        else
            blks(i).Latencies=mat2str(mdata.Blocks(i).Latencies);
        end
        if length(blks(i).Latencies)>maxLenLat
            maxLenLat=length(blks(i).Latencies);
        end
        if isempty(mdata.Blocks(i).Unfolding)
            blks(i).Unfolding='';
        else
            blks(i).Unfolding=mat2str(mdata.Blocks(i).Unfolding);
        end
        if length(blks(i).Unfolding)>maxLenUnfo
            maxLenUnfo=length(blks(i).Unfolding);
        end
        cost=-2;
        for j=1:numel(cdata.Blocks)
            if(strcmp(cdata.Blocks(j).Name,blks(i).Name))
                cost=cdata.Blocks(j).Cost;
            end
        end
        if(cost>=-1)
            blks(i).Cost=num2str(cost);
        else
            blks(i).Cost='NC';
        end
        if length(blks(i).Cost)>maxLenCost
            maxLenCost=length(blks(i).Cost);
        end
        blks(i).OriginalCost='0';
        for j=1:numel(opd)
            if strcmp(blks(i).Name,opd(j).Name)
                blks(i).OriginalCost=num2str(opd(j).Cost);
            end
        end
        if(cost>0)
            totalExec=totalExec+cost;
        end
    end


    mappingDataAttributesStr='';
    for i=1:12
        if(bitget(mappingData.Attributes,i))
            attributeStr='';
            switch(i)
            case 1
                attributeStr='Model cache';
            case 2
                attributeStr='MAT file';
            case 3
                attributeStr='MATLAB';
            case 4
                attributeStr='RTW';
            case 5
                attributeStr='SIM';
            case 6
                attributeStr='UI';
            case 7
                attributeStr='Subgraph';
            case 8
                attributeStr='Single thread';
            case 9
                attributeStr='Profiling';
            case 10
                attributeStr='Insufficient work';
            case 11
                attributeStr='Partitioned';
            case 12
                attributeStr='Unfolded block';
            end
            mappingDataAttributesStr=[mappingDataAttributesStr,attributeStr,', '];
        end
    end


    costDataAttributesStr='';
    for i=1:9
        if(bitget(costData.Attributes,i))
            attributeStr='';
            switch(i)
            case 1
                attributeStr='Model cache';
            case 2
                attributeStr='MAT file';
            case 3
                attributeStr='MATLAB';
            case 4
                attributeStr='Single thread';
            case 5
                attributeStr='Global override';
            case 6
                attributeStr='Profiling';
            case 7
                attributeStr='Estimate';
            case 8
                attributeStr='Sim profile';
            case 9
                attributeStr='RTW Profile';
            end
            costDataAttributesStr=[costDataAttributesStr,attributeStr,', '];
        end
    end

    hSSBlk=mappingData.TopMostDataflowSubsystem;
    ssBlkName='';
    if hSSBlk~=0
        ssBlkName=getfullname(hSSBlk);
    end

    minExecTime=25000;
    if slsvTestingHook('SLMCMinMultithreadExecTime')>0
        minExecTime=slsvTestingHook('SLMCMinMultithreadExecTime');
    end

    fprintf('\nMapping data\n');
    fprintf('_____________\n');
    fprintf('Subsystem:               %s\n',ssBlkName);
    fprintf('Mapping Data Attributes: %s\n',mappingDataAttributesStr);
    fprintf('Cost Data Attributes:    %s\n',costDataAttributesStr);
    fprintf('Threads:                 %d\n',mappingData.NumberOfThreads);
    fprintf('SpecifiedLatency:        %d\n',mdata.SpecifiedLatency);
    fprintf('ActualLatency:           %d\n',mdata.ActualLatency);
    fprintf('OptimalLatency:          %d\n',mdata.OptimalLatency);
    fprintf('Simulink Version:        %s\n',mdata.slVer);
    fprintf('Total exec time(ns):     %d\n',totalExec);
    fprintf('Min exec time(ns):       %d\n',minExecTime);


    tpd=costData.TallPoleData;
    if~isempty(tpd.TallPoleBlock)
        fprintf('Tall pole block:     %s\n',tpd.TallPoleBlock);
        fprintf('Tall pole ratio:     %d\n',tpd.TallPoleRatio);
    end


    fprintf('%s\n',['Name',blanks(maxLenName-2),'Thread PipeStage Latencies',blanks(maxLenLat-9),'Unfold',blanks(maxLenUnfo-6),'Cost',blanks(maxLenCost-3),'OriginalCost']);
    for i=1:numel(blks)
        fprintf('%s\n',[blks(i).Name,blanks(maxLenName-length(blks(i).Name)+2)...
        ,blks(i).ThreadID,blanks(7-length(blks(i).ThreadID))...
        ,blks(i).PipelineStage,blanks(10-length(blks(i).PipelineStage))...
        ,blks(i).Latencies,blanks(maxLenLat-length(blks(i).Latencies))...
        ,blks(i).Unfolding,blanks(maxLenUnfo-length(blks(i).Unfolding))...
        ,blks(i).Cost,blanks(maxLenCost-length(blks(i).Cost)+1)...
        ,blks(i).OriginalCost]);
    end
end


