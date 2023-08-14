function y=bin2float(bin,wordsize)




    if isempty(bin)
        y=0;
        return
    end

    if nargin==1
        wordsize=32;
    end

    fp=getFloatProperties(wordsize);


    w=fp.wordlength;
    [mbin,nbin]=size(bin);
    if nbin<w

        o='0';

        bin=[o(ones(mbin,1),ones(w-nbin,1)),bin];
    end





    s=(-1).^bin2dec(bin(:,1));


    e=bin2dec(bin(:,2:fp.exponentlength+1));


    b=e-fp.exponentbias;


    f=pow2(bin2dec(bin(:,fp.exponentlength+2:end)),-fp.fractionlength);


    y=zeros(size(s));


    n=e==0&f~=0;
    y(n)=s(n).*pow2(f(n),fp.exponentmin);


    n=e~=0&b<=fp.exponentmax;
    y(n)=s(n).*pow2(1+f(n),b(n));


    n=b==fp.exponentmax+1&f~=0;
    y(n)=nan;


    n=b==fp.exponentmax+1&f==0;
    y(n)=s(n).*inf;


    function floatprop=getFloatProperties(wordsize)
        floatprop=struct('wordlength',[],...
        'exponentlength',[],...
        'fractionlength',[],...
        'exponentbias',[],...
        'exponentmin',[],...
        'exponentmax',[]);
        switch wordsize
        case 32
            floatprop.wordlength=32;
            floatprop.exponentlength=8;
            floatprop.fractionlength=23;
            floatprop.exponentbias=127;
            floatprop.exponentmin=-126;
            floatprop.exponentmax=127;
        case 64
            floatprop.wordlength=64;
            floatprop.exponentlength=11;
            floatprop.fractionlength=52;
            floatprop.exponentbias=1023;
            floatprop.exponentmin=-1022;
            floatprop.exponentmax=1023;
        otherwise
            error(message('ERRORHANDLER:utils:InvalidOptionForBin2Float','ticcsext.Utilities.bin2float'));
        end

