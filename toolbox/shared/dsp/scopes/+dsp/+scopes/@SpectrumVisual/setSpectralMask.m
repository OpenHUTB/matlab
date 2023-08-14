function setSpectralMask(this,maskSpecObj)






    if~(isa(maskSpecObj,'dsp.scopes.SpectralMaskSpecification')&&isvalid(maskSpecObj))
        error(message('dspshared:SpectrumAnalyzer:invalidMaskSpecification','SpectralMask'));
    end

    set(this.MaskSpecificationObject,get(maskSpecObj));
    this.MaskUpdatedListener=event.listener(maskSpecObj,'MaskUpdated',...
    makeCallback(this,@updateSpectralMask,true));
    updateSpectralMask(this,true);