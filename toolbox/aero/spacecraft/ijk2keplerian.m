function[a,ecc,incl,RAAN,argp,nu,truelon,arglat,lonper]=ijk2keplerian(r_ijk,v_ijk)








    if~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAeroTlbx'));
    end


    narginchk(2,2);
    p=inputParser;
    addRequired(p,'r_ijk',@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'ijk2keplerian','IJK position'));
    addRequired(p,'v_ijk',@(x)validateattributes(x,{'numeric'},{'real','finite','nonnan','numel',3},'ijk2keplerian','IJK velocity'));
    parse(p,r_ijk,v_ijk);

    r_ijk=p.Results.r_ijk(:)/1000;
    v_ijk=p.Results.v_ijk(:)/1000;

    RAAN=nan;argp=nan;nu=nan;
    arglat=nan;truelon=nan;lonper=nan;

    small=1e-12;
    mu=398600.4418;


    r=norm(r_ijk);
    v=norm(v_ijk);


    h_vec=cross(r_ijk,v_ijk);
    h=norm(h_vec);

    if h>small
        n_vec=cross([0,0,1],h_vec);
        n=norm(n_vec);


        e_vec=((v*v-mu/r).*r_ijk-dot(r_ijk,v_ijk).*v_ijk)/mu;
        ecc=norm(e_vec);

        energy=(v*v/2)-(mu/r);

        if abs(energy)>small
            a=-mu/(2*energy);
        else
            a=inf;
        end


        incl=acos(min(max(h_vec(3)/h,-1),1));


        if n>small
            RAAN=acos(min(max(n_vec(1)/n,-1),1));
            if n_vec(2)<0
                RAAN=2*pi-RAAN;
            end
        end


        if ecc<small
            if incl<small||abs(incl-pi)<small

                truelon=acos(min(max(r_ijk(1)/r,-1),1));
                if r_ijk(2)<0||incl>pi/2
                    truelon=2*pi-truelon;
                end
            else

                arglat=acos(min(max(dot(n_vec,r_ijk)/(n*r),-1),1));
                if r_ijk(3)<0
                    arglat=2*pi-arglat;
                end
            end

        else

            nu=acos(min(max(dot(e_vec,r_ijk)/(ecc*r),-1),1));
            if dot(r_ijk,v_ijk)<0
                nu=2*pi-nu;
            end

            if incl<small||abs(incl-pi)<small

                lonper=acos(min(max(e_vec(1)/ecc,-1),1));
                if e_vec(2)<0||incl>pi/2
                    lonper=2*pi-lonper;
                end
            else

                argp=acos(min(max(dot(n_vec,e_vec)/(n*ecc),-1),1));
                if e_vec(3)<0
                    argp=2*pi-argp;
                end
            end
        end
        a=a*1000;
        incl=incl*180/pi;
        RAAN=RAAN*180/pi;
        argp=argp*180/pi;
        nu=nu*180/pi;
        truelon=truelon*180/pi;
        arglat=arglat*180/pi;
        lonper=lonper*180/pi;
    else
        error(message('spacecraft:cubesat:AngMomZero'));
    end
end
