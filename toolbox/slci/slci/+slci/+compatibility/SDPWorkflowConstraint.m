





classdef SDPWorkflowConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'IsSDPWorkflow',aObj.ParentModel().getName());
        end

    end

    methods

        function obj=SDPWorkflowConstraint(varargin)
            obj.setEnum('SDPWorkflow');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end


        function out=check(aObj)
            out=[];



            platformType=coder.dictionary.internal.getPlatformType(...
            aObj.ParentModel().getName());
            if strcmpi(platformType,'FunctionPlatform')
                out=aObj.getIncompatibility();
            end
        end


        function out=getDescription(aObj)%#ok
            out='SLCI does not support models using service interface';
        end
    end
end