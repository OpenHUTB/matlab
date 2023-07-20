function crosscheckModelAndRecordedData(modelName)






    taskMgrBlk=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager');

    if~isempty(taskMgrBlk)
        taskMgrBlk=taskMgrBlk{1};
        thisAllTaskData=get_param(taskMgrBlk,'AllTaskData');
        thisDM=soc.internal.TaskManagerData(thisAllTaskData);
        thisTaskNames=thisDM.getTaskNames;
        allFilePaths={};
        for i=1:numel(thisTaskNames)
            thisTaskData=thisDM.getTask(thisTaskNames{i});
            if thisTaskData.playbackRecorded
                [allFilePaths{end+1},~,~]=...
                fileparts(thisTaskData.diagnosticsFile);%#ok<AGROW>
            end
        end
        if(numel(unique(allFilePaths))>1)
            error(message('soc:scheduler:MixedDiagnosticsFiles'));
        end
        taskInfoFile=fullfile(allFilePaths{1},'TaskInfo.mat');
        if exist(taskInfoFile,'file')
            taskInfo=load(taskInfoFile);
            if(~isfield(taskInfo,'allTaskData'))
                error(message('soc:scheduler:InvalidTaskInfo'));
            end
            diagDM=soc.internal.TaskManagerData(taskInfo.allTaskData);
            diagTaskNames=diagDM.getTaskNames;
            fieldsToCheck={'taskName','taskType','taskPeriod',...
            'taskPriority','coreNum'};
            for i=1:numel(thisTaskNames)
                taskName=thisTaskNames{i};
                thisTaskData=thisDM.getTask(taskName);
                if(~thisTaskData.playbackRecorded),continue;end
                [~,diagTaskName,~]=fileparts(thisTaskData.diagnosticsFile);
                diagTaskData=diagDM.getTask(diagTaskName);
                if~contains(taskName,diagTaskNames)
                    error(message('soc:scheduler:TaskNotInRecording',taskName));
                end
                thisTaskFieldNames=fieldnames(thisTaskData);
                for j=1:numel(thisTaskFieldNames)
                    theField=thisTaskFieldNames{j};
                    if~contains(theField,fieldsToCheck),continue;end
                    if~isequal(thisTaskData.(theField),diagTaskData.(theField))
                        warning(message('soc:scheduler:TaskSettingsDiffer',...
                        taskName,theField,string(thisTaskData.(theField)),...
                        string(diagTaskData.(theField))));
                    end
                end
            end
        else

            disp('Could not find task information file.');
        end
    else

        disp('Could not find Task Manager block.');
    end
end
