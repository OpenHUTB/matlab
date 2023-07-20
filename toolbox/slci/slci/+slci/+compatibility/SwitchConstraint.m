


classdef SwitchConstraint<slci.compatibility.Constraint

    methods

        function obj=SwitchConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('Switch');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)
            out='For a switch, 1) the first and third inport, and the outport should all be of the same data type';
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(compiledPortDataTypes.Inport{1},...
                compiledPortDataTypes.Inport{3})
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SwitchNonUniformPortDataTypes',...
                aObj.ParentBlock().getName());
                return;
            end

            if~strcmpi(compiledPortDataTypes.Inport{1},...
                compiledPortDataTypes.Outport{1});
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SwitchNonUniformPortDataTypes',...
                aObj.ParentBlock().getName());
            end

        end

    end
end
