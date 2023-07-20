function fv=getFrequencyVector(obj)




    fv=[];
    if isLocked(obj)
        fv=obj.pFreqVect;
    end
end
