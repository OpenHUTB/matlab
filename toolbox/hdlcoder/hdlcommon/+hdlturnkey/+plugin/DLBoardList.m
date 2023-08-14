


classdef DLBoardList<hdlturnkey.plugin.BoardList


    properties(Access=protected)

        Workflow=hdlcoder.Workflow.DeepLearningProcessor;
    end

    methods

        function obj=DLBoardList()

            obj=obj@hdlturnkey.plugin.BoardList;


            obj.buildAvailablePlatformList;
        end

    end

end


