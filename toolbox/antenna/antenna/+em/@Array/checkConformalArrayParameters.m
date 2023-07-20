function checkConformalArrayParameters(obj)
    if isscalar(obj.Element)
        numelements=size(obj.ElementPosition,1);
        array_present=0;
    else
        if iscell(obj.Element)
            for m=1:numel(obj.Element)
                if~any(strcmpi(class(obj.Element{m}),...
                    {'linearArray','rectangularArray','circularArray'}))
                    array_present=0;
                else
                    array_present=1;
                    break;
                end
            end
        elseif any(strcmpi(class(obj.Element),{'linearArray','rectangularArray','circularArray'}))
            array_present=1;
        else
            array_present=0;
        end
        if array_present==0
            numelements=numel(obj.Element);
        else
            numelements=getNumFeedLocations(obj);
        end
    end
    if array_present==0
        checkElementPosition(obj,numelements);
        checkAmplitudeTaper(obj,numelements);
        checkPhaseShift(obj,numelements);
    else
        checkElementPosition(obj,size(obj.ElementPosition,1));
        checkAmplitudeTaper(obj,size(obj.ElementPosition,1));
        checkPhaseShift(obj,size(obj.ElementPosition,1));
    end
    tempElement=makeTemporaryElementCacheForConformal(obj,numelements);
    checkReference(obj,tempElement);
    checkIfElementHasInfGndPlane(obj,tempElement)
end