function linkData=getData(this,srcName,elementId)

    linkData=[];

    if~ischar(srcName)

        [~,srcName]=rmisl.modelFileParts(srcName);
    end
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);

    if isempty(srcRoot)
        return;
    else
        elt=rmimap.RMIRepository.getNode(srcRoot,elementId);

        if~isempty(elt)
            links=elt.dependeeLinks;

            if links.size>0
                emptyReqs=rmi.createEmptyReqs(links.size);
                linkData=emptyReqs(:);

                for i=1:links.size
                    linkData(i)=rmimap.RMIRepository.populateReqData(links.at(i),linkData(i));
                end
            end
        end
    end
end


