function updateFracLengthFromWordLength(this)




    try
        wleval=eval(this.WordLength);
        fl=num2str(wleval-this.NumIntegerBits);
    catch
        fl=this.BestPrecString;
    end

    this.FracLength=fl;
