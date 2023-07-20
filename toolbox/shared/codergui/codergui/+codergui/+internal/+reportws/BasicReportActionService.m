classdef(Sealed)BasicReportActionService<codergui.internal.WebService








    properties(Hidden,Constant)
        OPEN_CHANNEL_REQUEST='open/request'
        OPEN_CHANNEL_REPLY='open/reply'
        PACK_CHANNEL_REQUEST='packngo/request'
        PACK_CHANNEL_REPLY='packngo/reply'
        CAN_PACK_CHANNEL_REQUEST='packngo/query/request'
        CAN_PACK_CHANNEL_REPLY='packngo/query/reply'
        HELP_REQUEST='help/request'
        HELP_REPLY='help/reply'
    end

    properties(SetAccess=immutable)
ReportViewer
    end

    properties(Access=private)
ReportFileListener
ReportInfo
    end

    methods
        function this=BasicReportActionService(reportViewer)
            this.ReportViewer=reportViewer;
            this.ReportFileListener=addlistener(reportViewer,'ReportFile',...
            'PostSet',@(varargin)this.handleReportChange());
        end

        function start(this,~)
            this.handleReportChange();
            this.ReportViewer.Client.subscribe(this.OPEN_CHANNEL_REQUEST,@(msg)this.openInEditor(msg));
            this.ReportViewer.Client.subscribe(this.PACK_CHANNEL_REQUEST,@(msg)this.packAndGo(msg));
            this.ReportViewer.Client.subscribe(this.CAN_PACK_CHANNEL_REQUEST,@(msg)this.canPackAndGo(msg));
            this.ReportViewer.Client.subscribe(this.HELP_REQUEST,@(msg)this.invokeHelpView(msg));
        end

        function shutdown(this)
            delete(this.ReportFileListener);
        end
    end

    methods(Hidden)
        function handleReportChange(this)
            if~isempty(this.ReportViewer.FileSystem)
                try
                    this.ReportInfo=this.ReportViewer.FileSystem.loadMatFile(...
                    codergui.ReportServices.REPORT_INFO_FILE,'reportInfo');
                    this.ReportInfo=this.ReportInfo.reportInfo;
                catch me
                    this.ReportInfo=[];
                    coder.internal.gui.asyncDebugPrint(me);
                end
            else
                this.ReportInfo=[];
            end
        end

        function openInEditor(this,msg)
            editor=[];
            success=false;
            file=msg.file;
            if~isempty(file)&&file(1)=='#'&&...
                isfield(this.ReportInfo,'modelName')
                editor=this.openFunctionBlock(file);
            elseif~isempty(file)&&endsWith(file,'.sfx')

                opentoline(file,msg.line,0);
                success=true;
            else



                file=this.getMatlabFile(file);
                if~isempty(file)
                    if codergui.internal.canEditInMatlab("native")
                        editor=matlab.desktop.editor.openDocument(file);
                    elseif codergui.internal.canEditInMatlab("external")
                        edit(file);
                        success=true;
                    end
                end
            end
            if~success&&~isempty(editor)
                if isfield(msg,'line')&&msg.line>0
                    if codergui.internal.isMatlabOnline()
                        opentoline(msg.file,msg.line,0);
                        this.ReportViewer.minimize();
                    else
                        editor.goToLine(msg.line);
                    end
                elseif isfield(msg,'functionName')&&~isempty(msg.functionName)
                    editor.goToFunction(msg.functionName);
                end
                editor.makeActive();
                success=true;
            end
            this.reply(this.ReportViewer,msg,this.OPEN_CHANNEL_REPLY,'success',success);
        end

        function packAndGo(this,msg)
            coder.internal.ddux.logger.logCoderEventData("appPackage","report");
            success=false;
            errMessage='';
            if~isfield(this.ReportInfo,'modelName')
                buildFolder=this.findBuildFolder();
                if~isempty(buildFolder)
                    buildInfo=[];
                    if exist(fullfile(buildFolder,'buildInfo.mat'),'file')~=0
                        try
                            buildInfo=load(fullfile(buildFolder,'buildInfo.mat'),'buildInfo');
                            buildInfo=buildInfo.buildInfo;
                        catch
                        end
                    else
                        try

                            buildInfo=this.ReportViewer.FileSystem.loadMatFile(...
                            codergui.ReportServices.BUILD_INFO_FILE,'buildInfo');
                            buildInfo=buildInfo.buildInfo;
                        catch
                        end
                    end
                    if~isempty(buildInfo)
                        if isfield(msg,'packType')&&~isempty(msg.packType)
                            packType=msg.packType;
                        else
                            packType='';
                        end
                        [success,errMessage]=this.invokePackNGo(buildInfo,msg.file,packType);
                    end
                end
            end
            this.reply(this.ReportViewer,msg,this.PACK_CHANNEL_REPLY,'success',success,'message',errMessage);
        end

        function canPackAndGo(this,msg)
            supported=false;
            if isfield(this.ReportInfo,'canPackage')&&this.ReportInfo.canPackage
                buildFolder=this.findBuildFolder();
                if~isempty(buildFolder)
                    supported=exist(fullfile(buildFolder,'buildInfo.mat'),'file')~=0;
                end
            end
            this.reply(this.ReportViewer,msg,this.CAN_PACK_CHANNEL_REPLY,'supported',supported);
        end

        function invokeHelpView(this,msg)
            if isfield(msg,'topic')
                topic=msg.topic;
            else
                topic='';
            end
            if~isempty(topic)
                extraArgs={'CSHelpWindow'};
            else
                extraArgs={};
            end

            mapPath='';
            if~isempty(this.ReportViewer.Manifest)
                mayHaveMainDoc=this.ReportViewer.ReportType.canHaveMainDocTopic();
                if mayHaveMainDoc
                    [mapPath,topic]=this.ReportViewer.ReportType.resolveDocPage(this.ReportViewer.Manifest,topic);
                end
            else
                mayHaveMainDoc=true;
            end

            if~isfield(msg,'requestType')||strcmpi(msg.requestType,'open')
                success=false;
                if mayHaveMainDoc
                    if~isempty(mapPath)&&~isempty(topic)
                        try
                            helpview(mapPath,topic,extraArgs{:});
                        catch me
                            this.fail(this.ReportViewer,msg,this.HELP_REPLY,me);
                            return;
                        end
                        success=true;
                    end
                end
                if success
                    this.reply(this.ReportViewer,msg,this.HELP_REPLY,'success',true);
                else
                    this.fail(this.ReportViewer,msg,this.HELP_REPLY,...
                    sprintf('Could not resolve topic "%s"',topic));
                end
            else
                this.reply(this.ReportViewer,msg,this.HELP_REPLY,...
                'hasLocalDoc',logical(exist(mapPath,'file')));
            end
        end
    end

    methods(Access=private)
        function editor=openFunctionBlock(this,sidPrecursor)
            editor=[];
            sid=regexprep(sidPrecursor,'^#','');


            if isfield(this.ReportInfo,'modelName')&&~isempty(this.ReportInfo.modelName)
                modelName=this.ReportInfo.modelName;
            else
                modelName=Simulink.ID.getModel(sid);
            end
            if~ismember(modelName,find_system('SearchDepth',0))
                try
                    open_system(this.ReportInfo.modelName);
                catch
                    if isfield(this.ReportInfo,'modelPath')&&~isempty(this.ReportInfo.modelPath)
                        try
                            open_system(this.ReportInfo.modelPath);
                        catch
                            return;
                        end
                    else
                        return;
                    end
                end
            end



            try
                [blockName,sidNumber,stateflowNumber]=sfprivate('traceabilityManager','parseSSId',sid);
                if isempty(stateflowNumber)

                    open_system(sid);
                else
                    chart=idToHandle(sfroot,sfprivate('block2chart',sprintf('%s:%s',blockName,sidNumber)));
                    blockObj=chart.find('SSIdNumber',str2double(stateflowNumber));
                    blockObj.view();
                    if~isa(blockObj,'Stateflow.EMChart')&&~isa(blockObj,'Stateflow.EMFunction')
                        return;
                    end
                end
            catch
            end


            try

                [~,sfFuncId]=codergui.evalprivate('sfDecodeBlockPath',sidPrecursor);
                if sfFuncId~=-1
                    sf('Open',sfFuncId,0,-2);
                else
                    return;
                end
            catch
                return;
            end

            if feature('openMLFBInSimulink')
                m=slmle.internal.slmlemgr.getInstance;
                objectId=m.getObjectId(Simulink.ID.getFullName(sid));
                editor=m.getMLFBEditor(objectId);
            else

                editor=matlab.desktop.editor.getActive();
            end


        end

        function file=getMatlabFile(this,rawFile)
            file=[];

            if exist(rawFile,'file')~=0
                file=rawFile;
            end

            if isempty(file)
                [parentFile,filename,ext]=fileparts(rawFile);
                if isfield(this.ReportInfo,'relativePaths')&&this.ReportInfo.relativePaths.isKey(parentFile)
                    relParent=this.ReportInfo.relativePaths(parentFile);
                elseif isfield(this.ReportInfo,'relativeBuildDirectory')
                    relParent=this.ReportInfo.relativeBuildDirectory;
                else
                    relParent='';
                end
                if~isempty(relParent)


                    rebased=this.rebasePath(relParent);
                    file=fullfile(rebased,[filename,ext]);
                    if exist(file,'file')==0
                        file=[];
                    end
                end
            end
        end

        function buildFolder=findBuildFolder(this)
            if exist(this.ReportInfo.buildDirectory,'dir')~=0
                buildFolder=this.ReportInfo.buildDirectory;
            else
                buildFolder='';
            end
        end

        function reportFolder=getReportFolder(this)
            [parent,file,ext]=fileparts(this.ReportViewer.ReportFile);
            if~isempty(ext)
                reportFolder=parent;
            elseif~isempty(parent)||~isempty(file)
                reportFolder=fullfile(parent,file);
            else
                reportFolder=pwd();
            end
        end

        function rebased=rebasePath(this,relPath)
            basePath=this.getReportFolder();
            try
                rebased=codergui.internal.util.getCanonicalPath(fullfile(basePath,relPath));
            catch
                rebased=fullfile(basePath,relPath);
            end
        end
    end

    methods(Static,Access=private)
        function[success,errMessage]=invokePackNGo(buildInfo,file,packType)
            errMessage='';
            curDir=pwd();
            cdCleanup=onCleanup(@()cd(curDir));

            if isempty(fileparts(file))
                file=fullfile(pwd,file);
            end

            if exist('packType','var')&&~isempty(packType)
                extraArgs={'packType',packType};
            else
                extraArgs={};
            end

            try
                startDir=buildInfo.getSourcePaths(true,'StartDir');
                startDir=startDir{1};
                [~,tempZipName]=fileparts(tempname(startDir));
                buildInfo.packNGo({'fileName',tempZipName,extraArgs{:}});%#ok<CCAT>                
                src=fullfile(startDir,[tempZipName,'.zip']);
                movefile(src,file,'f');
                success=true;
            catch me
                errMessage=me.message;
                success=false;
            end
        end
    end
end


