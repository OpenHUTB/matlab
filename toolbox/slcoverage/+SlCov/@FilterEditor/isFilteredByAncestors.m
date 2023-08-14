function[res,prop]=isFilteredByAncestors(this,ssid)




    res=false;
    allAncs=this.getAncestors(ssid);
    prop=[];
    topIdx=[];
    for idx=1:numel(allAncs)
        [res,prop]=this.isFilteredIntern(allAncs{idx});
        if res
            topIdx=idx;
            res=true;
            break;
        end
    end
    if res

        this.cacheIt(ssid,res,prop);
        for idx=1:topIdx
            this.cacheIt(allAncs{topIdx},res,prop);
        end
    end