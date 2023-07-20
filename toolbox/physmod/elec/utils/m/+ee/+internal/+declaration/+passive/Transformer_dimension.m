function[Nw1,Nw2,Nw3,coreArea,coreLength]=Transformer_dimension(SRated,FRated,pu_Xm,varargin)%#codegen






    mur=4000;
    B=1.5;
    Ku=0.4;
    J=200;

    mu0=4*pi*1e-7;
    H=B/(mu0*mur);
    Kf=2*pi/sqrt(2);

    if length(varargin)==2
        Pt=2*SRated;
    else
        Pt=3*SRated;
    end

    Ap=Pt*1e4/(Kf*Ku*B*J*FRated);
    coreArea=sqrt(Ap/1.5)/1e4;

    base_winding1=varargin{1};
    base_winding2=varargin{2};
    V1=base_winding1(1);
    V2=base_winding2(1);
    Nw1=V1/(Kf*B*FRated*coreArea);
    Nw2=Nw1*V2/V1;

    Imag=(1/pu_Xm)*base_winding1(4);
    coreLength=Nw1*Imag*sqrt(2)/H;

    if length(varargin)==2
        Nw3=0;
    else
        base_winding3=varargin{3};
        V3=base_winding3(1);
        Nw3=Nw1*V3/V1;
    end

end
