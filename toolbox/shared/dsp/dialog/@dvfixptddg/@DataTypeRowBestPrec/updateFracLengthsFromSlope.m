function updateFracLengthsFromSlope(this,value)







    try
        slope=eval(value);
        str=num2str(-log2(slope));
        this.FracLength=str;
        this.FracLengthEdit=str;
    catch
        str=['-log2(',value,')'];
        this.FracLength=str;
        this.FracLengthEdit=str;
    end

