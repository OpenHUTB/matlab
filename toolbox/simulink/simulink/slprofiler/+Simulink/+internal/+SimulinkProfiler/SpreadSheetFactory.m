classdef SpreadSheetFactory<Simulink.internal.SimulinkProfiler.SpreadSheetFactoryInterface
    methods
        function spreadsheetComponent=create(~,studio,name)
            spreadsheetComponent=...
            GLUE2.SpreadSheetComponent(studio,name,true);
        end
    end
end