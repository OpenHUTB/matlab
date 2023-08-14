



classdef PosConverter<handle




    properties
FileInfos
    end

    methods

        function obj=PosConverter()
            obj.FileInfos=containers.Map('KeyType','char','ValueType','any');
        end


        function parseFiles(obj,fileNames)
            for ii=1:numel(fileNames)
                currentFile=fileNames{ii};

                fileInfo=sldv.code.internal.FilePosInfo();
                if fileInfo.parseFile(currentFile)
                    [~,baseName,ext]=fileparts(currentFile);
                    fileName=[baseName,ext];
                    obj.FileInfos(fileName)=fileInfo;
                end
            end
        end





        function[srcFileName,srcLine,found]=convertPos(obj,checkFileName,checkLine)
            found=false;



            [~,base,ext]=fileparts(checkFileName);
            checkFileName=[base,ext];
            if obj.FileInfos.isKey(checkFileName)
                fileInfo=obj.FileInfos(checkFileName);
                [srcFileName,srcLine,found]=fileInfo.getPosition(checkLine);
            end

            if~found
                srcFileName=checkFileName;
                srcLine=checkLine;
            end
        end
    end
end
