


classdef IPBoardList<hdlturnkey.plugin.BoardList


    properties(Access=protected)

        Workflow=hdlcoder.Workflow.IPCoreGeneration;
    end

    methods

        function obj=IPBoardList()

            obj=obj@hdlturnkey.plugin.BoardList;


            obj.isDefaultWorkflow=true;


            obj.buildAvailablePlatformList;
        end

    end

end
