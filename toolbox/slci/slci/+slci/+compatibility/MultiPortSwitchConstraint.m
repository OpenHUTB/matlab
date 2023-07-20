


classdef MultiPortSwitchConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='For a multi port switch, the data inports and outports must be of a uniform data type';
        end

        function obj=MultiPortSwitchConstraint()
            obj.setEnum('MultiPortSwitch');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');


            for i=3:numel(compiledPortDataTypes.Inport)
                if~strcmpi(compiledPortDataTypes.Inport{2},...
                    compiledPortDataTypes.Inport{i});
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'MultiPortSwitchNonUniformPortDataTypes',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end




            if~strcmpi(compiledPortDataTypes.Inport{2},...
                compiledPortDataTypes.Outport{1});
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MultiPortSwitchNonUniformPortDataTypes',...
                aObj.ParentBlock().getName());
                return;
            end

        end

    end
end
