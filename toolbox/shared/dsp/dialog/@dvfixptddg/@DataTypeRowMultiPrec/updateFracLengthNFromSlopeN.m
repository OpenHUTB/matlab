function updateFracLengthNFromSlopeN(this,value,prop)







    try
        slope=eval(value);
        this.(prop)=num2str(-log2(slope));
    catch
        this.(prop)=['-log2(',value,')'];
    end
