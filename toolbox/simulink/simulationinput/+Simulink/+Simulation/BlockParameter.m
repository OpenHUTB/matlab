



















classdef BlockParameter
    properties(SetAccess=private,GetAccess=public)
BlockPath
Name
    end

    properties(SetAccess=public,GetAccess=public)
Value
    end

    properties(Constant,Access=private)
        BlockParameterHelper=getSimulationInputBlockParameterHelper()
    end

    methods
        function obj=BlockParameter(path,name,value)
            if~isvarname(name)
                throw(MException(message('Simulink:Commands:ParamUnknown',path,name)));
            end
            obj.BlockPath=path;
            obj.Name=name;
            obj.Value=value;

            obj.BlockParameterHelper.validateSettableParam(path,name);
        end

        function validate(obj)


            obj.BlockParameterHelper.validateParam(obj.BlockPath,obj.Name);
        end

        function T=table(obj)
            T=table;
            for i=1:numel(obj)
                blockPath=obj(i).BlockPath;
                if matlab.internal.display.isHot
                    blockWithLink=sprintf('<a href="matlab:MultiSim.internal.openAndHiliteSystem(''%s'')">%s</a>',blockPath,blockPath);
                else
                    blockWithLink=blockPath;
                end
                value=Simulink.Simulation.internal.varValue2str(obj(i).Value);
                T=[T;{i,obj(i).Name,blockWithLink,value}];
            end
            T.Properties.VariableNames=["Index","Name","BlockPath","Value"];


            T.Name=categorical(T.Name);
            T.BlockPath=categorical(T.BlockPath);
            T.Value=categorical(T.Value);
        end
    end
end

