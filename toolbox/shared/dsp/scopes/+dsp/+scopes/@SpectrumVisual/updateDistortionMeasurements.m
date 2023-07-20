function updateDistortionMeasurements(this)




    distortionMeasurementsProps=get(this.DistortionMeasurementsObject);
    distortionMeasurementsProps.Enable=false;
    setPropertyValue(this,'DistortionMeasurementsProperties',distortionMeasurementsProps);

end
