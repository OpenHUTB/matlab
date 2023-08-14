classdef Interaction<handle





    properties
interactionContent
currentTaskObj
initializationCode
interactionAssessments
    end

    properties(Access=protected)
        sequencePath=[];
    end

    methods(Access=public)
        function obj=Interaction(courseCode,dataSrc)





            [conceptSequence,interactionFile]=obj.validateData(dataSrc);
            modelName=learning.simulink.SimulinkAppInteractions.getModelNameFromCourseCode(courseCode);

            contentsRoot=learning.simulink.SimulinkAppInteractions.getContentPath;
            obj.sequencePath=fullfile(contentsRoot,conceptSequence);
            addpath(obj.sequencePath);


            interactionFilePath=fullfile(contentsRoot,conceptSequence,interactionFile);
            obj.interactionContent=learning.simulink.internal.readInteractionFile(interactionFilePath);
            interactionAssessmentFile=obj.getAssessmentFile(interactionFilePath);
            obj.interactionAssessments=obj.getInteractionAssessmentsFromFile(interactionAssessmentFile);

            if isempty(obj.interactionContent.simulinkInteraction.questions)

                currentTask=0;
                obj.initializationCode=obj.interactionContent.simulinkInteraction.initializationCode;
                courseObject=learning.simulink.Interaction.createCourseObject(courseCode,...
                conceptSequence,interactionFile,currentTask);


                taskQuestion=[];
                obj.currentTaskObj=learning.simulink.Task(taskQuestion,courseObject,modelName,conceptSequence);
                return
            end


            currentTask=1;

            obj.initializationCode=obj.interactionContent.simulinkInteraction.initializationCode;

            courseObject=learning.simulink.Interaction.createCourseObject(courseCode,...
            conceptSequence,interactionFile,currentTask);
            obj.currentTaskObj=learning.simulink.Task(obj.interactionContent.simulinkInteraction.questions(courseObject.task),...
            courseObject,modelName,conceptSequence);
        end

        function delete(obj)
            if~isempty(obj.sequencePath)
                rmpath(obj.sequencePath);
                obj.sequencePath=[];
            end
        end

        function newTaskObj=setToTaskN(obj,taskNumber)
            newCourseObj=obj.currentTaskObj.getCourseObject;
            newCourseObj.task=taskNumber;
            newTaskObj=learning.simulink.Task(obj.interactionContent.simulinkInteraction.questions(newCourseObj.task),newCourseObj,...
            learning.simulink.Application.getInstance().getModelName,obj.currentTaskObj.getConceptSequence);
            obj.currentTaskObj=newTaskObj;
        end

        function interactionContent=getInteractionContent(obj)
            interactionContent=obj.interactionContent;
        end

        function interactionAssessments=getInteractionAssessmentsFromFile(obj,interactionAssessmentFile)
            if exist(interactionAssessmentFile,'file')
                interactionAssessment=jsondecode(fileread(interactionAssessmentFile));
            end
            numOfTasks=length(obj.interactionContent.simulinkInteraction.questions);
            interactionAssessments=cell(0,numOfTasks);
            for i=1:numOfTasks



                currentQuestion=obj.interactionContent.simulinkInteraction.questions(i);

                switch currentQuestion.assessmentType
                case{'mlsignal','mlmodel','signal','sfmodel'}
                    hasGenericAssessments=isfield(currentQuestion,'hasGenericAssessments')&&...
                    currentQuestion.hasGenericAssessments;
                    if hasGenericAssessments
                        generalAssessments=obj.getGeneralAssessments(interactionAssessment.task(i).assessment);
                        assert(isempty(learning.assess.checkAssessmentsForPlots(generalAssessments)),'Cannot have a block signal assessment and generic assessment with plot in the same task');
                        blockAssessment=struct(...
                        "graderType",currentQuestion.assessmentType,...
                        "grader",currentQuestion.tasksToKeep,...
                        "graderParams",currentQuestion.maskParameters);
                        allAssessments=cell(1,length(generalAssessments)+1);
                        allAssessments{1}=blockAssessment;
                        allAssessments(2:end)=generalAssessments;
                        interactionAssessments{i}=allAssessments;
                    else
                        interactionAssessments{i}=struct(...
                        "graderType",currentQuestion.assessmentType,...
                        "grader",currentQuestion.tasksToKeep,...
                        "graderParams",currentQuestion.maskParameters);
                    end
                case 'quiz'
                    interactionAssessments{i}=struct("graderType",currentQuestion.assessmentType);
                case 'general'
                    interactionAssessments{i}=obj.getGeneralAssessments(interactionAssessment.task(i).assessment);
                otherwise
                    error('Not a valid assessment type');
                end
            end
        end

        function interactionAssessments=getInteractionAssessments(obj)
            interactionAssessments=obj.interactionAssessments;
        end
    end

    methods(Access=private)
        function taskAssessments=getGeneralAssessments(obj,assessments)


            numOfAssessments=length(assessments);
            taskAssessments=cell(1,numOfAssessments);
            for j=1:numOfAssessments
                assessmentName=['Student',assessments(j).type];
                assessmentProps=assessments(j).props;
                if isfield(assessmentProps,'SolutionFile')
                    assessmentProps.SolutionFile=fullfile(obj.sequencePath,assessmentProps.SolutionFile);
                end
                if isfield(assessmentProps,'ReferenceSignalFile')
                    assessmentProps.ReferenceSignalFile=fullfile(obj.sequencePath,assessmentProps.ReferenceSignalFile);
                end
                taskAssessments{j}=learning.assess.assessments.student.(assessmentName)(assessmentProps);
            end
        end
    end

    methods(Static,Access=private)

        function[conceptSequence,interactionFile]=validateData(dataSrc)


            srcParts=strsplit(dataSrc,'/');
            if isempty(regexp(srcParts{end},'interaction.*[.]json','ONCE'))
                error(message('learning:simulink:resources:ErrorInvalidInteraction'));
            else
                conceptSequence=strjoin(srcParts(1:end-1),'/');
                interactionFile=srcParts{end};
            end
        end

        function courseObject=createCourseObject(courseCode,conceptSequence,interactionFile,currentTask)



            section=learning.simulink.SimulinkAppInteractions.interactionToSection(courseCode,...
            conceptSequence,interactionFile);
            [chapter_idx,concept_idx]=...
            learning.simulink.SimulinkAppInteractions.indicesFromConceptSequence(courseCode,conceptSequence);
            courseObject=struct('course',courseCode,'chapter',chapter_idx,...
            'lesson',concept_idx,'section',section,'task',currentTask);
        end

        function assessmentFilePath=getAssessmentFile(interactionFilePath)



            [filePath,fileName,fileExt]=fileparts(interactionFilePath);
            assessmentFilePath=fullfile(filePath,[fileName,'Assessment',fileExt]);
        end
    end

end
