classdef(Sealed)MldatxReportFileSystem<codergui.internal.fs.ReportFileSystem




    properties(Dependent,SetAccess=private,GetAccess=public)
Writable
    end

    properties(Access=private)
ArchiveModel
Archive
    end

    methods(Access={?codergui.internal.fs.ReportFileSystem})
        function this=MldatxReportFileSystem(reportFile)
            this=this@codergui.internal.fs.ReportFileSystem(reportFile);
            this.ArchiveModel=mf.zero.Model();
            this.Archive=coderapp.internal.file.archive.Package(this.ArchiveModel,...
            struct('FilePath',this.ReportFile,'TempDirPath',tempname));
            this.Archive.open(this.ReportFile);
        end
    end

    methods(Access=protected)
        function data=loadRelativeMatFile(this,relPath,varName)
            if~isempty(varName)
                varArg={varName};
            else
                varArg={};
            end
            [file,fileCleanup]=this.toTemporaryFile(relPath);%#ok<ASGLU>
            data=load(file,varArg{:});
        end

        function text=readRelativeTextFile(this,relPath,encoding)
            [file,fileCleanup]=this.toTemporaryFile(relPath);%#ok<ASGLU>
            text=this.doReadTextFile(file,encoding);
        end

        function exists=relativeFileExists(this,relPath)
            try
                exists=this.Archive.hasFile(normalizePath(relPath));
            catch
                exists=false;
            end
        end
    end

    methods
        function ioService=createFileIoService(this,defaultEncoding,requestChannel,replyChannel)
            ioService=codergui.internal.fs.ReportFileIoService(this,requestChannel,replyChannel);
            ioService.DefaultEncoding=defaultEncoding;
        end

        function writable=get.Writable(this)
            writable=codergui.internal.util.isWritable(this.ReportFile);
            [parent,~,~]=fileparts(this.ReportFile);
            if writable
                writable=isempty(parent)||codergui.internal.util.isWritable(parent);
            end
        end

        function addFile(this,fileName,srcFilePath)
            assert(codergui.internal.util.isAbsolute(srcFilePath)&&...
            ~codergui.internal.util.isAbsolute(fileName));
            this.Archive.addFile(normalizePath(fileName),srcFilePath);
            this.Archive.save();
        end
    end

    methods(Access=private)
        function[file,fileCleanup]=toTemporaryFile(this,resourceUri)
            file=this.Archive.extractFile(normalizePath(resourceUri));
            fileCleanup=[];
            if~isempty(file)&&nargout>1



                fileCleanup=onCleanup(@()this.quietlyDeleteFile(file));
            end
        end
    end

    methods(Static,Hidden)
        function quietlyDeleteFile(file)
            if exist(file,'file')
                try
                    evalc('delete(file)');
                catch
                end
            end
        end
    end
end

function uri=normalizePath(uri)
    uri=regexprep(uri,{'\\','(^[^/])'},{'/','/$1'});
end
