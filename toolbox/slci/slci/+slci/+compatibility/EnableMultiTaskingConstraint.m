

classdef EnableMultiTaskingConstraint<slci.compatibility.Constraint





    methods

        function obj=EnableMultiTaskingConstraint()
            obj.setEnum('EnableMultiTasking');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=getDescription(aObj)%#ok
            out=DAStudio.message('Slci:compatibility:EnableMultiTasking');
        end


        function out=check(aObj)
            out=[];
            modelSampleTime=...
            slci.internal.getModelSampleTimes(...
            aObj.ParentModel().getHandle());

            isMultirate=slci.internal.isMultipleSampleTimes(...
            modelSampleTime);

            if isMultirate
                isMultiTasking=...
                strcmpi(aObj.ParentModel().getParam('EnableMultiTasking'),'on');
                if~isMultiTasking

                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'EnableMultiTasking');
                end
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            SubTitle=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintInfo');
            if status
                RecAction=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintRecAction',aObj.ParentModel.getName);
                StatusText=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintPass');
            else
                RecAction=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintRecAction',aObj.ParentModel.getName);
                StatusText=DAStudio.message('Slci:compatibility:EnableMultiTaskingConstraintWarn',aObj.ParentModel.getName);
            end
        end
    end
end