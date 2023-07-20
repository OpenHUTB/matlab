function isComplex=isComplexSignal(this,sigName)
    isComplex=false;
    if contains(lower(sigName),this.REAL_PART_STR)||...
        contains(lower(sigName),this.IMAG_PART_STR)
        isComplex=true;
    end
end