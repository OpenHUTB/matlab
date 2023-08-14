function setupMeasurementsSpecification(this)






    this.PeakFinderObject=dsp.scopes.PeakFinderSpecification(this.Application);
    this.CursorMeasurementsObject=dsp.scopes.CursorMeasurementsSpecification(this.Application);
    this.ChannelMeasurementsObject=dsp.scopes.ChannelMeasurementsSpecification(this.Application);
    this.DistortionMeasurementsObject=dsp.scopes.DistortionMeasurementsSpecification(this.Application);
    this.CCDFMeasurementsObject=dsp.scopes.CCDFMeasurementsSpecification(this.Application);

    updateMeasurementsPropertyValues(this);

    this.PeakFinderUpdatedListener=event.listener(this.PeakFinderObject,...
    'PeakFinderUpdated',makeCallback(this,@updatePeakFinder));
    this.CursorMeasurementsUpdatedListener=event.listener(this.CursorMeasurementsObject,...
    'CursorMeasurementsUpdated',makeCallback(this,@updateCursorMeasurements));

    this.ChannelMeasurementsUpdatedListener=event.listener(this.ChannelMeasurementsObject,...
    'ChannelMeasurementsUpdated',makeCallback(this,@updateChannelMeasurements));

    this.DistortionMeasurementsUpdatedListener=event.listener(this.DistortionMeasurementsObject,...
    'DistortionMeasurementsUpdated',makeCallback(this,@updateDistortionMeasurements));

    this.CCDFMeasurementsUpdatedListener=event.listener(this.CCDFMeasurementsObject,...
    'CCDFMeasurementsUpdated',makeCallback(this,@updateCCDFMeasurements));
end
