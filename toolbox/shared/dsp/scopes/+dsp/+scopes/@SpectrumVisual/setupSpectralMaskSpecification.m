function setupSpectralMaskSpecification(this)






    this.MaskSpecificationObject=dsp.scopes.SpectralMaskSpecification(this.Application);
    maskProps=getPropertyValue(this,'SpectralMaskProperties');



    if~isempty(maskProps)
        set(this.MaskSpecificationObject,maskProps);
    else
        maskProps=get(this.MaskSpecificationObject);
        setPropertyValue(this,'SpectralMaskProperties',maskProps);
    end
    setup(this.MaskTesterObject);
    this.Plotter.MaskSpecificationObject=this.MaskSpecificationObject;
    this.MaskUpdatedListener=event.listener(this.MaskSpecificationObject,...
    'MaskUpdated',makeCallback(this,@updateSpectralMask,true));
    updateSpectralMask(this);
end