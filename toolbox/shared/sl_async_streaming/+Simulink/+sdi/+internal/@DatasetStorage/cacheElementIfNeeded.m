function cacheElementIfNeeded(this,elIdxs)




    fullFlushIfNeeded(this);

    bWasElementLoaded=this.HasAnyElementBeenCached;
    origCache=this.ElementCache;
    try
        for idx=1:length(elIdxs)
            elIdx=elIdxs(idx);
            if elIdx>0&&elIdx<=this.numElements&&~isempty(this.DatasetRef)
                if~isCached(this.ElementCache,elIdx)
                    this.ElementCache=cacheElement(...
                    this.ElementCache,...
                    elIdx,...
                    getElement(this.DatasetRef,elIdx));
                    this.HasAnyElementBeenCached=true;
                end
            end
        end
    catch me %#ok<NASGU>



        this.HasAnyElementBeenCached=false;
        fullyLoadCache(this,1);



        if bWasElementLoaded
            for idx=1:this.numElements
                elem=getElements(origCache,idx);
                if~isempty(elem)
                    this.ElementCache=setElements(this.ElementCache,idx,elem);
                end
            end
        end
    end
end
