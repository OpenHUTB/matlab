function[r_ecef,varargout]=eci2ecef(utc,r_eci,varargin)








    if~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAeroTlbx'));
    end


    narginchk(2,14);
    nargoutchk(1,3);
    p=inputParser;
    addRequired(p,'utc',@(x)Aero.internal.validation.validateScalarDatetimeOrDateVector(x,'eci2ecef','UTC'));
    addRequired(p,'r_eci',@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'eci2ecef','ECI position'));
    addOptional(p,'v_eci',[nan,nan,nan],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'eci2ecef','ECI velocity'));
    addOptional(p,'a_eci',[nan,nan,nan],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'eci2ecef','ECI acceleration'));
    addParameter(p,'dAT',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'eci2ecef','TAI-UTC'));
    addParameter(p,'dUT1',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'eci2ecef','UTC-UT1'));
    addParameter(p,'pm',[0,0],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',2},'eci2ecef','polar displacement'));
    addParameter(p,'dCIP',[0,0],@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',2},'eci2ecef','CIP adjustment'));
    addParameter(p,'lod',0,@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','scalar'},'eci2ecef','excess length of day'));
    parse(p,utc,r_eci,varargin{:});

    r_eci=p.Results.r_eci(:);
    v_eci=p.Results.v_eci(:);
    a_eci=p.Results.a_eci(:);


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


    R_pm=angle2dcm(sp,-pm(1),-pm(2),'ZYX');


    R_woPM=dcmeci2ecef('IAU-2000/2006',utc,p.Results.dAT,...
    p.Results.dUT1,'dCIP',p.Results.dCIP*pi/180);


    r_pef=R_woPM*r_eci(:);

    r_ecef=R_pm*r_pef;

    if nargout>1

        v_pef=R_woPM*v_eci(:)-cross(omega,r_pef);

        v_ecef=R_pm*v_pef;
        varargout{1}=v_ecef;
    end

    if nargout>2

        a_ecef=R_pm*(R_woPM*a_eci-cross(omega,cross(omega,r_pef))-...
        2*cross(omega,v_pef));
        varargout{2}=a_ecef;
    end
end
