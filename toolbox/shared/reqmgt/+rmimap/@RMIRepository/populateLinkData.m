function populateLinkData(link)





    dependeeNode=link.dependeeNode;
    if isa(dependeeNode,'rmidd.Root')
        destType=dependeeNode.getProperty('source');
    else
        destType=dependeeNode.root.getProperty('source');
    end
    link.setProperty('source',destType);

    if isa(link.dependentNode,'rmidd.Root')
        srcUrl=link.dependentNode.url;
        link.setProperty('dependentId','');
    else
        srcUrl=link.dependentNode.root.url;
        link.setProperty('dependentId',link.dependentNode.id);
    end
    link.setProperty('dependentUrl',srcUrl);

    if isa(dependeeNode,'rmidd.Root')
        destUrl=dependeeNode.url;
        link.setProperty('dependeeId','');
    else
        destUrl=dependeeNode.root.url;
        link.setProperty('dependeeId',dependeeNode.id);
    end
    link.setProperty('dependeeUrl',destUrl);
end
