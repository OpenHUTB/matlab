



classdef TraceabilityDb<codeinstrum.internal.TraceabilityData

    methods



        function this=TraceabilityDb(varargin)
            this@codeinstrum.internal.TraceabilityData(varargin{:});
        end




        function files=getInstrumentedFiles(obj)
            files=obj.getFilesInCurrentModule();
            idx=false(size(files));
            for ii=1:numel(files)
                idx(ii)=~isempty(files(ii).instrumentedContents);
            end
            files=files(idx);
        end






        function insertOk=setInstrumentedContent(obj,...
            fileName,...
            fileContent)
            insertOk=true;
            srcFile=polyspace.internal.getAbsolutePath(fileName);
            f=obj.getFile(srcFile);
            if~isempty(f)
                f.instrumentedContents=fileContent;
            else
                insertOk=false;
            end
        end



        function ok=writeInstrumentedContent(obj,file,outputFile)
            fileContent=unicode2native(file.instrumentedContents,'UTF-8');

            fid=fopen(outputFile,'wb');
            if fid>=3
                fwrite(fid,fileContent);
                fclose(fid);
                ok=true;
            else
                ok=false;
            end
        end
    end
    methods(Access=protected,Static=true)
        function[fileName,relativePath]=getConvertedPath(outputDir,subDir,file,isWrapperFile)
            if nargin<4
                isWrapperFile=false;
            end

            [~,stem,ext]=fileparts(file.path);
            if~isWrapperFile

                stem=stem((stem>='0'&stem<='9')|(stem>='A'&stem<='Z')|(stem>='a'&stem<='z')|stem=='_');
                relativePath=fullfile(subDir,sprintf('f_%s_%s%s',stem,file.checksum,ext));
            else
                relativePath=fullfile(subDir,sprintf('wrappers%s',ext));
            end

            fileName=fullfile(outputDir,relativePath);
        end
    end
end


