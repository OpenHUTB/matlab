function[errdb,errcol]=errcalc(errin,data,errorMetric,noiseFloor)




%#codegen

    if length(size(data))==3
        datasize=size(data);
        outsize=datasize(1:2);
        cols=prod(outsize);
        data=reshape(data,cols,[]).';
        errin=reshape(errin,cols,[]).';
    end
    ndata=size(errin,2);
    if strcmpi(errorMetric,'relative')



        dnz=rf.internal.rational.datanz(data,noiseFloor);
        maxdnz=max(dnz);
        mindnz=min(dnz);
        maxminrat=maxdnz./mindnz;
        logmaxminrat=log10(maxminrat);
        logmaxminrat(logmaxminrat==0)=1;
        fit=errin+data;
        fittnz=rf.internal.rational.datanz(fit,noiseFloor);
        logrerr=abs(log10(dnz)-log10(fittnz));
        maxlogrerr=max(logrerr);
        rr=maxlogrerr./logmaxminrat;
        errcol=20*log10(rr);
    else
        normerr=vecnorm(errin);
        denom=vecnorm(data);
        denom(denom==0)=eps;
        normx=normerr./denom;
        errcol=20*log10(normx);
    end
    assert(numel(errcol)==ndata)
    errdb=max(errcol(:));

end
