function linkSet=getLinkSet(artifactPath,domain,doCreate)

    if nargin<3
        doCreate=false;
    end
    if~doCreate&&~slreq.data.ReqData.exists()
        linkSet=[];
        return;
    end

    [~,~,fExt]=fileparts(artifactPath);
    if exist(artifactPath,'file')~=2||isempty(fExt)
        artifactPath=resolveArtifactPath(artifactPath);
    end

    if nargin<2
        domain=slreq.utils.getDomainLabel(artifactPath);
    end

    r=slreq.data.ReqData.getInstance;


    linkSet=r.getLinkSet(artifactPath,domain);


    if isempty(linkSet)&&doCreate
        linkSet=r.createLinkSet(artifactPath,domain);

        if strcmp(domain,'linktype_rmi_data')

            rmide.registerCallback();
        end
    end
end

function out=resolveArtifactPath(in)


    fullPath=which(in);
    if~isempty(fullPath)
        out=fullPath;
    else


        reqSet=slreq.data.ReqData.getInstance.getReqSet(in);
        if~isempty(reqSet)
            out=reqSet.filepath;
        else
            out=in;
        end
    end
end

