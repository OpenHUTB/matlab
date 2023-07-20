classdef File<handle


    properties(GetAccess=public,SetAccess=private,Hidden)

        FileID=-1;
    end

    methods
        function closeFile=generateFile(obj,fileName)
            obj.openFile(fileName);


            closeFile=onCleanup(@()obj.closeFile());

        end

        function openFile(obj,fileName)
            [~,~,ext]=fileparts(fileName);
            if isempty(ext)
                fileName=[fileName,'.m'];
            end
            fileID=downstream.tool.createFile(fileName);
            obj.FileID=fileID;
        end

        function closeFile(obj)
            status=fclose(obj.FileID);
            if status==-1
                error('Could not close file.')
            else
                obj.FileID=-1;
            end
        end
        function addComment(obj,commentStr)

            comment=['% ',commentStr];
            hdlturnkey.backend.ScriptGeneration.addLine(obj.FileID,comment);
        end
        function addLine(obj,str)

            hdlturnkey.backend.ScriptGeneration.addLine(obj.FileID,str);
        end
    end
end

