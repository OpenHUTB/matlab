function h=draw(h,src,eventData)







    setxy(h);


    c1=get(h,'Color');
    c2=get(h,'SubColor');
    lw1=get(h,'LineWidth');
    lw2=get(h,'SubLineWidth');
    lt1=get(h,'LineType');
    lt2=get(h,'SubLineType');
    xdata=get(h,'XData');
    ydata=get(h,'YData');

    switch lower(get(h,'Type'))
    case 'z'
        set(h.ImpedanceGrid,'XData',xdata,'YData',ydata,...
        'Visible','on','Color',c1,'LineWidth',lw1,'LineStyle',lt1);
        set(h.AdmittanceGrid,'XData',0,'YData',0,...
        'Visible','off','Color',c2,'LineWidth',lw1,'LineStyle',lt2);
    case 'y'
        set(h.AdmittanceGrid,'XData',-xdata,'YData',ydata,...
        'Visible','on','Color',c1,'LineWidth',lw1,'LineStyle',lt1);
        set(h.ImpedanceGrid,'XData',0,'YData',0,'Visible','off',...
        'Color',c2,'LineWidth',lw2,'LineStyle',lt2);
    case 'zy'
        set(h.ImpedanceGrid,'XData',xdata,'YData',ydata,...
        'Visible','on','Color',c1,'LineWidth',lw1,'LineStyle',lt1);
        set(h.AdmittanceGrid,'XData',-xdata,'YData',ydata,...
        'Visible','on','Color',c2,'LineWidth',lw2,'LineStyle',lt2);
    case 'yz'
        set(h.AdmittanceGrid,'XData',-xdata,'YData',ydata,...
        'Visible','on','Color',c1,'LineWidth',lw1,'LineStyle',lt1);
        set(h.ImpedanceGrid,'XData',xdata,'YData',ydata,...
        'Visible','on','Color',c2,'LineWidth',lw2,'LineStyle',lt2);
    end
    set(h.StaticGrid,'Visible','on','Color',c1,'LineWidth',lw1,...
    'LineStyle',lt1);


    restack(h);
    label(h);
    axis off;

    function h=setxy(h)



        N=100;M=128;
        nn=size(h.Values,2);
        X=zeros(1,((2+4*nn)*(N+1))+M+1);
        Y=zeros(1,((2+4*nn)*(N+1))+M+1);


        r=50;
        x0=r/(r+1);
        r0=1/(r+1);
        t=0:M;
        s1=1;
        s2=s1+M;
        X(1,s1:s2)=x0+r0*sin(t*2*pi/M);
        Y(1,s1:s2)=r0*cos(t*2*pi/M);


        s1=s2+1;
        s2=s1+2*N+1;
        z=z2g((linspace(0,50,N)).^2+1i*50*ones(1,N));
        X(1,s1:s2)=[NaN,real(z),NaN,real(conj(z))];
        Y(1,s1:s2)=[NaN,imag(z),NaN,imag(conj(z))];


        for idx=1:nn
            s1=s2+1;
            s2=s1+4*N+3;
            r=h.Values(1,idx);
            x=(linspace(0,sqrt(h.Values(2,idx)),N)).^2;
            ZR=z2g(r*ones(1,N)+1i*x);
            ZX=z2g(x+1i*r*ones(1,N));
            X(1,s1:s2)=[NaN,real(ZR),NaN,real(conj(ZR)),NaN,real(ZX)...
            ,NaN,real(conj(ZX))];
            Y(1,s1:s2)=[NaN,imag(ZR),NaN,imag(conj(ZR)),NaN,imag(ZX)...
            ,NaN,imag(conj(ZX))];
        end


        set(h,'XData',X);
        set(h,'YData',Y);

        function h=restack(h)



            ch=allchild(double(h.Axes));
            Yidx=find(double(h.AdmittanceGrid)==ch);
            Zidx=find(double(h.ImpedanceGrid)==ch);



            if((Zidx>Yidx)&&strcmpi(h.Type(1),'z'))||...
                ((Yidx>Zidx)&&strcmpi(h.Type(1),'y'))

                tmp=ch(Yidx);
                ch(Yidx)=ch(Zidx);
                ch(Zidx)=tmp;
                set(h.Axes,'Children',ch);
            end


            function g=z2g(z)

                g=(z-1)./(z+1);
