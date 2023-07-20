classdef(Abstract)ReportFileSystem<handle




    methods(Static,Sealed)
        function fs=fromReportFile(reportFile)
            if isa(reportFile,'codergui.internal.VirtualReport')
                fs=codergui.internal.fs.VirtualReportFileSystem(reportFile);
            else
                [filename,reportFile]=codergui.ReportServices.getReportFilename(reportFile);
                [~,~,ext]=fileparts(filename);
                if strcmpi(ext,'.mldatx')
                    fs=codergui.internal.fs.MldatxReportFileSystem(reportFile);
                else
                    fs=codergui.internal.fs.BasicReportFileSystem(reportFile);
                end
            end
        end
    end

    properties(SetAccess=immutable)
ReportFile
    end

    properties(Abstract,SetAccess=private,GetAccess=public)
Writable
    end

    methods(Sealed)
        function this=ReportFileSystem(reportFile)
            this.ReportFile=reportFile;
        end

        function data=loadMatFile(this,path,varName)
            if nargin<3
                varName='';
            end
            if this.isRelativeFile(path)
                data=this.loadRelativeMatFile(path,varName);
            elseif~isempty(varName)
                data=load(path,varName);
            else
                data=load(path);
            end
        end

        function text=readTextFile(this,path,encoding)
            if nargin<3
                encoding='';
            end
            if this.isRelativeFile(path)
                text=this.readRelativeTextFile(path,encoding);
            else
                text=this.doReadTextFile(path,encoding);
            end
        end

        function exists=fileExists(this,path)
            if this.isRelativeFile(path)
                exists=this.relativeFileExists(path);
            else
                exists=exist(path,'file')||exist(path,'dir');
            end
        end
    end

    methods(Abstract)
        ioService=createFileIoService(this,defaultEncoding,requestChannel,replyChannel)
        addFile(this,fileName,srcFilePath)
    end

    methods(Abstract,Access=protected)
        data=loadRelativeMatFile(this,relPath)

        text=readRelativeTextFile(this,relPath,encoding)

        exists=relativeFileExists(this,relPath)
    end

    methods(Static,Access=private)
        function relative=isRelativeFile(path)
            relative=~codergui.internal.util.isAbsolute(path);
        end
    end

    methods(Static,Hidden)
        function text=doReadTextFile(file,encoding)
            if nargin>1&&~isempty(encoding)
                fid=fopen(file,'r','n');
                text=native2unicode(fread(fid,[1,inf],'uint8'),encoding);%#ok<N2UNI> 
                fclose(fid);
            else
                text=fileread(file);
            end
        end
    end

    methods(Static,Sealed)
        function[filename,filePath]=getReportFilename(folder)
            if isa(folder,'codergui.internal.VirtualReport')
                filename='';
                filePath='';
                return;
            end

            [parent,filename,ext]=fileparts(folder);
            if any(strcmpi(ext,{'.mldatx','.html'}))

                filename=[filename,ext];
                filePath=fullfile(parent,filename);
                return;
            elseif~isempty(ext)
                folder=parent;
            end

            filename=[];
            if nargin>0
                if exist(fullfile(folder,'report.mldatx'),'file')
                    filename='report.mldatx';
                elseif exist(fullfile(folder,'index.html'),'file')
                    filename='index.html';
                elseif exist(fullfile(folder,codergui.ReportServices.MANIFEST_FILENAME),'file')
                    filename=codergui.ReportServices.MANIFEST_FILENAME;
                end
            end
            if isempty(filename)
                filename='report.mldatx';
            end
            filePath='';
            if nargin>0
                filePath=fullfile(folder,filename);
                if~exist(filePath,'file')
                    filePath='';
                end
            end
        end
    end
end