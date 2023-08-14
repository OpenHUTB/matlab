function updateCursorMeasurements(this)




    cursorMeasurementsProps=get(this.CursorMeasurementsObject);
    cursorMeasurementsProps.Enable=false;
    setPropertyValue(this,'CursorMeasurementsProperties',cursorMeasurementsProps);

end
