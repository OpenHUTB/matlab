function textRange=addRangeItem(this,linkset,textItem,rangeId,range)






    textRange=slreq.datamodel.TextRange(this.model);


    textRange.id=slreq.utils.getLongIdFromShortId(textItem.id,rangeId);
    textRange.start=range(1);
    textRange.end=range(2);
    if reqmgt('rmiFeature','MLChangeTracking')
        textRange.revision=slreq.adapters.MATLABAdapter.getRevisionForRange(range(1),range(2),textItem);
    end
    linkset.items.add(textRange);
    textRange.textItem=textItem;

end
