function updateCCDFMeasurements(this)




    ccdfMeasurementsProps=get(this.CCDFMeasurementsObject);
    ccdfMeasurementsProps.Enable=false;
    setPropertyValue(this,'CCDFMeasurementsProperties',ccdfMeasurementsProps);

end
