function this=removeElements(this,idx)





    fullyLoadCache(this,idx);
    this.ElementCache=removeElements(this.ElementCache,idx);
    this.HasAnyElementBeenCached=true;
end
