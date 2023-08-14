



classdef BlockMultirateConstraint<slci.compatibility.Constraint

    methods

        function obj=BlockMultirateConstraint()
            obj.setEnum('BlockMultirate');
            obj.setFatal(false);
            obj.setCompileNeeded(true);
        end


        function out=getDescription(aObj)%#ok
            out='Block should not have multiple compiled sample times.';
        end


        function out=check(aObj)
            out=[];
            compiledSampleTime=...
            aObj.ParentBlock.getParam('CompiledSampleTime');
            isMultirate=slci.internal.isMultipleSampleTimes(compiledSampleTime);

            if isMultirate
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end
end