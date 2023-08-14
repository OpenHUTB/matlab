


classdef AvailableSimulationToolList<downstream.plugin.AvailablePluginList



    properties

        TheAvailableToolList=[];


        CustomToolPath='';
    end

    properties(Access=protected,Hidden=true)

        hD=0;
    end

    methods

        function obj=AvailableSimulationToolList

            obj=obj@downstream.plugin.AvailablePluginList;


            obj.buildAvailableToolList;

        end

        function buildAvailableToolList(obj)






            obj.TheAvailableToolList=[];




            supportedTool=obj.getSupportedPluginList;



            obj.collectSupportedPlugins(supportedTool);


            obj.getAvailableToolPlugin;

        end

        function nameList=getToolNameList(obj)

            if~obj.isToolListEmpty
                toolList=obj.TheAvailableToolList;
                nameList={toolList.ToolName};
            else
                nameList={};
            end
        end

        function isEmpty=isToolListEmpty(obj)

            isEmpty=isempty(obj.TheAvailableToolList);
        end

        function[isIn,hTool]=isInToolList(obj,toolName)


            toolList=obj.TheAvailableToolList;
            isIn=false;
            hTool=[];
            for ii=1:length(toolList)
                t=toolList(ii);
                if strcmpi(toolName,t.ToolName)
                    isIn=true;
                    hTool=t;
                    return;
                end
            end
        end

        function addToToolList(obj,hTool)

            if obj.isToolListEmpty
                obj.TheAvailableToolList=hTool;
            else
                obj.TheAvailableToolList(end+1)=hTool;
            end
        end

        function removeFromToolList(obj,hTool)

            idx=obj.TheAvailableToolList~=hTool;
            obj.TheAvailableToolList=obj.TheAvailableToolList(idx);
        end

        function hstr=printToolList(obj)

            hstr='';
            toolList=obj.TheAvailableToolList;
            for ii=1:length(toolList)
                s=toolList(ii);
                hstr=sprintf('%s  %s\n',hstr,s.ToolName);
            end
        end

    end

    methods(Access=protected)

        function collectSupportedPlugins(obj,supportedTool)

            for ii=1:length(supportedTool)


                s=supportedTool(ii);
                try
                    hP=downstream.plugin.PluginBase.loadPluginFile(s.pluginPackage,'plugin_tool');
                catch %#ok<CTCH>

                    continue;
                end
                hP.PluginPath=s.pluginPath;
                hP.PluginPackage=s.pluginPackage;


                if~hP.publishTool
                    continue;
                end




                isInList=obj.isInToolList(hP.ToolName);
                if~isInList
                    obj.addToToolList(hP);
                end

            end

        end

        function getAvailableToolPlugin(obj)









            removeList={};
            for ii=1:length(obj.TheAvailableToolList)
                hP=obj.TheAvailableToolList(ii);

                toolPath='';

                [isAvailable,toolPath]=obj.checkToolAvailability(toolPath,hP);
                if~isAvailable

                    removeList{end+1}=hP;%#ok<AGROW>
                else
                    hP.ToolPath=toolPath;
                end
            end

            for ii=1:length(removeList)
                hP=removeList{ii};
                obj.removeFromToolList(hP);
            end
        end

        function[isexist,userplugin]=existUserDefinedPlugin(obj)%#ok<MANU>











            isexist=false;
            userplugin=[];

            if evalin('base','exist(''hdlcoder_downstream_integration_plugin'', ''var'')');

                userplugin=evalin('base','hdlcoder_downstream_integration_plugin');

                if isfield(userplugin,'pluginPath')&&isfield(userplugin,'pluginPackage')
                    isexist=true;
                end
            end
        end

        function[isAvailable,toolPath]=checkToolAvailability(obj,toolPath,hP)


            isAvailable=true;

            if isempty(toolPath)

                [isexist,toolPath]=...
                downstream.AvailableToolList.simplewhich(hP.cmd_openTargetTool);
                if~isexist
                    isAvailable=false;
                    return;
                end

            else

                [isexist,~]=downstream.AvailableToolList.simplewhich(...
                fullfile(toolPath,hP.cmd_openTargetTool));
                if~isexist
                    isAvailable=false;
                    return;
                end
            end
        end

        function setupPluginDirList(obj)


            obj.PluginDirList={...
            fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+downstreamsimtools'),...
            };
            obj.PackagePathList={...
            'downstreamsimtools',...
            };
        end

    end

    methods(Static=true)

        function[isexist,path]=simplewhich(inFileName)







            isexist=false;
            path='';



            [filePath,~,fileExt]=fileparts(inFileName);
            if isempty(fileExt)&&ispc
                inFileName=[inFileName,'.exe'];
            end


            if~isempty(filePath)
                if exist(inFileName,'file');
                    isexist=true;
                    path=filePath;
                end
                return;
            end


            envPath=getenv('PATH');
            envPathSep=regexp(envPath,['\s*',pathsep,'\s*'],'split');


            for ii=1:length(envPathSep)
                aPath=envPathSep{ii};

                if exist(aPath,'dir')
                    searchStr=fullfile(aPath,inFileName);
                    if exist(searchStr,'file');
                        isexist=true;
                        path=aPath;
                        return;
                    end
                end
            end
        end

    end


end


