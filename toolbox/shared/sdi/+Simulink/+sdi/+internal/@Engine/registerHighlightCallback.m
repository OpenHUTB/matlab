function registerHighlightCallback(this,domain,cb)



















    if this.HighlightCallbacks.isKey(domain)
        this.HighlightCallbacks.deleteDataByKey(domain);
    end


    if~isempty(cb)
        this.HighlightCallbacks.insert(domain,cb);
    end
end
