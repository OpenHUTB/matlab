function[subRootsArray,subRootIdx]=extractSubRoots(this,parentRoot)








    subRootsArray={};
    subRootIdx=[];
    parentName=parentRoot.url;
    nodeDataSize=parentRoot.nodeData.size;
    for i=1:nodeDataSize
        ndData=parentRoot.nodeData.at(i);
        if rmimap.RMIRepository.isSimulinkSubroot(ndData)

            newSubRoot=rmidd.Root(this.graph);
            this.graph.roots.append(newSubRoot);
            newSubRoot.url=[parentName,ndData.getValue('id')];
            if strcmp(ndData.getValue('source'),'linktype_rmi_matlab')

                rmiml.RmiMlData.getInstance.register(newSubRoot.url);
            else











            end

            subRootsArray{end+1}=newSubRoot;%#ok<AGROW>
            subRootIdx(end+1)=i;%#ok<AGROW>
        end
    end
    if~isempty(subRootsArray)
        this.dealLinkData(parentRoot,subRootsArray);
    end
end


