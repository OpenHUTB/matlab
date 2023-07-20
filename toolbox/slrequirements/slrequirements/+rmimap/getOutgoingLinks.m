function links=getOutgoingLinks(srcName,nodeId)


    links=rmimap.RMIRepository.getInstance.getData(srcName,nodeId);

end
