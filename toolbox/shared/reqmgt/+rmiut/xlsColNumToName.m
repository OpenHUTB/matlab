function out=xlsColNumToName(in)

    remainder=mod(in,26);
    [out,in]=convertOneChar(remainder,'',in);
    while in>0
        remainder=mod(in,26);
        [out,in]=convertOneChar(remainder,out,in);
    end
end


function[out,in]=convertOneChar(last,out,in)
    if last==0
        out=['Z',out];
        in=in/26-1;
    else
        out=[char(64+last),out];
        in=(in-last)/26;
    end
end
