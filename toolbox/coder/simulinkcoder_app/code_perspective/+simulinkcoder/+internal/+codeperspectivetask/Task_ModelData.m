classdef Task_ModelData<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='ModelData'
    end

    methods
        function result=turnOn(~,~,~)
            result=true;
        end

        function turnOff(~,~)
        end

        function bool=isAutoOn(~,input)


            bool=false;
        end

        function reset(~,~)


        end
    end
end

