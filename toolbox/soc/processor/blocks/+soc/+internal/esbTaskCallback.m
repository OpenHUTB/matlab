function esbTaskCallback(blk,action)





    mdlName=bdroot(blk);

    maskObj=Simulink.Mask.get(blk);
    idxDurSrc=ismember({maskObj.Parameters(:).Name},'taskDurationSource');
    idxDiagFile=ismember({maskObj.Parameters(:).Name},'diagnosticsFile');
    idxEvent=ismember({maskObj.Parameters(:).Name},'taskEvent');
    idxPeriod=ismember({maskObj.Parameters(:).Name},'taskPeriod');
    pushBtnBrowse=maskObj.getDialogControl('selectDiagnosticsFile');
    pushBtnPreview=maskObj.getDialogControl('previewDiagnosticsFile');
    groupDuration=maskObj.getDialogControl('taskDurationSettings');

    switch action
    case 'load'
        soc.internal.ESBRegistry.manageInstance('destroy',mdlName,'ESB');
        locUpdatePopOptionsFromBlockUserData(blk);
    case 'maskInitializationCallback'

        sfcnBlkName='S-Function1';
        parBlk=get_param(blk,'Parent');
        topBlk=[parBlk,'/',get_param(blk,'Name')];
        taskDurSrc=get_param(blk,'TaskDurationSource');
        isPlayback=isequal(get_param(blk,'playbackRecorded'),'on');
        isDurFromPort=~isPlayback&&isequal(taskDurSrc,'Input port');
        hInportBlk=find_system(topBlk,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'BlockType',...
        'Inport','Name','Inport');
        hGroundBlk=find_system(topBlk,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'BlockType',...
        'Ground','Name','Ground');
        if isDurFromPort
            if~isempty(hGroundBlk)
                delete_line(topBlk,['Ground','/1'],[sfcnBlkName,'/1']);
                delete_block([topBlk,'/','Ground']);
            end
            if isempty(hInportBlk)
                add_block('built-in/Inport',[topBlk,'/','Inport']);
                add_line(topBlk,['Inport','/1'],[sfcnBlkName,'/1']);
            end
        else
            if~isempty(hInportBlk)
                delete_line(topBlk,['Inport','/1'],[sfcnBlkName,'/1']);
                delete_block([topBlk,'/','Inport']);
            end
            if isempty(hGroundBlk)
                add_block('built-in/Ground',[topBlk,'/','Ground']);
                add_line(topBlk,['Ground','/1'],[sfcnBlkName,'/1']);
            end
        end
    case 'taskTypeChanged'
        taskType=get_param(blk,'taskType');
        if strcmpi(taskType,'Event-driven')
            maskObj.Parameters(idxEvent).Visible='on';
            maskObj.Parameters(idxPeriod).Visible='off';
        else
            maskObj.Parameters(idxEvent).Visible='off';
            maskObj.Parameters(idxPeriod).Visible='on';
        end
    case 'coreSelectionChanged'
        maskObj=Simulink.Mask.get(blk);
        idx=ismember({maskObj.Parameters(:).Name},'coreNum');
        if isequal(get_param(blk,'coreSelection'),'Any core')
            maskObj.Parameters(idx).Visible='off';
        else
            maskObj.Parameters(idx).Visible='on';
        end
    case 'taskDurationSourceChanged'
        playbackRecorded=get_param(blk,'playbackRecorded');
        taskDur=get_param(blk,'taskDurationSource');
        if isequal(playbackRecorded,'on')
            groupDuration.Visible='off';
        elseif isequal(taskDur,'Dialog')
            maskObj.Parameters(idxDiagFile).Visible='off';
            pushBtnBrowse.Visible='off';
            pushBtnPreview.Visible='off';
            groupDuration.Visible='on';
            groupDuration.Enabled='on';
        elseif isequal(taskDur,'Input port')
            maskObj.Parameters(idxDiagFile).Visible='off';
            pushBtnBrowse.Visible='off';
            pushBtnPreview.Visible='off';
            groupDuration.Visible='off';
        elseif isequal(taskDur,'Recorded task execution statistics')
            maskObj.Parameters(idxDiagFile).Visible='on';
            pushBtnBrowse.Visible='on';
            pushBtnPreview.Visible='off';
            groupDuration.Visible='on';
            groupDuration.Enabled='off';
        end
    case 'playbackChanged'
        groupDuration=maskObj.getDialogControl('taskDurationSettings');
        playbackRecorded=get_param(blk,'playbackRecorded');
        if isequal(playbackRecorded,'on')
            maskObj.Parameters(idxDurSrc).Visible='off';
            maskObj.Parameters(idxDiagFile).Visible='on';
            pushBtnBrowse.Visible='on';
            pushBtnPreview.Visible='on';
            groupDuration.Visible='off';
        else
            maskObj.Parameters(idxDurSrc).Visible='on';
            pushBtnPreview.Visible='off';
            taskDur=get_param(blk,'taskDurationSource');
            if isequal(taskDur,'Dialog')
                maskObj.Parameters(idxDiagFile).Visible='off';
                pushBtnBrowse.Visible='off';
                groupDuration.Visible='on';
                groupDuration.Enabled='on';
            elseif isequal(taskDur,'Input port')
                maskObj.Parameters(idxDiagFile).Visible='off';
                pushBtnBrowse.Visible='off';
                groupDuration.Visible='off';
                groupDuration.Enabled='off';
            else
                maskObj.Parameters(idxDiagFile).Visible='on';
                pushBtnBrowse.Visible='on';
                groupDuration.Visible='on';
                groupDuration.Enabled='off';
            end
        end
    case 'selectDiagnosticsFile'
        if~isequal(get_param(mdlName,'SimulationStatus'),'running')
            [selectedFile,selectedPath]=uigetfile({'*.csv',...
            'Diagnostics data'},'Select diagnostics file');
            if selectedFile~=0
                set_param(blk,'DiagnosticsFile',...
                fullfile(selectedPath,selectedFile));
                if isequal(get_param(blk,'playbackRecorded'),'off')
                    [mean,dev]=...
                    soc.internal.getTaskDurationFromDiagnosticsFile(...
                    get_param(blk,'taskName'),...
                    fullfile(selectedPath,selectedFile),...
                    get_param(blk,'Name'));
                    set_param(blk,'taskDuration',num2str(mean));
                    set_param(blk,'taskDurationDeviation',num2str(dev));
                end
            end
        end
    end
end


function locUpdatePopOptionsFromBlockUserData(blk)
    taskEventList={};
    maskObj=Simulink.Mask.get(blk);
    blkParameters={maskObj.Parameters(:).Name};
    [~,idx]=ismember('taskEvent',blkParameters);
    ud=get_param(blk,'UserData');
    if~isempty(ud)&&isfield(ud,'TaskEventList')&&iscell(ud.TaskEventList)
        taskEventList=ud.TaskEventList;
    end
    eventID=get_param(blk,'taskEvent');
    updatedTaskEventList=['<empty>',taskEventList];

    if~ismember(eventID,updatedTaskEventList)
        updatedTaskEventList=[updatedTaskEventList,eventID];
    end
    maskObj.Parameters(idx).TypeOptions=updatedTaskEventList;
end
