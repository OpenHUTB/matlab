



classdef RefModelMultirateConstraint<slci.compatibility.Constraint

    methods

        function obj=RefModelMultirateConstraint()
            obj.setEnum('RefModelMultirate');
            obj.setFatal(false);
            obj.setCompileNeeded(true);
        end


        function out=getDescription(aObj)%#ok
            out=['A referenced model should not have multiple '...
            ,'compiled sample times.'];
        end


        function out=check(aObj)
            out=[];
            if aObj.ParentModel().getCheckAsRefModel()
                mdl_handle=get_param(aObj.ParentModel().getSID(),'Handle');
                compiledSampleTime=...
                slci.internal.getModelSampleTimes(mdl_handle);
                isMultirate=slci.internal.isMultipleSampleTimes(...
                compiledSampleTime);

                if isMultirate
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentModel().getName());
                end
            end
        end

    end
end