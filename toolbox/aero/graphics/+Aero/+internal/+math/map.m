function output=map(value,frombounds,tobounds)





    output=interp1(frombounds,tobounds,value,"linear","extrap");

end

