function[h,WARN]=firceqripDesign(N,fo,del,ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8)









































































    N=N+1;



    TBT='mid';
    FT='low';
    PT='lin';
    PlotFig=0;
    PlotDB=0;
    TRACE=0;
    ROP=0;
    IS=0;
    IST='invsinc';
    R=1;
    C=0;
    pow=1;



    if nargin>3
        if dspIsChar(ARG1)==0
            ROP=ARG1;
        elseif strcmpi(ARG1,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG1,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG1,'high')
            FT='high';
        elseif strcmpi(ARG1,'slope')
            ROP=10;
        elseif any(strcmpi(ARG1,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG1,'min')
            PT='min';
        elseif strcmpi(ARG1,'plot')
            PlotFig=1;
        elseif strcmpi(ARG1,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG1,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG1));
        end
    end

    if nargin>4
        if dspIsChar(ARG2)==0
            if any(strcmpi(ARG1,{'invsinc','invdiric'}))
                C=ARG2(1);
                if length(ARG2)>1
                    pow=ARG2(2);
                    if length(ARG2)>2&&strcmpi(ARG1,'invdiric')
                        R=ARG2(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG1,'slope')
                ROP=ARG2;
            end
        elseif strcmpi(ARG2,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG2,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG2,'high')
            FT='high';
        elseif strcmpi(ARG2,'slope')
            ROP=10;
        elseif any(strcmpi(ARG2,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG2,'min')
            PT='min';
        elseif strcmpi(ARG2,'plot')
            PlotFig=1;
        elseif strcmpi(ARG2,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG2,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG2));
        end
    end

    if nargin>5
        if dspIsChar(ARG3)==0
            if any(strcmpi(ARG2,{'invsinc','invdiric'}))
                C=ARG3(1);
                if length(ARG3)>1
                    pow=ARG3(2);
                    if length(ARG3)>2&&strcmpi(ARG2,'invdiric')
                        R=ARG3(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG2,'slope')
                ROP=ARG3;
            end
        elseif strcmpi(ARG3,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG3,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG3,'high')
            FT='high';
        elseif strcmpi(ARG3,'slope')
            ROP=10;
        elseif any(strcmpi(ARG3,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG3,'min')
            PT='min';
        elseif strcmpi(ARG3,'plot')
            PlotFig=1;
        elseif strcmpi(ARG3,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG3,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG3));
        end
    end

    if nargin>6
        if dspIsChar(ARG4)==0
            if any(strcmpi(ARG3,{'invsinc','invdiric'}))
                C=ARG4(1);
                if length(ARG4)>1
                    pow=ARG4(2);
                    if length(ARG4)>2&&strcmpi(ARG3,'invdiric')
                        R=ARG4(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG3,'slope')
                ROP=ARG4;
            end
        elseif strcmpi(ARG4,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG4,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG4,'high')
            FT='high';
        elseif strcmpi(ARG4,'slope')
            ROP=10;
        elseif any(strcmpi(ARG4,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG4,'min')
            PT='min';
        elseif strcmpi(ARG4,'plot')
            PlotFig=1;
        elseif strcmpi(ARG4,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG4,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG4));
        end
    end

    if nargin>7
        if dspIsChar(ARG5)==0
            if any(strcmpi(ARG4,{'invsinc','invdiric'}))
                C=ARG5(1);
                if length(ARG5)>1
                    pow=ARG5(2);
                    if length(ARG5)>2&&strcmpi(ARG4,'invdiric')
                        R=ARG5(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG4,'slope')
                ROP=ARG5;
            end
        elseif strcmpi(ARG5,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG5,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG5,'high')
            FT='high';
        elseif strcmpi(ARG5,'slope')
            ROP=10;
        elseif any(strcmpi(ARG5,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG5,'min')
            PT='min';
        elseif strcmpi(ARG5,'plot')
            PlotFig=1;
        elseif strcmpi(ARG5,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG5,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG5));
        end
    end

    if nargin>8
        if dspIsChar(ARG6)==0
            if any(strcmpi(ARG5,{'invsinc','invdiric'}))
                C=ARG6(1);
                if length(ARG6)>1
                    pow=ARG6(2);
                    if length(ARG6)>2&&strcmpi(ARG5,'invdiric')
                        R=ARG6(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG5,'slope')
                ROP=ARG6;
            end
        elseif strcmpi(ARG6,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG6,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG6,'high')
            FT='high';
        elseif strcmpi(ARG6,'slope')
            ROP=10;
        elseif any(strcmpi(ARG6,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG6,'min')
            PT='min';
        elseif strcmpi(ARG6,'plot')
            PlotFig=1;
        elseif strcmpi(ARG6,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG6,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG6));
        end
    end

    if nargin>9
        if dspIsChar(ARG7)==0
            if any(strcmpi(ARG6,{'invsinc','invdiric'}))
                C=ARG7(1);
                if length(ARG7)>1
                    pow=ARG7(2);
                    if length(ARG7)>2&&strcmpi(ARG6,'invdiric')
                        R=ARG7(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG6,'slope')
                ROP=ARG7;
            end
        elseif strcmpi(ARG7,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG7,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG7,'high')
            FT='high';
        elseif strcmpi(ARG7,'slope')
            ROP=10;
        elseif any(strcmpi(ARG7,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG7,'min')
            PT='min';
        elseif strcmpi(ARG7,'plot')
            PlotFig=1;
        elseif strcmpi(ARG7,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG7,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG7));
        end
    end

    if nargin>10
        if dspIsChar(ARG8)==0
            if any(strcmpi(ARG7,{'invsinc','invdiric'}))
                C=ARG8(1);
                if length(ARG8)>1
                    pow=ARG8(2);
                    if length(ARG8)>2&&strcmpi(ARG7,'invdiric')
                        R=ARG8(3);
                        IST='invdiric';
                    end
                end
            elseif strcmpi(ARG7,'slope')
                ROP=ARG8;
            end
        elseif strcmpi(ARG8,'passedge')
            TBT='passedge';
        elseif strcmpi(ARG8,'stopedge')
            TBT='stopedge';
        elseif strcmpi(ARG8,'high')
            FT='high';
        elseif strcmpi(ARG8,'slope')
            ROP=10;
        elseif any(strcmpi(ARG8,{'invsinc','invdiric'}))
            IS=1;
        elseif strcmpi(ARG8,'min')
            PT='min';
        elseif strcmpi(ARG8,'plot')
            PlotFig=1;
        elseif strcmpi(ARG8,'plotDB')
            PlotFig=1;
            PlotDB=1;
        elseif strcmpi(ARG8,'trace')
            TRACE=1;
        else
            error(message('dsp:firceqrip:FilterErr',ARG8));
        end
    end









    if ROP<0
        error(message('dsp:firceqrip:MustBePositive'));
    end
    if ROP>0
        ROP=log(10)/20*ROP;
    end


    if strcmpi(FT,'low')
    elseif strcmpi(FT,'high')
        fo=1-fo;
        del=del([2,1]);
    end

    if strcmpi(PT,'min')

        N=2*N-1;
    end

    if rem(N,2)==1
        Type=1;
        n=(N+1)/2;
    else
        Type=2;
        n=N/2;
    end


    L=2^ceil(log2(15*n));
    SN=1e-8;
    f=(0:L)/L;
    tw=exp(pi*(N-1)/2*1i*f');
    n1=max([1,round((n-1)*fo)]);
    n2=n-n1-1;
    if Type==1
        rs=[fo*(0:n1-1)/n1,fo,fo+(1-fo)*(1:n2)/n2]';
    else
        rs=[fo*(0:n1-1)/n1,fo,fo+(n2)/(n2+1)*(1-fo)*(1:n2)/n2]';
    end


    if strcmpi(PT,'lin')

        up=[1,0]+del;
        lo=[1,0]-del;
        if IS==0
            upper=up(1)*(f<fo)+up(2)*(f>fo).*exp(-ROP*(f-fo));
            lower=lo(1)*(f<fo)+lo(2)*(f>fo).*exp(-ROP*(f-fo));
        else


            P=(f<fo).*isinc(f,C,IST,R).^pow;
            upper=P+del(1)*(f<fo)+up(2)*(f>fo).*exp(-ROP*(f-fo));
            lower=P-del(1)*(f<fo)+lo(2)*(f>fo).*exp(-ROP*(f-fo));
        end

        uc=max(upper)-1;
        uc=ceil(uc*5)/5+1;
    else

        up=[1,0]+del;
        lo=[1-del(1),0];
        if IS==0
            upper=(1+del(1))*(f<fo)+del(2)*(f>fo).*exp(-ROP*(f-fo));
            lower=(1-del(1))*(f<fo);
        else


            P=(f<fo).*isinc(f,C,IST,R).^pow;
            upper=P+del(1)*(f<fo)+del(2)*(f>fo).*exp(-ROP*(f-fo));
            lower=P-del(1)*(f<fo);
        end

        uc=max(upper)^2-1;
        uc=ceil(uc*5)/5+1;
        up=up.^2;
        lo=lo.^2;
        upper=upper.^2;
        lower=lower.^2;

        ROP=ROP*2;
        pow=2*pow;
    end

    upper=upper';
    lower=lower';



    if strcmpi(TBT,'mid')
        if strcmpi(PT,'lin')
            Ho=0.5;
        else
            Ho=(0.5)^2;
        end
    elseif strcmpi(TBT,'passedge')
        if IS==0
            Ho=lo(1);
        else
            Ho=isinc(fo,C,IST,R)^pow-del(1);
        end
    elseif strcmpi(TBT,'stopedge')
        Ho=up(2);
    else
        error(message('dsp:firceqrip:FilterProblem'));
    end




    Err=1;
    itnum=0;
    WARN=false;
    MAXITER=30;
    while Err>SN


        Yp=up(1)*(1-(-1).^(1:n1))/2+lo(1)*((-1).^(1:n1)+1)/2;
        Yp=Yp(n1:-1:1);
        if IS>0

            if strcmpi(PT,'lin')
                Yp=Yp-1+(isinc(rs(1:n1),C,IST,R)').^pow;
            else
                Yp=(1+del(1))*(1-(-1).^(1:n1))/2+(1-del(1))*((-1).^(1:n1)+1)/2;
                Yp=Yp(n1:-1:1);
                Yp=Yp-1+(isinc(rs(1:n1),C,IST,R)').^(pow/2);
                Yp=Yp.^2;
            end
        end
        Ys=lo(2)*(1-(-1).^(1:n2))/2+up(2)*((-1).^(1:n2)+1)/2;
        Ys=Ys.*exp(-ROP*(rs(n1+2:end)-fo))';
        Y=[Yp,Ho,Ys];


        if Type==1
            a=cos(pi*rs*(0:n-1))\Y';
        else
            a=cos(pi*rs*((0:n-1)+0.5))\Y';
        end


        if Type==1
            h=[a(n:-1:2)/2;a(1);a(2:n)/2];
        else
            h=[a(n:-1:1);a]/2;
        end


        H=fft(h,2*L);
        H=H(1:L+1);
        H=real(tw.*H);



        ri_up=locmax(H-upper);
        k=find(f(ri_up)>=fo);
        if~isempty(k)
            ri_up(k(1))=[];
        end
        ri_lo=locmax(lower-H);

        k=find(f(ri_lo)<=fo);
        if~isempty(k)
            ri_lo(k(end))=[];
        end
        ri=sort([ri_up;ri_lo]);
        if ri(end)==ri(end-1)
            ri(end)=[];
        end
        if ri(1)==ri(2)
            ri(1)=[];
        end
        lr=length(ri);
        if Type==2
            ri=ri(1:lr-1);
            lr=lr-1;
        end
        while lr>n-1
            if((ri(lr)-1)/L<fo)&&(Type==2)

                x1=0;x2=1;

            else
                n1=sum(ri/L<fo);
                n2=sum(ri/L>fo);
                if rem(n1,2)==0

                    x1=lo(1)-H(ri(1));
                else

                    x1=H(ri(1))-up(1);
                end
                if rem(n2,2)==0

                    x2=H(ri(lr))-up(2)*exp(-ROP*(f(ri(lr))-fo));
                else

                    x2=lo(2)*exp(-ROP*(f(ri(lr))-fo))-H(ri(lr));
                end
            end
            if x1<x2
                ri(1)=[];
            else
                ri(lr)=[];
            end
            lr=lr-1;
        end

        old_rs=rs;
        rs=(ri-1)/L;
        rsp=rs(rs<fo,1);
        rss=rs(rs>fo,1);
        n1=length(rsp);
        n2=length(rss);


        if IS==0
            rsp=frefine(a,rsp,Type);
        else


        end
        if ROP==0
            rss=frefine(a,rss,Type);
        else
            if strcmpi(PT,'min')
                rss(1:2:end)=frefine(a,rss(1:2:end),Type);
            end
        end

        rs=[rsp;fo;rss];


        if TRACE==1



            plot(f,H,old_rs,Y,'o',f,upper,'--',f,lower,'--',(ri-1)/L,H(ri),'rx');
            axis([0,1,-.2,uc])
drawnow
        end


        if Type==1
            Hp=cos(pi*rsp*(0:n-1))*a;
            Hs=cos(pi*rss*(0:n-1))*a;
        else
            Hp=cos(pi*rsp*((0:n-1)+0.5))*a;
            Hs=cos(pi*rss*((0:n-1)+0.5))*a;
        end


        if IS>0

            if strcmpi(PT,'lin')
                Ep_up=max(Hp(end:-2:1)-(isinc(rsp(end:-2:1),C,IST,R).^pow)-del(1));
                Ep_lo=max(-Hp(end-1:-2:1)+(isinc(rsp(end-1:-2:1),C,IST,R).^pow-del(1)));
            else
                Ep_up=max(sqrt(Hp(end:-2:1))-sqrt(isinc(rsp(end:-2:1),C,IST,R).^pow))-del(1);
                Ep_lo=max(-sqrt(Hp(end:-2:1))+sqrt(isinc(rsp(end:-2:1),C,IST,R).^pow))-del(1);
            end
        else
            Ep_up=max(Hp)-up(1);
            Ep_lo=lo(1)-min(Hp);
        end
        Es_up=max(Hs(2:2:end)-up(2)*exp(-ROP*(rss(2:2:end)-fo)));
        Es_lo=max(-Hs(1:2:end)+lo(2)*exp(-ROP*(rss(1:2:end)-fo)));
        Err=max([Ep_up(:);Ep_lo(:);Es_up(:);Es_lo(:)]);
        if TRACE==1
            fprintf(1,'    Err = %20.15f\n',Err);
        end
        itnum=itnum+1;
        if itnum>MAXITER
            WARN=true;
            break
        end
    end

    h=h';


    if strcmpi(FT,'high')
        fo=1-fo;
        up=up([2,1]);

        h=h.*(-1).^(1:N);
        if Type==1
            if max(h)+min(h)<0
                h=-h;
            end
        end
    end

    if strcmpi(PT,'min')

        h=firminphase(h);
        up=sqrt(up);


        ROP=ROP/2;
        upper=sqrt(upper);
        lower=sqrt(lower);
        uc=max(upper)-1;
        uc=ceil(uc*5)/5+1;
    end


    H=fft(h',2*L);
    H=H(1:L+1);
    H=abs(H);


    if PlotFig==1
        ls='r--';
        if strcmpi(FT,'high')
            fop=f(f>fo);
            fos=f(f<fo);
        else
            fop=f(f<fo);
            fos=f(f>fo);
        end
        if strcmpi(FT,'low')
            if PlotDB==1
                c=20*log10(up(2)*exp(-ROP*(1-fo)));
                c=-ceil(-c/10)*10-10;
                u2=20*log10(uc);
                u2=5*ceil(u2/5);
                plot(f,20*log10(abs(H)+eps),...
                fop,20*log10(upper(f<fo)),ls,...
                fop,20*log10(lower(f<fo)),ls,...
                fo*[1,1],[c,20*log10(max(upper))],ls,...
                [fo,1],20*log10(up(2)*exp(-ROP*([fo,1]-fo))),ls)
                axis([0,1,c,u2])
                ylabel('|H(f)| dB')
            else
                plot(f,abs(H),...
                fop,upper(f<fo),ls,...
                fop,lower(f<fo),ls,...
                fo*[1,1],[0,max(upper)],ls,...
                fos,up(2)*exp(-ROP*(fos-fo)),ls)
                axis([0,1,0,uc])
                ylabel('|H(f)|')
            end
        end
        if strcmpi(FT,'high')
            if PlotDB==1
                c=20*log10(up(1)*exp(-ROP*(fo)));
                c=-ceil(-c/10)*10-10;
                u2=20*log10(uc);
                u2=5*ceil(u2/5);
                plot(f,20*log10(abs(H)+10*eps),...
                fos,20*log10(up(1)*exp(-ROP*(fo-fos))),ls,...
                fo*[1,1],[c,20*log10(max(upper))],ls,...
                1-f(f<(1-fo)),20*log10(upper(f<(1-fo))),ls,...
                1-f(f<(1-fo)),20*log10(lower(f<(1-fo))),ls)
                axis([0,1,c,u2])
                ylabel('|H(f)| dB')
            else
                plot(f,abs(H),...
                fos,up(1)*exp(-ROP*(fo-fos)),ls,...
                fo*[1,1],[0,max(upper)],ls,...
                1-f(f<(1-fo)),upper(f<(1-fo)),ls,...
                1-f(f<(1-fo)),lower(f<(1-fo)),ls)
                axis([0,1,0,uc])
                ylabel('|H(f)|')
            end
        end
        xlabel('f')
drawnow
    end










    function rs=frefine(a,rs,TYPE)









        a=a(:);
        w=pi*rs(:);
        m=length(a)-1;
        if TYPE==1
            v=0:m;
        else
            v=(0:m)+0.5;
        end
        for k=1:7




            H1=-sin(w*v)*(v'.*a);
            H2=-cos(w*v)*((v.^2)'.*a);
            w=w-H1./H2;
        end
        rs(:)=w;
        rs=rs/pi;





        function k=locmax(x)



            s=size(x);
            x=x(:).';
            N=length(x);
            b1=x(1:N-1)<=x(2:N);
            b2=x(1:N-1)>x(2:N);
            k=find(b1(1:N-2)&b2(2:N-1))+1;
            if x(1)>x(2)
                k=[k,1];
            end
            if x(N)>x(N-1)
                k=[k,N];
            end
            k=sort(k);
            if s(2)==1
                k=k';
            end



            function y=isinc(x,C,IST,R)


                if strcmpi(IST,'invsinc')


                    x=x*C*pi;
                    y=ones(size(x));
                    i=find(x&sin(x));
                    y(i)=(x(i))./sin(x(i));
                elseif strcmpi(IST,'invdiric')

                    x=x*pi;
                    y=ones(size(x));
                    i=find(sin(x/(2*R))&sin(C*x/2));
                    y(i)=R*C*sin(x(i)/(2*R))./sin(C*x(i)/2);
                else
                    error(message('dsp:firceqrip:InvalidIsincResponse'));
                end
