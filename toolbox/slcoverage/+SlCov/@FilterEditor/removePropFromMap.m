function map=removePropFromMap(this,map,prop)



    key=this.getPropKey(prop);
    if map.isKey(key)
        if isMetricProperty(this,prop)||this.isRteProperty(prop)
            sp=map(key);
            idx=[];
            for k=1:numel(sp.value)
                cv=sp.value(k);
                if isequal(cv.name,prop.value.name)&&...
                    isequal(cv.idx,prop.value.idx)&&...
                    isequal(cv.outcomeIdx,prop.value.outcomeIdx)
                    idx=k;
                    break;
                end
            end
            if~isempty(idx)
                sp.value(idx)=[];

                if isempty(sp.value)
                    this.removeProp(key,sp);
                else
                    map(key)=sp;
                end
            end
        else
            this.removeProp(key,prop);
        end
    end
    this.resetCache

