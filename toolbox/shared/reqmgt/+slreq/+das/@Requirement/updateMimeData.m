function updateMimeData(this,dasObjs)










    kvPairsList=GLEE.ByteArrayList;

    if isempty(dasObjs)


        this.mimeData=kvPairsList;
        return;
    end

    if this.isJustification



        this.mimeData=kvPairsList;
        return;
    end

    reqSet=this.RequirementSet;
    reqSetName=GLEE.ByteArrayPair(GLEE.ByteArray('ReqSetName'),GLEE.ByteArray(reqSet.Name));
    kvPairsList.add(reqSetName);

    sid=GLEE.ByteArrayPair(GLEE.ByteArray('SID'),GLEE.ByteArray(this.SID));
    kvPairsList.add(sid);




    summary=GLEE.ByteArrayPair(GLEE.ByteArray('Summary'),GLEE.ByteArray(sprintf('%s: %s',this.Id,this.Summary)));
    kvPairsList.add(summary);

    description=GLEE.ByteArrayPair(GLEE.ByteArray('Description'),GLEE.ByteArray(this.Description));
    kvPairsList.add(description);

    rationale=GLEE.ByteArrayPair(GLEE.ByteArray('Rationale'),GLEE.ByteArray(this.Rationale));
    kvPairsList.add(rationale);

    size=slreq.app.MarkupManager.DefaultMarkupSize;
    width=GLEE.ByteArrayPair(GLEE.ByteArray('Width'),GLEE.ByteArray(num2str(size(1))));
    kvPairsList.add(width);
    height=GLEE.ByteArrayPair(GLEE.ByteArray('Height'),GLEE.ByteArray(num2str(size(2))));
    kvPairsList.add(height);

    clientDefName=GLEE.ByteArrayPair(GLEE.ByteArray('ClientDefName'),GLEE.ByteArray(slreq.app.MarkupManager.clientDefName));
    kvPairsList.add(clientDefName);

    cItemId='';



    for n=1:length(dasObjs)
        if isempty(cItemId)
            cItemId=dasObjs(n).dataUuid;
        else
            cItemId=[cItemId,',',dasObjs(n).dataUuid];%#ok<AGROW>
        end
    end

    clientItemId=GLEE.ByteArrayPair(GLEE.ByteArray('ClientItemId'),GLEE.ByteArray(cItemId));
    kvPairsList.add(clientItemId);


    label=upper(slreq.app.LinkTypeManager.getForwardName(slreq.custom.LinkType.Implement));
    defaultConnectorLabel=GLEE.ByteArrayPair(GLEE.ByteArray('DefaultConnectorLabel'),GLEE.ByteArray(label));
    kvPairsList.add(defaultConnectorLabel);

    sourceEndpointShape=GLEE.ByteArrayPair(GLEE.ByteArray('SourceEndpointShape'),GLEE.ByteArray(num2str(diagram.markup.EndpointShape.Arrow)));
    kvPairsList.add(sourceEndpointShape);

    targetEndpointShape=GLEE.ByteArrayPair(GLEE.ByteArray('TargetEndpointShape'),GLEE.ByteArray(num2str(diagram.markup.EndpointShape.Nothing)));
    kvPairsList.add(targetEndpointShape);

    this.mimeData=kvPairsList;
end
