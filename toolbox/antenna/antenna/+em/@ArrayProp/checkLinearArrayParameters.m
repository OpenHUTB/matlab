function checkLinearArrayParameters(obj)
    numelements=obj.NumElements;

    checkElementSpacing(obj);
    checkAmplitudeTaper(obj,numelements);
    checkPhaseShift(obj,numelements);
end