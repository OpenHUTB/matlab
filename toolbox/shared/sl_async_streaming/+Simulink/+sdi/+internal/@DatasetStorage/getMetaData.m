function ret=getMetaData(this,idx,prop)






    fullFlushIfNeeded(this);

    cacheElementIfNeeded(this,idx);
    ret=getMetaData(this.ElementCache,idx,prop);
end
