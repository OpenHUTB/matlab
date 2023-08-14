function[aMS,aLS]=getMS_LS(u)





    if isa(u,'uint64')
        nShift=11;
        tempMS=bitsra(u,nShift);
        tempLS=bitand(u,uint64(2^nShift-1));
        aMS=2^nShift*double(tempMS);
        aLS=double(tempLS);
    elseif isa(u,'int64')
        nShift=10;
        tempMS=bitsra(u,nShift);
        tempLS=bitand(u,int64(2^nShift-1));
        aMS=2^nShift*double(tempMS);
        aLS=double(tempLS);
    else

        aMS=double(u);
        aLS=0;
    end
end


