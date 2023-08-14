function mustBeSameLengthAsFirstDim(a,b,name1,name2)






    if(~isscalar(a))&&(size(b,1)~=1)
        Aero.internal.validation.mustBeSameLength(a,b(:,1),name1,name2)
    end

end

