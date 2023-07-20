classdef FileUtil





    methods(Static)
        function filePath=getFullFileNameForBlock(block)





            filePathOnBlock=get_param(block,'FileName');
            [path,fileName,ext]=fileparts(filePathOnBlock);
            if isempty(fileName)
                filePath=fileName;
                return;
            end
            if isempty(ext)


                filePathOnBlock=[filePathOnBlock,'.mat'];
            end
            if isempty(path)
                filePath=which(filePathOnBlock);
                if isempty(filePath)
                    filePath=filePathOnBlock;
                end
            else
                filePath=filePathOnBlock;
            end
        end

        function filePath=getConciseFileNameForFile(InputFileName)



            [pathname,fileName,Ext]=fileparts(InputFileName);
            currentdir=pwd;
            if strcmp(pathname,currentdir)||...
                Simulink.signaleditorblock.FileUtil.isOnPath(pathname)
                filePath=[fileName,Ext];
            else
                filePath=InputFileName;
            end
        end

        function bool=isDefaultState(blockH)
            fullfileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(blockH);
            if~exist(fullfileName,'file')&&...
                strcmp(fullfileName,'untitled.mat')


                bool=true;
            else
                bool=false;
            end
        end
    end

    methods(Static,Access='private')
        function onPath=isOnPath(Folder)
            pathCell=regexp(path,pathsep,'split');
            if ispc
                onPath=any(strcmpi(Folder,pathCell));
            else
                onPath=any(strcmp(Folder,pathCell));
            end
        end
    end
end

