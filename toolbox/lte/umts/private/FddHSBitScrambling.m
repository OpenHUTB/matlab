












function[out]=FddHSBitScrambling(input)
    if(isempty(input))
        out=[];
        return
    end
    out=double(fdd('HsdpaBitScrambler',input));

    if size(input,2)<size(input,1)
        out=transpose(out);
    end

end