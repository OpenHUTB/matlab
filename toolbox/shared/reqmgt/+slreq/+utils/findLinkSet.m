function linkSet=findLinkSet(artifact)




    if~ischar(artifact)

        artifactPath=get_param(artifact,'FileName');
    else

        [aDir,~,aExt]=fileparts(artifact);
        if isempty(aDir)||isempty(aExt)
            artifactPath=which(artifact);
            if isempty(artifactPath)

                artifactPath=artifact;
            end
        else
            artifactPath=artifact;
        end
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);

end