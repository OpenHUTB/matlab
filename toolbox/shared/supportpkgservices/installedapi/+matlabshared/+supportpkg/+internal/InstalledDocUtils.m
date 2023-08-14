classdef InstalledDocUtils




    properties(Constant)
        PROPERTIES_FILE="doccenter.properties";
        HELP_BASE=fullfile("help","supportpkg");
    end


    methods(Access=public,Static)
        function docInfo=getInstalledDocInfo(spRoot)





            docInfo=[];


            allHelpDirs=matlabshared.supportpkg.internal.InstalledDocUtils.getAllHelpDirs(spRoot);

            if isempty(allHelpDirs)
                return;
            end

            for i=1:numel(allHelpDirs)
                currentHelpDir=allHelpDirs(i);
                helpDirInfo=matlabshared.supportpkg.internal.InstalledDocUtils.getSpDataFromHelpDir(currentHelpDir);
                docInfo=[docInfo;helpDirInfo];
            end

        end
    end

    methods(Access=private,Static)

        function helpDirs=getAllHelpDirs(spRoot)
            helpDirs=[];




            if isempty(spRoot)||~exist(spRoot,'dir')
                return;
            end
            dirToSearch=fullfile(spRoot,matlabshared.supportpkg.internal.InstalledDocUtils.HELP_BASE);
            dirContents=dir(dirToSearch);


            helpDirs=dirContents([dirContents.isdir]);


            helpDirNames=convertCharsToStrings({helpDirs.name});


            helpDirs=helpDirs(helpDirNames~="."&helpDirNames~="..");
        end


        function spHelpData=getSpDataFromHelpDir(helpDir)
            spHelpData=[];

            fileToRead=fullfile(helpDir.folder,helpDir.name,matlabshared.supportpkg.internal.InstalledDocUtils.PROPERTIES_FILE);




            if~exist(fileToRead,'file')
                return;
            end

            fileContents=string(fileread(fileToRead));
            allLines=fileContents.splitlines();
            displayName=allLines(allLines.startsWith("displayname:")).extractAfter("displayname:");
            baseShortName=allLines(allLines.startsWith("baseshortname:")).extractAfter("baseshortname:");
            pathFromDocRoot=allLines(allLines.startsWith("pathfromdocroot:")).extractAfter("pathfromdocroot:");

            spHelpData=struct("SupportPackageHelpRoot",fullfile(helpDir.folder,helpDir.name),...
            "DisplayName",displayName,...
            "BaseShortName",baseShortName,...
            "PathFromDocRoot",pathFromDocRoot);
        end


    end
end