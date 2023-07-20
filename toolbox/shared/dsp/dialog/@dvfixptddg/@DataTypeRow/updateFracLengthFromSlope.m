function updateFracLengthFromSlope(this,value)






    try
        slope=eval(value);
        this.FracLength=num2str(-log2(slope));
    catch
        this.FracLength=['-log2(',value,')'];
    end

