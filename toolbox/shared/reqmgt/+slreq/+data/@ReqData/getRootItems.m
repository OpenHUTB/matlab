function reqObjs=getRootItems(this,reqSet)







    modelReqSet=this.getModelObj(reqSet);
    rootItems=modelReqSet.rootItems.toArray();

    if~isempty(rootItems)

        reqObjs(size(rootItems))=slreq.data.Requirement();
        for i=1:length(rootItems)
            childObj=this.wrap(rootItems(i));
            reqObjs(i)=childObj;
        end
    else
        reqObjs=slreq.data.Requirement.empty;
    end
end
