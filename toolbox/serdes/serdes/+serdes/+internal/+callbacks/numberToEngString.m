function engString=numberToEngString(number)
    if number==0
        engString='0';
    else

        lognum=log10(number);
        exponent=floor(lognum);
        exponent=exponent-mod(exponent,3);

        mantissa=power(10,lognum-exponent);
        if exponent==0
            engString=sprintf('%g',mantissa);
        else
            engString=sprintf('%ge%d',mantissa,exponent);
        end
    end
end
