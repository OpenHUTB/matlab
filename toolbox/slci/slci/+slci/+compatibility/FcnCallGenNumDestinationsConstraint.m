


classdef FcnCallGenNumDestinationsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='For a function call generator, the number of destinations must be 1';
        end

        function obj=FcnCallGenNumDestinationsConstraint()
            obj.setEnum('FcnCallGenNumDestinations');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            numOutports=numel(portHandles.Outport);
            if numOutports>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'FcnCallGenNumDestinations');
            end
        end

    end
end
