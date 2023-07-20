function checkInfGndPlaneWidth(obj,propVal,bool)
    if(isempty(obj.GroundPlaneLength))
        if isinf(propVal)
            infGPsoln(obj,true,bool);
        end
    elseif isinf(propVal)||isinf(obj.GroundPlaneLength)
        infGPsoln(obj,true,bool);
    else
        infGPsoln(obj,false);
    end
end