function[T_mtpa,id_mtpa,iq_mtpa,idq_limits]=autoblks_determine_mtpa(Rs,flux,Ld,Lq,p,T_max,bp,varargin)%#ok<INUSL>








    switch nargin
    case 7
        Kt=(3/2)*p*flux;
        is=T_max/Kt;

    case 8
        is=varargin{1};
        id_Tmax=(-flux+sqrt(flux^2+8*(Ld-Lq)^2.*is.*is))/4/(Ld-Lq);
        iq_Tmax=sqrt(is.*is-id_Tmax.*id_Tmax);
        T_max=1.5*p*(flux+(Ld-Lq).*id_Tmax).*iq_Tmax;

    otherwise
        error(message('autoblks:autoblkErrorMsg:errInvNInp'));
    end




    is=linspace(0,is,bp);
    id_mtpa=(-flux+sqrt(flux^2+8*(Ld-Lq)^2.*is.*is))/4/(Ld-Lq);
    iq_mtpa=sqrt(is.*is-id_mtpa.*id_mtpa);
    T_mtpa=1.5*p*(flux+(Ld-Lq).*id_mtpa).*iq_mtpa;
    idq_limits(1)=interp1(T_mtpa,id_mtpa,T_max,'spline');
    idq_limits(2)=interp1(T_mtpa,iq_mtpa,T_max,'spline');
    idq_limits(3)=sqrt(idq_limits(1)^2+idq_limits(2)^2);
    is=linspace(0,idq_limits(3),bp);
    id_mtpa=(-flux+sqrt(flux^2+8*(Ld-Lq)^2.*is.*is))/4/(Ld-Lq);
    iq_mtpa=sqrt(is.*is-id_mtpa.*id_mtpa);
    T_mtpa=1.5*p*(flux+(Ld-Lq).*id_mtpa).*iq_mtpa;

end
