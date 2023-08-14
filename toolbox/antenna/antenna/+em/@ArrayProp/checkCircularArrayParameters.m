function checkCircularArrayParameters(obj)
    numelements=obj.NumElements;
    checkRadiusVsNumElements(obj,obj.Radius);
    checkAmplitudeTaper(obj,numelements);
    checkPhaseShift(obj,numelements);
end