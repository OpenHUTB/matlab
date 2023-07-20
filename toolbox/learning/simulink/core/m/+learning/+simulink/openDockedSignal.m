

function graderType_code=openDockedSignal(block)

    isGrader=contains(get_param(block,'ReferenceBlock'),'signalCheck');
    [~,editor]=learning.simulink.getTrainingModelProperties;

    checkQuery=containers.Map({'signal','mlmodel','mlsignal','sfmodel','noTasks','general','quiz'},...
    {'signal','ml','mlsignal','sf','noTasks','general','quiz'});

    if isGrader
        graderType=SignalCheckUtils.getGraderType(block);





        switch graderType
        case 'mlmodel'
            [status,messages]=ModelMATLABCheck.getRequirements(block);
            learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'soln-noimg',messages,status);
        case 'sfmodel'
            [status,messages]=ModelStateflowCheck.getRequirements(block);
            learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'soln-noimg',messages,status);
        case 'mlsignal'
            [status,messages]=SignalMATLABCheck.getRequirements(block);
            learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'soln',messages,status);
        otherwise
            taskNum=LearningApplication.getCurrentTask();
            interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
            currentAssessments=interactionAssessments{taskNum};
            if isstruct(currentAssessments)
                learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'soln');
            else
                numOfAssessBlocks=1;
                generalAssessments=currentAssessments(numOfAssessBlocks+1:end);
                generalMessages=learning.assess.getAssessmentRequirements(generalAssessments);
                assessBlockMessage={message('learning:simulink:resources:AssessmentPaneSignalRequirement').getString()};
                messages=[assessBlockMessage,generalMessages];
                status=-ones(1,length(currentAssessments));
                learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'soln',messages,status);
            end
        end


        currentCourse=LearningApplication.getCurrentCourse();
        if isequal(currentCourse,'stateflow')


            studio=editor.getStudio();
            symManager=Stateflow.internal.SymbolManager.GetSymbolManagerForStudio(studio.getStudioTag());
            if~isempty(currentCourse)&&~isequal(symManager,0)&&symManager.isPanelVisible
                learning.stateflow.moveSymbolsPaneDown();
            end
        end
    else


        interactionContent=learning.simulink.Application.getInstance().getInteractionContent();
        taskNum=LearningApplication.getCurrentTask();
        graderType=getGraderTypeFromQuestions(interactionContent.simulinkInteraction.questions,taskNum);
        switch graderType
        case 'noTasks'
            learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,block,'optional')
        case 'quiz'
            learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,'','quiz');
        case 'general'
            interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
            currentAssessments=interactionAssessments{taskNum};
            messages=learning.assess.getAssessmentRequirements(currentAssessments);
            status=-ones(1,length(messages));
            assessmentWithPlot=learning.assess.checkAssessmentsForPlots(currentAssessments);
            if~isempty(assessmentWithPlot)


                selectedBlock=[];
                showFigureWindow=false;
                assessmentWithPlot.writePlotFigure(selectedBlock,showFigureWindow);
                learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,'','soln',messages,status);
            else
                learning.simulink.slAcademy.slFeedbackHandler.createDocked(editor,'','soln-noimg',messages,status);
            end
        end
    end

    graderType_code=checkQuery(graderType);
end

function graderType=getGraderTypeFromQuestions(questions,currentTask)
    if isempty(questions)
        graderType='noTasks';
    elseif isequal(questions(currentTask).assessmentType,'quiz')
        graderType='quiz';
    else
        graderType='general';
    end
end