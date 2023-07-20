

classdef ModelStateflowCheck<handle

    methods(Static)

        function maskInitFcn(~)
        end

        function openFcn()


        end

        function updatePassStatus(block)
            status=LearningApplication.gradeStateflowTask(block);

            if all(status==1)
                set_param(block,'pass','1');
            else
                set_param(block,'pass','0');
            end
        end

        function[status,requirements]=getRequirements(block)
            [status,requirements]=LearningApplication.gradeStateflowTask(block);

            userData=str2double(get_param(block,'pass'));
            if userData==-1
                status=double(status);
                status(:)=-1;
            end
        end

    end

end
