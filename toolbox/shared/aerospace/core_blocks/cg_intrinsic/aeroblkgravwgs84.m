function grav=aeroblkgravwgs84(lla,method,units,no_atmos,...
    precessing,nocentrifugal,jd_loc,jDate,day,month,year)






%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    method=double(method);
    units=double(units);
    day=double(day);
    month=double(month);
    year=double(year);

    maxAlt=20000;
    deg2rad=pi/180;


    if units==1
        in_conv=.3048;
        out_conv=1/.3048;
    else
        in_conv=1;
        out_conv=1;
    end


    if all(size(lla)>1)
        lat=lla(:,1).*deg2rad;
        lon=lla(:,2).*deg2rad;
        alt=lla(:,3).*in_conv;
    else
        lat=lla(1)*deg2rad;
        lon=lla(2)*deg2rad;
        alt=lla(3)*in_conv;
    end


    model_data.noatmos=no_atmos;
    model_data.precessing=precessing;
    model_data.JD=jDate;
    model_data.nocentrifugal=nocentrifugal;
    model_data.WGS=loadParams();


    phi_wrapped=false(size(lat));
    for i=1:length(lat)
        [lat(i),phi_wrapped(i)]=aeroblkphiWrap(lat(i));
    end

    grav=zeros(size(lla));
    grav_T=zeros(size(lat));
    grav_N=zeros(size(lat));

    switch method
    case 0

        grav_N=wgs84_taylor_series(...
        alt,lat,model_data,out_conv);


    case 1

        [E2,GM,lon,model_data]=shared_utils(lon,phi_wrapped,...
        day,month,year,model_data,jd_loc);

        grav_N=wgs84_approx(alt,lat,lon,model_data,E2,GM,...
        out_conv);

    case 2

        [E2,GM,lon,model_data]=shared_utils(lon,phi_wrapped,...
        day,month,year,model_data,jd_loc);

        [grav_N,grav_T]=wgs84_exact(...
        alt,lat,lon,model_data,E2,GM,out_conv);
    end

    if all(size(lla)>1)
        grav(1:length(grav_N),3)=grav_N(:);
        grav(1:length(grav_T),1)=grav_T(:);
    else
        grav(3)=grav_N;
        grav(1)=grav_T;
    end



end




function[gamma_h]=wgs84_taylor_series(...
    h,phi,udata,out_conv_factor)

    WGS=udata.WGS;
    gamma_h=zeros(numel(h));
    for i=1:numel(h)

        sinphi=sin(phi(i));
        sin2phi=sinphi*sinphi;


        gamma_ts=WGS.gamma_e*(1+WGS.k*sin2phi)/...
        sqrt(1-WGS.e2*sin2phi);

        m=WGS.a*WGS.a*WGS.b*WGS.omega_default*WGS.omega_default/...
        WGS.GM_default;


        gamma_h(i)=out_conv_factor*gamma_ts*...
        (1-2*(1+1/WGS.inv_f+m-2*sin2phi/WGS.inv_f)...
        *h(i)/WGS.a+3*h(i)*h(i)/(WGS.a*WGS.a));
    end

end


function[gamma_h]=wgs84_approx(...
    h,phi,lambda,udata,E2,GM,out_conv_factor)

    gamma_h=zeros(numel(h));
    for i=1:numel(h)

        sinphi=sin(phi(i));
        sin2phi=sinphi*sinphi;
        cosphi=cos(phi(i));
        coslambda=cos(lambda(i));
        sinlambda=sin(lambda(i));

        [gamma_u,gamma_beta]=wgs84_calc_shared_vars(udata,h(i),...
        E2,cosphi,sinphi,sin2phi,coslambda,sinlambda,GM);


        gamma_h(i)=out_conv_factor*...
        sqrt(gamma_u*gamma_u+gamma_beta*gamma_beta);
    end

end

