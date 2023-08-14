function[U]=FFT_function(u);










    figure_N=u(length(u),1);
    mask=u(length(u)-1,:);
    nDec=u(length(u)-2,1);
    base=u(length(u)-3,:);

    u=u(1:length(u)-4,:);
    [r,c]=size(u);
    if r==1;N=c;
        S=2*fft(u)/N;
        U(1)=S(1)/2;
        NN=ceil(N/2);
        U(2:NN)=S(2:NN);
    else N=r;
        NN=ceil(N/2);
        S=2*fft(u)/N;
        U(1,:)=S(1,:)/2;
        U(2:NN,:)=S(2:NN,:);
    end;
    U=U./(ones(length(U),1)*base);
    UacRms=sqrt(sum(abs(U(2:length(U),:)).^2/2));
    UHarmRms=sqrt(sum(abs(U(3:length(U),:)).^2/2));
    U1Rms=sqrt(sum(abs(U(2,:)).^2/2,1));
    Udc=abs(U(1,:));
    Urms=sqrt(UacRms.^2+Udc.^2);
    k=UHarmRms./UacRms;
    g=U1Rms./UacRms;

    thr=1e-6;
    U=abs(U.*(abs(U)>thr));

    if sum(get(0,'child')==figure_N)==1;
        set(0,'CurrentFigure',figure_N);
    else figure(figure_N);
        set(figure_N,'units','normal','position',[0.33,0.5,0.66,0.30]);
    end;

    MASK=ones(length(U),1)*mask;

    U_=abs(U).*MASK;
    Umax=max(max(U_))+1e-10;
    Umin=min(min(U_))-1e-10;

    colormap([0,0,0]);
    bar((0:length(U)-1)',U_);
    set(gcf,'renderer','zbuffer');
    ax=axis;axis([-1,1.05*(length(U)-1),1.05*Umin,1.05*Umax]);
    grid;
    xlabel('Order of Harmonic');
    ylabel('Magnitude based on "Base Peak" - Parameter');
    title('Peak Magnitude Spectrum called by Simulink','FontSize',12);

    if nDec>0;
        txt1=['Total  RMS  = ',num2str(round_nDec(Urms,nDec))];
        txt2=['           DC    = ',num2str(round_nDec(Udc,nDec))];
        txt3=['Fund. RMS = ',num2str(round_nDec(U1Rms,nDec))];
        txt4=['Harm. RMS = ',num2str(round_nDec(UHarmRms,nDec))];
        txt5=['AC      RMS = ',num2str(round_nDec(UacRms,nDec))];

        ax=axis;
        x=ax(1)+0.5*(ax(2)-ax(1));
        y=ax(3)+0.95*(ax(4)-ax(3));
        dy=0.04*(ax(4)-ax(3));

        text(x,y,txt1,'FontSize',10);y=y-dy;
        text(x,y,txt2,'FontSize',10);y=y-dy;
        text(x,y,txt3,'FontSize',10);y=y-dy;
        text(x,y,txt4,'FontSize',10);y=y-dy;
        text(x,y,txt5,'FontSize',10);y=y-dy;
    end;


    U=[U;Urms;Udc;U1Rms;UHarmRms;UacRms];




    function[X]=round_nDec(x,n);
        y=x*10^n;
        Y=round(y);
        X=Y/10^n;