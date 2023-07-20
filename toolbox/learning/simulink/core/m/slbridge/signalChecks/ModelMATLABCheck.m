classdef ModelMATLABCheck<handle


    methods(Static)

        function maskInitFcn(~)
        end

        function openFcn()


        end

        function updatePassStatus(block)
            status=ModelMATLABCheck.assessSignal(block);

            if all(status==1)
                set_param(block,'pass','1');
            else
                set_param(block,'pass','0');
            end
        end

        function[status,requirements]=getRequirements(block)
            evalFunc=get_param(block,'mlfunc');
            evalFunc=evalFunc(2:end-1);

            [status,requirements]=feval(evalFunc,block);

            userData=str2double(get_param(block,'pass'));
            if userData==-1
                status=double(status);
                status(:)=-1;
            end
        end

    end

    methods(Static,Access=private)

        function[status,requirements]=assessSignal(block)
            evalFunc=get_param(block,'mlfunc');
            evalFunc=evalFunc(2:end-1);
            try
                [status,requirements]=feval(evalFunc,block);
            catch
                status=0;
                requirements={message('learning:simulink:resources:ModelMATLABCheckError').getString()};
                sldiagviewer.reportError(requirements{1});
            end
        end

    end

end
