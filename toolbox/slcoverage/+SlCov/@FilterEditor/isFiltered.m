function[res,prop,rationale]=isFiltered(this,ssid)



    res=false;
    prop=[];
    rationale='';
    if isempty(ssid)
        return;
    end
    [res,prop]=this.isFilteredIntern(ssid);
    if res
        rationale=getLocalRationale(this,prop);

        if prop.mode==1
            [ares,aprop]=this.isFilteredByAncestors(ssid);

            if ares&&aprop.mode==0
                res=ares;
                prop=aprop;
                rationale=getLocalRationale(this,prop);
            end

            if isempty(rationale)&&ares
                rationale=getLocalRationale(this,aprop);
            end
        end
    else
        [res,prop]=this.isFilteredByAncestors(ssid);
        if res
            rationale=getLocalRationale(this,prop);
        end
    end



    function text=getLocalRationale(this,cp)
        text='';
        value=this.filterState(this.getPropKey(cp));
        if isfield(cp,'Rationale')
            text=value.Rationale;
        end
