function checkInfGndPlaneLength(obj,propVal,bool)
    if(isempty(obj.GroundPlaneWidth))
        if isinf(propVal)
            infGPsoln(obj,true,bool);
        end
    elseif isinf(propVal)||isinf(obj.GroundPlaneWidth)
        infGPsoln(obj,true,bool);
    else
        infGPsoln(obj,false);
    end
end