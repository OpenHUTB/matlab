function ret=getElements(this,idx)





    fullFlushIfNeeded(this);

    cacheElementIfNeeded(this,idx);
    ret=getElements(this.ElementCache,idx);
end
