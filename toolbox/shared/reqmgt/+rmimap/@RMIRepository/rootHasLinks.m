function[hasLinks,hasLinkedItems]=rootHasLinks(this,rootName)




    hasLinks=false;


    if~ischar(rootName)


        [~,rootName]=rmisl.modelFileParts(rootName);
    end
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);


    if isempty(srcRoot)
        error(message('Slvnv:rmigraph:UnmatchedModelName',rootName));
    else

        myLinks=srcRoot.links;
        for i=1:myLinks.size
            link=myLinks.at(i);
            if~strcmp(link.getProperty('linked'),'0')
                hasLinks=true;
                hasLinkedItems=true;
                return;
            end
        end
    end




    hasLinkedItems=false;
    for i=2:srcRoot.nodeData.size
        ndData=srcRoot.nodeData.at(i);
        if rmimap.RMIRepository.isSimulinkSubroot(ndData)
            subRootName=[rootName,ndData.getValue('id')];
            if this.rootHasLinks(subRootName)
                hasLinks=true;
                return;
            end
        end
    end
end


