function[r_ijk,v_ijk]=keplerian2ijk(a,ecc,incl,RAAN,argp,nu,varargin)








    if~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAeroTlbx'));
    end


    narginchk(6,9);
    p=inputParser;
    addRequired(p,'a',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative'},'keplerian2ijk','semi-major axis'));
    addRequired(p,'ecc',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative'},'keplerian2ijk','eccentricity'));
    addRequired(p,'incl',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative','<=',180},'keplerian2ijk','inclination'));
    addRequired(p,'RAAN',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative','<=',360},'keplerian2ijk','RAAN'));
    addRequired(p,'argp',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative','<=',360},'keplerian2ijk','argument of periapsis'));
    addRequired(p,'nu',@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnan','nonnegative','<=',360},'keplerian2ijk','true anomoly'));
    addParameter(p,'truelon',nan,@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnegative','<=',360},'keplerian2ijk','true longitude'));
    addParameter(p,'arglat',nan,@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnegative','<=',360},'keplerian2ijk','argument of latitude'));
    addParameter(p,'lonper',nan,@(x)validateattributes(x,{'numeric'},{'real','scalar','finite','nonnegative','<=',360},'keplerian2ijk','longitude of periapsis'));
    parse(p,a,ecc,incl,RAAN,argp,nu,varargin{:});



    [r_pqw,v_pqw]=keplerian2pqw(p.Results.a,p.Results.ecc,p.Results.incl,p.Results.nu,p.Results.truelon,p.Results.arglat);

    incl=p.Results.incl*pi/180;
    RAAN=p.Results.RAAN*pi/180;
    argp=p.Results.argp*pi/180;

    small=1e-12;


    if p.Results.ecc<small
        if incl<small||abs(incl-pi)<small
            argp=0;
            RAAN=0;
        else
            argp=0;
        end
    else
        if incl<small||abs(incl-pi)<small
            if~isnan(p.Results.lonper)
                lonper=p.Results.lonper*pi/180;
            else
                error(message('spacecraft:cubesat:LonPerRequired'));
            end
            argp=lonper;
            RAAN=0;
        end
    end


    pqw2ijk=rot3(-RAAN)*rot1(-incl)*rot3(-argp);

    r_ijk=pqw2ijk*r_pqw(:);
    v_ijk=pqw2ijk*v_pqw(:);
end

function rotm=rot1(ang)
    sa=sin(ang);
    ca=cos(ang);
    rotm=[1,0,0;0,ca,sa;0,-sa,ca];
end

function rotm=rot3(ang)
    sa=sin(ang);
    ca=cos(ang);
    rotm=[ca,sa,0;-sa,ca,0;0,0,1];
end

function[r_pqw,v_pqw]=keplerian2pqw(a,ecc,incl,nu,truelon,arglat)


















































    a=a/1000;
    incl=incl*pi/180;
    nu=nu*pi/180;

    small=1e-12;
    mu=398600.4418;


    if ecc<small
        if incl<small||abs(incl-pi)<small
            if~isnan(truelon)
                truelon=truelon*pi/180;
            else
                error(message('spacecraft:cubesat:TrueLonRequired'));
            end
            nu=truelon;
        else
            if~isnan(arglat)
                arglat=arglat*pi/180;
            else
                error(message('spacecraft:cubesat:ArgLatRequired'));
            end
            nu=arglat;
        end
    end


    if ecc<small
        slr=a;
    elseif abs(ecc-1)<small
        warning(message('spacecraft:cubesat:ParabolicOrbit'));
        slr=2*a;
    elseif ecc>1
        warning(message('spacecraft:cubesat:HyperbolicOrbit'));
        slr=a*(ecc^2-1);
    else
        slr=a*(1-ecc^2);
    end



    cosnu=cos(nu);
    sinnu=sin(nu);
    pqw_denom=1+ecc*cosnu;
    r_pqw(1)=slr*cosnu/pqw_denom;
    r_pqw(2)=slr*sinnu/pqw_denom;
    r_pqw(3)=0;

    if abs(slr)<0.0001
        slr=0.0001;
    end
    v_pqw(1)=-sinnu*sqrt(mu/slr);
    v_pqw(2)=(ecc+cosnu)*sqrt(mu/slr);
    v_pqw(3)=0;

    r_pqw=r_pqw(:)*1000;
    v_pqw=v_pqw(:)*1000;
end



