function linkedItemsHandles=getLinkedItemsInSSRefInstance(ssRefDiagram,mainModel)








    reqData=slreq.data.ReqData.getInstance;
    cLinkSet=reqData.getLinkSet(ssRefDiagram);


    linkedItemsHandles=zeros(64,1);
    currentIndex=1;
    if dig.isProductInstalled('Simulink')&&bdIsLoaded(ssRefDiagram)
        if~isempty(cLinkSet)
            linkedItems=cLinkSet.getLinkedItems();
            for i=1:length(linkedItems)
                cLinkedItem=linkedItems(i);
                ssRefItemId=[ssRefDiagram,cLinkedItem.id];
                instances=rmisl.getSSRefInstanceFromSourceItemInModel(ssRefItemId,mainModel);
                for index=1:length(instances)
                    cInstance=instances(index);
                    if currentIndex>length(linkedItemsHandles)

                        linkedItemsHandles(length(linkedItemsHandles)+1:length(linkedItemsHandles)*2)=[];
                    end
                    linkedItemsHandles(currentIndex)=cInstance;
                    currentIndex=currentIndex+1;
                end
            end
        end
    end

    linkedItemsHandles(currentIndex:end)=[];
end
