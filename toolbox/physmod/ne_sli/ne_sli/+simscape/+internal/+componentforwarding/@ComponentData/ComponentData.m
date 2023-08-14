classdef ComponentData







    properties(SetAccess=private)
Class
VariableData
ParameterData
    end
    methods
        function obj=ComponentData(class,version)

            obj.Class=class;
            [obj.VariableData,obj.ParameterData]=...
            getComponentData(class,version);

        end

        function cd=applySettings(cd,componentSettings)
            for idx=1:numel(cd.VariableData)
                id=cd.VariableData(idx).id;
                value=componentSettings.getValue(id);
                if~isempty(value)
                    cd.VariableData(idx).value=value;
                end
                unit=componentSettings.getUnit(id);
                if~isempty(unit)
                    cd.VariableData(idx).unit=unit;
                end
                priority=componentSettings.getPriority(id);
                if~isempty(priority)
                    cd.VariableData(idx).priority=priority;
                end
                specify=componentSettings.getSpecify(id);
                if~isempty(specify)
                    cd.VariableData(idx).specify=specify;
                end
            end
            for idx=1:numel(cd.ParameterData)
                id=cd.ParameterData(idx).id;
                value=componentSettings.getValue(id);
                if~isempty(value)
                    cd.ParameterData(idx).value=value;
                end
                unit=componentSettings.getUnit(id);
                if~isempty(unit)
                    cd.ParameterData(idx).unit=unit;
                end
                rtconfig=componentSettings.getRTConfig(id);
                if~isempty(rtconfig)
                    cd.ParameterData(idx).rtconfig=rtconfig;
                end
            end
        end

        function vars=getVariables(obj)
            vars=obj.VariableData;
        end

        function vars=getParameters(obj)
            vars=obj.ParameterData;
        end

        function class=getClass(obj)
            class=obj.Class;
        end
    end
end
