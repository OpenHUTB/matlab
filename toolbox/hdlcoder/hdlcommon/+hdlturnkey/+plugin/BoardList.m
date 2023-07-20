



classdef(Abstract)BoardList<hdlturnkey.plugin.PluginListBase


    properties(Abstract,Access=protected)

        Workflow;
    end

    properties(Access=protected)








        CustomizationFileName='hdlcoder_board_customization';


        PluginPathList=containers.Map();






        isDefaultWorkflow=false;
    end

    methods

        function obj=BoardList()

        end

        function buildAvailablePlatformList(obj)



            obj.PluginObjList=containers.Map;


            obj.buildBoardPluginList;

        end

    end

    methods(Access=protected)

        function buildBoardPluginList(obj)


            plugins=obj.searchBoardCustomizationFile;
            if isempty(plugins)
                return;
            end


            for ii=1:length(plugins)
                plugin=plugins{ii};


                try

                    hP=eval(plugin);


                    if~hP.isSupported
                        continue;
                    end


                    hP.validateBoard;

                catch ME

                    obj.reportInvalidPlugin(plugin,ME.message);
                    continue;
                end


                [packName,packFullPath]=obj.getPackageName(plugin);


                hP.PluginFileName=plugin;
                hP.PluginPath=packFullPath;
                hP.PluginPackage=packName;


                pluginName=hP.BoardName;
                obj.insertPluginObject(pluginName,hP);

            end

        end

        function plugins=searchBoardCustomizationFile(obj)

            plugins={};
            obj.PluginPathList=containers.Map();


            customFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(customFiles)
                customFile=customFiles{ii};
                [customfolder,customname,~]=fileparts(customFile);
                cd(customfolder);







                boardList={};
                if nargout(customname)==1
                    if obj.isDefaultWorkflow
                        boardList=eval(customname);
                    end
                    cd(currentFolder);
                elseif nargout(customname)==2
                    cd(customfolder);
                    [boardList,workflow]=eval(customname);
                    cd(currentFolder);


                    if~isa(workflow,'hdlcoder.Workflow')&&...
                        ~ischar(workflow)
                        error(message('hdlcommon:plugin:OutputEnumBoardRegistrationFile',customFile));
                    end


                    if~isequal(workflow,obj.Workflow)
                        continue;
                    end
                else
                    cd(currentFolder);

                    error(message('hdlcommon:plugin:InvalidOutputBoardRegistrationFile',...
                    customFile));
                end


                cellListMsg=message('hdlcommon:plugin:CellListBoardRegistrationFile',customFile);
                hdlturnkey.plugin.validateCellList(boardList,cellListMsg);


                for jj=1:length(boardList)
                    a_plugin=boardList{jj};
                    if~obj.PluginPathList.isKey(a_plugin)
                        obj.PluginPathList(a_plugin)=customFile;
                        plugins{end+1}=a_plugin;%#ok<AGROW>
                    else
                        error(message('hdlcommon:workflow:DuplicatePluginPath',a_plugin,obj.PluginPathList(a_plugin),customFile));
                    end
                end
            end
        end
    end
end


