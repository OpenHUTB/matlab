




classdef AvailableToolList<downstream.plugin.AvailablePluginList&...
    hdlturnkey.plugin.PluginListBase



    properties

        TheAvailableToolList=[];


        CustomToolPath='';
    end

    properties(Access=protected,Hidden=true)

        hD=0;
    end

    properties(Access=protected)





        CustomizationFileName='hdlcoder_tool_registration';

    end

    methods

        function obj=AvailableToolList(hDriver)

            obj=obj@downstream.plugin.AvailablePluginList;

            obj.hD=hDriver;


            obj.buildAvailableToolList;

        end

        function supportedTool=buildDynamicToolList(obj)


            obj.clearDynamicToolList;



            supportedTool=obj.searchToolRegistrationFile;

        end

        function buildAvailableToolList(obj,userToolPath)





            if nargin<2
                userToolPath='';
            end


            obj.TheAvailableToolList=[];


            [existUserPlugin,userPlugin]=obj.existUserDefinedPlugin;
            if existUserPlugin

                supportedTool=userPlugin;
            else

                supportedTool=obj.getSupportedPluginList;
            end



            Dynamic_SupportedPluginToolList=obj.buildDynamicToolList;








            combinedSupportedToolList=[supportedTool,Dynamic_SupportedPluginToolList];


            obj.collectSupportedPlugins(combinedSupportedToolList);


            obj.getAvailableToolPlugin(userToolPath);

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
        function isToolVersionSupported=isToolVersionSupported(obj,toolName)
            isToolVersionSupported=true;
            if obj.isToolListEmpty||isempty(toolName)
                isToolVersionSupported=true;
            else
                for idx=1:length(obj.TheAvailableToolList)
                    availableTool=obj.TheAvailableToolList(idx);
                    if strcmp(toolName,availableTool.ToolName)
                        isToolVersionSupported=~availableTool.AvailablePlugin.UnSupportedVersion;
                    end
                end
            end

        end

    end

    methods(Access=protected)

        function supportedTool=searchToolRegistrationFile(obj)




            toolRegFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            supportedTool=[];
            for ii=1:length(toolRegFiles)
                toolRegFile=toolRegFiles{ii};
                [toolRegFileFolder,toolRegFileName,~]=fileparts(toolRegFile);

                try

                    cd(toolRegFileFolder);
                    toolList=eval(toolRegFileName);

                    for ll=1:length(toolList)
                        toolPluginPath=toolList{ll};
                        [packName,packFullPath,~]=obj.getPackageName(toolPluginPath);
                        t.pluginPath=packFullPath;
                        t.pluginPackage=packName;

                        if isempty(supportedTool)
                            supportedTool=t;
                        else
                            supportedTool(end+1)=t;%#ok<AGROW>
                        end


                        obj.addToolName(toolPluginPath);
                    end
                catch ME

                    obj.reportInvalidPlugin(toolRegFile,ME.message);
                    cd(currentFolder);
                    continue;

                end
                cd(currentFolder);
            end
        end

        function clearDynamicToolList(obj)
            obj.initList;
        end

        function addToolName(obj,toolPluginPath)

            hPlugin=eval(toolPluginPath);

            ToolName=hPlugin.ToolName;


            [isIn,hExistingWorkflow]=isInList(obj,ToolName);
            if isIn
                existingFilePath=hExistingWorkflow.getAbsolutePath;
                error(message('hdlcommon:workflow:DuplicateToolName',ToolName,existingFilePath));
            else
                obj.insertPluginObject(ToolName,hPlugin);
            end
        end

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



                if~isempty(obj.hD.tclOnlyTool)
                    if~strcmpi(hP.ToolName,obj.hD.tclOnlyTool)
                        continue;
                    end
                end



                [isInList,hA]=obj.isInToolList(hP.ToolName);
                if~isInList
                    hA=downstream.AvailableTool;
                    hA.ToolName=hP.ToolName;
                    obj.addToToolList(hA);
                end
                hA.PluginList{end+1}=hP;


                if hP.isSupported
                    hA.SupportedVersionList{end+1}=hP.ToolVersion;
                end
            end

        end

        function getAvailableToolPlugin(obj,userToolPath)









            if~isempty(userToolPath)
                isAvailable=false;
                for ii=1:length(obj.TheAvailableToolList)
                    hA=obj.TheAvailableToolList(ii);
                    hP=hA.PluginList{end};
                    isAvailable=obj.checkToolAvailability(userToolPath,hP);
                    if isAvailable

                        hA.AvailableToolPath=userToolPath;

                        isValid=hA.checkToolVersion(obj.hD.tclOnly);
                        if isValid
                            break;
                        else
                            isAvailable=false;
                        end
                    end
                end

                if~isAvailable
                    error(message('hdlcommon:workflow:InvalidSynthToolPath',userToolPath));
                end
            end


            for ii=1:length(obj.TheAvailableToolList)
                hA=obj.TheAvailableToolList(ii);


                if~isempty(hA.AvailablePlugin)
                    continue;
                end

                hP=hA.PluginList{end};
                toolPath='';

                [isAvailable,toolPath]=obj.checkToolAvailability(toolPath,hP);
                if isAvailable

                    hA.AvailableToolPath=toolPath;

                    hA.checkToolVersion(obj.hD.tclOnly);
                end
            end



            for ii=1:length(obj.TheAvailableToolList)
                hA=obj.TheAvailableToolList(ii);


                if~isempty(hA.AvailablePlugin)
                    continue;
                end

                for jj=1:length(hA.PluginList)
                    hP=hA.PluginList{jj};
                    if~isempty(hP.ToolPath)

                        isAvailable=obj.checkToolAvailability(hP.ToolPath,hP);
                        if isAvailable

                            hA.AvailableToolPath=toolPath;

                            isValid=hA.checkToolVersion(obj.hD.tclOnly);
                            if isValid
                                break;
                            else
                                error(message('hdlcommon:workflow:ErrorInSpecifiedToolPath',hP.ToolPath));
                            end
                        else
                            error(message('hdlcommon:workflow:ErrorInSpecifiedToolPath',hP.ToolPath));
                        end
                    end
                end
            end


            if ispc
                exeqpro='qpro.exe';
            else
                exeqpro='qpro';
            end

            for i=1:length(obj.TheAvailableToolList)
                toolName=obj.TheAvailableToolList(i).ToolName;
                toolpath=obj.TheAvailableToolList(i).AvailableToolPath;
                searchStrPro=fullfile(toolpath,exeqpro);
                if(contains(toolName,'altera','IgnoreCase',true)&&exist(searchStrPro,'file'))
                    obj.TheAvailableToolList(i).AvailablePlugin=[];
                end
            end


            ii=1;
            while ii<=length(obj.TheAvailableToolList)
                hA=obj.TheAvailableToolList(ii);
                if isempty(hA.AvailablePlugin)
                    obj.removeFromToolList(hA);
                else
                    ii=ii+1;
                end
            end
        end

        function[isexist,userplugin]=existUserDefinedPlugin(obj)%#ok<MANU>











            isexist=false;
            userplugin=[];

            if evalin('base','exist(''hdlcoder_downstream_integration_plugin'', ''var'')')

                userplugin=evalin('base','hdlcoder_downstream_integration_plugin');

                if isfield(userplugin,'pluginPath')&&isfield(userplugin,'pluginPackage')
                    isexist=true;
                end
            end
        end

        function[isAvailable,toolPath]=checkToolAvailability(obj,toolPath,hP)


            isAvailable=true;

            if obj.hD.tclOnly
                return;
            end

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
            downstream.AvailableToolList.defaultPluginDir(),...
            fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+downstreamhlstools'),...
            };
            obj.PackagePathList={...
            'downstreamtools',...
            'downstreamhlstools',...
            };
        end

    end

    methods(Static=true)
        function pluginDir=defaultPluginDir()
            pluginDir=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+downstreamtools');
        end

        function[isexist,path]=simplewhich(inFileName)







            isexist=false;
            path='';



            [filePath,exeName,fileExt]=fileparts(inFileName);
            if isempty(fileExt)&&ispc

                if strcmpi(exeName,'vivado')||strcmpi(exeName,'vitis_hls')
                    inFileName=[inFileName,'.bat'];
                else
                    inFileName=[inFileName,'.exe'];
                end

            end


            if~isempty(filePath)
                if exist(inFileName,'file')
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
                    if exist(searchStr,'file')
                        isexist=true;
                        path=aPath;
                        return;
                    end
                end
            end
        end

    end


end


