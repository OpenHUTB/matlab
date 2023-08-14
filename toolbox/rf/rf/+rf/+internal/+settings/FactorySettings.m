classdef FactorySettings<matlab.settings.internal.FactorySettingsDefinition




    methods(Static)
        function createTree(rf)

            PlotAxis=rf.addGroup("PlotAxis");
            PlotAxis.addSetting("UseEngUnits",...
            "FactoryValue",true,...
            "ValidationFcn",@matlab.settings.mustBeLogicalScalar);

            rf.addSetting("Decaf","FactoryValue",false,...
            "ValidationFcn",@matlab.settings.mustBeLogicalScalar);
        end

        function upgraders=createUpgraders()


            upgraders=matlab.settings.SettingsFileUpgrader("v1");
        end
    end
end
