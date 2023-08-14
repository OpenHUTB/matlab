classdef RoadRunnerDataTableReader





    methods(Static)
        function callbackForTableType()
            maskObj=Simulink.Mask.get(gcb);
            blockParam=get_param(gcb,'BusType');
            maskParam=maskObj.getParameter('TableType').Value;
            if~strcmp(blockParam,maskParam)
                set_param(gcb,'BusType',maskParam);
                set_param(gcb,'TableName',...
                [ssm.maskcallbacks.RoadRunnerDataTable.tableNamePrefix,maskParam]);
            end
        end

        function callbackForQuery()
            set_param(gcb,'QueryString',get_param(gcb,'Query'));
        end
    end
end