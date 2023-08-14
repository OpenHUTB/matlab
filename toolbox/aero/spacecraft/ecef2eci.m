function[r_eci,varargout]=ecef2eci(utc,r_ecef,varargin)








    if~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAeroTlbx'));
    end


    narginchk(2,14);
    nargoutchk(1,3);
    p=inputParser;
    addRequired(p,'utc',@(x)Aero.internal.validation.validateScalarDatetimeOrDateVector(x,'ecef2eci','UTC'));
    addRequired(p,'r_ecef',@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'ecef2eci','ECEF position'));
    addOptional(p,'v_ecef',[nan,nan,nan],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'ecef2eci','ECEF velocity'));
    addOptional(p,'a_ecef',[nan,nan,nan],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'ecef2eci','ECEF acceleration'));
    addParameter(p,'dAT',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'ecef2eci','TAI-UTC'));
    addParameter(p,'dUT1',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'ecef2eci','UTC-UT1'));
    addParameter(p,'pm',[0,0],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',2},'ecef2eci','polar displacement'));
    addParameter(p,'dCIP',[0,0],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',2},'ecef2eci','CIP adjustment'));
    addParameter(p,'lod',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'ecef2eci','excess length of day'));
    parse(p,utc,r_ecef,varargin{:});

    r_ecef=p.Results.r_ecef(:);
    v_ecef=p.Results.v_ecef(:);
    a_ecef=p.Results.a_ecef(:);


    utc=p.Results.utc;
    if isa(utc,"datetime")

        utc=Aero.internal.math.createDateVec(utc);
    end


    omega=[0,0,7292115e-11*(1-p.Results.lod/86400)]';



    pm=p.Results.pm*pi/180;

    ssTT=utc(6)+p.Results.dAT+32.184;

    jdTT=mjuliandate(utc(1),utc(2),utc(3),utc(4),utc(5),ssTT);

    tTT=(jdTT-51544.5)/36525;

    sp=convang(-0.000047*tTT/3600,'deg','rad');


    R_pm=angle2dcm(sp,-pm(1),-pm(2),'ZYX')';


    R_woPM=dcmeci2ecef('IAU-2000/2006',utc,p.Results.dAT,...
    p.Results.dUT1,'dCIP',p.Results.dCIP*pi/180)';


    r_pef=R_pm'*r_ecef(:);

    r_eci=R_woPM*r_pef;

    if nargout>1

        v_pef=R_pm'*v_ecef(:);

        v_eci=R_woPM*(v_pef+cross(omega,r_pef));
        varargout{1}=v_eci;
    end

    if nargout>2

        a_eci=R_woPM*(R_pm'*a_ecef+cross(omega,cross(omega,r_pef))+2*cross(omega,v_pef));
        varargout{2}=a_eci;
    end
end
