function ret=numElements(this)




    fullFlushIfNeeded(this);
    ret=this.ElementCache.numElements();
end
