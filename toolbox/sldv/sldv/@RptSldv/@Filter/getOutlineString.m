function olstring=getOutlineString(thisComp)








    olstring=getName(thisComp);












    cInfo='';






    if~isempty(cInfo)
        olstring=[olstring,' - ',cInfo];
    end

