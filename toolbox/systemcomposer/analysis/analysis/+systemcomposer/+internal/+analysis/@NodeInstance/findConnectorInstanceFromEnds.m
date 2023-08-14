function instance=findConnectorInstanceFromEnds(~,source,dest)




    outgoing=source.connector.toArray;
    incoming=dest.connector.toArray;

    instance=outgoing(ismember(outgoing,incoming));
end
