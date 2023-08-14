function[artifact,id]=getExternalLinkArgs(linkedItem)

    switch class(linkedItem)

    case 'slreq.data.SourceItem'
        [artifact,id]=fromSourceItem(linkedItem);

    otherwise

        [isSf,objH,msg]=rmi.resolveobj(linkedItem);
        if isempty(objH)
            error('rmidoors.getExternalLinkArgs(): unsupported argument of type %s \n%s',...
            class(linkedItem),msg);
        else

            [artifact,id]=rmidata.getRmiKeys(objH,isSf);
            [~,~,slExt]=fileparts(get_param(artifact,'FileName'));
            artifact=[artifact,slExt];
        end
    end

end

function[artifact,id]=fromSourceItem(linkedItem)

    [~,aName,aExt]=fileparts(linkedItem.artifactUri);
    artifact=[aName,aExt];
    id=linkedItem.id;




    if linkedItem.isTextRange()
        textNodeId=linkedItem.getTextNodeId;
        if~isempty(textNodeId)
            artifact=[aName,textNodeId];
        end
    end
end



