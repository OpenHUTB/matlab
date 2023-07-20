















function links=outLinks(srcInfo)

    links=slreq.Link.empty();

    if isempty(srcInfo)
        rmiut.warnNoBacktrace('Slvnv:slreq:InvalidInputArgument');
        return;
    end

    switch class(srcInfo)

    case 'struct'
        srcItem=getSrcItem(srcInfo);

    case{'slreq.data.SourceItem','slreq.data.TextRange'}

        srcItem=srcInfo;

    case 'slreq.TextRange'
        links=srcInfo.getLinks();
        return;

    otherwise

        srcStruct=slreq.utils.resolveSrc(srcInfo);
        srcItem=getSrcItem(srcStruct);
    end

    if~isempty(srcItem)
        dataLinks=srcItem.getLinks();
        for i=1:numel(dataLinks)
            links(end+1)=slreq.utils.dataToApiObject(dataLinks(i));%#ok<AGROW>
        end
    end

end

function dataSourceItem=getSrcItem(srcStruct)

    dataSourceItem=[];


    linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcStruct.artifact);
    if isempty(linkSet)
        return;
    end


    localId=srcStruct.id;

    if strcmp(srcStruct.domain,'linktype_rmi_slreq')&&...
        isfield(srcStruct,'sid')&&~isempty(srcStruct.sid)
        localId=num2str(srcStruct.sid);
    else


        if isfield(srcStruct,'parent')&&~isempty(srcStruct.parent)


            textItem=linkSet.getTextItem(srcStruct.parent);
            if~isempty(textItem)
                localId=slreq.utils.getLongIdFromShortId(textItem.id,srcStruct.id);
            end
        end
    end


    dataSourceItem=linkSet.getLinkedItem(localId);
end
