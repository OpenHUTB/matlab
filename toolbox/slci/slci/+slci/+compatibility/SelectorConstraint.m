


classdef SelectorConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='A selector block must not use port-based indexing';
        end

        function obj=SelectorConstraint()
            obj.setEnum('Selector');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            numInports=numel(compiledPortDataTypes.Inport);
            if(numInports>1)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SelectorNonDialog',...
                aObj.ParentBlock().getName());
            end
        end

    end
end
