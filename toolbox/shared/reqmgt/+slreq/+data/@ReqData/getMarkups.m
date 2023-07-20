function markups=getMarkups(this,linkSetData)






    markups=slreq.data.Markup.empty();
    modelLinkSet=this.getModelObj(linkSetData);
    if modelLinkSet.markups.Size>0
        modelMarkups=modelLinkSet.markups.toArray;
        for i=1:length(modelMarkups)
            markups(end+1)=this.wrap(modelMarkups(i));%#ok<AGROW>
        end
    end
end
