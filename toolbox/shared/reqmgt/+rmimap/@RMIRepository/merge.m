function merge(this,srcRoot)








    nodeDataCount=srcRoot.nodeData.size;
    for i=2:nodeDataCount
        ndData=srcRoot.nodeData.at(i);
        if strcmp(ndData.getValue('source'),'linktype_rmi_matlab')


            id=ndData.getValue('id');
            mfNode=rmimap.RMIRepository.getNode(srcRoot,id);
            if isempty(mfNode)
                mfNode=this.addNode(srcRoot,id);
                mfNode.data=ndData;
            end
        end
    end



    totalLinkDataItems=srcRoot.linkData.size;
    for i=1:totalLinkDataItems
        linkDatum=srcRoot.linkData.at(i);


        dependentId=linkDatum.getValue('dependentId');
        if isempty(dependentId)

            dependentNode=srcRoot;
        else
            dependentNode=rmimap.RMIRepository.getNode(srcRoot,dependentId);
            if isempty(dependentNode)
                dependentNode=this.addNode(srcRoot,dependentId);
            end
        end


        this.appendLink(srcRoot,dependentNode,linkDatum,true);
    end
end


