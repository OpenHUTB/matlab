function rowIdx=showRteRule(this,ssid,rteType,idx,varargin)




    prop.isCode=iscell(ssid)||isstruct(ssid);
    if prop.isCode

    else
        v.ssid=ssid;
        v.type='rte';
        v.name=rteType;
        v.idx=idx;
        v.outcomeIdx=777;
    end
    prop.value=v;

    rowIdx=this.showRule(prop,varargin{:});