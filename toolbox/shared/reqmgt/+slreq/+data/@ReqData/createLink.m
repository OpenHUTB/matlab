function link=createLink(this,linkSource,linkInfo)





    try
        link=slreq.datamodel.Link(this.model);
        link.source=linkSource;
        link.description=linkInfo.description;
        link.revision=0;


        link.linkedVersion=getString(message('Slvnv:slreq:NoVersionAvaiable'));
        slreq.data.ReqData.updateModificationInfo(link);

        ref=slreq.datamodel.Reference(this.model);
        ref.domain=linkInfo.reqsys;
        ref.artifactUri=linkInfo.doc;
        ref.artifactId=linkInfo.id;


        ref.linkedVersion=getString(message('Slvnv:slreq:NoVersionAvaiable'));

        this.populateReqSetUri(ref);



        link.dest=ref;


        if isfield(linkInfo,'linked')&&~linkInfo.linked
            link.setProperty('isSurrogateLink','1');
        end
        if isfield(linkInfo,'keywords')&&~isempty(linkInfo.keywords)
            this.setKeywords(link,linkInfo.keywords);
        end


        srcPath=linkSource.artifact.artifactUri;
        this.resolveReference(ref,srcPath);




        link.typeName=slreq.custom.LinkType.Relate.getTypeName();
    catch ME
        if~isempty(link)
            link.destroy;
        end

        ex=MException(message('Slvnv:slreq:InvalidInputArgument'));
        throwAsCaller(ex);
    end
end
