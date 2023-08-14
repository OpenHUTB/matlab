function checkInfGndPlaneRadius(obj,propVal,bool)

    if isinf(propVal)
        infGPsoln(obj,true,bool);
    else
        infGPsoln(obj,false);
    end
end