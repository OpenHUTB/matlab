





function yesno=hasLinks(artifact)

    yesno=false;

    if~slreq.data.ReqData.exists()



        return;
    end

    if ischar(artifact)&&any(artifact=='.')
        artifactPath=artifact;
        domain=slreq.utils.getDomainLabel(artifact);
    else

        artifactPath=get_param(artifact,'FileName');
        domain='linktype_rmi_simulink';
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath,domain);
    if~isempty(linkSet)
        items=linkSet.getLinkedItems();
        for i=1:length(items)
            links=items(i).getLinks;
            if~isempty(links)
                yesno=true;
                return;
            end
        end
    end

end
