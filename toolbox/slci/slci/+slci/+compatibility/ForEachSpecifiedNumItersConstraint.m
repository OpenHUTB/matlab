


classdef ForEachSpecifiedNumItersConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='For Each subsystem must not specify the number of iterations';
        end


        function obj=ForEachSpecifiedNumItersConstraint()
            obj.setEnum('ForEachSpecifiedNumIters');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            blk=aObj.ParentBlock();
            assert(isa(blk,'slci.simulink.ForEachBlock'));

            isSupported=aObj.isNumItersSpecified();

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end

    methods(Access=private)

        function isSupported=isNumItersSpecified(aObj)
            isSupported=false;

            blk=aObj.ParentBlock();
            try
                value=slResolve(get_param(blk.getHandle,'SpecifiedNumIters'),blk.getSID);
            catch
                return;
            end

            if isnumeric(value)
                isSupported=value<0;
            end
        end
    end
end
