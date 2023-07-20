classdef PathUtils<handle


    methods(Access=public,Static)
        function resolvedLocation=resolveFileAgainstFileSystem(fileLocation,checkExists)








            if nargin<2
                checkExists=true;
            end

            if(isempty(fileLocation))
                resolvedLocation='';
                return
            end

            javaFile=iGetJavaFile(fileLocation);



            if(~javaFile.isAbsolute())
                fullFileLocation=fullfile(pwd,fileLocation);
                javaFile=iGetJavaFile(fullFileLocation);
            end


            if(checkExists&&~javaFile.exists())
                resolvedLocation='';
            else
                resolvedLocation=char(...
                javaFile.getCanonicalFile().getAbsolutePath()...
                );
            end
        end

        function valid=loadProjectForOpenPRJ(projectSpecifier)



            if matlab.internal.project.util.useWebFrontEnd
                try
                    valid=matlab.internal.project.api.isBookmarkFile(projectSpecifier);
                    if~valid
                        return;
                    end
                    openProject(projectSpecifier);
                    valid=true;
                    return
                catch
                    valid=false;
                    return;
                end
            end

            try


                resolvedJFile=matlab.internal.project.util.PathUtils...
                .getJavaFileForProjectLoadFromMATLABString(projectSpecifier);


                com.mathworks.toolbox.slproject.project...
                .ProjectLauncherFile.getProjectRootFolderFromFileSpecification(resolvedJFile);
                valid=true;

            catch
                valid=false;
            end
            if(valid)
                matlab.project.loadProject(projectSpecifier);
            end

        end

        function pathsEqual=areFileSystemPathsEqual(path1,path2)

            try
                file1=java.io.File(path1);
                file2=java.io.File(path2);

                pathsEqual=file1.getCanonicalPath.equals(file2.getCanonicalPath);
            catch
                pathsEqual=false;
            end

        end

        function hasExtension=fileHasProjectFileExtension(file)

            projectFileExtension=char(com.mathworks.toolbox.slproject.resources.SlProjectResources.getString('launcher.fileExtension'));

            [~,~,locationExt]=fileparts(file);
            hasExtension=strcmp(locationExt,projectFileExtension);

        end

        function resolvedLocation=getJavaFileForProjectLoadFromMATLABString(projectLocation)

            import matlab.internal.project.util.PathUtils;
            resolvedLocation=PathUtils.resolveFileAgainstFileSystem(projectLocation);




            if isempty(resolvedLocation)
                if(iIsPWDNameProjectLocation(projectLocation))
                    resolvedLocation=pwd;
                else
                    errorMsg=message('MATLAB:project:api:FileDoesNotExist',projectLocation);
                    exception=MException('MATLAB:project:api:FileDoesNotExist',...
                    '%s',errorMsg.getString());
                    import matlab.internal.project.util.exceptions.Prefs;
                    if(Prefs.ShortenStacks)
                        exception.throwAsCaller();
                    else
                        exception.rethrow();
                    end
                end
            end

            resolvedLocation=java.io.File(resolvedLocation);
        end

    end

end

function javaFile=iGetJavaFile(fileLocation)
    if isa(fileLocation,'java.io.File')
        javaFile=fileLocation;
    else
        javaFile=java.io.File(java.lang.String(fileLocation));
    end
end

function isPWDProjectLocation=iIsPWDNameProjectLocation(projectLocation)




    import matlab.internal.project.util.PathUtils;
    parentFolder=fileparts(pwd);


    if(strcmp(parentFolder,pwd))
        isPWDProjectLocation=false;
        return;
    end

    isPWDProjectLocation=PathUtils.areFileSystemPathsEqual(pwd,...
    fullfile(parentFolder,projectLocation)...
    );

end
