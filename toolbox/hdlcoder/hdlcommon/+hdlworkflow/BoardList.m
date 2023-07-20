



classdef BoardList<hdlturnkey.plugin.BoardList


    properties(Access=protected)


        Workflow='';
    end

    methods

        function obj=BoardList(workflowName)

            obj=obj@hdlturnkey.plugin.BoardList;
            obj.Workflow=workflowName;


            obj.buildAvailablePlatformList;
        end

    end

end


