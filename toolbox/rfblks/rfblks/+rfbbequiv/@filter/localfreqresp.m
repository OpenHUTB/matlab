function transf=localfreqresp(h,block)








    MaskWSValues=rfblksgetblockmaskwsvalues(block);


    method=MaskWSValues.Method;
    filttype=MaskWSValues.Filttype;
    N=MaskWSValues.N;
    flo=MaskWSValues.Flo;
    fhi=MaskWSValues.Fhi;
    Rp=MaskWSValues.Rp;
    Rs=MaskWSValues.Rs;
    npts=MaskWSValues.MaxLength;
    fc=MaskWSValues.Fc;
    ts=MaskWSValues.Ts;

    set(h,'MaxLength',npts,'Fc',fc,'Ts',ts);


    freq=frequency(h);




    if isnan(N)||isinf(N)
        error(message('rfblks:rfbbequiv:filter:localfreqresp:InvalidOrder'));
    end


    if~isequal(floor(N),N)
        error(message('rfblks:rfbbequiv:filter:localfreqresp:OrderNotInteger'));
    end


    if N<1
        error(message('rfblks:rfbbequiv:filter:localfreqresp:OrderLessThan1'));
    end

    switch method
    case 'Butterworth'
        m={'butter',N};
    case 'Chebyshev I'
        if~isscalar(Rp)||~isnumeric(Rp)||isnan(Rp)||...
            ~isreal(Rp)||Rp<=0
            error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
            ,'Cheby1RpNotPositive']));
        end
        m={'cheby1',N,Rp};
    case 'Chebyshev II'
        if~isscalar(Rs)||~isnumeric(Rs)||isnan(Rs)||...
            ~isreal(Rs)||Rs<0
            error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
            ,'Cheby2RsNotPositive']));
        end
        m={'cheby2',N,Rs};
    case 'Elliptic'
        if~isscalar(Rp)||~isnumeric(Rp)||isnan(Rp)||...
            ~isreal(Rp)||Rp<=0
            error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
            ,'EllipRpNotPositive']));
        end
        if~isscalar(Rs)||~isnumeric(Rs)||isnan(Rs)||...
            ~isreal(Rs)||Rs<=0
            error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
            ,'EllipRsNotPositive']));
        end
        m={'ellip',N,Rp,Rs};
    case 'Bessel'
        m={'besself',N};
    otherwise
        error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
        ,'UnknownFilterMethod']));
    end

    Wlo=2*pi*flo;
    Whi=2*pi*fhi;

    switch filttype
    case 'Lowpass'
        if~isscalar(flo)||~isnumeric(flo)||isnan(flo)||...
            ~isreal(flo)||flo<0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2LowpassFloNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'FloNotPositive']));
            end
        end
        t=[m,{Wlo}];
    case 'Highpass'
        if~isscalar(flo)||~isnumeric(flo)||isnan(flo)||...
            ~isreal(flo)||flo<0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2HighpassFloNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'HighpassFloNotPositive']));
            end
        end
        t=[m,{Wlo},{'high'}];
    case 'Bandpass'
        if~isscalar(flo)||~isnumeric(flo)||isnan(flo)||...
            ~isreal(flo)||flo<0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandpassFloNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandpassFloNotPositive']));
            end
        end
        if~isscalar(fhi)||~isnumeric(fhi)||isnan(fhi)||...
            ~isreal(fhi)||fhi<=0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandpassFhiNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandpassFhiNotPositive']));
            end
        end
        if flo>=fhi
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandpassFhiFlo']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandpassFhiFlo']));
            end
        end
        t=[m,{[Wlo,Whi]}];
    case 'Bandstop'
        if~isscalar(flo)||~isnumeric(flo)||isnan(flo)||...
            ~isreal(flo)||flo<0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandstopFloNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandstopFloNotPositive']));
            end
        end
        if~isscalar(fhi)||~isnumeric(fhi)||isnan(fhi)||...
            ~isreal(fhi)||fhi<=0
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandstopFhiNotPositive']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandstopFhiNotPositive']));
            end
        end
        if flo>=fhi
            if strcmp(method,'Chebyshev II')
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'Cheby2BandstopFhiFlo']));
            else
                error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
                ,'BandstopFhiFlo']));
            end
        end
        t=[m,{[Wlo,Whi]},{'stop'}];
    otherwise
        error(message(['rfblks:rfbbequiv:filter:localfreqresp:'...
        ,'UnknownFilterType']));
    end



    if~strcmp(method,'Bessel')
        t=[t,{'s'}];
    end


    [z,p,k]=feval(t{:});

    Npts=numel(freq);
    transf=zeros(1,Npts);
    for i1=1:Npts
        transf(i1)=k*prod(z-1i*2*pi*freq(i1))./prod(p-1i*2*pi*freq(i1));
    end
