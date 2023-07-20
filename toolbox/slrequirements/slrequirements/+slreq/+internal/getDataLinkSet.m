function dataLinkSet=getDataLinkSet(srcInfo)


    if isa(srcInfo,'slreq.LinkSet')
        linkSet=srcInfo;
    else
        if~ischar(srcInfo)

            srcInfo=get_param(srcInfo,'Name');
        end
        [~,srcInfo]=fileparts(srcInfo);
        linkSet=slreq.find('type','LinkSet','Name',srcInfo);
        if isempty(linkSet)
            error(message('Slvnv:slreq:NoLinkSetFor',srcInfo));
        end
    end

    dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(linkSet.Artifact,linkSet.Domain);
end
