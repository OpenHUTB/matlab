classdef ResourcePathHandler<handle



    properties(Access=private)
isEnabled
isInteractive
    end

    methods(Access=private)

        function this=ResourcePathHandler()
            this.isEnabled=true;
            this.isInteractive=false;
        end

    end

    methods(Static)

        function singletonHandler=getInstance()
            persistent handler;
            if isempty(handler)
                handler=slreq.uri.ResourcePathHandler();
            end
            singletonHandler=handler;
        end

        function fullPath=getFullPath(givenPath,refData)
            if rmiut.isCompletePath(givenPath)
                fullPath=givenPath;
            else
                refPath=slreq.uri.getReferencePath(refData);
                fullPath=slreq.uri.ResourcePathHandler.resolveFullPath(givenPath,refPath);
            end
        end

        function setInteractive(val)
            handler=slreq.uri.ResourcePathHandler.getInstance();
            handler.isInteractive=val;
        end

        function enable()
            slreq.uri.ResourcePathHandler.getInstance.setEnabled(true);
        end

        function disable()
            slreq.uri.ResourcePathHandler.getInstance.setEnabled(false);
        end

        function validatedPath=validatePath(givenPath,referencePath)







            validatedPath=givenPath;
            if isfile(slreq.internal.LinkUtil.extractArtifactUri(validatedPath))
                return;
            end
            givenFolder=fileparts(givenPath);
            isAbsolutePath=~isempty(givenFolder)&&rmiut.isCompletePath(givenFolder);
            if isAbsolutePath


                validatedPath=slreq.uri.getShortNameExt(givenPath);
                if isfile(slreq.internal.LinkUtil.extractArtifactUri(validatedPath))
                    return;
                end
                wasGivenRelativePath=false;
            else
                wasGivenRelativePath=~isempty(givenFolder);
            end


            constructedPath=fullfile(referencePath,givenPath);
            if wasGivenRelativePath

                constructedPath=rmiut.simplifypath(constructedPath,filesep);
            end
            if isfile(slreq.internal.LinkUtil.extractArtifactUri(constructedPath))
                validatedPath=constructedPath;
            end


        end

    end

    methods

        function preferredPath=getPreferredPath(this,givenPath,refData,storedUri)

            if nargin<4
                storedUri='';
            end

            if~this.isEnabled


                shortName=slreq.uri.getShortNameExt(givenPath);
                if~isempty(which(shortName))
                    preferredPath=shortName;
                else
                    preferredPath=slreq.uri.ResourcePathHandler.cleanupRelativePath(givenPath);
                end
                return;
            end


            pathPreference=rmipref('DocumentPathReference');



            refPath=slreq.uri.getReferencePath(refData);

            if~strcmp(pathPreference,'absolute')


                [givenFolder,fName,fExt]=fileparts(givenPath);
                shortName=[fName,fExt];
                if rmiut.cmp_paths(givenFolder,refPath)
                    preferredPath=shortName;
                    return;
                end
            end

            switch pathPreference

            case 'none'


                preferredPath=shortName;




                if isempty(which(shortName))

                    if this.isInteractive


                        preferredPath=slreq.uri.ResourcePathHandler.promptToRecoverWhenShortNameUnresolved(shortName,givenPath,refPath);
                        this.isInteractive=false;

                    else










                        preferredPath=slreq.uri.ResourcePathHandler.makeSrcRelativePath(givenPath,refPath);
                        if~strcmp(preferredPath,storedUri)


                            rmiut.warnNoBacktrace('Slvnv:slreq_uri:UnresolvedShortPath',shortName);






                            unwantedRelativePart=repmat(['..',filesep],1,5);
                            if contains(preferredPath,unwantedRelativePart)
                                preferredPath=givenPath;
                            end
                        end

                        if isempty(preferredPath)
                            preferredPath=givenPath;


                        else



                        end
                    end

                end

            case 'absolute'
                preferredPath=slreq.uri.ResourcePathHandler.resolveFullPath(givenPath,refPath);

            case 'pwdRelative'
                fullPath=slreq.uri.ResourcePathHandler.resolveFullPath(givenPath,refPath);
                if strncmp(fullPath,pwd,length(pwd))
                    preferredPath=strrep(fullPath,pwd,'.');
                else
                    preferredPath=rmiut.relative_path(fullPath,pwd);
                end
                preferredPath=slreq.uri.ResourcePathHandler.cleanupRelativePath(preferredPath);

            case 'modelRelative'
                preferredPath=slreq.uri.ResourcePathHandler.makeSrcRelativePath(givenPath,refPath);

            otherwise


                error('invalid case in slreq.utils.userPreferredPath(): %s',pathPreference);
            end

        end

    end

    methods(Access=private)

        function setEnabled(this,val)
            this.isEnabled=val;
        end

    end

    methods(Static,Access=private)

        function result=promptToRecoverWhenShortNameUnresolved(shortName,givenPath,refPath)





            fullPathBasedOnRef=fullfile(refPath,shortName);
            fullPathBasedOnPWD=fullfile(pwd,shortName);
            if exist(fullPathBasedOnRef,'file')>0
                fullPath=fullPathBasedOnRef;
                relativePath=shortName;
            elseif exist(fullPathBasedOnPWD,'file')>0
                fullPath=fullPathBasedOnPWD;
                relativePath=slreq.uri.ResourcePathHandler.makeSrcRelativePath(fullPath,refPath);
            else
                [relativePath,fullPath]=slreq.uri.ResourcePathHandler.makeSrcRelativePath(givenPath,refPath);
            end

            if isempty(fullPath)||exist(fullPath,'file')==0

                error(message('Slvnv:slreq_uri:UnresolvedShortPath',shortName));
            else
                neededFolder=fileparts(fullPath);
                response=questdlg(...
                getString(message('Slvnv:slreq_uri:UnresolvedShortPathFolder',shortName,neededFolder)),...
                getString(message('Slvnv:slreq_uri:UnresolvedShortPathTitle')),...
                getString(message('Slvnv:slreq_uri:UseRelativePath')),...
                getString(message('Slvnv:slreq_uri:UseRelativePathAlways')),...
                getString(message('Slvnv:slreq_uri:AddToMatlabPath')),...
                getString(message('Slvnv:slreq_uri:UseRelativePath')));
                if isempty(response)
                    error(message('Slvnv:slreq_uri:UnresolvedShortPath',shortName));
                else
                    switch response
                    case getString(message('Slvnv:slreq_uri:UseRelativePathAlways'))
                        result=relativePath;
                        rmipref('DocumentPathReference','modelRelative');
                    case getString(message('Slvnv:slreq_uri:AddToMatlabPath'))
                        addpath(neededFolder);

                        msgbox(...
                        getString(message('Slvnv:slreq_uri:MatlabPathUpdatedMsg',neededFolder)),...
                        getString(message('Slvnv:slreq_uri:MatlabPathUpdatedTitle')));
                        result=shortName;
                    otherwise

                        result=relativePath;
                    end
                end
            end
        end

        function[relativePath,fullPath]=makeSrcRelativePath(givenPath,refPath)
            fullPath=slreq.uri.ResourcePathHandler.resolveFullPath(givenPath,refPath);
            if isempty(fullPath)

                relativePath='';
                return;
            end
            if strncmp(fullPath,refPath,length(refPath))
                relativePath=strrep(fullPath,refPath,'.');
            else
                relativePath=rmiut.relative_path(fullPath,refPath);
            end
            relativePath=slreq.uri.ResourcePathHandler.cleanupRelativePath(relativePath);
        end

        function relPath=cleanupRelativePath(relPath)
            if rmiut.isCompletePath(relPath)
                return;
            end

            if relPath(1)=='.'&&any(relPath(2)=='/\')
                relPath(1:2)=[];
            end



            relPath(relPath=='\')='/';
        end

        function fullPath=resolveFullPath(relPath,refPath)
            if rmiut.isCompletePath(relPath)
                fullPath=relPath;
            else

                fullPath=which(relPath);

                if isempty(fullPath)

                    fullPath=slreq.uri.ResourcePathHandler.checkLocalPathRelativeToFolder(relPath,refPath);
                end

                if isempty(fullPath)

                    myPwd=pwd();
                    if~strcmp(refPath,myPwd)&&~isempty(fileparts(relPath))
                        fullPath=slreq.uri.ResourcePathHandler.checkLocalPathRelativeToFolder(relPath,myPwd);
                    end
                end
            end
        end

        function fullPath=checkLocalPathRelativeToFolder(relPath,refPath)
            fullPath='';
            constructedPath=fullfile(refPath,relPath);
            cleanedPath=rmiut.simplifypath(constructedPath,filesep);
            if isfile(cleanedPath)
                fullPath=cleanedPath;
            end
        end

    end
end


