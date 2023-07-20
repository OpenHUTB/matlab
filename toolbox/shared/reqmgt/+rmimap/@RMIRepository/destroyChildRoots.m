function destroyChildRoots(this,srcRoot)





    nodeDataLength=srcRoot.nodeData.size;
    for i=1:nodeDataLength
        ndData=srcRoot.nodeData.at(i);
        if rmimap.RMIRepository.isSimulinkSubroot(ndData)

            childId=[srcRoot.url,ndData.getValue('id')];
            childRoot=rmimap.RMIRepository.getRoot(this.graph,childId);
            if isempty(childRoot)







            else
                if strcmp(ndData.getValue('source'),'linktype_rmi_matlab')
                    rmiml.RmiMlData.getInstance.unregister(childRoot.url);
                end
                childRoot.destroy();
            end
        end
    end
end


