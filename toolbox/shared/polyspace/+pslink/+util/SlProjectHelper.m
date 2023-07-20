classdef SlProjectHelper




    methods(Static=true)



        function addFolderContent(project,resFolder)
            list=dir(resFolder);
            filenames={list(~[list.isdir]).name};

            for ii=1:numel(filenames)
                currentFile=fullfile(resFolder,filenames{ii});
                addFile(project,currentFile);
            end
        end




        function addFile(project,fileToAdd)
            fileInfo=project.findFile(currentFile);
            if numel(fileInfo)==0
                project.addFile(fileToAdd);
            end
        end




        function[slProject,pslinkOptions]=getAndCheckCurrentProject(pslinkOptions)
            slProject=[];

            try
                slProject=slproject.getCurrentProject();
            catch
                warning('pslink:cannotAccessSimulinkProject',DAStudio.message('polyspace:gui:pslink:cannotAccessSimulinkProject'));
            end
            if~isempty(slProject)
                slProjRootFolder=fullfile(slProject.RootFolder);
                if~polyspace.internal.isAbsolutePath(pslinkOptions.ResultDir)
                    pslinkOptions.ResultDir=fullfile(slProjRootFolder,pslinkOptions.ResultDir);
                else
                    pslinkOptions.ResultDir=fullfile(pslinkOptions.ResultDir);
                end

                pslinkOptions.ResultDir=polyspace.util.FileHelper.normalizeFolderPath(pslinkOptions.ResultDir);
                slProjRootFolder=polyspace.util.FileHelper.normalizeFolderPath(slProjRootFolder);

                if~strncmp(pslinkOptions.ResultDir,slProjRootFolder,length(slProjRootFolder))


                    error('pslink:slProjectInvalidFolder',DAStudio.message('polyspace:gui:pslink:slProjectInvalidFolder',...
                    strrep(pslinkOptions.ResultDir,'\','\\'),strrep(slProjRootFolder,'\','\\')));
                end
            end
        end
    end
end


