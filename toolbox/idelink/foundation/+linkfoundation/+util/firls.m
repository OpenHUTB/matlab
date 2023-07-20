function[h,a]=firls(N,F,A)
















    if(max(F)>1)||(min(F)<0)
        error(message('ERRORHANDLER:utils:InvalidFreqRange'))
    end
    if(rem(length(F),2)~=0)
        error(message('ERRORHANDLER:utils:InvalidFreqLength'));
    end
    if(length(F)~=length(A))
        error(message('ERRORHANDLER:utils:InconsistentFreq'));
    end

    W=ones(length(F)/2,1);


    N=N+1;


    F=F(:)/2;A=A(:);W=sqrt(W(:));

    dF=diff(F);

    L=(N-1)/2;
    Nodd=rem(N,2);

    if~Nodd
        m=(0:L)+.5;
    else
        m=(0:L);
    end
    k=m';

    if Nodd
        k=k(2:length(k));
        b0=0;
    end;
    b=zeros(size(k));
    for s=1:2:length(F),

        m=(A(s+1)-A(s))/(F(s+1)-F(s));

        b1=A(s)-m*F(s);

        if Nodd
            b0=b0+(b1*(F(s+1)-F(s))+m/2*(F(s+1)*F(s+1)-F(s)*F(s)))...
            *abs(W((s+1)/2)^2);
        end

        b=b+(m/(4*pi*pi)*(cos(2*pi*k*F(s+1))-cos(2*pi*k*F(s)))./(k.*k))...
        *abs(W((s+1)/2)^2);
        b=b+(F(s+1)*(m*F(s+1)+b1)*linkfoundation.util.sinc(2*k*F(s+1))...
        -F(s)*(m*F(s)+b1)*linkfoundation.util.sinc(2*k*F(s)))...
        *abs(W((s+1)/2)^2);
    end;

    if Nodd
        b=[b0;b];
    end;

    a=(W(1)^2)*4*b;
    if Nodd
        a(1)=a(1)/2;
    end

    if Nodd
        h=[a(L+1:-1:2)/2;a(1);a(2:L+1)/2].';
    else
        h=.5*[flipud(a);a].';
    end;

    if nargout>1
        a=1;
    end


