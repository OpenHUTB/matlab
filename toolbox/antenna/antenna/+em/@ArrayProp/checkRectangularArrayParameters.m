function checkRectangularArrayParameters(obj)
    numelements=prod(obj.Size);

    checkRowSpacing(obj);
    checkColumnSpacing(obj);
    checkLattice(obj);
    checkAmplitudeTaper(obj,numelements);
    checkPhaseShift(obj,numelements);
end