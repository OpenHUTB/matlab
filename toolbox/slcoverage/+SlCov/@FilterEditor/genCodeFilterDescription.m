function desc=genCodeFilterDescription(this,rowIdx)




    desc='';
    if isempty(rowIdx)
        rowIdx=0;
    end

    if~isempty(rowIdx)&&this.ctableIdxMap.isKey(rowIdx+1)
        prop=this.ctableIdxMap(rowIdx+1);
        if this.filterState.isKey(prop.value)
            desc=SlCov.FilterEditor.getCodeFilterDescription(prop);
        end
    end
