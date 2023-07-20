function out=roundup(in,multiple)



    modIn=mod(in,multiple);
    out=in+(modIn~=0)*(multiple-modIn);
end
