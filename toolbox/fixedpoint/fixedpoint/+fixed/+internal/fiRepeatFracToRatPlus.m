function r=fiRepeatFracToRatPlus(c)
























    m=numel(c);
    k=m;

    [r,k]=nextV(c,k);

    while k>0













        [left,k]=nextV(c,k);

        r=left+r.inv();
    end
end

function[r,k]=nextV(c,k)
    r=fixed.internal.ratPlus(c{k});
    k=k-1;
end


