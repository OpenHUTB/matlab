function conns=getConnectors(this,linkSetData)







    conns=slreq.data.Connector.empty;
    modelLinkSet=this.getModelObj(linkSetData);
    items=modelLinkSet.items.toArray;
    for i=1:numel(items)
        item=items(i);
        links=item.outgoingLinks.toArray;
        for j=1:length(links)
            link=links(j);
            connector=link.connector;
            diagramConnector=link.diagramConnector;
            if~isempty(connector)
                conns(end+1)=connector;%#ok<AGROW>
            elseif~isempty(diagramConnector)
                conns(end+1)=diagramConnector;%#ok<AGROW>
            end
        end
    end
end
