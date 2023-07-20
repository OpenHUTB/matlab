

classdef LearningApplication<handle



    methods(Static,Access=public)


        function setupSimulinkStudio(courseCode,dataSrc)
            learning.simulink.Application.getInstance().setupSimulinkStudio(courseCode,dataSrc);
        end

        function setupTask(taskNumber)
            learning.simulink.Application.getInstance().setupTask(taskNumber);
        end

        function updateAssessmentPane
            learning.simulink.Application.getInstance().updateAssessmentPane;
        end

        function sclOpenTask=getSclOpenTask
            sclOpenTask=learning.simulink.Application.getInstance().getSclOpenTask;
        end

        function setSclOpenTask(openTask)
            learning.simulink.Application.getInstance().setSclOpenTask(openTask);
        end

        function modelName=getModelName
            modelName=learning.simulink.Application.getInstance().getModelName;
        end

        function[pass,grader]=submitTask
            [pass,grader]=learning.simulink.Application.getInstance().submitTask;
        end

        function nTasks=getNumberOfTasks
            nTasks=learning.simulink.Application.getInstance().getNumberOfTasks;
        end

        function currentTask=getCurrentTask
            currentTask=learning.simulink.Application.getInstance().getCurrentTask;
        end

        function resetTask
            learning.simulink.Application.getInstance().resetTask;
        end

        function exitInteraction
            learning.simulink.Application.getInstance().exitInteraction;
        end

        function[pass,requirements]=gradeStateflowTask(block)
            [pass,requirements]=learning.simulink.Application.getInstance().gradeStateflowTask(block);
        end

        function currentCourse=getCurrentCourse()
            currentCourse=learning.simulink.Application.getInstance().getCurrentCourse();
        end

        function isInStateflowOnrampCourse=isInStateflowOnrampCourse()
            isInStateflowOnrampCourse=isequal(LearningApplication.getCurrentCourse,'stateflow');
        end
    end

    methods(Access=private)


        function obj=LearningApplication()
            obj=[];
        end
    end
end
