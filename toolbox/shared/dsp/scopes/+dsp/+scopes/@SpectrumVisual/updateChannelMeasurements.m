function updateChannelMeasurements(this)




    channelMeasurementsProps=get(this.ChannelMeasurementsObject);
    channelMeasurementsProps.Enable=false;
    setPropertyValue(this,'ChannelMeasurementsProperties',channelMeasurementsProps);

end
