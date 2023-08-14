function retVal=applyChildren(hThis)




    retVal=true;
    nItems=length(hThis.Items);
    for idx=1:nItems
        retStat=hThis.Items(idx).Apply();
        if(retStat==false)
            retStat=false;
            idStr=sprintf('%s.realizeChildren',class(hThis));
            error(idStr,'Failed to Apply item(%d): ''%s''',idx,class(hThis.Items(idx)));
        end
    end
