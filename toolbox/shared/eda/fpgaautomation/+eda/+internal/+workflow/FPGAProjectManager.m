classdef FPGAProjectManager<handle































    properties(Abstract,SetAccess=protected)
mToolInfo
    end

    properties(Access=protected)
ProjParamParser
BuildParamParser
    end

    properties(SetAccess=protected)
        ProjectFolder='';
        ProjectName='';
        ProjectExt='';
        ProjectPath='';
        ProjectFullPath='';
    end

    properties(Transient,Hidden)
ToolProcessMap
TclCmdQueue
        StatusMsg='';
NewProject

        TclPrefix,DispStat,CustomLabel,LabelStr,xfileaddcmdswitch
AssertProcErr
        PreBuildStat,PostBuildStat,DispProjLink,Blocking,AddEDASLComment,EchoOutput
    end

    properties(Hidden)
        TclScriptName='fpgaproj.tcl';
    end

    properties(Dependent)
ProjectFile
    end

    methods

        function h=FPGAProjectManager
            h.makeParamParser;
        end

        function validateFPGATool(h)
            h.mToolInfo.checkFPGATool;
        end

        function setProjectByName(h,folder,name)

            h.ProjectFolder=folder;
            h.ProjectName=name;
            h.ProjectPath=fullfile(folder,[name,h.ProjectExt]);
            h.setProjectAction;
        end

        function setProjectByPath(h,projectPath)

            [pathstr,name,ext]=fileparts(projectPath);
            if isempty(name)||isempty(ext)
                error(message('EDALink:FPGAProjectManager:InvalidPath',projectPath));
            end
            h.ProjectFolder=pathstr;
            h.ProjectName=name;
            h.ProjectExt=ext;
            h.ProjectPath=projectPath;
            h.setProjectAction;
        end

        function result=get.ProjectFile(h)
            if isempty(h.ProjectName)
                result='';
            else
                result=[h.ProjectName,h.ProjectExt];
            end
        end


        function addFiles(h,filePath,fileType,fileLib,varargin)


            h.validateSrcFileArg(filePath,fileType);
            if nargin<4
                fileLib={};
            end


            fullFilePath=cell(size(filePath));
            for n=1:length(filePath)
                if exist(filePath{n},'file')~=2
                    error(message('EDALink:FPGAProjectManager:FileNotFound',filePath{n}));
                end
                [fileDir,fileName,fileExt]=fileparts(filePath{n});
                if isempty(fileDir)
                    fullFilePath{n}=fullfile(pwd,[fileName,fileExt]);
                else
                    org_dir=pwd;
                    cd(fileDir);
                    fileDir=pwd;
                    cd(org_dir);

                    fullFilePath{n}=fullfile(fileDir,[fileName,fileExt]);
                end
            end

            h.addFullPathFiles_priv(fullFilePath,fileType,fileLib,varargin{:});
        end


        function addFullPathFiles(h,filePath,fileType,varargin)


            h.validateSrcFileArg(filePath,fileType);

            h.addFullPathFiles_priv(filePath,fileType,{},varargin{:});
        end



        function setFPGASystemClockFrequency(~,~)


        end


        function generateIP(~,~)


        end


        function runCustomTclCommand(h,command,varargin)





            validateattributes(command,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});


            command=[h.TclPrefix,command];

            command=regexprep(command,'\n',['\n',h.TclPrefix]);

            command=regexprep(command,[h.TclPrefix,'\s*$'],'');

            h.TclCmdQueue{end+1}=command;
            if h.DispStat&&h.CustomLabel


                h.StatusMsg=[h.StatusMsg,h.LabelStr];
            end
        end
        function insertTclComment(h,comment)
            validateattributes(comment,{'char'},{'nonempty'});
            str=hdlformatcomment(comment,0,'#');
            if str(end)==char(10)
                str(end)=[];
            end
            h.TclCmdQueue{end+1}=sprintf('\n%s',str);
        end




        function str=getProjectStatus(h)
            if isempty(h.ProjectFullPath)
                projPath=h.ProjectPath;
            else
                projPath=h.ProjectFullPath;
            end
            str=printProjectStatus(h,projPath);
        end






        function[buildErr,buildMsg]=build(h,varargin)
            h.validateFPGATool;
            h.parseBuildParam(varargin{:});

            if h.NewProject&&~isempty(h.ProjectFolder)

                eda.internal.workflow.makeDir(h.ProjectFolder);
            end



            orgDir=pwd;
            if~isempty(h.ProjectFolder)
                cd(h.ProjectFolder);
            end

            try
                h.writeTclScript(h.TclScriptName);

                h.ProjectFullPath=fullfile(pwd,h.ProjectFile);
                if h.PreBuildStat
                    h.dispProjectStatus;
                end

                [buildErr,buildMsg]=h.executeTclScript(h.TclScriptName);

                if h.PostBuildStat
                    h.dispProjectStatus;
                end

                cd(orgDir);
            catch me
                cd(orgDir);
                rethrow(me);
            end
        end



        function generateTclScript(h,tclFile)


            validateattributes(tclFile,{'char'},{'nonempty'});
            h.writeTclScript(tclFile);
        end

        function parseBuildParam(h,varargin)
            if nargin>1
                h.BuildParamParser.parse(varargin{:});
                projStat=h.BuildParamParser.Results.ProjectStatusDisplay;
                h.PreBuildStat=strcmpi(projStat,'PreBuild');
                h.PostBuildStat=strcmpi(projStat,'PostBuild');
                h.DispProjLink=h.BuildParamParser.Results.ProjectLinkDisplay;
                h.Blocking=h.BuildParamParser.Results.BlockingBuild;
                h.EchoOutput=h.BuildParamParser.Results.EchoOutput;
                h.AddEDASLComment=h.BuildParamParser.Results.AddEDASLComment;
                h.TclScriptName=h.BuildParamParser.Results.TclScriptName;
            else
                h.PreBuildStat=false;
                h.PostBuildStat=true;
                h.DispProjLink=true;
                h.Blocking=true;
                h.EchoOutput=false;
                h.TclScriptName='fpgaproj.tcl';
            end
        end

        function writeTclScript(h,tclFile)
            fid=fopen(tclFile,'w+');
            if fid==-1
                error(message('EDALink:ISETclProjectManager:OpenTclFileError'));
            end

            if nargin<2
                mver=ver('matlab');
                hver=ver('hdlverifier');
                if h.AddEDASLComment
                    fprintf(fid,['# Generated by %s %s and %s %s\n'...
                    ,'# For internal use only\n\n'],...
                    mver.Name,mver.Version,hver.Name,hver.Version);
                else
                    fprintf(fid,['# Generated by %s %s\n'...
                    ,'# For internal use only\n\n'],...
                    mver.Name,mver.Version);
                end
            end

            fprintf(fid,'%s\n',h.TclCmdQueue{:});
            fclose(fid);
        end

        function[err,stat]=executeTclScript(h,tclScript)

            if ispc


                curpath=pwd;
                if length(curpath)>=2&&strcmp(curpath(1:2),'\\')
                    error(message('EDALink:ISETclProjectManager:UNCPathFound',curpath));
                end
            end
            xtclsh=[h.mToolInfo.FPGAToolTclShell,' '];
            if h.Blocking
                if h.EchoOutput
                    [err,stat]=system([xtclsh,tclScript],'-echo');
                else
                    [err,stat]=system([xtclsh,tclScript]);
                end
            else
                if ispc
                    [err,stat]=system([xtclsh,tclScript,'&']);
                elseif isunix
                    [err,stat]=system(['xterm -hold -sb -sl 256 -e bash -e -c '''...
                    ,xtclsh,tclScript,'''&']);
                else
                    error(message('EDALink:ISETclProjectManager:UnsupportedOS'));
                end
            end
        end

        function str=printProjectStatus(h,projPath)
            str=sprintf('%s',strrep(h.StatusMsg,'_PROJPATH__',projPath));
        end

        function dispProjectStatus(h)
            projPath=h.ProjectFullPath;
            if isempty(projPath)



                error(message('EDALink:ISETclProjectManager:NoProjectPath'));
            end
            if h.DispProjLink
                projPath=h.getProjectLink(projPath);
            end
            fprintf('%s',h.printProjectStatus(projPath));
        end

        function link=getProjectLink(h,projectPath)


            if feature('hotlinks')
                cmd=['system([''',h.mToolInfo.FPGAToolCmd,' '' char(34) '''...
                ,projectPath,''' char(34) char(38)]);'];
                link=['<a href="matlab:',cmd,'">',projectPath,'</a>'];
            else
                link=projectPath;
            end
        end

        function addStatus(h,str,indent)
            h.StatusMsg=[h.StatusMsg,dispFpgaMsg(str,indent)];
        end

        function parseProjParam(h,varargin)

            h.TclPrefix='';
            h.DispStat=true;
            h.CustomLabel=false;
            h.xfileaddcmdswitch='';
            h.LabelStr='';

            if nargin>1
                h.ProjParamParser.parse(varargin{:});
                if h.ProjParamParser.Results.EmitAsComment
                    h.TclPrefix='# ';
                end
                h.DispStat=h.ProjParamParser.Results.StatusDisplay;
                if~any(strcmp('CustomLabel',h.ProjParamParser.UsingDefaults))
                    h.CustomLabel=true;
                    h.LabelStr=h.ProjParamParser.Results.CustomLabel;
                end
                if~any(strcmp('xfileaddcmdswitch',h.ProjParamParser.UsingDefaults))
                    h.xfileaddcmdswitch=h.ProjParamParser.Results.xfileaddcmdswitch;
                end
            end
        end

        function validateProjectFile(h)
            if isempty(h.ProjectFile)
                error(message('EDALink:ISETclProjectManager:UndefinedProject'));
            end
        end
    end

    methods(Static,Access=protected)
        function newstr=addPathQuote(str)

            newstr=str;
            if strfind(newstr,' ')
                if~strcmp(newstr(1),'"')
                    newstr=['"',newstr];
                end
                if~strcmp(newstr(end),'"')
                    newstr=[newstr,'"'];
                end
            end
        end
    end

    methods(Abstract)

        initialize(h)



        isExistingProject(h)
        deleteExistingProject(h)










        createProject(h,varargin)
        openProject(h,varargin)
        closeProject(h,varargin)
        cleanProject(h,varargin);
        setTopLevel(h,entityName,varargin);



        setTargetDevice(h,targetDevice,varargin)

        setProperties(h,prop,varargin);



        runHDLCompilation(h,varargin)
        runSynthesis(h,varargin)
        runPlaceAndRoute(h,varargin)
        runBitGeneration(h,varargin)
        runProcess(h,process,varargin)


        getTimingResult(h,rtnVar,varargin)

    end

    methods(Abstract,Access=protected)
        addFullPathFiles_priv(h,filePath,fileType,fileLib,varargin)
    end

    methods(Access=protected)


        function makeParamParser(h)
            h.ProjParamParser=inputParser;
            h.ProjParamParser.addParamValue('StatusDisplay',true,...
            @islogical);
            h.ProjParamParser.addParamValue('CustomLabel','',...
            @ischar);
            h.ProjParamParser.addParamValue('EmitAsComment',false,...
            @islogical);
            h.ProjParamParser.addParamValue('xfileaddcmdswitch','',...
            @ischar);

            h.BuildParamParser=inputParser;
            h.BuildParamParser.addParameter('ProjectStatusDisplay','PostBuild',...
            @(x)any(strcmpi(x,{'PreBuild','PostBuild','Off'})));
            h.BuildParamParser.addParameter('ProjectLinkDisplay',true,...
            @islogical);
            h.BuildParamParser.addParameter('BlockingBuild',true,...
            @islogical);
            h.BuildParamParser.addParameter('AddEDASLComment',true,...
            @islogical);
            h.BuildParamParser.addParameter('EchoOutput',true,...
            @islogical);
            h.BuildParamParser.addParameter('TclScriptName','fpgaproj.tcl',...
            @(x)ischar(x)||isstring(x));

        end

        function setProjectAction(~,varargin)

        end
    end

    methods(Static,Access=protected)
        function validateSrcFileArg(filePath,fileType)

            validateattributes(filePath,{'cell'},{'vector','nonempty'});
            validateattributes(fileType,{'cell'},{'vector','nonempty'});
            if~all(cellfun(@(x)ischar(x)&&~isempty(x),filePath))||...
                ~all(cellfun(@(x)ischar(x)&&~isempty(x),fileType))
                error(message('EDALink:FPGAProjectManager:InvalidSrcFileInput'));
            end

            if numel(filePath)~=numel(fileType)
                error(message('EDALink:FPGAProjectManager:SrcFilePathTypeLen'));
            end
        end
    end
end


