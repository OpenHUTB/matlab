function deg=decodeDMS(str)










    t=str2double(str(1:end-1));
    D=fix(t/10000);
    t=t-10000*D;
    M=fix(t/100);
    S=t-100*M;

    deg=D+(M+S/60)/60;
    if(str(end)=='S')||(str(end)=='W')
        deg=-deg;
    end
