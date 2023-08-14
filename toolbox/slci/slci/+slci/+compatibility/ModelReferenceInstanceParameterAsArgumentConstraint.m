





classdef ModelReferenceInstanceParameterAsArgumentConstraint<slci.compatibility.Constraint

    methods

        function obj=ModelReferenceInstanceParameterAsArgumentConstraint()
            obj.setEnum('ModelReferenceInstanceParameterAsArgument');
            obj.setFatal(false);
            obj.setCompileNeeded(false);
        end


        function out=getDescription(aObj)%#ok
            out=['A referenced model should not use any instance '...
            ,'parameter as argument of its parent model.'];
        end


        function out=check(aObj)
            out=[];
            aBlk=aObj.ParentBlock;
            assert(isa(aBlk,'slci.simulink.ModelReferenceBlock'));
            ips=aBlk.getParam('InstanceParameters');
            for i=1:numel(ips)
                if ips(i).Argument
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum);
                    return;
                end
            end
        end

    end
end