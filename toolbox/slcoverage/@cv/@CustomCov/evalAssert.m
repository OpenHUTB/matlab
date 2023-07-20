function isViolated=evalAssert(this,val)



    try
        isViolated=~evalDec(this,val);

    catch MEx %#ok<NASGU>
        Mex.message;
    end