function cacheMaxMinHoldLineProperties(this,lineNum,props,clobberExistingProps,lineType)




    cachedProps=this.([lineType,'HoldLinePropertiesCache']);
    if(lineNum<=length(cachedProps))&&~isempty(cachedProps{lineNum})
        if clobberExistingProps
            props=dsp.scopes.SpectrumPlotter.mergeStructs(cachedProps{lineNum},props);
        else
            props=dsp.scopes.SpectrumPlotter.mergeStructs(props,cachedProps{lineNum});
        end
    end
    this.([lineType,'HoldLinePropertiesCache']){lineNum}=props;
end
