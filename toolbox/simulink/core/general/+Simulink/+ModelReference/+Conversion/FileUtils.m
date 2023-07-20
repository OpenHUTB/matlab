classdef FileUtils<handle
    methods(Static,Access=public)
        function checkFileName(fileName)
            if(exist(fileName,'file'))
                throw(MException(message('Simulink:modelReferenceAdvisor:FileExisted',fileName)));
            end
        end


        function deleteFile(fileName)
            if exist(fileName,'file')
                delete(fileName);
            end
        end


        function fName=getUniqueFileName(fName)
            [filePath,fileName,fileExt]=fileparts(fName);
            idx=0;
            tmpFileName=fName;
            while(exist(tmpFileName,'file')>0)
                tmpFileName=fullfile(filePath,[fileName,int2str(idx),fileExt]);
                idx=idx+1;
            end
            fName=tmpFileName;
        end
    end
end
