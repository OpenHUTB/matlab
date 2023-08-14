


classdef TurnkeyBoardList<hdlturnkey.data.AvailableBoardList



    properties

        BuiltInDirPath=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+hdlturnkey','+board');
        BuiltInPackagePath='hdlturnkey.board';

        PluginDirName='hdlcustomboard';
        PluginFileName='plugin_board';
    end

    methods

        function obj=TurnkeyBoardList()



            obj.buildAvailableBoardList;

        end

        function buildAvailableBoardList(obj)



            searchPluginDirList(obj);

            buildBoardPluginList(obj);

            buildCustomBoardList(obj);

        end

        function buildCustomBoardList(obj)

            obj.CustomObjList=containers.Map;
            r=which('eda.internal.boardmanager.BoardManager');
            if~isempty(r)
                hManager=eda.internal.boardmanager.BoardManager.getInstance;

                tkBoardNames=hManager.getTurnkeyBoardNames;
                for m=1:length(tkBoardNames)
                    obj.CustomObjList(tkBoardNames{m})=...
                    hManager.getTurnkeyBoardObj(tkBoardNames{m});
                end
            end
        end

    end

end


