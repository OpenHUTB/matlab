function routineLabelInfo=getRoutineLabel(routineBlock)




    routineLabelInfo=[];
    fixedScheduleDataNames={'_Block_Enable','_Variable_Write_Enable','_Force_RungIn_False'};


    if taskHasDataAccessing(routineBlock)



        routineLabelInfo=...
        newRoutineDataInfo(routineBlock,fixedScheduleDataNames{2},'BOOL','1',false);
        return
    end


    parentPOU=slplc.utils.getParentPOU(routineBlock);
    parentPLCBlockType=slplc.utils.getParam(parentPOU,'PLCBlockType');
    if~strcmpi(parentPLCBlockType,'AOIRunner')
        powerRailStartBlk=plc_find_system(routineBlock,...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'PLCBlockType','PowerRailStart');
        if isempty(powerRailStartBlk)

            return
        end
    end


    fixedRoutineDataInfo=newRoutineDataInfo(routineBlock,fixedScheduleDataNames{1},'BOOL','1',false);
    fixedRoutineDataInfo(end+1)=newRoutineDataInfo(routineBlock,fixedScheduleDataNames{2},'BOOL','0',false);
    fixedRoutineDataInfo(end+1)=newRoutineDataInfo(routineBlock,fixedScheduleDataNames{3},'BOOL','0',false);

    blocksWithLabel=getLabelBlocks(routineBlock);
    for blkCount=1:numel(blocksWithLabel)
        blk=blocksWithLabel{blkCount};
        labelTagName=get_param(blk,'PLCLabelTag');
        if isempty(routineLabelInfo)
            routineLabelInfo=newRoutineDataInfo(routineBlock,labelTagName,'BOOL','0',true);
        elseif~ismember(labelTagName,{routineLabelInfo.Name})

            routineLabelInfo(end+1)=newRoutineDataInfo(routineBlock,labelTagName,'BOOL','0',true);%#ok<*AGROW>
        end
    end

    routineLabelInfo=[fixedRoutineDataInfo,routineLabelInfo];
end

function labelBlocks=getLabelBlocks(blockPath)
    labelBlocks={};
    if~isempty(blockPath)
        labelBlocks=plc_find_system(blockPath,...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'regexp','on',...
        'PLCLabelTag','^\w');
    end
end

function routineDataInfo=newRoutineDataInfo(routineBlock,labelName,dataType,initValue,isLabel)
    [dataName,dsmDataName]=slplc.utils.parseRoutineLabel(routineBlock,labelName);
    routineDataInfo=struct(...
    'Name',labelName,...
    'DataName',dataName,...
    'DSMDataName',dsmDataName,...
    'DataType',dataType,...
    'InitialValue',initValue,...
    'IsLabel',isLabel...
    );
end

function tf=taskHasDataAccessing(routineBlock)
    tf=false;
    taskBlocks=plc_find_system(routineBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCBlockType','Task');
    for taskCount=1:numel(taskBlocks)

        taskBlockVarReadWriteBlks=plc_find_system(taskBlocks{taskCount},...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'regexp','on',...
        'PLCBlockType','VariableWrite|VariableRead');
        if~isempty(taskBlockVarReadWriteBlks)
            tf=true;
            break
        end
    end
end
