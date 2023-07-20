



classdef TraceabilityDb<sldv.code.internal.TraceabilityDb
    methods
        function obj=TraceabilityDb(varargin)
            obj@sldv.code.internal.TraceabilityDb(varargin{:});
        end

        function fileNames=extractInstrumentedFiles(obj,outputDir,subDir)
            files=obj.getInstrumentedFiles();
            numFiles=numel(files);

            fileNames=cell(1,numFiles);

            for ii=1:numFiles
                file=files(ii);
                isWrapperFile=((file.kind==internal.cxxfe.instrum.FileKind.SOURCE)&&(file.status==internal.cxxfe.instrum.FileStatus.INTERNAL));
                [filePath,relativePath]=sldv.code.internal.TraceabilityDb.getConvertedPath(outputDir,subDir,file,isWrapperFile);
                fileNames{ii}=relativePath;
                polyspace.internal.makeParentDir(filePath);

                if~obj.writeInstrumentedContent(file,filePath)
                    sldv.code.internal.throwError('sldv_sfcn:sldv_slcc:cannotWriteTemporaryFile');
                end
            end
        end
    end
end


