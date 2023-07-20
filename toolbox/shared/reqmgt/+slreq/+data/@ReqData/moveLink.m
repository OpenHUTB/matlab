function wasMoved=moveLink(this,link,position)






    if isa(link,'slreq.data.Link')
        mfLink=this.getModelObj(link);
    elseif isa(link,'slreq.datamodel.Link')
        mfLink=link;
    else
        error('moveLink(): invalid input of type %s',class(link));
    end
    sourceItem=mfLink.source;
    allLinks=sourceItem.outgoingLinks;


    if allLinks(position).sid==mfLink.sid
        wasMoved=false;
    else
        allLinks.remove(mfLink);
        allLinks.insertAt(mfLink,position);
        wasMoved=true;
    end
end
