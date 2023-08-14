function mustBeEmptyStringOrStateSpace(linSys)





    if isa(linSys,"ss")
        return
    end

    if(isStringScalar(linSys)&&(linSys~=""))||~isempty(linSys)
        error(message("aeroblks_flightcontrol:validation:mustBeEmptyStringOrStateSpace"))
    end

end
