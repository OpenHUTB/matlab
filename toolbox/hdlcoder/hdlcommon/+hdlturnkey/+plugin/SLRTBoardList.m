


classdef SLRTBoardList<hdlturnkey.plugin.BoardList


    properties(Access=protected)

        Workflow=hdlcoder.Workflow.SimulinkRealTimeFPGAIO;
    end

    methods

        function obj=SLRTBoardList()

            obj=obj@hdlturnkey.plugin.BoardList;


            obj.buildAvailablePlatformList;
        end

        function nameList=getBoardNameList(obj,~)
            nameList=getNameList(obj);
        end

        function isEmpty=isBoardListEmpty(obj)
            isEmpty=isListEmpty(obj);
        end

        function[isIn,hP]=isInBoardList(obj,boardName)


            [isIn,hP]=isInList(obj,boardName);
        end
    end

end



