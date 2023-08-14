function thisBase=Base(SRated,VRated,FRated,connection,varargin)%#codegen




    coder.allowpcode('plain');

    switch nargin
    case 4

        thisBase=ee.internal.perunit.createEmptyBase();
    case 5

        thisBase=varargin{1};
    end

    thisBase.SRated=SRated;
    thisBase.VRated=VRated;
    thisBase.FRated=FRated;
    thisBase.connection=connection;


    thisBase.SPerPhase=thisBase.SRated./3;
    thisBase.PPerPhase=thisBase.SPerPhase;
    thisBase.QPerPhase=thisBase.SPerPhase;

    if thisBase.connection==ee.enum.Connection.wye
        thisBase.V=thisBase.VRated./sqrt(3);
    elseif thisBase.connection==ee.enum.Connection.delta1
        thisBase.V=thisBase.VRated;
    else
        thisBase.V=thisBase.VRated;
    end

    thisBase.v=sqrt(2)*thisBase.V;
    thisBase.I=thisBase.SPerPhase./thisBase.V;
    thisBase.i=sqrt(2)*thisBase.I;
    thisBase.Z=thisBase.V^2./thisBase.SPerPhase;
    thisBase.R=thisBase.Z;
    thisBase.X=thisBase.Z;
    thisBase.Y=thisBase.SPerPhase./thisBase.V^2;
    thisBase.G=thisBase.Y;
    thisBase.B=thisBase.Y;
    thisBase.wElectrical=2*pi*thisBase.FRated;
    thisBase.L=thisBase.X./thisBase.wElectrical;
    thisBase.C=1./(thisBase.X*thisBase.wElectrical);
    thisBase.psi=thisBase.L*thisBase.i;
    thisBase.Psi=thisBase.psi./sqrt(2);

end