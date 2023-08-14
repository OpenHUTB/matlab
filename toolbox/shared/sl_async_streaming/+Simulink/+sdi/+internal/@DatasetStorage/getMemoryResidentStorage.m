function obj=getMemoryResidentStorage(this)



    fullyLoadCache(this);
    obj=this.ElementCache;
end