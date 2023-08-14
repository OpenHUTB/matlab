function y=linspaceOnAxis(x1,x2,n,scale,nbuffer)








    n=n*(1+2*nbuffer);

    if strcmp(scale,'log')
        x1log=log10(abs(x1));
        x2log=log10(abs(x2));
        diffxlog=x2log-x1log;
        x1log=x1log-nbuffer*diffxlog;
        x2log=x2log+nbuffer*diffxlog;
        y=sign(x1).*(10.^(linspace(x1log,x2log,n)));
    else
        diffx=x2-x1;
        x1=x1-nbuffer*diffx;
        x2=x2+nbuffer*diffx;
        y=linspace(x1,x2,n);
    end
end