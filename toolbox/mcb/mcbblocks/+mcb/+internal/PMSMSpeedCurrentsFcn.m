function[operatingPoint,status_ok]=PMSMSpeedCurrentsFcn(pmsm,...
    inverter,seed,solveType,varargin)
    [licenseStatus,licenseerror]=builtin('license','checkout','Motor_Control_Blockset');
    if licenseStatus==0
        error(licenseerror);
    end

    p=inputParser;
    addRequired(p,'pmsm',@(x)isstruct(x)&&min(isfield(x,{'p','Rs','Ld','Lq','FluxPM','B','I_rated'})));
    addRequired(p,'inverter',@(x)isstruct(x)&&min(isfield(x,{'V_dc'})));
    addRequired(p,'seed',@(x)isstruct(x));
    addRequired(p,'solveType',@(x)isnumeric(x)&&isfinite(x));
    addParameter(p,'loopLimit',10000,@(x)isnumeric(x)&&isfinite(x)&&(x<1e6&&x>1000));
    addParameter(p,'reductionFactor',0.01,@(x)isnumeric(x)&&isfinite(x)&&(x>0&&x<=1));
    addParameter(p,'voltageEquation','actual',@(x)any(ismember(lower(x)...
    ,{'actual','approximate'})));
    addParameter(p,'outputAll',0,@(x)any(ismember(x,[1,0])));
    parse(p,pmsm,inverter,seed,solveType,varargin{:});

    pmsm=p.Results.pmsm;
    inverter=p.Results.inverter;
    if~isfield(inverter,'R_board')
        inverter.R_board=0;
    end
    seed=p.Results.seed;
    solveType=p.Results.solveType;

    loopLimit=p.Results.loopLimit;
    reductionFactor=p.Results.reductionFactor;
    voltageEquation=p.Results.voltageEquation;
    includeR=strcmpi(voltageEquation,'actual');

    outputAll=p.Results.outputAll;

    irdropVcc=1-includeR;

    stk=dbstack;
    calledFromAnother=0;
    if length(stk)>1
        calledFromAnother=1;
    end

    Bv=pmsm.B;

    if pmsm.Lq<pmsm.Ld
        Lq=pmsm.Ld;
        Ld=pmsm.Lq;
        if calledFromAnother==0
            disp(message('mcb:blocks:APILqLessThanLdSwapping').getString());
        end
    else
        Ld=pmsm.Ld;
        Lq=pmsm.Lq;
    end
    Pp=pmsm.p;
    Irated=pmsm.I_rated;
    fluxPM=pmsm.FluxPM;
    R=pmsm.Rs;

    I_short=inverter.V_dc/sqrt(3)/R;

    if Irated>(I_short)
        Irated=I_short;
    end

    vmax=inverter.V_dc/sqrt(3)-(irdropVcc)*(pmsm.Rs+inverter.R_board)*Irated;

    if includeR==0
        R=0;
    end

    elec2mech=1/Pp;

    Bv=Bv*elec2mech;

    status_ok=1;
    switch solveType
    case 1
        L=Ld;
        nr.a=fluxPM/L;
        nr.a2=fluxPM^2/L^2;
        nr.b=R/L;
        nr.b2=R^2/L^2;
        nr.c=Irated^2;
        nr.d=vmax^2/L^2;

        iterationcount=0;
        xseed=[seed.id;seed.iq;seed.w];
        thiserror=[1;1;1];
        xold=xseed;
        x=xold(1);y=xold(2);
        while((thiserror(1)>1e-6||thiserror(2)>1e-6||thiserror(3)>1e-3||x>0...
            ||y<0)&&(iterationcount<loopLimit))
            x=xold(1);y=xold(2);z=xold(3);
            F=[x+z^2*nr.a/(nr.b2+z^2);(x^2+y^2-nr.c);
            ((x^2+y^2)*(nr.b2+z^2)+z^2*nr.a2+2*z*nr.a*(z*x+y*nr.b)-nr.d)];
            J=[(1),(0),(2*z*nr.a/(nr.b2+z^2)-2*nr.a*z^3/(nr.b2+z^2)^2);
            (2*x),(2*y),(0);
            (2*x*(nr.b2+z^2)+2*z^2*nr.a)...
            ,(2*y*(nr.b2+z^2)+2*z*nr.a*nr.b)...
            ,(2*z*(x^2+y^2+nr.a2+2*nr.a*x)+2*y*nr.a*nr.b)];
            xnew=xold-reductionFactor*J^-1*F;
            thiserror=xnew-xold;
            thiserror=abs(thiserror);
            xold=xnew;
            iterationcount=iterationcount+1;
        end
        if outputAll==1
            operatingPoint=xnew;
        else
            operatingPoint=xnew(3);
        end
        if iterationcount>=loopLimit
            status_ok=0;
        end
    case 2
        L=Ld;
        nr.a=fluxPM/L;
        nr.a2=fluxPM^2/L^2;
        nr.b=R/L;
        nr.b2=R^2/L^2;
        nr.c=1.5*Pp*fluxPM/Bv;
        nr.d=vmax^2/L^2;

        iterationcount=0;
        xseed=[seed.id;seed.iq;seed.w];
        thiserror=[1;1;1];
        xold=xseed;
        x=xold(1);y=xold(2);
        while((thiserror(1)>1e-6||thiserror(2)>1e-6||thiserror(3)>1e-3...
            ||x>0||y<0)&&(iterationcount<loopLimit))
            x=xold(1);y=xold(2);z=xold(3);

            F=[x+z^2*nr.a/(nr.b2+z^2);(y*nr.c-z);
            ((x^2+y^2)*(nr.b2+z^2)+z^2*nr.a2+2*z*nr.a*(z*x+y*nr.b)-nr.d)];
            J=[(1),(0),(2*z*nr.a/(nr.b2+z^2)-2*nr.a*z^3/(nr.b2+z^2)^2);
            (0),(nr.c),(-1);
            (2*x*(nr.b2+z^2)+2*z^2*nr.a)...
            ,(2*y*(nr.b2+z^2)+2*z*nr.a*nr.b)...
            ,(2*z*(x^2+y^2+nr.a2+2*nr.a*x)+2*y*nr.a*nr.b)];

            xnew=xold-reductionFactor*J^-1*F;
            thiserror=xnew-xold;
            thiserror=abs(thiserror);
            xold=xnew;
            iterationcount=iterationcount+1;
        end
        if outputAll==1
            operatingPoint=xnew;
        else
            operatingPoint=xnew(3);
        end
        if iterationcount>=loopLimit
            status_ok=0;
        end
    case 3
        nr.a=Irated^2;
        nr.b=R^2;
        nr.c=Ld*Lq;
        nr.d=Lq^2;
        nr.e=Ld-Lq;
        nr.f=Ld+Lq;
        nr.g=2*Ld-Lq;
        nr.h=vmax^2;
        nr.k=Lq^2*Ld;

        iterationcount=0;
        xseed=[seed.id;seed.iq;seed.w];
        thiserror=[1;1;1];
        xold=xseed;
        x=xold(1);y=xold(2);
        while((thiserror(1)>1e-6||thiserror(2)>1e-6||thiserror(3)>1e-3...
            ||x>0||y<0)&&(iterationcount<loopLimit))
            x=xold(1);y=xold(2);z=xold(3);
            F=[(x^2+y^2-nr.a);((x*R-y*z*Lq)^2+(y*R+x*z*Ld+z*fluxPM)^2-nr.h);
            (((x*R-y*z*Lq)^2*(nr.b-z^2*nr.c))...
            +((x*R-y*z*Lq)*fluxPM*R*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +((x*R-y*z*Lq)*(y*R+x*z*Ld+z*fluxPM)*2*R*z*nr.f)...
            -((y*R+x*z*Ld+z*fluxPM)^2*(nr.b-z^2*nr.c))...
            +((y*R+x*z*Ld+z*fluxPM)*z*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))
            ];
            J=[(2*x),(2*y),(0);
            (2*R*(x*R-y*z*Lq)+2*z*Ld*(y*R+x*z*Ld+z*fluxPM))...
            ,(-2*z*Lq*(x*R-y*z*Lq)+2*R*(y*R+x*z*Ld+z*fluxPM))...
            ,(-2*y*Lq*(x*R-y*z*Lq)+2*(x*Ld+fluxPM)*(y*R+x*z*Ld+z*fluxPM));
            ((x*R-y*z*Lq)*2*R*(nr.b-z^2*nr.c)+(R^2*fluxPM*(nr.b...
            +2*z^2*nr.d-z^2*nr.c)/nr.e)+(2*R*z*nr.f*(R*(y*R+x*z*Ld...
            +z*fluxPM)+z*Ld*(x*R-y*z*Lq)))-((y*R+x*z*Ld...
            +z*fluxPM)*2*z*Ld*(nr.b-z^2*nr.c))...
            +(z^2*Ld*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))...
            ,((x*R-y*z*Lq)*2*(-z*Lq)*(nr.b-z^2*nr.c)...
            +(R*(-z*Lq)*fluxPM*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +(2*R*z*nr.f*((-z*Lq)*(y*R+x*z*Ld+z*fluxPM)...
            +R*(x*R-y*z*Lq)))-((y*R+x*z*Ld+z*fluxPM)*2*R*(nr.b...
            -z^2*nr.c))+(z*R*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))...
            ,((x*R-y*z*Lq)*2*(-y*Lq)*(nr.b-z^2*nr.c)...
            +(R*(-y*Lq)*fluxPM*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +(2*R*z*nr.f*((-y*Lq)*(y*R+x*z*Ld+z*fluxPM)...
            +(x*Ld+fluxPM)*(x*R-y*z*Lq)))-((y*R+x*z*Ld...
            +z*fluxPM)*2*(x*Ld+fluxPM)*(nr.b-z^2*nr.c))...
            +(z*(x*Ld+fluxPM)*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e)...
            +((x*R-y*z*Lq)^2*(-z*2*nr.c))+((x*R...
            -y*z*Lq)*fluxPM*R*(2*z*2*nr.d-z*2*nr.c)/nr.e)+((x*R...
            -y*z*Lq)*(y*R+x*z*Ld+z*fluxPM)*2*R*nr.f)-((y*R...
            +x*z*Ld+z*fluxPM)^2*(-z*2*nr.c))+((y*R+x*z*Ld...
            +z*fluxPM)*fluxPM*(3*z^2*nr.k)/nr.e))];
            xnew=xold-reductionFactor*J^-1*F;
            thiserror=xnew-xold;
            thiserror=abs(thiserror);
            xold=xnew;
            iterationcount=iterationcount+1;
        end
        if outputAll==1
            operatingPoint=xnew;
        else
            operatingPoint=xnew(3);
        end
        if iterationcount>=loopLimit
            status_ok=0;
        end

    case 4
        nr.b=R^2;
        nr.c=Ld*Lq;
        nr.d=Lq^2;
        nr.e=Ld-Lq;
        nr.f=Ld+Lq;
        nr.g=2*Ld-Lq;
        nr.h=vmax^2;
        nr.k=Lq^2*Ld;
        nr.m=1.5*Pp*nr.e/Bv;
        nr.n=1.5*Pp*fluxPM/Bv;

        iterationcount=0;
        xseed=[seed.id;seed.iq;seed.w];
        thiserror=[1;1;1];
        xold=xseed;
        x=xold(1);y=xold(2);
        while((thiserror(1)>1e-6||thiserror(2)>1e-6||thiserror(3)>1e-3...
            ||x>0||y<0)&&(iterationcount<loopLimit))
            x=xold(1);y=xold(2);z=xold(3);
            F=[(nr.m*x*y+nr.n*y-z);((x*R-y*z*Lq)^2+(y*R+x*z*Ld...
            +z*fluxPM)^2-nr.h);
            (((x*R-y*z*Lq)^2*(nr.b-z^2*nr.c))+((x*R...
            -y*z*Lq)*fluxPM*R*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +((x*R-y*z*Lq)*(y*R+x*z*Ld+z*fluxPM)*2*R*z*nr.f)...
            -((y*R+x*z*Ld+z*fluxPM)^2*(nr.b-z^2*nr.c))+((y*R+x*z*Ld...
            +z*fluxPM)*z*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))
            ];
            J=[(nr.m*y),(nr.m*x+nr.n),(-1);
            (2*R*(x*R-y*z*Lq)+2*z*Ld*(y*R+x*z*Ld+z*fluxPM))...
            ,(-2*z*Lq*(x*R-y*z*Lq)+2*R*(y*R+x*z*Ld+z*fluxPM))...
            ,(-2*y*Lq*(x*R-y*z*Lq)+2*(x*Ld+fluxPM)*(y*R+x*z*Ld+z*fluxPM));
            ((x*R-y*z*Lq)*2*R*(nr.b-z^2*nr.c)+(R^2*fluxPM*(nr.b...
            +2*z^2*nr.d-z^2*nr.c)/nr.e)+(2*R*z*nr.f*(R*(y*R...
            +x*z*Ld+z*fluxPM)+z*Ld*(x*R-y*z*Lq)))-((y*R+x*z*Ld...
            +z*fluxPM)*2*z*Ld*(nr.b-z^2*nr.c))...
            +(z^2*Ld*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))...
            ,((x*R-y*z*Lq)*2*(-z*Lq)*(nr.b-z^2*nr.c)...
            +(R*(-z*Lq)*fluxPM*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +(2*R*z*nr.f*((-z*Lq)*(y*R+x*z*Ld+z*fluxPM)...
            +R*(x*R-y*z*Lq)))-((y*R+x*z*Ld+z*fluxPM)*2*R*(nr.b...
            -z^2*nr.c))+(z*R*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e))...
            ,((x*R-y*z*Lq)*2*(-y*Lq)*(nr.b-z^2*nr.c)...
            +(R*(-y*Lq)*fluxPM*(nr.b+2*z^2*nr.d-z^2*nr.c)/nr.e)...
            +(2*R*z*nr.f*((-y*Lq)*(y*R+x*z*Ld+z*fluxPM)+(x*Ld...
            +fluxPM)*(x*R-y*z*Lq)))-((y*R+x*z*Ld+z*fluxPM)*2*(x*Ld...
            +fluxPM)*(nr.b-z^2*nr.c))+(z*(x*Ld...
            +fluxPM)*fluxPM*(nr.b*nr.g+z^2*nr.k)/nr.e)...
            +((x*R-y*z*Lq)^2*(-z*2*nr.c))+((x*R...
            -y*z*Lq)*fluxPM*R*(2*z*2*nr.d-z*2*nr.c)/nr.e)...
            +((x*R-y*z*Lq)*(y*R+x*z*Ld+z*fluxPM)*2*R*nr.f)...
            -((y*R+x*z*Ld+z*fluxPM)^2*(-z*2*nr.c))+((y*R+x*z*Ld...
            +z*fluxPM)*fluxPM*(3*z^2*nr.k)/nr.e))];
            xnew=xold-reductionFactor*J^-1*F;
            thiserror=xnew-xold;
            thiserror=abs(thiserror);
            xold=xnew;
            iterationcount=iterationcount+1;
        end
        if outputAll==1
            operatingPoint=xnew;
        else
            operatingPoint=xnew(3);
        end
        if iterationcount>=loopLimit
            status_ok=0;
        end
    case 5
        id_mtpa=(-fluxPM+sqrt(fluxPM^2+8*Irated^2*(Ld...
        -Lq)^2))/(4*(Ld-Lq));
        iq_mtpa=sqrt(Irated^2-id_mtpa^2);
        coeff.a=(fluxPM+id_mtpa*Ld)^2+Lq^2*iq_mtpa^2;
        coeff.b=2*iq_mtpa*R*fluxPM+2*id_mtpa*iq_mtpa*R*(Ld-Lq);
        coeff.c=Irated^2*R^2-vmax^2;
        w_corner=roots([coeff.a,coeff.b,coeff.c]);
        w_corner=w_corner(imag(w_corner)==0);
        w_corner=w_corner(w_corner>=0);
        if isempty(w_corner)
            w_corner=0;
        end
        if outputAll==1
            operatingPoint=[id_mtpa;iq_mtpa;w_corner];
        else
            operatingPoint=w_corner;
        end
    case 6
        L=Ld;
        coeff.a=fluxPM^2+(L^2*Irated^2);
        coeff.b=2*Irated*R*fluxPM;
        coeff.c=(Irated^2*R^2)-vmax^2;
        w_corner=roots([coeff.a,coeff.b,coeff.c]);
        w_corner=w_corner(imag(w_corner)==0);
        w_corner=w_corner(w_corner>=0);
        id_mtpa=0;
        iq_mtpa=Irated;
        if isempty(w_corner)
            w_corner=0;
        end
        if outputAll==1
            operatingPoint=[id_mtpa;iq_mtpa;w_corner];
        else
            operatingPoint=w_corner;
        end
    case 7
        id_wmax_bv=roots([...
        (-(Ld-Lq)^2*(Ld^2-Lq^2))...
        ,(-((Ld-Lq)^2*2*Ld*fluxPM)...
        -(2*fluxPM*(Ld-Lq)*(Ld^2-Lq^2)))...
        ,(-((Ld-Lq)^2*(fluxPM^2+(2*R*Bv/(1.5*Pp))...
        +Lq^2*Irated^2))...
        -(4*fluxPM^2*Ld*(Ld-Lq))...
        +(((Ld-Lq)^2*Irated^2-fluxPM^2)*(Ld^2-Lq^2)))...
        ,(-(2*fluxPM*(Ld-Lq)*(fluxPM^2+(2*R*Bv/(1.5*Pp))...
        +Lq^2*Irated^2))...
        +(2*Ld*fluxPM*(Irated^2*(Ld-Lq)^2-fluxPM^2))...
        +(2*fluxPM*Irated^2*(Ld-Lq)*(Ld^2-Lq^2)))...
        ,(((Irated^2*(Ld-Lq)^2-fluxPM^2)*(fluxPM^2...
        +(2*R*Bv/(1.5*Pp))+Lq^2*Irated^2))...
        +(4*fluxPM^2*Ld*(Ld-Lq)*Irated^2)...
        +(Irated^2*fluxPM^2*(Ld^2-Lq^2)))...
        ,((2*fluxPM*(Ld-Lq)*Irated^2*(fluxPM^2...
        +(2*R*Bv/(1.5*Pp))+Lq^2*Irated^2))...
        +(2*Irated^2*fluxPM^3*Ld))...
        ,((Irated^2*fluxPM^2*(fluxPM^2+(2*R*Bv/(1.5*Pp))...
        +Lq^2*Irated^2))...
        +(Irated^2*R^2-vmax^2)*(Bv/(1.5*Pp))^2)...
        ]);
        id_wmax_bv=id_wmax_bv(imag(id_wmax_bv)==0);
        id_wmax_bv=id_wmax_bv((id_wmax_bv)<Irated);
        id_wmax_bv=id_wmax_bv((id_wmax_bv)>-Irated);
        id_wmax_bv=id_wmax_bv((id_wmax_bv)<=0);
        if isempty(id_wmax_bv)
            id_wmax_bv=0;
            iq_wmax_bv=0;
            w_max_bv=0;
        else
            iq_wmax_bv=sqrt(Irated^2-id_wmax_bv.^2);
            w_max_bv=1.5*Pp*iq_wmax_bv*(fluxPM+(Ld-Lq)*id_wmax_bv)/Bv;
        end
        if outputAll==1
            operatingPoint=[id_wmax_bv;iq_wmax_bv;w_max_bv];
        else
            operatingPoint=w_max_bv;
        end
    case 8
        L=Ld;
        coeff.a=Irated^2*L^2+fluxPM^2+2*R*Bv/(1.5*Pp);
        coeff.b=Irated^2*R^2-vmax^2;
        coeff.c=-2*L*fluxPM;
        coeff.d=Irated^2;
        coeff.e=(Bv/(1.5*Pp*fluxPM))^2;
        coeff.f=coeff.c^2*coeff.e;
        coeff.g=(coeff.a^2-coeff.c^2*coeff.d);
        coeff.h=2*coeff.a*coeff.b;
        coeff.k=coeff.b^2;        w_max_vclmt_bv=roots([coeff.f,0,coeff.g,0,coeff.h,0,coeff.k]);
        w_max_vclmt_bv=w_max_vclmt_bv(imag(w_max_vclmt_bv)==0);
        w_max_vclmt_bv=w_max_vclmt_bv(w_max_vclmt_bv>seed.w);
        w_max_vclmt_bv=max(w_max_vclmt_bv);
        if isempty(w_max_vclmt_bv)
            w_max_vclmt_bv=0;
        else
            iq_wmax_bv=Bv*w_max_vclmt_bv/(1.5*Pp*fluxPM);
            id_wmax_bv=-sqrt(Irated^2-iq_wmax_bv^2);
        end
        if outputAll==1
            operatingPoint=[id_wmax_bv;iq_wmax_bv;w_max_vclmt_bv];
        else
            operatingPoint=w_max_vclmt_bv;
        end
    case 9
        w=seed.w;
        coeff.a=fluxPM*R*(R^2+2*w^2*Lq^2-w^2*Ld*Lq)/((Ld...
        -Lq)*(R^2-w^2*Ld*Lq));
        coeff.b=2*R*w*(Ld+Lq)/(R^2-w^2*Ld*Lq);
        coeff.c=w*fluxPM*(-R^2*Ld-w^2*Lq^2*Ld-R^2*(Ld...
        -Lq))/((Ld-Lq)*(R^2-w^2*Ld*Lq));
        coeff.d=w*Ld*(w*Ld-coeff.b*R)-R^2;
        coeff.e=R*(R+coeff.b*w*Lq)-w^2*Lq^2;
        coeff.f=w*Ld*(R+coeff.b*w*Lq)+R*(w*Ld-coeff.b*R)+2*R*w*Lq;
        coeff.g=w*Ld*(coeff.c+w*fluxPM)+w*fluxPM*(w*Ld...
        -coeff.b*R)-R*coeff.a;
        coeff.h=w*fluxPM*(R+coeff.b*w*Lq)+R*(coeff.c...
        +w*fluxPM)+w*Lq*coeff.a;
        coeff.k=w*fluxPM*(coeff.c+w*fluxPM);
        coeff.m=R^2+w^2*Ld^2;
        coeff.n=R^2+w^2*Lq^2;
        coeff.p=2*w*R*(Ld-Lq);
        coeff.q=2*w^2*fluxPM*Ld;
        coeff.r=2*w*R*fluxPM;
        coeff.s=w^2*fluxPM^2-vmax^2;

        iterationcount=0;
        xseed=[seed.id;seed.iq];
        thiserror=[1;1];
        xold=xseed;
        x=xold(1);y=xold(2);
        while((thiserror(1)>1e-6||thiserror(2)>1e-6...
            ||x>0||y<0)&&(iterationcount<loopLimit))
            x=xold(1);y=xold(2);
            F=[coeff.d*x^2+coeff.e*y^2+coeff.f*x*y+coeff.g*x+coeff.h*y+coeff.k;
            coeff.m*x^2+coeff.n*y^2+coeff.p*x*y+coeff.q*x+coeff.r*y+coeff.s];
            J=[(2*x*coeff.d+coeff.f*y+coeff.g)...
            ,(2*y*coeff.e+coeff.f*x+coeff.h);...
            (2*x*coeff.m+coeff.p*y+coeff.q)...
            ,(2*y*coeff.n+coeff.p*x+coeff.r)];
            xnew=xold-reductionFactor*J^-1*F;
            thiserror=xnew-xold;
            thiserror=abs(thiserror);
            xold=xnew;
            iterationcount=iterationcount+1;
        end
        id=x;iq=y;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
        if iterationcount>=loopLimit
            status_ok=0;
        end
    case 10
        w=seed.w;
        coeff.a=w^2*(Ld^2-Lq^2);
        coeff.b=2*w^2*fluxPM*Ld;
        coeff.c=Irated^2*(R^2+w^2*Lq^2)+w^2*fluxPM^2-vmax^2;
        coeff.d=Irated^2;
        coeff.e=2*w*R*fluxPM;
        coeff.f=2*w*R*(Ld-Lq);
        coeff.g=coeff.a^2+coeff.f^2;
        coeff.h=2*coeff.a*coeff.b+2*coeff.e*coeff.f;
        coeff.k=coeff.b^2+2*coeff.c*coeff.a-coeff.d*coeff.f^2+coeff.e^2;
        coeff.m=2*coeff.b*coeff.c-2*coeff.d*coeff.e*coeff.f;
        coeff.n=coeff.c^2-coeff.d*coeff.e^2;
        if R==0
            id=roots([coeff.a,coeff.b,coeff.c]);
        else
            id=roots([coeff.g,coeff.h,coeff.k,coeff.m,coeff.n]);
        end

        id=id(imag(id)==0);
        id=id(id<0);
        id=real(min(id));
        if isempty(id)
            id=-Irated;
        end
        iq=sqrt(Irated^2-id^2);
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 11
        w=seed.w;
        L=Ld;
        coeff.a=w*L;
        coeff.b=(Irated^2*(R^2+w.^2*L^2)...
        +w.^2*fluxPM^2-vmax^2)./(2*w*fluxPM);
        coeff.c=Irated^2;
        coeff.d=coeff.a.^2+R^2;
        coeff.e=2*coeff.a.*coeff.b;
        coeff.f=coeff.b.^2-coeff.c*R^2;
        if R==0
            id=-coeff.b./coeff.a;
        else
            id=(-coeff.e-sqrt((coeff.e).^2-4*coeff.d.*coeff.f))./(2*coeff.d);
        end
        id=id(imag(id)==0);
        id=id(id<0);
        if isempty(id)
            id=-Irated;
        end
        iq=sqrt(Irated^2-id.^2);
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 12
        w=seed.w;
        L=Ld;
        id=-w.^2*L*fluxPM./(R^2+w.^2*L^2);
        coeff.a=(R^2+w.^2*L^2);
        coeff.b=(2*R*w*fluxPM);
        coeff.c=(w.^2*fluxPM^2+id.^2.*(R^2+w.^2*L^2)+...
        2*w.^2*fluxPM*L.*id-vmax^2);
        iq=(-coeff.b+sqrt((coeff.b).^2-4*(coeff.a).*coeff.c))./(2*coeff.a);
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 13
        x1=seed.id;
        y1=sqrt(Irated^2-x1.^2);
        y2=-sqrt(Irated^2-x1.^2);
        indices=find(y1==real(y1));
        x2=x1(indices);x2=x2(end:-1:1);

        y=y1(indices);y=y(end:-1:1);
        indices=find(y2==real(y2));
        x2=[x2,x1(indices)];
        y=[y,y2(indices)];
        id=x2;
        iq=y;

        w=0*x2;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 14
        x=seed.id;

        T=seed.t;
        y=ones(1,length(x)).*T/(1.5*Pp*fluxPM);
        id=x;
        iq=y;

        w=0*x;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 15

        x=seed.id;

        T=seed.t;
        y=T./(1.5*Pp*(x*(Ld-Lq)+fluxPM));
        id=x;
        iq=y;

        w=0*x;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 16

        x1=seed.id;
        w=seed.w;
        coeff.a=R^2+w^2*Lq^2;
        coeff.b=2*w*fluxPM*R+2*w*(Ld-Lq)*R*x1;
        coeff.c=x1.^2*R^2+(x1*Ld+fluxPM).^2*w^2-vmax^2;
        y1=(-coeff.b+sqrt(coeff.b.^2-4*coeff.a.*coeff.c))/(2*coeff.a);
        y2=(-coeff.b-sqrt(coeff.b.^2-4*coeff.a.*coeff.c))/(2*coeff.a);
        indices=find(y1==real(y1));
        x2=x1(indices);x2=x2(end:-1:1);
        y=y1(indices);y=y(end:-1:1);
        indices=find(y2==real(y2));
        x2=[x2,x1(indices)];
        y=[y,y2(indices)];
        id=x2;
        iq=y;

        w=0*x2;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 17

        id=zeros(1,1000);
        y=linspace(-10*Irated,10*Irated,1000);
        iq=y;

        w=zeros(1,1000);
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 18

        x1=seed.id;
        y=sqrt(x1.^2+x1*fluxPM/(Ld-Lq));

        y1=y;
        y2=-y;
        indices=find(y1==real(y1));
        x2=x1(indices);
        y=y1(indices);
        indices=find(y2==real(y2));
        indices=indices(end:-1:1);
        x2=[x2,x1(indices)];
        y=[y,y2(indices)];
        id=x2;
        iq=y;

        w=0*x2;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 19

        w=seed.w;
        L=Ld;
        x1=-w^2*L*fluxPM/(R^2+L^2*w^2);
        id=ones(1,1000)*x1;
        y=linspace(-10*Irated,10*Irated,1000);
        iq=y;

        w=zeros(1,1000);
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 20

        x1=seed.id;
        w=seed.w;
        coeff.a=fluxPM*R*(R^2+2*w^2*Lq^2-w^2*Ld*Lq)/((Ld...
        -Lq)*(R^2-w^2*Ld*Lq));
        coeff.b=2*R*w*(Ld+Lq)/(R^2-w^2*Ld*Lq);
        coeff.c=w*fluxPM*(-R^2*Ld-w^2*Lq^2*Ld-R^2*(Ld...
        -Lq))/((Ld-Lq)*(R^2-w^2*Ld*Lq));
        coeff.d=w*Ld*(w*Ld-coeff.b*R)-R^2;
        coeff.e=R*(R+coeff.b*w*Lq)-w^2*Lq^2;
        coeff.f=w*Ld*(R+coeff.b*w*Lq)+R*(w*Ld-coeff.b*R)+2*R*w*Lq;
        coeff.g=w*Ld*(coeff.c+w*fluxPM)+w*fluxPM*(w*Ld...
        -coeff.b*R)-R*coeff.a;
        coeff.h=w*fluxPM*(R+coeff.b*w*Lq)+R*(coeff.c...
        +w*fluxPM)+w*Lq*coeff.a;
        coeff.k=w*fluxPM*(coeff.c+w*fluxPM);
        y1=((-coeff.f*x1-coeff.h)+sqrt((coeff.f*x1+coeff.h).^2...
        -4*coeff.e*(coeff.d*x1.^2+coeff.g*x1+coeff.k)))/(2*coeff.e);
        y2=((-coeff.f*x1-coeff.h)-sqrt((coeff.f*x1+coeff.h).^2...
        -4*coeff.e*(coeff.d*x1.^2+coeff.g*x1+coeff.k)))/(2*coeff.e);
        indices=find(y1==real(y1));
        x2=x1(indices);
        y=y1(indices);
        indices=find(y2==real(y2));
        indices=indices(end:-1:1);
        x2=[x2,x1(indices)];
        y=[y,y2(indices)];
        id=x2;
        iq=y;

        w=0*x2;
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 21

        x1=seed.vd;
        y1=sqrt(vmax^2-x1.^2);
        y2=-sqrt(vmax^2-x1.^2);
        indices=find(y1==real(y1));
        x2=x1(indices);x2=x2(end:-1:1);
        y=y1(indices);y=y(end:-1:1);
        indices=find(y2==real(y2));
        x2=[x2,x1(indices)];
        y=[y,y2(indices)];
        vd=x2;
        vq=y;

        w=0*x2;
        if outputAll==1
            operatingPoint=[vd;vq;w];
        else
            operatingPoint=w;
        end
    case 22
        L=Ld;
        coeff.a=(Bv*L/(1.5*Pp*fluxPM))^2;
        coeff.b=((Bv*R/(1.5*Pp*fluxPM))^2+(fluxPM^2)+(Bv*2*R/(1.5*Pp)));
        coeff.c=-vmax^2;
        w=roots([coeff.a,0,coeff.b,0,coeff.c]);
        w=w(imag(w)==0);
        w=w(w>0);
        id=0;
        iq=Bv*w/(1.5*Pp*fluxPM);

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 23
        w=seed.w;
        L=Ld;
        coeff.a=w.^2*L^2+R^2;
        coeff.b=2*R*w*fluxPM;
        coeff.c=w.^2*fluxPM^2-vmax^2;
        iq=(-coeff.b+sqrt(coeff.b.^2-4*coeff.a.*coeff.c))./(2*coeff.a);
        id=0*w;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 24
        wcorner=seed.w;
        L=Ld;
        coeff.k=fluxPM^2/(Irated^2*L^2);
        coeff.a=coeff.k-1;
        coeff.b=-2*coeff.k*wcorner;
        coeff.c=(coeff.k+1)*wcorner^2;
        w=roots([coeff.a,coeff.b,coeff.c]);
        w=w(imag(w)==0);
        w=w(w>0);

        w=w(w>=wcorner*1.001);
        id=fluxPM*(wcorner-w)/(L*w);
        iq=Irated*wcorner/w;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end

    case 25
        L=Ld;
        wcorner=seed.w;
        coeff.k1=(1.5*Pp*fluxPM/Bv)^2;
        coeff.k2=fluxPM^2/L^2;
        coeff.a=1;
        coeff.b=0;
        coeff.c=coeff.k1*coeff.k2-coeff.k1*Irated^2;
        coeff.d=-2*wcorner*coeff.k1*coeff.k2;
        coeff.e=coeff.k1*coeff.k2*wcorner^2;
        w=roots([coeff.a,coeff.b,coeff.c,coeff.d,coeff.e]);
        w=w(imag(w)==0);
        w=w(w>0);
        w=w(w>wcorner);
        iq=Bv*w/(1.5*Pp*fluxPM);
        id=-sqrt(Irated^2-iq^2);

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 26
        w=seed.w;
        wcorner=seed.wcorner;
        id=(wcorner-w)*fluxPM./(Ld*w);
        iq=Irated*wcorner./w;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 27
        w=seed.w;
        wcorner=seed.wcorner;
        id=(wcorner-w)*fluxPM./(Ld*w);
        iq=sqrt(Irated^2-id.^2);
        iq(abs(imag(iq))>0)=0;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 28
        L=Ld;
        wcorner=seed.w;
        coeff.k1=(L^2+fluxPM^2/Irated^2)*Irated/(2*fluxPM*L);
        coeff.k2=(R^2-vmax^2/Irated^2+2*fluxPM*wcorner*R/Irated)*Irated/(2*fluxPM*L);
        coeff.a=coeff.k1^2-1;
        coeff.b=2*coeff.k1*coeff.k2+wcorner^2;
        coeff.c=coeff.k2^2;

        w=roots([coeff.a,0,coeff.b,0,coeff.c]);
        w=w(imag(w)==0);
        w=w(w>0);

        w=w(w>wcorner*1.001);
        iq=Irated*wcorner/w;
        id=-sqrt(Irated^2-iq^2);

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 29
        w=seed.w;
        wcorner=seed.wcorner;
        iq=Irated*wcorner./w;
        id=-sqrt(Irated^2-iq.^2);

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 30
        L=Ld;
        wcorner=seed.w;
        w=sqrt(Irated*wcorner*1.5*Pp*fluxPM/Bv);
        iq=Irated*wcorner/w;
        coeff.a=R^2+w^2*L^2;
        coeff.b=2*fluxPM*L*w^2;
        coeff.c=iq^2*(R^2+w^2*L^2)-vmax^2+w^2*fluxPM^2+2*fluxPM*R*Irated*wcorner;
        id=(-coeff.b+sqrt(coeff.b.^2-4*coeff.a.*coeff.c))./(2*coeff.a);
        id=id(abs(id)<=1.001*sqrt(Irated^2-iq.^2));

        if isempty(id)
            w=[];
            iq=[];
        end

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 31
        w=seed.w;
        L=Ld;
        wcorner=seed.wcorner;
        iq=Irated*wcorner./w;
        coeff.a=R^2+w.^2*L^2;
        coeff.b=2*fluxPM*L*w.^2;
        coeff.c=iq.^2.*(R^2+w.^2*L^2)-vmax^2+w.^2*fluxPM^2+2*fluxPM*R*Irated*wcorner;
        id=(-coeff.b-sqrt(coeff.b.^2-4*coeff.a.*coeff.c))./(2*coeff.a);
        indices1=find(abs(id)>1.001*sqrt(Irated^2-iq.^2));
        id(indices1)=-1.001*sqrt(Irated^2-iq(indices1).^2);

        if isempty(id)
            w=[];
            iq=[];
        end
        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 32
        id=seed.id;
        L=Ld;
        iq=Irated*(fluxPM+L*id)/fluxPM;

        w=0*id;

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 33
        L=Ld;
        wcorner=seed.w;
        w=sqrt(Irated*wcorner*1.5*Pp*fluxPM/Bv);
        iq=Irated*wcorner/w;
        id=(wcorner-w)*fluxPM/(L*w);

        if outputAll==1
            operatingPoint=[id;iq;w];
        else
            operatingPoint=w;
        end
    case 34
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);

        error1=1;
        error2=1;
        id_mtpa=0;
        iq_mtpa=0;
        iq_mtpa_old=0;
        id_mtpa_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_mtpa,id_mtpa);
                Ld=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_mtpa,id_mtpa);
                Lq=interp2(TableData.iqVec,TableData.idVec,TableData.LqTable,iq_mtpa,id_mtpa);
            end
            coeff.a=9*Pp^2*(Ld-Lq)^2;
            coeff.b=0;
            coeff.c=0;
            coeff.d=6*T*Pp*fluxPM;
            coeff.e=-4*T^2;
            iq_mtpa=roots([coeff.a,coeff.b,coeff.c,coeff.d,coeff.e]);
            iq_mtpa=iq_mtpa(imag(iq_mtpa)==0);
            iq_mtpa=iq_mtpa(iq_mtpa>=0);
            iq_mtpa=max(iq_mtpa);
            iq_mtpa=min(iq_mtpa,Irated);
            id_mtpa=-fluxPM/(2*(Ld-Lq))-sqrt((fluxPM^2/(4*(Ld-Lq)^2))+iq_mtpa^2);

            id_mtpa=real(id_mtpa);
            id_mtpa=id_mtpa(id_mtpa<=0);
            id_mtpa=max(id_mtpa,-Irated);
            if goLUT==1
                error1=abs(iq_mtpa-iq_mtpa_old);
                error2=abs(id_mtpa-id_mtpa_old);
                iq_mtpa_old=iq_mtpa;
                id_mtpa_old=id_mtpa;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end
        iq_mtpa=signT*iq_mtpa;
        if outputAll==1
            operatingPoint=[id_mtpa;iq_mtpa;w];
        else
            operatingPoint=w;
        end
    case 35
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end

        error1=1;
        error2=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        id_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
                Ld=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_fw,id_fw);
                Lq=interp2(TableData.iqVec,TableData.idVec,TableData.LqTable,iq_fw,id_fw);
            end
            coeff.a=-w^2*Ld*fluxPM;
            coeff.b=-R*w*(Ld-Lq);
            coeff.c=R^2+w^2*Ld^2;
            coeff.d=R^2+w^2*Lq^2;
            coeff.e=2*R*w*fluxPM;
            coeff.f=w^2*fluxPM^2-vmax^2;
            coeff.g=1.5*Pp*(Ld-Lq);
            coeff.h=fluxPM/(Ld-Lq);
            coeff.q=coeff.c*coeff.d;
            coeff.k=coeff.c*coeff.e+2*coeff.h*coeff.b*coeff.c;
            coeff.m=(coeff.h*coeff.c+coeff.a)^2-2*T*coeff.c*coeff.b/coeff.g-coeff.a^2+coeff.c*coeff.f;
            coeff.n=-2*T*coeff.c*(coeff.h*coeff.c+coeff.a)/coeff.g;
            coeff.p=T^2*coeff.c^2/coeff.g^2;
            iq_fw=roots([coeff.q,coeff.k,coeff.m,coeff.n,coeff.p]);

            iq_fw=iq_fw(imag(iq_fw)==0);
            iq_fw=iq_fw(signT*iq_fw>=0);
            iq_fw=signT*max(signT*iq_fw);
            iq_fw=signT*min(Irated,signT*iq_fw);
            if isempty(iq_fw)
                tmp_id_fw=-pmsm.I_rated;
            else
                tmp_id_fw=(coeff.a+iq_fw*coeff.b+sqrt((-coeff.a-coeff.b*iq_fw)^2...
                -coeff.c*(coeff.d*iq_fw^2+coeff.e*iq_fw+coeff.f)))/coeff.c;
            end
            pmsm.Ld=Ld;pmsm.Lq=Lq;pmsm.FluxPM=fluxPM;
            operatingpoint=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
            inverter,seed,10,'outputAll',1,...
            'voltageEquation',voltageEquation);
            if isempty(iq_fw)||((operatingpoint(2)<signT*iq_fw)&&(abs(operatingpoint(1))<abs(tmp_id_fw)))

                id_fw=operatingpoint(1);
                iq_fw=signT*operatingpoint(2);
            else
                id_fw=tmp_id_fw;

                id_fw=real(id_fw);
                id_fw=max(id_fw,-Irated);
                iq_fw=signT*min(abs(iq_fw),sqrt(Irated^2-id_fw^2));
            end
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                error2=abs(id_fw-id_fw_old);
                iq_fw_old=iq_fw;
                id_fw_old=id_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    case 36
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end

        error1=1;
        error2=1;
        id_mtpv=0;
        iq_mtpv=0;
        iq_mtpv_old=0;
        id_mtpv_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_mtpv,id_mtpv);
                Ld=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_mtpv,id_mtpv);
                Lq=interp2(TableData.iqVec,TableData.idVec,TableData.LqTable,iq_mtpv,id_mtpv);
            end
            coeff1.a=fluxPM*R*(R^2+2*w^2*Lq^2-w^2*Ld*Lq)/((Ld...
            -Lq)*(R^2-w^2*Ld*Lq));
            coeff1.b=2*R*w*(Ld+Lq)/(R^2-w^2*Ld*Lq);
            coeff1.c=w*fluxPM*(-R^2*Ld-w^2*Lq^2*Ld-R^2*(Ld...
            -Lq))/((Ld-Lq)*(R^2-w^2*Ld*Lq));
            coeff1.d=w*Ld*(w*Ld-coeff1.b*R)-R^2;
            coeff1.e=R*(R+coeff1.b*w*Lq)-w^2*Lq^2;
            coeff1.f=w*Ld*(R+coeff1.b*w*Lq)+R*(w*Ld-coeff1.b*R)+2*R*w*Lq;
            coeff1.g=w*Ld*(coeff1.c+w*fluxPM)+w*fluxPM*(w*Ld...
            -coeff1.b*R)-R*coeff1.a;
            coeff1.h=w*fluxPM*(R+coeff1.b*w*Lq)+R*(coeff1.c...
            +w*fluxPM)+w*Lq*coeff1.a;
            coeff1.k=w*fluxPM*(coeff1.c+w*fluxPM);
            coeff.a=-coeff1.g/2;
            coeff.b=-coeff1.f/2;
            coeff.c=coeff1.d;
            coeff.d=coeff1.e;
            coeff.e=coeff1.h;
            coeff.f=coeff1.k;
            coeff.g=1.5*Pp*(Ld-Lq);
            coeff.h=fluxPM/(Ld-Lq);
            coeff.k=coeff.c*coeff.e+2*coeff.h*coeff.b*coeff.c;
            coeff.m=(coeff.h*coeff.c+coeff.a)^2-2*T*coeff.c*coeff.b/coeff.g-coeff.a^2+coeff.c*coeff.f;
            coeff.n=-2*T*coeff.c*(coeff.h*coeff.c+coeff.a)/coeff.g;
            coeff.p=T^2*coeff.c^2/coeff.g^2;
            coeff.q=coeff.c*coeff.d;
            iq_mtpv=roots([coeff.q,coeff.k,coeff.m,coeff.n,coeff.p]);
            iq_mtpv=iq_mtpv(imag(iq_mtpv)==0);
            iq_mtpv=iq_mtpv(signT*iq_mtpv>=0);
            iq_mtpv=signT*max(signT*iq_mtpv);
            iq_mtpv=signT*min(Irated,signT*iq_mtpv);
            id_mtpv=(coeff.a+iq_mtpv*coeff.b-sqrt((-coeff.a-coeff.b*iq_mtpv)^2...
            -coeff.c*(coeff.d*iq_mtpv^2+coeff.e*iq_mtpv+coeff.f)))/coeff.c;

            id_mtpv=real(id_mtpv);
            id_mtpv=max(id_mtpv,-Irated);
            iq_mtpv=signT*min(abs(iq_mtpv),sqrt(Irated^2-id_mtpv^2));
            if goLUT==1
                error1=abs(iq_mtpv-iq_mtpv_old);
                error2=abs(id_mtpv-id_mtpv_old);
                iq_mtpv_old=iq_mtpv;
                id_mtpv_old=id_mtpv;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end

        if outputAll==1
            operatingPoint=[id_mtpv;iq_mtpv;w];
        else
            operatingPoint=w;
        end
    case 37
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);

        error1=1;
        id_mtpa=0;
        iq_mtpa=0;
        iq_mtpa_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_mtpa,id_mtpa);
            end
            iq_mtpa=sign(T)*min(abs(T)/(1.5*Pp*fluxPM),Irated);
            if goLUT==1
                error1=abs(iq_mtpa-iq_mtpa_old);
                iq_mtpa_old=iq_mtpa;
                iterationcount=iterationcount+1;
            else
                error1=0;
            end
        end
        iq_mtpa=signT*iq_mtpa;

        if outputAll==1
            operatingPoint=[id_mtpa;iq_mtpa;w];
        else
            operatingPoint=w;
        end
    case 38
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);
        wcorner=seed.wcorner;
        L=Ld;

        error1=1;
        error2=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        id_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
                L=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_fw,id_fw);
            end
            id_fw=max((wcorner-w)*fluxPM/(w*L),-Irated);
            iq_fw=sign(T)*min([sqrt(Irated^2-id_fw^2),wcorner*Irated/w,...
            abs(T)/(1.5*Pp*fluxPM)]);
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                error2=abs(id_fw-id_fw_old);
                iq_fw_old=iq_fw;
                id_fw_old=id_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end
        iq_fw=signT*iq_fw;

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    case 39
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);
        wcorner=seed.wcorner;

        error1=1;
        error2=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        id_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
            end
            iq_fw=sign(T)*min([wcorner*Irated/w,abs(T)/(1.5*Pp*fluxPM)]);
            id_fw=-sqrt(Irated^2-iq_fw^2);
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                error2=abs(id_fw-id_fw_old);
                iq_fw_old=iq_fw;
                id_fw_old=id_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end
        iq_fw=signT*iq_fw;

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    case 40
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);

        error1=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
            end
            iq_fw=sign(T)*min(abs(T)/(1.5*Pp*fluxPM),Irated);
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                iq_fw_old=iq_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
            end
        end
        iq_fw=signT*iq_fw;

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    case 41
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        L=Ld;

        error1=1;
        error2=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        id_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
                L=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_fw,id_fw);
            end
            coeff.a=-w^2*L*fluxPM;
            coeff.b=R^2+w^2*L^2;
            coeff.c=w^2*fluxPM^2-vmax^2;
            coeff.d=2*R*w*fluxPM;
            iq_fw=T/(1.5*Pp*fluxPM);
            id_fw=[(coeff.a+sqrt(coeff.a^2-coeff.b*(coeff.b*iq_fw^2+coeff.c+coeff.d*iq_fw)))/coeff.b;
            (coeff.a-sqrt(coeff.a^2-coeff.b*(coeff.b*iq_fw^2+coeff.c+coeff.d*iq_fw)))/coeff.b];

            id_fw=id_fw(id_fw<0);
            id_fw=id_fw(imag(id_fw)==0);
            id_fw=max(id_fw);
            pmsm.Ld=L;pmsm.Lq=L;pmsm.FluxPM=fluxPM;
            operatingpoint=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
            inverter,seed,11,'outputAll',1,...
            'voltageEquation',voltageEquation);
            if isempty(id_fw)||((operatingpoint(2)<signT*iq_fw)&&(abs(operatingpoint(1))<abs(id_fw)))
                id_fw=operatingpoint(1);
                iq_fw=signT*operatingpoint(2);
            else
                id_fw=max(-Irated,id_fw);
                iq_fw=signT*min(abs(iq_fw),sqrt(Irated^2-id_fw^2));
            end
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                error2=abs(id_fw-id_fw_old);
                iq_fw_old=iq_fw;
                id_fw_old=id_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    case 42
        w=seed.w;
        T=seed.t;
        goLUT=seed.goLUT;
        signT=sign(T);
        if signT==0
            signT=1;
        end
        T=abs(T);
        L=Ld;

        error1=1;
        error2=1;
        id_fw=0;
        iq_fw=0;
        iq_fw_old=0;
        id_fw_old=0;
        TableData=seed.ParamTableData;
        iterationcount=0;
        while(error1>1e-6||error2>1e-6)&&(iterationcount<loopLimit)
            if goLUT==1
                fluxPM=interp2(TableData.iqVec,TableData.idVec,TableData.FluxPMTable,iq_fw,id_fw);
                L=interp2(TableData.iqVec,TableData.idVec,TableData.LdTable,iq_fw,id_fw);
            end
            iq_fw=T/(1.5*Pp*fluxPM);
            id_fw=-fluxPM*w^2*L/(R^2+w^2*L^2);
            if goLUT==1
                error1=abs(iq_fw-iq_fw_old);
                error2=abs(id_fw-id_fw_old);
                iq_fw_old=iq_fw;
                id_fw_old=id_fw;
                iterationcount=iterationcount+1;
            else
                error1=0;
                error2=0;
            end
        end
        iq_fw=signT*iq_fw;

        if outputAll==1
            operatingPoint=[id_fw;iq_fw;w];
        else
            operatingPoint=w;
        end
    otherwise
        warning(message('mcb:blocks:APIWrongSolveType'));
        if outputAll==1
            operatingPoint=[1e6;1e6;1e6];
        else
            operatingPoint=1e6;
        end
    end
end
