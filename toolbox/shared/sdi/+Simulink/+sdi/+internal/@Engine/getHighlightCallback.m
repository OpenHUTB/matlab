function ret=getHighlightCallback(this,domain)



    ret=[];
    if this.HighlightCallbacks.isKey(domain)
        ret=this.HighlightCallbacks.getDataByKey(domain);
    end
end
