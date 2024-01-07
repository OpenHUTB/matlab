function obj=coupledMicrostripLineDesign(obj,f,Zoe,Zoo)

    t=35e-6;
    h=obj.Height;
    er=obj.Substrate.EpsilonR;
    eta0=120*pi;

    testw=linspace(1e-6,15e-3,500);
    tests=linspace(1e-6,15e-3,500);
    i=1;
    Zeventest=zeros(500,500);
    Zoddtest=zeros(500,500);
    for w=testw
        j=1;
        for s=tests
            [Zeventest(i,j),Zoddtest(i,j)]=rfpcb.internal.coupledlineCalc(w,s,t,h,er,eta0);
            j=j+1;
        end
        i=i+1;
    end
    Zevendiff=Zeventest-Zoe;
    [~,b1]=min(abs(Zevendiff));
    Zodddiff=Zoddtest-Zoo;
    [~,b2]=min(abs(Zodddiff));
    diff1=b1-b2;
    [~,b3]=min(abs(diff1));
    CommonIndex=b1(b3);
    if CommonIndex>498
        error(message('rfpcb:rfpcberrors:Unsupported',...
        'Design of coupledMicrostripLine','this combination of Z0e and Z0o'));
    end
    wCalc=linspace(testw(CommonIndex-2),testw(CommonIndex+2),25);
    sCalc=linspace(1e-6,5e-3,10000);

    i=1;
    ZevenTotal=zeros(numel(wCalc),numel(sCalc));
    ZoddTotal=zeros(numel(wCalc),numel(sCalc));
    for w=wCalc
        j=1;k=1;
        for s=sCalc
            [Zeven,Zodd,epsilonReff]=rfpcb.internal.coupledlineCalc(w,s,t,h,er,eta0);
            if Zeven>Zoe-0.5&&Zeven<Zoe+0.5&&Zodd>Zoo-0.5&&Zodd<Zoo+0.5
                Width_Calc(k)=w;%#ok<AGROW>
                Spacing_Calc(k)=s;%#ok<AGROW>
                k=k+1;
            end
            ZevenTotal(i,j)=Zeven;
            ZoddTotal(i,j)=Zodd;
            j=j+1;
        end
        i=i+1;
    end
    if exist('Width_Calc','var')==0
        error(message('rfpcb:rfpcberrors:Unsupported',...
        'Design of coupledMicrostripLine','this combination of Z0e and Z0o'));
    end
    W=mean(Width_Calc);
    S=mean(Spacing_Calc);
    L=(0.25*(3e8/f)*(1/sqrt(epsilonReff)));
    obj.Length=L;
    obj.Width=W;
    obj.Spacing=S;
    obj.GroundPlaneWidth=4*W+2*S;

end