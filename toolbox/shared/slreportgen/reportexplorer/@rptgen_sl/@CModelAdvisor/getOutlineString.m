function olstring=getOutlineString(thisComp)



























    olstring=getName(thisComp);












    cInfo='';

    if thisComp.ReuseReport
        pReuseReport='true';
    else
        pReuseReport='false';
    end






    if~isempty(cInfo)
        olstring=[olstring,' - ',cInfo];
    end

