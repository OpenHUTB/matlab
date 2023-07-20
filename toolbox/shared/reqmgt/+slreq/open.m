
























function reqSetApi=open(reqSet)



    argType=class(reqSet);
    switch argType

    case 'slreq.ReqSet'
        reqSetApi=reqSet;

    case 'char'

        [fpath,fname,fext]=fileparts(reqSet);
        if strcmp(fext,'.slmx')||strcmp(fext,'.req')
            openLinkSet(fpath,fname,fext);
            return;
        end
        reqSetFile=ensureExtension(reqSet);
        reqSetApi=loadOrError(reqSetFile);


    case 'string'
        reqSetFile=ensureExtension(convertStringsToChars(reqSet));
        reqSetApi=loadOrError(reqSetFile);

    otherwise
        error(message('Slvnv:rmipref:InvalidArgument',argType));
    end

    if isempty(reqSetApi)
        return;
    end



    if slreq.editor()

        dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetApi.Name);
        dasReqSet=dataReqSet.getDasObject();
        mgr=slreq.app.MainManager.getInstance();
        re=mgr.requirementsEditor;
        re.setSelectedObject(dasReqSet);
        re.expand(dasReqSet);
    else


    end

    if isa(reqSet,'char')
        [~,~,fExt]=fileparts(reqSet);
        if strcmp(fExt,'.slx')&&~isempty(dataReqSet)


            parentModel=reqSet;
            open_system(parentModel);
        end
    end
end

function rsName=ensureExtension(rsName)
    [~,~,fExt]=fileparts(rsName);
    if isempty(fExt)||(~strcmp(fExt,'.slreqx')&&~strcmp(fExt,'.slx'))
        rsName=[rsName,'.slreqx'];
    end
end

function loaded=loadOrError(reqSet)
    try
        [~,~,fExt]=fileparts(reqSet);
        if strcmp(fExt,'.slx')
            [~,loaded]=slreq.load(reqSet);
        else
            loaded=slreq.load(reqSet);
        end
    catch ex
        errordlg(ex.message,getString(message('Slvnv:slreq_uri:FailedToOpen')));
        loaded=[];
    end
end


function openLinkSet(fpath,fname,fext)



    info=slreq.opc.extractMetaInfo(fullfile(fpath,[fname,fext]));
    if isfield(info,'artifactUri')
        artifact=info.artifactUri;
    else
        errordlg(getString(message('Slvnv:slreq:NoAssociatedArtifact',[fname,fext])),...
        getString(message('Slvnv:slreq:OpenLinkSet')));
        return;
    end

    artifactPath=artifact;
    [apath,aname,aext]=fileparts(artifact);
    if~isfile(artifact)
        artifactPath=which(aname+aext);
    end

    if isfile(artifactPath)
        answer=questdlg(...
        getString(message('Slvnv:slreq:OpenAssociatedArtifact',aname+aext)),...
        getString(message('Slvnv:slreq:OpenLinkSet')),...
        getString(message('Slvnv:slreq:PlainOpen')),...
        getString(message('Slvnv:slreq:Cancel')),...
        getString(message('Slvnv:slreq:PlainOpen')));
        if strcmp(answer,getString(message('Slvnv:slreq:PlainOpen')))
            open(artifactPath);
        end
    else
        errordlg(getString(message('Slvnv:slreq:AssociatedArtifactNotFound',aname+aext)),...
        getString(message('Slvnv:slreq:OpenLinkSet')));
    end
end
