



classdef AvailableTool<handle




    properties

        ToolName='';
        ToolVersion='';


        PluginList={};


        AvailableToolPath='';
        AvailablePlugin=[];


        SupportedVersionList={};

    end

    properties(Hidden=true)


        Default_openTargetTool='';
        Default_checkToolVersion='';
        Default_regexpToolVersion='';

    end

    methods

        function isValid=checkToolVersion(obj,tclOnly)


            isValid=true;





            if tclOnly


                toolVersion=obj.SupportedVersionList{1};

            else



                for i=1:length(obj.PluginList)


                    hP=obj.PluginList{i};




                    if(i==length(obj.PluginList))
                        toolVersion=obj.getToolVersion(obj.AvailableToolPath,hP,true);
                    else
                        toolVersion=obj.getToolVersion(obj.AvailableToolPath,hP,false);
                    end


                    if~isempty(toolVersion)
                        break;
                    end
                end
            end


            if isempty(toolVersion)

                isValid=false;

                obj.AvailablePlugin=obj.PluginList{end};

            else

                [isIn,hT]=obj.isInPluginVersionList(toolVersion);
                if isIn

                    obj.AvailablePlugin=hT;
                else

                    obj.AvailablePlugin=obj.pickInVersionList(toolVersion);
                end
            end








            if obj.isInSupportedVersionList(toolVersion)||...
                obj.isInPluginVersionList(toolVersion)
                obj.AvailablePlugin.UnSupportedVersion=false;
                obj.AvailablePlugin.VersionWarningMsg='';
            else
                obj.AvailablePlugin.UnSupportedVersion=true;
                obj.AvailablePlugin.VersionWarningMsg=obj.getVersionWarningMessage(toolVersion);
            end


            obj.ToolVersion=toolVersion;
            obj.AvailablePlugin.ToolVersion=toolVersion;
            obj.AvailablePlugin.ToolPath=obj.AvailableToolPath;
        end

    end

    methods(Access=protected)

        function toolVersion=getToolVersion(~,toolPath,hP,warnFlag)



            if nargin<4
                warnFlag=true;
            end
            isLibero=strcmpi(hP.ToolName,'Microchip Libero SoC');

            try
                if isLibero
                    currDir=pwd;
                    tclFileName='getToolVersion.tcl';
                    fid=downstream.tool.createTclFile(tclFileName);
                    fprintf(fid,'get_libero_release\n');
                    fprintf(fid,'set toolVersionVal [get_libero_release]\n');
                    fprintf(fid,'puts "$toolVersionVal"');
                    fclose(fid);

                    tclFilePath=fullfile(currDir,tclFileName);
                    cmdStr=fullfile(toolPath,['libero script:',tclFileName]);
                else
                    cmdStr=fullfile(toolPath,hP.cmd_checkToolVersion);
                end

                if isLibero
                    numAttempts=3;
                else
                    numAttempts=1;
                end

                for ii=1:numAttempts
                    [status,verStr]=system(cmdStr);


                    if status||~isempty(verStr)
                        break;
                    end
                end

                verID=eval(hP.cmd_regexpToolVersion);
                if isempty(verID)||(isLibero&&contains(verStr,'Error','IgnoreCase',true))







                    if isLibero
                        verID=regexp(toolPath,'v([\d\.]*)','tokens');
                        if contains(verID{1},'.')
                            toolVersion=verID{1}{:};
                        else
                            toolVersion=insertAfter(verID{1}{:},length(verID{1}{:})-1,'.');
                        end
                    else
                        toolVersion='';
                    end

                    if warnFlag
                        warning(message('hdlcommon:workflow:InvalidVersionNumber',cmdStr,verStr));
                    end
                else
                    toolVersion=verID{1}{:};
                end
            catch ME %#ok<NASGU>
                toolVersion='';
            end
            if isLibero
                c=onCleanup(@()delete(tclFilePath));
            end
        end

        function[isIn,hT]=isInPluginVersionList(obj,toolVersion)

            isIn=false;
            hT=[];
            if isempty(toolVersion)
                return;
            end

            pluginList=obj.PluginList;
            for ii=1:length(pluginList)
                t=pluginList{ii};
                if downstream.tool.isToolVersionMatch(toolVersion,t.ToolVersion)
                    isIn=true;
                    hT=t;
                    return;
                end
            end
        end

        function isIn=isInSupportedVersionList(obj,toolVersion)

            isIn=false;
            if isempty(toolVersion)
                return;
            end

            supportedVersionList=obj.SupportedVersionList;
            for ii=1:length(supportedVersionList)
                t=supportedVersionList{ii};
                if downstream.tool.isToolVersionMatch(toolVersion,t)
                    isIn=true;
                    return;
                end
            end
        end

        function hT=pickInVersionList(obj,toolVersion)



            inputVersionID=downstream.tool.getToolVersionNumber(toolVersion);


            pluginToolVersionID={};
            pluginList=obj.PluginList;
            for ii=1:length(pluginList)
                hP=pluginList{ii};
                toolVersionID=downstream.tool.getToolVersionNumber(hP.ToolVersion);
                pluginToolVersionID{end+1}=toolVersionID;%#ok<AGROW>
            end


            [maxID,maxIdx]=max([pluginToolVersionID{:}]);
            if inputVersionID>=maxID
                hT=pluginList{maxIdx};
                return;
            end


            [resultID,indexID]=sort([pluginToolVersionID{:}]);
            for ii=1:length(resultID)
                currentID=resultID(ii);
                if inputVersionID<currentID
                    pickIndex=indexID(ii);
                    hT=pluginList{pickIndex};
                    return;
                end
            end

        end

        function hstr=getVersionWarningMessage(obj,toolVersion)
            hstr=sprintf('Downstream Integration:\n');
            hstr=sprintf('%sCurrent version %s of %s tool on system path \nmay not be compatible with HDL Workflow Advisor. \n',hstr,toolVersion,obj.ToolName);
            hstr=sprintf('%sThe compatible version: \n',hstr);
            versionList=obj.SupportedVersionList;
            if~isempty(versionList)
                for ii=1:length(versionList)-1
                    s=versionList{ii};
                    hstr=sprintf('%s %s %s; \n',hstr,obj.ToolName,s);
                end
                hstr=sprintf('%s %s %s. \n',hstr,obj.ToolName,versionList{end});
            end
            hstr=sprintf('%sAttempt to continue running %s ... \n',hstr,obj.ToolName);
        end
    end

end
