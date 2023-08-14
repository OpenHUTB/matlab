function filePathUpdate(this,mfLinkSet,artifactPath,linkFilePath)%#ok<INUSL>







    mfLinkSet.filepath=linkFilePath;


    storedUri=mfLinkSet.artifactUri;
    [~,storedName,storedExt]=fileparts(strrep(storedUri,'\','/'));
    [givenDir,givenName,givenExt]=fileparts(strrep(artifactPath,'\','/'));
    givenName=removeTildaExt(givenName);

    if strcmp(givenExt,'.slmx')



        givenExt='';
        artifactPath=givenName;
    end
    if strcmp(storedUri,artifactPath)
        return;
    elseif strcmp(givenName,storedName)&&isResolvedPath(storedUri)
        return;
    else

        [linksFileDir,linksFileName]=fileparts(linkFilePath);
        if strcmp(givenName,storedName)
            if isempty(givenExt)&&isempty(storedExt)

            elseif isempty(givenExt)




                mfLinkSet.artifactUri=findOfflineArtifactFile(linksFileDir,givenName,storedExt);
            elseif isempty(storedExt)


                mfLinkSet.artifactUri=artifactPath;
            elseif strcmp(storedExt,givenExt)


                mfLinkSet.artifactUri=fullfile(givenDir,[givenName,storedExt]);
            else



                throwAsCaller(MException(message('Slvnv:slreq:ArtifactMismatch',artifactPath,storedUri)));
            end

        else





            if strcmp(mfLinkSet.name,'_linkset')&&strcmp(mfLinkSet.domain,'linktype_rmi_simulink')
                mfLinkSet.artifactUri=artifactPath;
            else
                mfLinkSet.artifactUri=findRenamedArtifactFile(artifactPath,storedUri,linksFileName);

                [~,mfLinkSet.name]=fileparts(mfLinkSet.artifactUri);
            end
        end
    end
end

function tf=isResolvedPath(storedUri)
    shortNameExt=slreq.uri.getShortNameExt(storedUri);
    tf=strcmp(which(shortNameExt),storedUri);
end

function out=removeTildaExt(in)
    x=find(in=='~');
    if isempty(x)
        out=in;
    else
        out=in(1:(x(end)-1));
    end
end

function pathToArtifactFile=findOfflineArtifactFile(linksFileDir,wantedName,storedExt)

    expectedArtifactPath=fullfile(linksFileDir,[wantedName,storedExt]);
    if exist(expectedArtifactPath,'file')>0

        pathToArtifactFile=expectedArtifactPath;
    else

        locatedPath=which([wantedName,storedExt]);
        if~isempty(locatedPath)


            pathToArtifactFile=locatedPath;
        else


            pathToArtifactFile=[wantedName,storedExt];
        end
    end
end

function pathToArtifactFile=findRenamedArtifactFile(artifactPath,storedUri,linksFileName)



    checkForName=exist(artifactPath,'file');
    if checkForName==2||checkForName==4
        if rmiut.isCompletePath(artifactPath)
            pathToArtifactFile=artifactPath;
        else
            pathToArtifactFile=which(artifactPath);
        end
        return;
    end






    if endsWith(linksFileName,'_dd')
        linksFileName(end-2:end)=[];
        if exist([linksFileName,'.sldd'],'file')
            pathToArtifactFile=which([linksFileName,'.sldd']);
            return;
        end
    elseif endsWith(linksFileName,'_st')
        linksFileName(end-2:end)=[];
        if exist([linksFileName,'.mldatx'],'file')
            pathToArtifactFile=which([linksFileName,'.mldatx']);
            return;
        end
    end






    if~ispc

        pathToArtifactFile=strrep(storedUri,'\','/');
    else
        pathToArtifactFile=storedUri;
    end

    rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactMismatch',artifactPath,storedUri);
end


