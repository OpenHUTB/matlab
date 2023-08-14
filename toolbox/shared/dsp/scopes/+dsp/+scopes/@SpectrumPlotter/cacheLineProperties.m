function cacheLineProperties(this,lineNum,props,clobberExistingProps)










    if nargin<4
        clobberExistingProps=true;
    end
    cachedProps=this.LinePropertiesCache;
    if(lineNum<=length(cachedProps))&&~isempty(cachedProps{lineNum})
        if clobberExistingProps
            props=dsp.scopes.SpectrumPlotter.mergeStructs(cachedProps{lineNum},props);
        else
            props=dsp.scopes.SpectrumPlotter.mergeStructs(props,cachedProps{lineNum});
        end
    end
    this.LinePropertiesCache{lineNum}=props;
end
