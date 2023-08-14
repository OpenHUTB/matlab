function disconnectIncomingLinks(this,reqSetObj)









    reqSet=this.getModelObj(reqSetObj);
    reqs=reqSet.items.toArray;
    for n=1:length(reqs)
        reqs(n).references.clear();
    end
end
