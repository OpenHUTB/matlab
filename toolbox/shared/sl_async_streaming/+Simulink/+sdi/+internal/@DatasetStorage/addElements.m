function this=addElements(this,idx,elem)





    fullyLoadCache(this,idx);
    this.ElementCache=addElements(this.ElementCache,idx,elem);
    this.HasAnyElementBeenCached=true;
end
