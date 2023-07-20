function clkreqs=analyzeImplementation(this)







    numstages=length(this.Stage);

    castype=getCascadeType(this);
    isinterp=strcmpi(castype,'interpolating');

    sampletimes=getSampleTimes(this);

    inputsampletimes=sampletimes(1:end-1);
    outputsampletimes=sampletimes(2:end);

    ffact=getFoldingFactor(this);

    if isinterp
        refsampletimes=outputsampletimes;
    else
        refsampletimes=inputsampletimes;
    end
    for n=1:numstages
        clkreqs(n).Rate=refsampletimes(n);
        clkreqs(n).Up=ffact(n);
        clkreqs(n).Down=1;
        if ffact(n)>1
            clkreqs(n).Offset=1;
        else
            clkreqs(n).Offset=1;
        end
    end
    if strcmpi(castype,'interpolating')








    else

        ceindx=length(clkreqs)+1;
        if strcmpi(castype,'decimating')||strcmpi(castype,'singlerate')
            clkreqs(ceindx).Rate=outputsampletimes(end);
            clkreqs(ceindx).Up=1;
            clkreqs(ceindx).Down=1;
            clkreqs(ceindx).Offset=1;
        end
    end



