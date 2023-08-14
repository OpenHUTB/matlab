function y=fullDivideInDouble(num,den)















    if~isa(den,'uint64')&&(~isa(den,'int64'))
        y=num./double(den);
    else
        [aMS,aLS]=fixed.internal.errorcalculator.getMS_LS(den);
        if aLS==0
            y=num./aMS;
        else
            quot1=num./aMS;
            tmp_qt=1+(aLS./aMS);
            quot2=1./tmp_qt;
            y=quot1.*quot2;
        end

    end
end
