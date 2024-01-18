function out=xlsColNameToNum(in)
    n=0;
    out=0;
    for code=double(reverse(in))
        out=out+(code-64)*power(26,n);
        n=n+1;
    end
end

