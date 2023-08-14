function this=setElements(this,idx,elem)




    fullFlushIfNeeded(this);
    this.ElementCache=setElements(this.ElementCache,idx,elem);
    this.HasAnyElementBeenCached=true;
end
