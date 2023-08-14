function[NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,...
    SetSaturation,Saturation,Xc]=SynchronousMachineConvert(NominalParameters,...
    MaskParameter1,MaskParameter2,MaskParameter3,Mechanical,InitialConditions,...
    SetSaturation,Saturation,sit,block)
















    Bloc=gcb;

    fn=NominalParameters(3);


    wen=2*pi*fn;

    X=MaskParameter1;
    tau=MaskParameter2;
    ra=MaskParameter3;

    xd=X(1);
    xpd=X(2);
    xsd=X(3);
    xq=X(4);












    switch sit
    case{0,4}

        xsq=X(5);
        xa=X(6);
        Tsqo=tau(3);
        Tsq=xsq*Tsqo/xq;

    case{2,6}

        xsq=X(5);
        xa=X(6);
        Tsq=tau(3);
        Tsqo=xq*Tsq/xsq;

    case{1,5}

        xpq=X(5);
        xsq=X(6);
        xa=X(7);
        Tpqo=tau(3);
        Tsqo=tau(4);
        So=Tpqo+Tsqo;
        Po=Tpqo*Tsqo;
        A=[xq*xq*xsq,-So*xq*xpq*xsq,xpq*xsq*Po*(xq+xsq)-xq*xsq*xsq*Po];
        TQ=sort(roots(A));

        CheckIsReal(TQ,Bloc);

        if(imag(TQ(2))~=0)


            Tpq=Tpqo*xpq/xq;
            blockName=strrep(char(block),newline,' ');
            Txt=[blockName,':',newline,newline,...
            'The data supplied for the q axis (reactances and time ',...
            'constants) are inconsistent. Fundamental parameters are ',...
            'computed using approximations.'];
            warndlg(Txt);
            warning('SimscapePowerSystemsST:InvalidParameters',Txt);


        else
            Tpq=TQ(2);
        end
        Tsq=Po*xsq/(xq*Tpq);

    case{3,7}

        xpq=X(5);
        xsq=X(6);
        xa=X(7);
        Tpq=tau(3);
        Tsq=tau(4);
        Ato=xq*Tpq/xpq+(xq/xsq-xq/xpq+1)*Tsq;
        Bto=xq*Tpq*Tsq/xsq;
        TQO=sort(abs(roots([1,Ato,Bto])));
        CheckIsReal(TQO,Bloc);
        Tpqo=TQO(2);
        Tsqo=TQO(1);
    end

    switch sit
    case{0,1,2,3}

        Tpdo=tau(1);
        Tsdo=tau(2);
        xmd=xd-xa;
        AA=xmd*(xpd-xa)/(xmd-(xpd-xa));
        Rf=(AA+xmd)/Tpdo/1;










        Tpd=(xpd*Tpdo+xpd*Tsdo)/xd-(xpd*xsd*Tpdo-xsd*(xpd^2*Tpdo^2+xpd^2*Tsdo^2+2*xpd^2*Tpdo*Tsdo-4*xd*xpd*Tpdo*Tsdo+4*xd*xsd*Tpdo*Tsdo-4*xpd*xsd*Tpdo*Tsdo)^(1/2)+xpd*xsd*Tsdo)/(2*xd*xsd);
        Tsd=(xpd*xsd*Tpdo-xsd*(xpd^2*Tpdo^2+xpd^2*Tsdo^2+2*xpd^2*Tpdo*Tsdo-4*xd*xpd*Tpdo*Tsdo+4*xd*xsd*Tpdo*Tsdo-4*xpd*xsd*Tpdo*Tsdo)^(1/2)+xpd*xsd*Tsdo)/(2*(xd*xpd-xd*xsd+xpd*xsd));


    case{4,5,6,7}

        Tpd=tau(1);
        Tsd=tau(2);
        xmd=xd-xa;
        AA=xmd*(xpd-xa)/(xmd-(xpd-xa));
        Rf=(AA+(xmd*xa)/(xmd+xa))/Tpd/1;










        Tpdo=(xd*xpd*Tsd+xd*xsd*Tpd-xd*xsd*Tsd+xpd*xsd*Tsd)/(xpd*xsd)-(xd*xpd*Tsd-(xd^2*xpd^2*Tsd^2+2*xd^2*xpd*xsd*Tpd*Tsd-2*xd^2*xpd*xsd*Tsd^2+xd^2*xsd^2*Tpd^2-2*xd^2*xsd^2*Tpd*Tsd+xd^2*xsd^2*Tsd^2-4*xd*xpd^2*xsd*Tpd*Tsd+2*xd*xpd^2*xsd*Tsd^2+2*xd*xpd*xsd^2*Tpd*Tsd-2*xd*xpd*xsd^2*Tsd^2+xpd^2*xsd^2*Tsd^2)^(1/2)+xd*xsd*Tpd-xd*xsd*Tsd+xpd*xsd*Tsd)/(2*xpd*xsd);
        Tsdo=(xd*xpd*Tsd-(xd^2*xpd^2*Tsd^2+2*xd^2*xpd*xsd*Tpd*Tsd-2*xd^2*xpd*xsd*Tsd^2+xd^2*xsd^2*Tpd^2-2*xd^2*xsd^2*Tpd*Tsd+xd^2*xsd^2*Tsd^2-4*xd*xpd^2*xsd*Tpd*Tsd+2*xd*xpd^2*xsd*Tsd^2+2*xd*xpd*xsd^2*Tpd*Tsd-2*xd*xpd*xsd^2*Tsd^2+xpd^2*xsd^2*Tsd^2)^(1/2)+xd*xsd*Tpd-xd*xsd*Tsd+xpd*xsd*Tsd)/(2*xpd*xsd);

    end



    Pd=Tpd*Tsd;
    Pdo=Tpdo*Tsdo;
    Sd=Tpd+Tsd;
    Sdo=Tpdo+Tsdo;
    k1=(Sdo-Sd)*(Pdo*Sd-Pd*Sdo)-(Pdo-Pd)^2;
    k2=Rf*xd*k1/xmd^2;
    A=Sdo-Sd;
    B=-2*(Pdo-Pd);
    C=(Pdo*Sd-Pd*Sdo)-k2;
    tkdc=sort(abs(roots([A,B,C])));
    Tkd=tkdc(1);
    k3=Pdo-Tkd*(Sdo-Tkd);
    k4=Pdo-Pd-Tkd*(Sdo-Sd);
    k5=(Pdo*Sd-Pd*Sdo)-Tkd*(Pdo-Pd);
    Xc=xmd^2/xd*k3/k4-xmd;
    Rkd=Rf*k1/k4^2;
    xf=Rf*k5/k4;
    xkd=Tkd*Rkd;

    Rf=Rf/wen;
    Rkd=Rkd/wen;


    xc=xa;
    xmq=xq-xc;

    switch sit
    case{0,2,4,6}

        xmqx=xmq*xc/xq;
        xkq1=(xmq*Tsq-xmqx*Tsqo)/(Tsqo-Tsq);
        Rkq1=(xkq1+xmq)/(wen*Tsqo);
        xkq2=inf;
        Rkq2=0;

    case{1,3,5,7}

        D=conv([Tpqo,1],[Tsqo,1]);
        N=conv([Tpq,1],[Tsq,1]);
        Nz=conv(N-D*xc/xq,[xmq/wen,0]);
        Dz=D-N;
        Nz=Nz(1:3);
        Dz=Dz(1:2);
        Req=Nz(3)/Dz(2);
        Nz=Nz/Nz(3);
        Dz=Dz/Dz(2);
        Tab=sort(abs(roots(Nz)));
        CheckIsReal(Tab,Bloc);
        Tab=1./Tab;
        Tm=sort(abs(roots(Dz)));
        CheckIsReal(Tm,Bloc);
        Tm=1/Tm(1);
        x=[1,1;Tab(1),Tab(2)]\[1;Tm]/Req;
        Rkq1=1/x(1);
        Rkq2=1/x(2);
        xkq1=Rkq1*Tab(2)*wen;
        xkq2=Rkq2*Tab(1)*wen;

    end



    Rs=ra;
    Ll=xc;
    Llfd=xf;
    Llkd=xkd;
    Llkq1=xkq1;
    Llkq2=xkq2;
    Lmd=xmd;
    Lmq=xmq;





    Stator=[Rs,Ll,Lmd,Lmq];
    Field=[Rf,Llfd];
    Dampers=[Rkd,Llkd,Rkq1,Llkq1,Rkq2,Llkq2];

    if any([Stator,Field,Dampers]<0)

        warning(message('physmod:powersys:library:InconsistentReactancesTimeConstants',Bloc));
    end

    function CheckIsReal(X,block)

        if~isreal(X)
            Txt=['The parameters supplied for the ',strrep(block,newline,char(32)),' block are inconsistent.'];
            Erreur.message=Txt;
            Erreur.identifier='SimscapePowerSystemsST:BlockParameterError';
            psberror(Erreur)
        end