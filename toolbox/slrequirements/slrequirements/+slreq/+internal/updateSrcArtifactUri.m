function success=updateSrcArtifactUri(docRefNode,updatedLocation,treatAsFile)








    success=false;


    if isa(docRefNode,'slreq.data.Requirement')
        if~docRefNode.isImportRootItem()
            error(message('Slvnv:slreq:TopLevelReferenceOnly','updateSrcFileLocation()'));
        end
        reqSet=docRefNode.getReqSet();
        origUri=docRefNode.artifactUri;
        domainLabel=docRefNode.domain;
        topNodeId=docRefNode.customId;
        group=slreq.data.ReqData.getInstance.findGroupInReqSet(reqSet,origUri,domainLabel);

    elseif isa(docRefNode,'slreq.datamodel.Group')
        group=docRefNode;
        reqSet=group.requirementSet;
        origUri=group.artifactUri;
        domainLabel=group.domain;
        topNodeId=getImportNodeCustomId(reqSet,origUri);

    else
        error(message('Slvnv:slreq:TopLevelReferenceOnly','updateSrcFileLocation()'));
    end

    if nargin<3
        treatAsFile=true;
    end

    reqSetLocation=fileparts(reqSet.filepath);
    linkType=rmi.linktype_mgr('resolveByRegName',domainLabel);
    if isempty(linkType)




        isFile=treatAsFile;
    else
        isFile=linkType.isFile;
    end

    if isFile
        if rmiut.isCompletePath(origUri)
            origLocation=origUri;
        else
            origLocation=rmiut.absolute_path(origUri,reqSetLocation);
        end
    else
        origLocation=origUri;
    end

    if nargin<2||isempty(updatedLocation)
        if isFile

            if isempty(linkType)
                [~,~,docExt]=fileparts(origUri);
                docExtStr=['*',docExt];
                docTypeStr=[docExtStr,' files'];
            else
                allExtensions=join(linkType.Extensions,';*');
                docExtStr=['*',allExtensions{1}];
                docTypeStr=linkType.Label;
            end
            instructionText=getString(message('Slvnv:reqmgt:SpecifyFileLocation'));
            [filename,pathname]=uigetfile({docExtStr,docTypeStr},instructionText,origLocation);
            if~ischar(filename)
                return;
            end
            updatedLocation=fullfile(pathname,filename);





            slreq.uri.ResourcePathHandler.setInteractive(true);
            clp=onCleanup(@()slreq.uri.ResourcePathHandler.setInteractive(false));
        else
            if~isempty(linkType.BrowseFcn)
                updatedLocation=linkType.BrowseFcn();
            else
                error('BrowseFcn() not defined for type %s',domainLabel);
            end
        end
    end

    if strcmp(updatedLocation,origLocation)
        return;
    end

    if isFile
        newUri=slreq.uri.getPreferredPath(updatedLocation,reqSetLocation,origUri);
    else
        newUri=updatedLocation;
    end


    group.artifactUri=newUri;
    success=true;






    [isReqIF,isLegacyReqIF]=slreq.uri.isImportedReqIF(domainLabel);
    isCurrentReqIF=isReqIF&&~isLegacyReqIF;
    if isReqIF&&~isLegacyReqIF

        return;

    elseif~isFile

        slreq.internal.updateTopLevelItems(reqSet,origUri,newUri,false);
        slreq.internal.duplicateImportOptionsFilesForArtifact(reqSet,origUri,newUri,false);

    elseif usingFilenameForCustomID(topNodeId,origUri)&&~isCurrentReqIF
        slreq.internal.updateTopLevelItems(reqSet,origUri,newUri,true);


        slreq.internal.duplicateImportOptionsFilesForArtifact(reqSet,origUri,newUri,true);







        if~isFile||exist(origLocation,'file')~=2

            slreq.data.ReqData.getInstance.updateDestUriInIncomingLinks(group,updatedLocation);
        end
    end
end

function tf=usingFilenameForCustomID(topNodeId,origFileName)


    if isempty(topNodeId)
        tf=false;
    else
        [~,shortFileName]=fileparts(origFileName);
        tf=strncmp(topNodeId,shortFileName,length(shortFileName));
    end
end

function customId=getImportNodeCustomId(mfReqSet,artifactUri)











    rootItems=mfReqSet.rootItems.toArray();
    for i=1:numel(rootItems)
        oneItem=rootItems(i);
        if isa(oneItem,'slreq.datamodel.ExternalRequirement')
            if strcmp(oneItem.group.artifactUri,artifactUri)
                customId=oneItem.customId;
                return;
            end
        end
    end
    customId='';
end


