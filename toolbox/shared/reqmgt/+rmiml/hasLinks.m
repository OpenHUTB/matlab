function result=hasLinks(sid,filters)




    if nargin==1
        filters=[];
    end

    linkedRanges=slreq.utils.getLinkedRanges(sid);
    for i=1:numel(linkedRanges)
        if slreq.utils.textRangeHasLinks(linkedRanges(i),filters)
            result=true;
            return;
        end
    end
    result=false;

end