function[gamma_h,gamma_phi]=wgs84_exact(...
    h,phi,lambda,udata,E2,GM,out_conv_factor)

    gamma_h=zeros(numel(h));
    gamma_phi=zeros(numel(h));
    for i=1:numel(h)

        sinphi=sin(phi(i));
        sin2phi=sinphi*sinphi;
        cosphi=cos(phi(i));
        coslambda=cos(lambda(i));
        sinlambda=sin(lambda(i));
        tanphi=sinphi/cosphi;


        psi=atan(tanphi*(1-1/udata.WGS.inv_f)*(1-1/udata.WGS.inv_f));

        cospsi=cos(psi);
        sinpsi=sin(psi);


        alpha=phi(i)-psi;

        cosalpha=cos(alpha);
        sinalpha=sin(alpha);

        [gamma_u,gamma_beta,cosbeta,sinbeta,u,u2E2,w]=...
        wgs84_calc_shared_vars(udata,h(i),E2,cosphi,sinphi,...
        sin2phi,coslambda,sinlambda,GM);

        gamma_r=(cosbeta*cospsi*u/(w*sqrt(u2E2))+sinbeta*sinpsi/w)*...
        gamma_u+(sinpsi*cosbeta*u/(w*sqrt(u2E2))-...
        sinbeta*cospsi/w)*gamma_beta;

        gamma_psi=(sinbeta*cospsi/w-sinpsi*cosbeta*u/(w*sqrt(u2E2)))*...
        gamma_u+(cosbeta*cospsi*u/(w*sqrt(u2E2))+...
        sinbeta*sinpsi/w)*gamma_beta;


        gamma_h(i)=out_conv_factor*...
        ((-gamma_r)*cosalpha-gamma_psi*sinalpha);


        gamma_phi(i)=out_conv_factor*...
        ((-gamma_r)*sinalpha+gamma_psi*cosalpha);

    end
end


function[gamma_u,gamma_beta,cosbeta,sinbeta,u,u2E2,w]=...
    wgs84_calc_shared_vars(udata,h,E2,cosphi,sinphi,...
    sin2phi,coslambda,sinlambda,GM)

    WGS=udata.WGS;


    N=WGS.a/(sqrt(1-WGS.e2*sin2phi));


    x_rec=(N+h)*cosphi*coslambda;
    y_rec=(N+h)*cosphi*sinlambda;
    z_rec=(WGS.b_over_a*WGS.b_over_a*N+h)*sinphi;


    D=x_rec*x_rec+y_rec*y_rec+z_rec*z_rec-E2;
    u2=0.5*D*(1+sqrt(1+4*E2*z_rec*z_rec/(D*D)));
    u2E2=u2+E2;


    u=sqrt(u2);


    beta=atan(z_rec*sqrt(u2E2)/(u*sqrt(x_rec*x_rec+y_rec*y_rec)));


    sinbeta=sin(beta);
    sin2beta=sinbeta*sinbeta;
    cosbeta=cos(beta);
    cos2beta=cosbeta*cosbeta;


    w=sqrt((u2+E2*sin2beta)/u2E2);


    q=0.5*((1+3*u2/(E2))*atan(WGS.E/u)-3*u/WGS.E);


    qo=0.5*((1+3*WGS.b*WGS.b/E2)*atan(WGS.E/WGS.b)...
    -3*WGS.b/WGS.E);


    q_prime=3*((1+u2/(E2))*(1-(u/WGS.E)*atan(WGS.E/u)))-1.0;


    if~udata.precessing
        omega=WGS.omega_default;
    else

        omega=WGS.omega_prime+7.086e-12+...
        4.3e-15*((udata.JD-2451545)/36525);
    end


    if~udata.nocentrifugal
        cf_u=u*cos2beta*omega*omega/w;
        cf_beta=sqrt(u2E2)*cosbeta*sinbeta*omega*omega/w;
    else
        cf_u=0;
        cf_beta=0;
    end


    gamma_u=-(GM/u2E2+omega*omega*WGS.a*WGS.a*WGS.E*q_prime*...
    (0.5*sin2beta-1/6)/(u2E2*qo))/w+cf_u;


    gamma_beta=omega*omega*WGS.a*WGS.a*q*sinbeta*cosbeta/...
    (sqrt(u2E2)*w*qo)-cf_beta;

end


function[E2,GM,lambda,model_data]=shared_utils(lambda,phi_wrapped,...
    day,month,year,model_data,jd_loc)


    E2=model_data.WGS.E*model_data.WGS.E;

    if~model_data.noatmos
        GM=model_data.WGS.GM_default;
    else
        GM=model_data.WGS.GM_prime;
    end

    if~jd_loc
        [day,month,year]=aeroblkisDateValid(day,month,year,2000);
        model_data.JD=aeroblkcalcJulianDate(day,month,year);
    end
    for i=1:length(lambda)
        lambda(i)=aeroblklambdaWrap(lambda(i),phi_wrapped(i));
    end

end


function prms=loadParams()

    prms.a=6378137.0;
    prms.inv_f=298.257223563;
    prms.omega_default=7292115.0e-11;
    prms.GM_default=3986004.418e+8;
    prms.GM_prime=3986000.9e+8;
    prms.omega_prime=7292115.1467e-11;
    prms.gamma_e=9.7803253359;

    prms.k=0.00193185265241;
    prms.e2=6.69437999014e-3;
    prms.E=5.2185400842339e+5;
    prms.b=6356752.3142;
    prms.b_over_a=0.996647189335;

end


