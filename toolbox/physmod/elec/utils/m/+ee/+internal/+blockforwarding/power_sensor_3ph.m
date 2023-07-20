function out=power_sensor_3ph(in)










    out=in;




    blockName=strrep(gcb,newline,' ');
    pm_warning('physmod:ee:library:PowerSensorUnitsChangedToWatts',blockName);


end