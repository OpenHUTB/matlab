



classdef StudioMgr<handle




    properties(Access=private)
currentStudio
preserveDirty
editor
modelName
courseObject
conceptSequence
        pass=0;
assessmentPaneWidth
taskPaneWidth
passStatus
        additionalModels={};
    end

    properties(Constant,Hidden,Access=public)
        TASK_PANE_ID='TaskWindow';
        TASK_PANE_TAG='learning.simulink.Interaction';
        ASSESS_PANE_ID='SignalCheck';
    end

    methods(Access=public)

        function obj=StudioMgr(modelName,courseObject,conceptSequence)






            obj.modelName=modelName;
            obj.setCourseObject(courseObject);
            obj.setConceptSequence(conceptSequence);

            obj.createNewModel;
            learning.simulink.closeNotificationBar(obj.modelName);
            obj.editor=learning.simulink.getEditorFromModel(obj.modelName);

            obj.createBlankAssessPane;
            obj.createTaskWindow;

            obj.runInitializationCode;
            obj.addStartingBlocks;




            if~courseObject.task
                assessmentBlockPath=[];
                learning.simulink.openDockedSignal(assessmentBlockPath);
            end
        end

        function[studio,editor]=getActiveStudioAndEditor(obj)

            studio=[];
            editor=[];
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            for idx=1:numel(allStudios)
                if strcmp(get_param(allStudios(idx).App.blockDiagramHandle,'Name'),obj.modelName)
                    studio=allStudios(idx);
                    editor=allStudios(idx).App.getActiveEditor;
                end
            end

        end

        function setupTask(obj,taskNumber)



            obj.stopModel();
            obj.closeSignalAndScopeWindows();

            if learning.simulink.Application.getInstance().getCurrentTask()~=taskNumber


                learning.simulink.Application.getInstance().gotoTaskNumber(taskNumber);
            end

            learning.simulink.closeNotificationBar(obj.modelName);
            obj.editor=learning.simulink.getEditorFromModel(obj.modelName);
            contentsRoot=learning.simulink.SimulinkAppInteractions.getContentPath;
            interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
            assessmentParams=interactionAssessments{obj.courseObject.task};





            existing_graders=find_system(obj.modelName,'MatchFilter',...
            @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            existing_grader_num=str2double(get_param(existing_graders,'task'));

            learning.assess.clearBlockEffects(obj.modelName);





            isBlockAssessment=isstruct(assessmentParams)||isstruct(assessmentParams{1});
            isQuizAssessment=isstruct(assessmentParams)&&...
            isequal(assessmentParams.graderType,'quiz');
            if isBlockAssessment&&~isQuizAssessment
                if~isstruct(assessmentParams)
                    assessmentParams=assessmentParams{1};
                end
                rm_graders=~ismember(existing_grader_num,assessmentParams.grader);
                last_block_pos=[];




                existing_signal_graders=existing_graders(cellfun(...
                @isempty,regexp(get_param(existing_graders,'ReferenceBlock'),'Model')));
                if~isempty(existing_signal_graders)
                    last_block_pos=get_param(existing_signal_graders{end},'Position');
                end



                if isfield(assessmentParams,'keepConnected')
                    keepConnected=assessmentParams.keepConnected;
                else


                    keepConnected=zeros(1,length(assessmentParams.grader));




                    indexOfGraderBlocksToKeepConnected=length(assessmentParams.grader);


                    for i=1:length(assessmentParams.grader)-1

                        currentGraderIdx=find(existing_grader_num==assessmentParams.grader(i));
                        if contains(existing_graders{currentGraderIdx},'Signal')
                            indexOfGraderBlocksToKeepConnected=i;
                            break;
                        end
                    end
                    keepConnected(indexOfGraderBlocksToKeepConnected)=true;
                end


                obj.deletePrevGraderBlks(rm_graders,existing_graders,keepConnected);

                doOffset=false;
                if numel(assessmentParams.grader)>1
                    doOffset=true;
                end

                assess_pos=learning.simulink.calcAssessmentBlkPosition(obj.modelName,last_block_pos,...
                doOffset,assessmentParams.graderType);


                graderMap=containers.Map({'mlsignal','mlmodel','signal','sfmodel'},...
                {'signalChecks/MATLAB Signal Check','signalChecks/MATLAB Model Check',...
                'signalChecks/Signal Assessment','signalChecks/Stateflow Model Check'});

                blockNameMap=containers.Map({'mlsignal','mlmodel','signal','sfmodel'},...
                {'Signal Assessment','Model Assessment','Signal Assessment','Stateflow Assessment'});



                load_system(fullfile(learning.simulink.SimulinkAppInteractions.getSLTrainingPath,'signalChecks','signalChecks.slx'));



                numBlocksNamed=numel(find_system(obj.modelName,'MatchFilter',...
                @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'RegExp','on','Name',blockNameMap(assessmentParams.graderType)));

                if numBlocksNamed>0
                    assessmentBlockName=[blockNameMap(assessmentParams.graderType),num2str(numel(numBlocksNamed))];
                else
                    assessmentBlockName=blockNameMap(assessmentParams.graderType);
                end








                if isempty(existing_graders(~rm_graders))||~ismember(num2str(taskNumber),get_param(existing_graders(~rm_graders),'task'))
                    assess_block=add_block(graderMap(assessmentParams.graderType),...
                    [obj.modelName,'/',assessmentBlockName]);
                else


                    assess_block=getSimulinkBlockHandle(find_system(obj.modelName,'MatchFilter',...
                    @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'RegExp','on','ReferenceBlock','signalChecks'));
                end

                set_param(assess_block,'Position',assess_pos);

                if strcmp(assessmentParams.graderType,'mlmodel')||strcmp(assessmentParams.graderType,'sfmodel')
                    annotation_str=message('learning:simulink:resources:noInputRequired').getString();
                    if all(rm_graders)
                        annotation_str=message('learning:simulink:resources:noInputRequiredTask').getString();
                    end
                    set_param(assess_block,'AttributesFormatString',annotation_str);
                end

                close_system('signalChecks');

                interactionNum=learning.simulink.SimulinkAppInteractions.sectionToInteraction(obj.courseObject.course,...
                obj.conceptSequence,obj.courseObject.section);
                answerSignalFile=['interaction',num2str(interactionNum),'_task',...
                num2str(obj.courseObject.task),'.mat'];

                if exist(fullfile(contentsRoot,obj.conceptSequence,answerSignalFile),'file')==2
                    answer=load(fullfile(contentsRoot,obj.conceptSequence,answerSignalFile));
                    varnames=fieldnames(answer);
                    model_ws=get_param(obj.modelName,'ModelWorkspace');
                    for idx=1:numel(varnames)
                        model_ws.assignin(varnames{idx},answer.(varnames{idx}));
                    end
                end

                if isfield(assessmentParams.graderParams,'y_ans')
                    assessmentParams.graderParams.y_ans_upper=assessmentParams.graderParams.y_ans;
                    assessmentParams.graderParams=rmfield(assessmentParams.graderParams,'y_ans');
                end
                maskParamNames=fieldnames(assessmentParams.graderParams);

                for idx=1:numel(maskParamNames)
                    set_param(assess_block,maskParamNames{idx},...
                    assessmentParams.graderParams.(maskParamNames{idx}));
                end

                isSignalBlock=isequal(assessmentParams.graderType,'signal');
                if isSignalBlock
                    if any(contains(maskParamNames,'range'))
                        signalType="'signal'";
                    else
                        signalType="'bound'";
                    end
                    set_param(assess_block,'signal_type',signalType);
                end
                set_param(assess_block,'task',num2str(obj.courseObject.task));

                obj.resetTasksAsUnsubmitted;

                if strcmp(assessmentParams.graderType,'sfmodel')&&isequal(get_param(assess_block,'startInChart'),'true')
                    obj.openStateflowChart(taskNumber);


                    [~,obj.editor]=obj.getActiveStudioAndEditor;
                end
                set_param(assess_block,'PreCopyFcn',...
                "error(message('learning:simulink:resources:ErrorNoCopy'))");
                set_param(assess_block,'PreDeleteFcn',...
                "error(message('learning:simulink:resources:ErrorNoDelete'))");
            elseif isQuizAssessment

                if~isempty(existing_graders)
                    grader_blocks_to_remove=~ismember(existing_grader_num,assessmentParams.grader);
                    keep_graders_connected=false;
                    obj.deletePrevGraderBlks(grader_blocks_to_remove,existing_graders,keep_graders_connected);
                end
            else





                if~isempty(existing_graders)
                    grader_blocks_to_keep=[];
                    grader_blocks_to_remove=~ismember(existing_grader_num,grader_blocks_to_keep);
                    keep_graders_connected=false;
                    obj.deletePrevGraderBlks(grader_blocks_to_remove,existing_graders,keep_graders_connected);
                end
            end


            learning.simulink.internal.util.CourseUtils().addStopFcnForAssessmentBlock(obj.modelName);


            learning.simulink.glowGrader.clearAllGlows('GlowGrader',obj.modelName);
            learning.simulink.resetPlots(obj.modelName);

            resetModelLocation=...
            learning.simulink.SimulinkAppInteractions.statusFileForConceptSequence(obj.courseObject.course,...
            obj.conceptSequence,obj.courseObject.section);




            currentCourse=obj.getCourse();
            requiredProducts=learning.simulink.preferences.slacademyprefs.CourseMap(currentCourse).ProductNames;
            usesSimscape=any(contains(lower(requiredProducts),'simscape'));
            if usesSimscape
                set_param(obj.modelName,'ReturnWorkspaceOutputs','off');
            end



            interactionContent=learning.simulink.Application.getInstance().getInteractionContent();
            if isfield(interactionContent.simulinkInteraction.questions(taskNumber),'additionalModels')
                obj.additionalModels=interactionContent.simulinkInteraction.questions(taskNumber).additionalModels;
            end
            modelFolder=fullfile(tempdir,'simulinkselfpaced');
            folderContents=dir(modelFolder);
            isFolder=arrayfun(@(x)x.isdir,folderContents);
            folderContents(isFolder)=[];

            for i=1:length(folderContents)
                isCourseModel=contains(folderContents(i).name,obj.modelName);
                isAdditionalModel=any(cellfun(@(x)isequal([x,'.slx'],folderContents(i).name),obj.additionalModels));
                isCacheModel=any(cellfun(@(x)isequal([x,'.slxc'],folderContents(i).name),obj.additionalModels));
                if~isCourseModel&&~isAdditionalModel&&~isCacheModel


                    bdclose(folderContents(i).name);
                    delete(fullfile(folderContents(i).folder,folderContents(i).name));
                end
            end

            folderContents=dir(modelFolder);
            isFolder=[folderContents.isdir]';
            folderContents(isFolder)=[];

            for i=1:length(obj.additionalModels)
                tempDirModelName=obj.additionalModels{i};
                tempDirModelPath=fullfile(modelFolder,tempDirModelName);

                isAlreadyCopied=any(arrayfun(@(x)isequal(x.name,[tempDirModelName,'.slx']),folderContents));
                isOpened=bdIsLoaded(tempDirModelName)&&strcmp(get_param(tempDirModelName,'Shown'),'on');
                if~isAlreadyCopied||(isAlreadyCopied&&~isOpened)




                    conceptSequence=learning.simulink.Application.getInstance().getConceptSequence();
                    additionalModelPath=fullfile(learning.simulink.SimulinkAppInteractions.getContentPath,...
                    conceptSequence,'additionalModels',[obj.additionalModels{i},'.slx']);
                    copyfile(additionalModelPath,[tempDirModelPath,'.slx']);
                    fileattrib([tempDirModelPath,'.slx'],'+w');
                    open_system(tempDirModelPath);
                    Simulink.addBlockDiagramCallback(tempDirModelName,'CloseRequest',['additionalModel',num2str(i),'cb'],...
                    @()error('Simulink:Commands:CancelCloseModel','Cancel model close'));

                    model_obj=get_param(obj.modelName,"Object");
                    try
                        model_obj.refreshModelBlocks;
                    catch err

                        if~strcmp(err.identifier,'Simulink:modelReference:InvalidModelrefName')
                            rethrow(err);
                        end
                    end
                end








                lockStatus=get_param(obj.additionalModels{i},'Lock');
                if strcmp(lockStatus,'off')
                    learning.simulink.saveCurrentToResetModel(tempDirModelName,...
                    0,obj.courseObject.task,resetModelLocation);
                end
            end



            learning.simulink.saveCurrentToResetModel(obj.modelName,obj.courseObject.section,...
            obj.courseObject.task,resetModelLocation);

            save_system(obj.modelName,'SaveDirtyReferencedModels','on');
        end

        function[pass,grader]=submitTask(obj)


            obj.stopModel();




            [~,obj.editor]=obj.getActiveStudioAndEditor;



            studio=obj.editor.getStudio;
            signalCheckComponent=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.ASSESS_PANE_ID);
            assessPaneWidth=signalCheckComponent.getWidget.contentRect(3);
            if~isequal(assessPaneWidth,obj.assessmentPaneWidth)
                obj.assessmentPaneWidth=assessPaneWidth;
            end


            taskPaneComponent=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.TASK_PANE_ID);
            tPaneWidth=taskPaneComponent.getWidget.contentRect(3);
            if~isequal(tPaneWidth,obj.taskPaneWidth)
                obj.taskPaneWidth=tPaneWidth;
            end



            grd_block=find_system(obj.modelName,'IncludeCommented','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');


            obj.editor.closeNotificationByMsgID(obj.editor.getActiveNotification);



            if isempty(grd_block)


                interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
                taskNum=LearningApplication.getCurrentTask();
                currentAssessments=interactionAssessments{taskNum};

                learning.assess.clearBlockEffects(obj.modelName);
                obj.passStatus=learning.assess.gradeGeneralAssessments(currentAssessments,obj.modelName);




                numTasks=learning.simulink.Application.getInstance().getNumberOfTasks();
                if isequal(numTasks,taskNum)&&isempty(learning.assess.getAssessmentWithPlot())
                    try

                        if learning.simulink.Application.getInstance().getTestMode()
                            sim(learning.simulink.Application.getInstance().getModelName);
                        else
                            evalc('sim(learning.simulink.Application.getInstance().getModelName);');
                        end
                    catch ex



                        sldiagviewer.reportError(ex);
                    end
                end



                pass=obj.passStatus;
                pass(pass<=0)=0;

                pass=logical(pass)';
                grader=taskNum.*ones(1,length(pass))';
            else



                learning.simulink.Application.getInstance().clearStateflowBreakpoints();

                try

                    if learning.simulink.Application.getInstance().getTestMode()
                        sim(learning.simulink.Application.getInstance().getModelName);
                    else
                        evalc('sim(learning.simulink.Application.getInstance().getModelName);');
                    end
                catch ex



                    sldiagviewer.reportError(ex);
                end


                for idx=1:numel(grd_block)
                    if(isequal(get_param(grd_block{idx},'Commented'),'off'))
                        SignalCheckUtils.updatePassStatus(grd_block{idx});
                        learning.simulink.updateGlow(grd_block{idx});
                        pass_status=str2double(get_param(grd_block{idx},'pass'));
                        learning.simulink.updateGraderBadge(grd_block{idx},pass_status);
                    end
                end

                pass=str2double(get_param(grd_block,'pass'));
                grader=str2double(get_param(grd_block,'task'));



                pass(pass<=0)=0;

                pass=logical(pass);

                isCommented=get_param(grd_block,'Commented');

                if~all(pass==1)

                    if any(contains(isCommented,'on'))



                        msgString=message('learning:simulink:resources:NotificationBarMissingAssessment').getString();
                        obj.sendWarningToCanvas('NotificationBarMissingAssessment',msgString);

                    elseif numel(pass)==1
                        hilite_name=grd_block{1};



                        currentTask=learning.simulink.Application.getInstance().getCurrentTask();
                        if contains(hilite_name,'Stateflow')
                            msgString=message('learning:simulink:resources:NotificationBarIncorrectStateflow',currentTask).getString();
                            msgID='NotificationBarIncorrectStateflow';
                        else
                            msgString=message('learning:simulink:resources:NotificationBarIncorrectSingle',...
                            currentTask,hilite_name).getString();
                            msgID='NotificationBarIncorrectSingle';
                        end
                        obj.sendWarningToCanvas(msgID,msgString);
                    else

                        msgBlockList=cell(numel(grader(~pass)),1);

                        hilite_names=grd_block(~pass);
                        block_names=get_param(grd_block(~pass),'Name');

                        for idx=1:numel(hilite_names)
                            msgBlockList{idx}=[' <a href="matlab:hilite_system(''',hilite_names{idx},''',''orangeWhite'');">',block_names{idx},'</a>'];
                        end

                        msgBlockList=strjoin(msgBlockList,',');



                        msgString=message('learning:simulink:resources:NotificationBarIncorrectMultiple',msgBlockList).getString();

                        obj.sendWarningToCanvas('NotificationBarIncorrectMultiple',msgString);
                    end
                end


                interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
                taskNum=LearningApplication.getCurrentTask();
                currentAssessments=interactionAssessments{taskNum};
                hasGeneralAssessments=~isstruct(currentAssessments);
                if hasGeneralAssessments
                    generalAssessmentPassStatus=learning.assess.gradeGeneralAssessments(currentAssessments(2:end),obj.modelName);
                    generalAssessmentPassStatus(generalAssessmentPassStatus<=0)=0;

                    generalAssessmentPassStatus=logical(generalAssessmentPassStatus)';
                    generalAssessmentGrader=taskNum.*ones(1,length(generalAssessmentPassStatus))';

                    numOfAssessmentBlks=1;
                    pass(2:length(generalAssessmentPassStatus)+numOfAssessmentBlks,1)=generalAssessmentPassStatus;
                    grader(2:length(generalAssessmentGrader)+numOfAssessmentBlks,1)=generalAssessmentGrader;
                end

            end

            save_system(learning.simulink.Application.getInstance().getModelName,'SaveDirtyReferencedModels',true);

        end

        function resetTask(obj)






            yesStr=message('learning:simulink:resources:DialogExitTrue').getString();
            noStr=message('learning:simulink:resources:DialogExitFalse').getString();

            reset_confirm=questdlg(message('learning:simulink:resources:ResetConfirmDialogText').getString(),...
            message('learning:simulink:resources:ResetConfirmDialogName').getString(),...
            yesStr,noStr,noStr);

            if isempty(reset_confirm)||strcmp(reset_confirm,noStr)
                return
            end

            resetModelLocation=...
            learning.simulink.SimulinkAppInteractions.statusFileForConceptSequence(obj.courseObject.course,...
            obj.conceptSequence,obj.courseObject.section);

            obj.stopModel();


            taskResetModel=['Section',num2str(obj.courseObject.section),'TaskResets'];
            reset_subsys=[taskResetModel,'/Task',num2str(obj.courseObject.task),'Reset'];
            if exist(fullfile(resetModelLocation,[taskResetModel,'.slx']),'file')==0
                error(message('learning:simulink:resources:ResetErrorMsg'));
            end



            open_system(obj.modelName);


            learning.simulink.allowGraderDelete(obj.modelName);
            Simulink.BlockDiagram.deleteContents(obj.modelName);

            learning.simulink.closeNotificationBar(obj.modelName);
            obj.editor=learning.simulink.getEditorFromModel(obj.modelName);


            load_system(fullfile(resetModelLocation,[taskResetModel,'.slx']))
            Simulink.SubSystem.copyContentsToBlockDiagram(reset_subsys,obj.modelName);





            existing_graders=find_system(obj.modelName,'MatchFilter',...
            @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            current_grader=[];
            if~isempty(existing_graders)
                for idx=1:numel(existing_graders)
                    pass_status='-1';
                    set_param(existing_graders{idx},'pass',pass_status);
                    learning.simulink.updateGraderBadge(existing_graders{idx},str2double(pass_status));

                    set_param(existing_graders{idx},'PreCopyFcn',...
                    "error(message('learning:simulink:resources:ErrorNoCopy'))");
                    set_param(existing_graders{idx},'PreDeleteFcn',...
                    "error(message('learning:simulink:resources:ErrorNoDelete'))");
                end
                close_system(fullfile(resetModelLocation,[taskResetModel,'.slx']))

                existing_grader_num=str2double(get_param(existing_graders,'task'));
                current_grader=existing_graders{existing_grader_num==obj.courseObject.task};
                learning.simulink.Application.getInstance().setSclOpenTask(obj.courseObject.task);
                learning.simulink.deleteUndockedFigures(obj.modelName);
                learning.simulink.resetPlots(obj.modelName);






                contentsRoot=learning.simulink.SimulinkAppInteractions.getContentPath;
                assessmentParams=learning.simulink.SimulinkAppInteractions.getAssessmentParams(contentsRoot,...
                obj.courseObject,obj.courseObject.task);
                if strcmp(assessmentParams.graderType,'sfmodel')
                    startInChart=zeros(1,length(existing_graders));
                    for i=1:length(existing_graders)
                        if get_param(existing_graders{i},'startInChart')
                            startInChart(i)=1;
                        else
                            startInChart(i)=0;
                        end
                    end
                    startInChart=any(startInChart);
                    if startInChart
                        obj.openStateflowChart(obj.courseObject.task);
                    end
                end
            else


                userBlockValueFile=learning.assess.getAssessmentPlotLogFile();
                if exist(userBlockValueFile,'file')
                    delete(userBlockValueFile);
                end
            end


            learning.simulink.openDockedSignal(current_grader);

            for i=1:length(obj.additionalModels)




                lockStatus=get_param(obj.additionalModels{i},'Lock');
                if strcmp(lockStatus,'on')
                    continue
                end

                additionalResetModel=[obj.additionalModels{i},'_reset_copy'];
                reset_subsys=[additionalResetModel,'/Task',num2str(obj.courseObject.task),'Reset'];
                if exist(fullfile(resetModelLocation,[additionalResetModel,'.slx']),'file')==0
                    error(message('learning:simulink:resources:ResetErrorMsg'));
                end
                Simulink.BlockDiagram.deleteContents(obj.additionalModels{i});

                load_system(fullfile(resetModelLocation,[additionalResetModel,'.slx']))
                Simulink.SubSystem.copyContentsToBlockDiagram(reset_subsys,obj.additionalModels{i});
                close_system(fullfile(resetModelLocation,[additionalResetModel,'.slx']),0)
            end
            save_system(obj.modelName,'SaveDirtyReferencedModels','on');
        end

        function setCourseObject(obj,courseObject)

            obj.courseObject=courseObject;
        end

        function setConceptSequence(obj,conceptSequence)

            obj.conceptSequence=conceptSequence;
        end

        function createTaskWindow(obj)




            if~isempty(obj.currentStudio)
                taskComponent=obj.currentStudio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.TASK_PANE_ID);
                if~isempty(taskComponent)
                    if~taskComponent.isVisible
                        obj.currentStudio.showComponent(taskComponent);
                    end
                    return
                end
            end

            taskPane=learning.simulink.slAcademy.TaskPane();
            taskPane.show(obj.editor.getStudio);

            model_ws=get_param(obj.modelName,'ModelWorkspace');
            model_ws.assignin('courseObject',obj.courseObject);



        end

        function updateAssessmentPane(obj)



            blkHandle=find_system(obj.modelName,'RegExp','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock','signalChecks','task',num2str(obj.courseObject.task));

            interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
            taskNum=LearningApplication.getCurrentTask();
            currentAssessments=interactionAssessments{taskNum};

            if numel(blkHandle)>1
                error(message('learning:simulink:resources:ErrorAddMultipleAssessments'));
            elseif isequal(numel(blkHandle),1)
                blkHandle=blkHandle{1};

                referenceMap=containers.Map(...
                {'signalChecks/MATLAB Signal Check',...
                'signalChecks/MATLAB Model Check',...
                'signalChecks/Signal Assessment',...
                'signalChecks/Stateflow Model Check'},...
                {'mlsignal','mlmodel','signal','sfmodel'});

                assessmentType=referenceMap(get_param(blkHandle,'ReferenceBlock'));


                full_block_path=[get_param(blkHandle,'Parent'),'/',get_param(blkHandle,'Name')];
                switch assessmentType
                case 'mlsignal'
                    SignalMATLABCheck.writeCurrentPlot(full_block_path);
                case 'signal'
                    SignalAssessment.writeCurrentPlot(full_block_path);
                end

                learning.simulink.openDockedSignal(full_block_path);
            elseif isstruct(currentAssessments)


                learning.simulink.slAcademy.slFeedbackHandler.createDocked(obj.editor,'','quiz');
            else


                messages=learning.assess.getAssessmentRequirements(currentAssessments);

                obj.passStatus=-ones(1,length(messages));
                assessmentWithPlot=learning.assess.checkAssessmentsForPlots(currentAssessments);
                userBlockValueFile=learning.assess.getAssessmentPlotLogFile();
                if exist(userBlockValueFile,'file')
                    delete(userBlockValueFile);
                end
                if~isempty(assessmentWithPlot)
                    selectedBlock=gcb;
                    if~strcmp(get_param(gcb,'Selected'),'on')
                        selectedBlock=[];
                    end
                    showFigureWindow=false;
                    assessmentWithPlot.writePlotFigure(selectedBlock,showFigureWindow);
                    learning.simulink.slAcademy.slFeedbackHandler.createDocked(obj.editor,'','soln',messages,obj.passStatus);
                else
                    learning.simulink.slAcademy.slFeedbackHandler.createDocked(obj.editor,'','soln-noimg',messages,obj.passStatus);
                end

            end

        end

        function exitInteraction(obj)
            obj.cleanUpWorkingModels();
        end

        function studio=getCurrentStudio(obj)
            studio=obj.currentStudio;
        end

        function handlePostNameChanged(obj,studio)
            assert(~isempty(studio));
            assert(~isempty(studio.App));
            obj.modelName=get_param(studio.App.blockDiagramHandle,'Name');
            obj.closeSignalAndScopeWindows();

            learning.simulink.Application.getInstance().setModelPosition(learning.simulink.getTrainingStudioPosition(obj.modelName))


            function closeSLOnrampDDGComponent(tag)
                compAssessPane=studio.getComponent('GLUE2:DDG Component',tag);
                if~isempty(compAssessPane)
                    studio.destroyComponent(compAssessPane);
                end
            end
            closeSLOnrampDDGComponent(learning.simulink.StudioMgr.TASK_PANE_ID);
            closeSLOnrampDDGComponent(learning.simulink.StudioMgr.ASSESS_PANE_ID);




            blkHandles=find_system(obj.modelName,'MatchFilter',...
            @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            if~isempty(blkHandles)
                cellfun(@(blockHandle)set_param(blockHandle,'PreDeleteFcn',''),blkHandles);
                cellfun(@(blockHandle)delete_block(blockHandle),blkHandles);
            end
        end

        function handlePreClose(obj,studio)
            assert(~isempty(studio));
            assert(~isempty(studio.App));

            obj.closeSignalAndScopeWindows();

            learning.simulink.Application.getInstance().setModelPosition(learning.simulink.getTrainingStudioPosition(obj.modelName))

            cellfun(@(x)bdclose(x),obj.additionalModels);



            obj.cleanUpResetModels();
        end

        function[pass,requirements]=gradeStateflowTask(obj,block)





            flags=get_param(block,'flags');

            flags=flags(2:end-1);
            flags=strsplit(flags,' ');

            requirements=obj.getRequirements();





            interactionNum=learning.simulink.SimulinkAppInteractions.sectionToInteraction(obj.courseObject.course,...
            obj.conceptSequence,obj.courseObject.section);
            solutionFileName=['solution_interaction',num2str(interactionNum),...
            '_task',num2str(obj.courseObject.task)];
            solution=learning.stateflow.ModelStructureBuilder.Construct(solutionFileName);
            userModel=learning.stateflow.ModelStructureBuilder.Construct(obj.modelName);
            assessmentResults=learning.stateflow.assess(solution,userModel,flags);

            pass=cellfun(@isempty,assessmentResults);






            if isequal(numel(requirements),1)
                pass=all(pass);
            elseif isequal(numel(flags),numel(requirements))

            else
                error("Can't have a difference in requirements and flags unless there is only one requirement")
            end
        end

        function requirements=getRequirements(obj)





            requirementsEntry=strrep(obj.conceptSequence,'/','_');
            interactionNum=learning.simulink.SimulinkAppInteractions.sectionToInteraction(obj.courseObject.course,...
            obj.conceptSequence,obj.courseObject.section);
            requirementsEntry=[requirementsEntry,'_Interaction',int2str(interactionNum),...
            '_Task',int2str(obj.courseObject.task)];
            requirementsEntry=strrep(requirementsEntry,' ','_');
            requirementsEntry=strrep(requirementsEntry,'_-_','_');
            requirementIdx=1;
            messageEntry=strcat('learning:simulink:stateflowOnrampRequirements:',requirementsEntry,'_Req',int2str(requirementIdx));
            requirements={message(messageEntry).getString()};
            noErrorThrown=true;





            while noErrorThrown
                requirementIdx=requirementIdx+1;
                try
                    messageEntry=strcat('learning:simulink:stateflowOnrampRequirements:',requirementsEntry,'_Req',int2str(requirementIdx));
                    requirements{end+1}=message(messageEntry).getString();
                catch
                    noErrorThrown=false;
                end
            end
        end

        function course=getCourse(obj)
            course=obj.courseObject.course;
        end

        function assessmentPaneWidth=getAssessmentPaneWidth(obj)
            assessmentPaneWidth=obj.assessmentPaneWidth;
        end

        function taskPaneWidth=getTaskPaneWidth(obj)
            taskPaneWidth=obj.taskPaneWidth;
        end

        function passStatus=getPassStatus(obj)
            passStatus=obj.passStatus;
        end

        function sendWarningToCanvas(obj,messageID,messageString)


            obj.editor.deliverWarnNotification(messageID,messageString);
        end
    end

    methods(Access=private)

        function createNewModel(obj)

            learning.simulink.internal.util.clearAndResetFolder(fullfile(tempdir,'signalCheck'));

            if~exist(fullfile(tempdir,'simulinkselfpaced'),'dir')
                mkdir(fullfile(tempdir,'simulinkselfpaced'));
            end

            if isempty(learning.simulink.Application.getInstance().getModelPosition)
                learning.simulink.Application.getInstance().setModelPosition(learning.simulink.getTrainingStudioPosition(obj.modelName));
            end

            if bdIsLoaded(obj.modelName)


                error(message('learning:simulink:resources:ErrorTrainingModelOpen'));
            end


            contentRoot=learning.simulink.preferences.slacademyprefs.contentPath;
            courseFileName=['course_',obj.courseObject.course,'.json'];
            defaultTemplate='simulink_model_template.sltx';
            jsonFile=jsondecode(fileread(fullfile(contentRoot,courseFileName)));
            if isfield(jsonFile,'modelTemplate')
                modelTemplate=jsonFile.modelTemplate;
            else
                modelTemplate=defaultTemplate;
            end

            modelTemplatePath=fullfile(contentRoot,'model_templates',modelTemplate);
            bd=Simulink.createFromTemplate(modelTemplatePath,'Name',obj.modelName);
            slhistory.exclude.set(get_param(bd,'Handle'));
            load_system(bd);
            set_param(obj.modelName,'CloseFcn','learning.simulink.cleanupOnlineTraining');
            set_param(obj.modelName,'StopFcn','learning.simulink.modelCallbacks.stopFunction(gcs)');
            set_param(obj.modelName,'StartFcn','learning.simulink.modelCallbacks.startFunction(gcs)');
            set_param(obj.modelName,'SaveTime','off');



            set_param(obj.modelName,'Location',learning.simulink.Application.getInstance().getModelPosition);

            open_system(obj.modelName);
            modelPath=fullfile(tempdir,'simulinkselfpaced',[obj.modelName,'.slx']);
            save_system(obj.modelName,modelPath);




            obj.preserveDirty=Simulink.PreserveDirtyFlag(obj.modelName,'blockDiagram');

            obj.editor=learning.simulink.getEditorFromModel(obj.modelName);
        end

        function createBlankAssessPane(obj)

            learning.simulink.slAcademy.slFeedbackHandler.createDocked(obj.editor,'','blank');

            [obj.currentStudio,obj.editor]=obj.getActiveStudioAndEditor;
            obj.currentStudio.raise;
        end

        function addStartingBlocks(obj)
            contentsRoot=learning.simulink.SimulinkAppInteractions.getContentPath;
            interactionNum=learning.simulink.SimulinkAppInteractions.sectionToInteraction(obj.courseObject.course,...
            obj.conceptSequence,obj.courseObject.section);

            modelPath=fullfile(contentsRoot,obj.conceptSequence,'StartingModels.slx');
            if exist(modelPath,'file')~=0

                w(1)=warning('off','Simulink:modelReference:ModelNotFoundWithBlockName');
                w(2)=warning('off','Simulink:Libraries:MissingLibrary');
                c=onCleanup(@()warning(w));

                load_system(modelPath);


                startModelSubsystem=find_system('StartingModels','MatchFilter',...
                @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'Name',['interaction',num2str(interactionNum)]);

                if~isempty(startModelSubsystem)
                    Simulink.SubSystem.copyContentsToBlockDiagram(startModelSubsystem{1},obj.modelName);
                    MG2.Util.waitForGui;
                    obj.positionStartingBlocks;
                end
                close_system('StartingModels');
            end

        end

        function positionStartingBlocks(obj)

            canvas=obj.editor.getCanvas;

            bounds=canvas.Scene.Bounds;
            extents=canvas.SceneRectInView;





            extents(3)=.85*extents(3);
            extents(4)=.85*extents(4);

            leftPad=15;

            if(bounds(3)+leftPad>.80*extents(3))||(bounds(4)>.95*extents(4))
                viewWidth=bounds(3)/.80;
                viewHeight=bounds(4)/.95;
            else
                viewWidth=extents(3);
                viewHeight=extents(4);
            end



            viewRect=[bounds(1)-leftPad,bounds(2)-.5*(viewHeight-bounds(4)),viewWidth,viewHeight];
            canvas.showSceneRectWithMargins(viewRect);

        end

        function deletePrevGraderBlks(obj,rm_graders,existing_graders,keepConnected)

            if sum(rm_graders)>0
                learning.simulink.allowGraderDelete(obj.modelName,{existing_graders{rm_graders}});
                if~keepConnected
                    grader_ports=get_param({existing_graders{rm_graders}},'PortHandles');
                    grader_ports=grader_ports(cellfun(@(x)~isempty(x.Inport),grader_ports));
                    existing_lines=cellfun(@(x)get_param(x.Inport,'Line'),grader_ports);
                    valid_lines=arrayfun(@(x)~eq(x,-1),existing_lines);
                    existing_lines=existing_lines(valid_lines);
                    line_points=get_param(existing_lines,'Points');
                    if iscell(line_points)
                        for idx=1:length(line_points)
                            line_points{idx}(end,1)=line_points{idx}(end,1)-20;
                            delete_line(existing_lines(idx));
                            add_line(obj.modelName,line_points{idx});
                        end
                    else
                        line_points(end,1)=line_points(end,1)-20;
                        delete_line(existing_lines)
                        add_line(obj.modelName,line_points);
                    end
                end
                delete_block({existing_graders{rm_graders}})
            end

        end

        function resetTasksAsUnsubmitted(obj)



            existing_graders=find_system(obj.modelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            for idx=1:numel(existing_graders)
                pass_status='-1';
                set_param(existing_graders{idx},'pass',pass_status);
                learning.simulink.updateGraderBadge(existing_graders{idx},str2double(pass_status));
            end
        end

        function stopModel(obj)
            if~strcmp(get_param(obj.modelName,'SimulationStatus'),'stopped')
                set_param(obj.modelName,'SimulationCommand','continue');
            end
        end


        function closeSignalAndScopeWindows(obj)



            blkHandles=find_system(obj.modelName,'RegExp','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock','signalChecks','task',num2str(obj.courseObject.task));
            if~isempty(blkHandles)
                cellfun(@(blockHandle)learning.simulink.StudioMgr.closeSignalWindowForBlock(blockHandle),blkHandles);
            end

        end

        function openStateflowChart(obj,currentTask)
            chartPath=[obj.modelName,'/Chart'];
            open_system(chartPath);
            model=learning.stateflow.ModelStructureBuilder.getModel(obj.modelName);
            chart=model.find('-isa','Stateflow.Chart','Name','Chart');
            if numel(chart)>1
                for i=1:length(chart)
                    if isequal(chart(i).Path,chartPath)
                        chart=chart(i);
                        break;
                    end
                end
            end
            if isequal(currentTask,1)
                chartId=sf('Private','block2chart','StateflowOnramp/Chart');
                studioTag=obj.editor.getStudio().getStudioTag();
                Stateflow.internal.SymbolManager.ShowSymbolManagerForStudio(...
                chartId,chartId,studioTag);
                chart.fitToView();
            end
        end

        function cleanUpWorkingModels(obj)
            modelFolder=fullfile(tempdir,'simulinkselfpaced');
            for i=1:length(obj.additionalModels)
                bdclose(obj.additionalModels{i});
                delete(fullfile(modelFolder,[obj.additionalModels{i},'.slx']));
            end
            workingModelPath=fullfile(modelFolder,obj.modelName);
            if exist(workingModelPath,'file')
                delete([workingModelPath,'.slx']);
            end
            if bdIsLoaded(obj.modelName)
                bdclose(obj.modelName);
            end
        end

        function cleanUpResetModels(obj)
            topLevelResetDir=fullfile(tempdir,'SimulinkTraining');
            courseName=learning.simulink.SimulinkAppInteractions.getCourseNameFromCode(obj.getCourse());
            folderContents=dir(fullfile(topLevelResetDir,courseName,obj.conceptSequence));
            isFolder=arrayfun(@(x)x.isdir,folderContents);
            folderContents(isFolder)=[];
            for i=1:length(folderContents)
                bdclose(folderContents(i).name);
                delete(fullfile(folderContents(i).folder,folderContents(i).name));
            end
        end
    end

    methods(Static,Access=private)
        function position=getTrainingStudioPosition(modelName)

            if bdIsLoaded(modelName)
                position=get_param(modelName,'Location');
            else
                ss=get(groot,'ScreenSize');
                position=[1,1,.9*ss(3),ss(4)-100];
            end

        end

        function runInitializationCode()
            if~isempty(learning.simulink.Application.getInstance().getInitCode)
                for idx=1:numel(learning.simulink.Application.getInstance().getInitCode)
                    evalin('base',learning.simulink.Application.getInstance().getInitCode{idx});
                end
            end
        end

        function closeSignalWindowForBlock(blockHandle)
            blockName=getfullname(blockHandle);

            fh=findobj(0,'type','Figure','tag',blockName);
            if~isempty(fh)
                close(fh);
            end
        end
    end
end
