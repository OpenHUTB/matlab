function[azimuth,elevation,flag_az,flag_el]=checkMonotonic(azimuth,elevation)


    flag_az=0;
    flag_el=0;
    if numel(azimuth)>1&&any(diff(azimuth)<0)
        azimuth=flip(azimuth);
        flag_az=1;
    end
    if numel(elevation)>1&&any(diff(elevation)<0)
        elevation=flip(elevation);
        flag_el=1;
    end
end

