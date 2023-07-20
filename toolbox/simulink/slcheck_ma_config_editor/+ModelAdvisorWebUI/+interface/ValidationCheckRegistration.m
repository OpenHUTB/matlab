classdef ValidationCheckRegistration<handle


    properties
        completecuiCellArray;
        completeFileName;
    end

    methods
        function newObj=ValidationCheckRegistration()
            newObj.completecuiCellArray=[];
            newObj.completeFileName=[];
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)||~isvalid(uniqueInstance)
                obj=ModelAdvisorWebUI.interface.ValidationCheckRegistration();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end


    methods

        function reset(obj)
            obj.completecuiCellArray=[];
            obj.completeFileName=[];
        end
        function registerChecks(obj,val)
            obj.completecuiCellArray=val;
        end

        function registerFileName(obj,val)
            obj.completeFileName=val;
        end

        function filename=getCompleteFileName(obj)
            filename=obj.completeFileName;
        end

        function data=getCompletecuiCellArray(obj)
            data=obj.completecuiCellArray;
        end

    end
end
