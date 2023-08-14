

classdef(Sealed)OnDemandCodeMetrics


    properties(Hidden,Constant)
        CODE_METRICS_STATE='codeMetricsReportState'
        STATE_SUPPORTED='supported'
        STATE_GENERATED='generated'
        STATE_UNSUPPORTED='unsupported'
        EXPECTED_FILENAME='metrics.html'
    end

    properties(SetAccess=private)
CodeMetricsData
    end

    properties(SetAccess=immutable)
Supported
UnsupportedReason
    end

    properties(SetAccess=immutable,GetAccess=private)
FileSystem
Manifest
GeneratedSourceInfo
    end

    methods
        function this=OnDemandCodeMetrics(reportOrViewer)
            if isa(reportOrViewer,'codergui.ReportViewer')
                this.FileSystem=reportOrViewer.FileSystem;
                this.Manifest=reportOrViewer.Manifest;
            else
                this.FileSystem=codergui.internal.fs.ReportFileSystem.fromReportFile(reportOrViewer);
                manifest=this.FileSystem.loadMatFile('manifest.mat','manifest');
                this.Manifest=manifest.manifest;
            end
            this.GeneratedSourceInfo=this.loadGeneratedSourceInfo(this.FileSystem);
            [this.Supported,this.UnsupportedReason]=this.canGenerateCodeMetricsReport();
        end

        function data=generateData(this)
            if isempty(this.CodeMetricsData)&&this.Supported
                this.CodeMetricsData=this.invokeCodeMetrics();
            end
            data=this.CodeMetricsData;
        end

        function generated=generatePage(this,outFile)
            if this.Supported
                this.invokeCodeMetrics(outFile);
                generated=exist(outFile,'file')~=0;
            else
                generated=false;
            end
        end
    end

    methods(Access=private)
        function data=invokeCodeMetrics(this,outFile)
            tempFolder=tempname();
            tempFolderCleanup=onCleanup(@()this.silentlyDeleteFile(tempFolder));
            mkdir(tempFolder);


            buildInfo=this.FileSystem.loadMatFile(codergui.ReportServices.BUILD_INFO_FILE,'buildInfo');
            buildInfo=buildInfo.buildInfo;
            save(fullfile(tempFolder,'buildInfo.mat'),'buildInfo');


            buildInfoSource=fullfile(coder.CodeMetrics.getFileListFromBuildInfo(buildInfo));
            recreatedFiles={};
            for i=1:size(this.GeneratedSourceInfo,1)
                [origPath,serializedPath]=this.GeneratedSourceInfo{i,:};
                if~ismember(fullfile(origPath),buildInfoSource)
                    continue;
                end
                [~,filename,ext]=fileparts(origPath);
                recreatedFile=fullfile(tempFolder,[filename,ext]);
                text=this.FileSystem.readTextFile(serializedPath,this.Manifest.DefaultEncoding);
                fid=fopen(recreatedFile,'w','n',this.Manifest.DefaultEncoding);
                fprintf(fid,'%s',text);
                fclose(fid);
                recreatedFiles{end+1}=recreatedFile;%#ok<AGROW>
            end


            data=coder.CodeMetrics(tempFolder,[],struct('FileList',{recreatedFiles}));
            if nargin<2||isempty(outFile)
                return;
            end


            codeMetrics=coder.report.CodeMetrics(data,true);
            htmlLinkManager=coder.report.HTMLLinkManager(true);
            htmlLinkManager.BuildDir=tempFolder;
            codeMetrics.setLinkManager(htmlLinkManager);
            codeMetrics.ReportFolder=fullfile(tempFolder,'html');
            mkdir(codeMetrics.ReportFolder);
            codeMetrics.generate();
            copyfile(fullfile(codeMetrics.ReportFolder,codeMetrics.ReportFileName),outFile);
        end

        function[generatable,reason]=canGenerateCodeMetricsReport(this)
            reason='';
            generatable=~isempty(this.FileSystem)&&~isempty(this.Manifest)&&...
            this.Manifest.hasProperty(this.CODE_METRICS_STATE)&&...
            ~strcmp(this.Manifest.getProperty(this.CODE_METRICS_STATE),this.STATE_UNSUPPORTED)&&...
            ~isempty(this.GeneratedSourceInfo)&&...
            this.FileSystem.fileExists(codergui.ReportServices.BUILD_INFO_FILE);
            if~generatable
                return;
            end


            generatable=strcmp(this.Manifest.Platform,computer())||all(startsWith({this.Manifest.Platform,computer()},'PCWIN'));
            if~generatable
                if startsWith(this.Manifest.Platform,'PCWIN')
                    original='Windows';
                elseif startsWith(this.Manifest.Platform,'MACI')
                    original='Mac';
                else
                    original='Linux';
                end
                reason=message('coderWeb:matlab:cmReasonCrossPlatform',original).getString();
                return;
            end

            generatable=all(available([...
            coderapp.internal.Products.MatlabCoder...
            ,coderapp.internal.Products.EmbeddedCoder]))&&...
            ~isempty(which('coder.report.CodeMetrics'));
            if~generatable
                reason=message('coderWeb:matlab:cmReasonLicense').getString();
                return;
            end
        end
    end

    methods(Static,Access=private)
        function info=loadGeneratedSourceInfo(fs)
            try
                if fs.fileExists(codergui.ReportServices.GENERATED_CODE_INFO_FILE)
                    info=fs.loadMatFile(codergui.ReportServices.GENERATED_CODE_INFO_FILE);
                    info=info.generatedCodeInfo.generatedSourceFiles;
                else
                    info=[];
                end
            catch
                info=[];
            end
        end
    end

    methods(Static,Hidden)
        function silentlyDeleteFile(file)
            try
                if isfolder(file)
                    rmdir(file,'s');
                else
                    delete(file);
                end
            catch
            end
        end
    end
end