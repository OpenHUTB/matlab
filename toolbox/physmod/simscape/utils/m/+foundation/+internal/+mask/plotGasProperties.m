function plotGasProperties(varargin)










    narginchk(1,2)


    hBlock=varargin{1};

    if nargin==2
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="foundation.gas.utilities.gas_properties"


        if exist("hFigure","var")
            if isgraphics(hFigure,"figure")&&...
                string(hFigure.Tag)=="Gas Properties - Plot Gas Properties"
                blockPath=getappdata(hFigure,"blockPath");
                hBlock=getSimulinkBlockHandle(blockPath);


                if~is_simulink_handle(hBlock)||...
                    string(get_param(hBlock,"ComponentPath"))~="foundation.gas.utilities.gas_properties"
                    error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
                end
            else
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        end
    end

    fluidProps=ExtractTLProperties(hBlock);

    if nargin==2
        plotFluidProperties(fluidProps,hBlock,hFigure)
    else
        plotFluidProperties(fluidProps,hBlock)
    end

end

function fluidProps=ExtractTLProperties(hBlock)

    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);




    gas_spec=simscapeParameter(blockParams,'gas_spec');
    R=simscapeParameter(blockParams,'R');
    Z=simscapeParameter(blockParams,'Z');
    T_ref=simscapeParameter(blockParams,'T_ref');
    h_ref=simscapeParameter(blockParams,'h_ref');
    cp_ref=simscapeParameter(blockParams,'cp_ref');
    mu_ref=simscapeParameter(blockParams,'mu_ref');
    k_ref=simscapeParameter(blockParams,'k_ref');
    T_min_perfect=simscapeParameter(blockParams,'T_min_perfect');
    T_max_perfect=simscapeParameter(blockParams,'T_max_perfect');
    p_min_perfect=simscapeParameter(blockParams,'p_min_perfect');
    p_max_perfect=simscapeParameter(blockParams,'p_max_perfect');


    T_TLU1=simscapeParameter(blockParams,'T_TLU1');
    h_TLU1=simscapeParameter(blockParams,'h_TLU1');
    cp_TLU1=simscapeParameter(blockParams,'cp_TLU1');
    mu_TLU1=simscapeParameter(blockParams,'mu_TLU1');
    k_TLU1=simscapeParameter(blockParams,'k_TLU1');
    T_range_flag=simscapeParameter(blockParams,'T_range_flag');
    T_min_semiperfect=simscapeParameter(blockParams,'T_min_semiperfect');
    T_max_semiperfect=simscapeParameter(blockParams,'T_max_semiperfect');
    p_min_semiperfect=simscapeParameter(blockParams,'p_min_semiperfect');
    p_max_semiperfect=simscapeParameter(blockParams,'p_max_semiperfect');


    T_TLU2=simscapeParameter(blockParams,'T_TLU2');
    p_TLU2=simscapeParameter(blockParams,'p_TLU2');
    rho_TLU2=simscapeParameter(blockParams,'rho_TLU2');
    s_TLU2=simscapeParameter(blockParams,'s_TLU2');
    h_TLU2=simscapeParameter(blockParams,'h_TLU2');
    cp_TLU2=simscapeParameter(blockParams,'cp_TLU2');
    mu_TLU2=simscapeParameter(blockParams,'mu_TLU2');
    k_TLU2=simscapeParameter(blockParams,'k_TLU2');
    beta_TLU2=simscapeParameter(blockParams,'beta_TLU2');
    alpha_TLU2=simscapeParameter(blockParams,'alpha_TLU2');
    pT_region_flag=simscapeParameter(blockParams,'pT_region_flag');
    pT_validity_TLU2=simscapeParameter(blockParams,'pT_validity_TLU2');
    T_min_real=simscapeParameter(blockParams,'T_min_real');
    T_max_real=simscapeParameter(blockParams,'T_max_real');
    p_min_real=simscapeParameter(blockParams,'p_min_real');
    p_max_real=simscapeParameter(blockParams,'p_max_real');

    p_atm=simscapeParameter(blockParams,'p_atm');
    Mach_rev=simscapeParameter(blockParams,'Mach_rev');


    fileID='physmod:simscape:library:comments:gas:utilities:gas_properties:';

    Mach_rev_str=string(message([fileID,'Mach_rev']));
    R_str=string(message([fileID,'R']));
    T_TLU1_str=string(message([fileID,'T_TLU1']));
    T_TLU2_str=string(message([fileID,'T_TLU2']));
    T_max_perfect_str=string(message([fileID,'T_max_perfect']));
    T_max_real_str=string(message([fileID,'T_max_real']));
    T_max_semiperfect_str=string(message([fileID,'T_max_semiperfect']));
    T_min_perfect_str=string(message([fileID,'T_min_perfect']));
    T_min_real_str=string(message([fileID,'T_min_real']));
    T_min_semiperfect_str=string(message([fileID,'T_min_semiperfect']));
    T_ref_str=string(message([fileID,'T_ref']));
    Z_str=string(message([fileID,'Z']));
    alpha_TLU2_str=string(message([fileID,'alpha_TLU2']));
    beta_TLU2_str=string(message([fileID,'beta_TLU2']));
    cp_TLU1_str=string(message([fileID,'cp_TLU1']));
    cp_TLU2_str=string(message([fileID,'cp_TLU2']));
    cp_ref_str=string(message([fileID,'cp_ref']));
    h_TLU1_str=string(message([fileID,'h_TLU1']));
    h_TLU2_str=string(message([fileID,'h_TLU2']));
    k_TLU1_str=string(message([fileID,'k_TLU1']));
    k_TLU2_str=string(message([fileID,'k_TLU2']));
    k_ref_str=string(message([fileID,'k_ref']));
    mu_TLU1_str=string(message([fileID,'mu_TLU1']));
    mu_TLU2_str=string(message([fileID,'mu_TLU2']));
    mu_ref_str=string(message([fileID,'mu_ref']));
    pT_validity_TLU2_str=string(message([fileID,'pT_validity_TLU2']));
    p_TLU2_str=string(message([fileID,'p_TLU2']));
    p_atm_str=string(message([fileID,'p_atm']));
    p_max_perfect_str=string(message([fileID,'p_max_perfect']));
    p_max_real_str=string(message([fileID,'p_max_real']));
    p_max_semiperfect_str=string(message([fileID,'p_max_semiperfect']));
    p_min_perfect_str=string(message([fileID,'p_min_perfect']));
    p_min_real_str=string(message([fileID,'p_min_real']));
    p_min_semiperfect_str=string(message([fileID,'p_min_semiperfect']));
    rho_TLU2_str=string(message([fileID,'rho_TLU2']));
    s_TLU2_str=string(message([fileID,'s_TLU2']));
    T_TLU1_min_str=string(message([fileID,'T_TLU1_min']));
    T_TLU1_max_str=string(message([fileID,'T_TLU1_max']));
    T_TLU2_min_str=string(message([fileID,'T_TLU2_min']));
    T_TLU2_max_str=string(message([fileID,'T_TLU2_max']));
    p_TLU2_min_str=string(message([fileID,'p_TLU2_min']));
    p_TLU2_max_str=string(message([fileID,'p_TLU2_max']));
    ZR_str=string(message([fileID,'ZR']));


    T_TLU1_min=min(T_TLU1);
    T_TLU1_max=max(T_TLU1);
    T_TLU2_min=min(T_TLU2);
    T_TLU2_max=max(T_TLU2);
    p_TLU2_min=min(p_TLU2);
    p_TLU2_max=max(p_TLU2);
    ZR=Z*R;


    if gas_spec==1

        assert(R>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',R_str))
        assert(Z>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',Z_str))
        assert(value(T_ref,'K')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',T_ref_str))
        assert(cp_ref>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',cp_ref_str))
        assert(mu_ref>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',mu_ref_str))
        assert(k_ref>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',k_ref_str))
        assert(value(T_min_perfect,'K')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',T_min_perfect_str))
        assert(value(T_max_perfect,'K')>value(T_min_perfect,'K'),...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',T_max_perfect_str,T_min_perfect_str))
        assert(p_min_perfect>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_min_perfect_str))
        assert(p_max_perfect>p_min_perfect,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',p_max_perfect_str,p_min_perfect_str))
        assert(p_atm>=p_min_perfect,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_atm_str,p_min_perfect_str))
        assert(p_atm<=p_max_perfect,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_atm_str,p_max_perfect_str))
        assert(Mach_rev>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',Mach_rev_str))

    elseif gas_spec==2
        assert(R>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',R_str))
        assert(Z>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',Z_str))
        assert(length(T_TLU1)>=2,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_TLU1_str,'2'))
        assert(length(h_TLU1)==length(T_TLU1),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',h_TLU1_str,T_TLU1_str))
        assert(length(cp_TLU1)==length(T_TLU1),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',cp_TLU1_str,T_TLU1_str))
        assert(length(mu_TLU1)==length(T_TLU1),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',mu_TLU1_str,T_TLU1_str))
        assert(length(k_TLU1)==length(T_TLU1),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',k_TLU1_str,T_TLU1_str))
        assert(all(diff(value(T_TLU1,'K'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',T_TLU1_str))
        assert(all(diff(h_TLU1)>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',h_TLU1_str))
        assert(all(value(T_TLU1(:),'K')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',T_TLU1_str))
        assert(all(cp_TLU1(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',cp_TLU1_str))
        assert(all(mu_TLU1(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mu_TLU1_str))
        assert(all(k_TLU1(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',k_TLU1_str))
        assert(p_min_semiperfect>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_min_semiperfect_str))
        assert(p_max_semiperfect>p_min_semiperfect,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',p_max_semiperfect_str,p_min_semiperfect_str))
        assert(all(cp_TLU1(:)>ZR),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThan',cp_TLU1_str,ZR_str))
        assert(p_atm>=p_min_semiperfect,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_atm_str,p_min_semiperfect_str))
        assert(p_atm<=p_max_semiperfect,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_atm_str,p_max_semiperfect_str))
        assert(Mach_rev>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',Mach_rev_str))

        if T_range_flag==2
            assert(value(T_min_semiperfect,'K')>=value(T_TLU1_min,'K'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_min_semiperfect_str,T_TLU1_min_str))
            assert(value(T_max_semiperfect,'K')>value(T_min_semiperfect,'K'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThan',T_max_semiperfect_str,T_min_semiperfect_str))
            assert(value(T_max_semiperfect,'K')<=value(T_TLU1_max,'K'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',T_max_semiperfect_str,T_TLU1_max_str))
        end

    else
        assert(length(T_TLU2)>=2,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_TLU2_str,'2'))
        assert(length(p_TLU2)>=2,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_TLU2_str,'2'))
        assert(all(size(rho_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',rho_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(s_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',s_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(h_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',h_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(cp_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',cp_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(mu_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',mu_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(k_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',k_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(beta_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',beta_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(size(alpha_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',alpha_TLU2_str,T_TLU2_str,p_TLU2_str))
        assert(all(diff(value(T_TLU2,'K'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',T_TLU2_str))
        assert(all(diff(p_TLU2)>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',p_TLU2_str))
        assert(all(value(T_TLU2(:),'K')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',T_TLU2_str))
        assert(all(p_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',p_TLU2_str))
        assert(all(rho_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',rho_TLU2_str))
        assert(all(cp_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',cp_TLU2_str))
        assert(all(mu_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',mu_TLU2_str))
        assert(all(k_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',k_TLU2_str))
        assert(all(beta_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',beta_TLU2_str))
        assert(all(alpha_TLU2(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',alpha_TLU2_str))
        assert(all(all(cp_TLU2>repmat(simscape.Value(value(T_TLU2(:),'K'),'K'),1,length(p_TLU2)).*alpha_TLU2.^2.*beta_TLU2./rho_TLU2)),...
        message('physmod:simscape:library:gas:CvGreaterThanZero'))
        assert(Mach_rev>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',Mach_rev_str))

        if pT_region_flag==1
            assert(p_atm>=p_TLU2_min,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_atm_str,p_TLU2_min_str))
            assert(p_atm<=p_TLU2_max,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_atm_str,p_TLU2_max_str))

        elseif pT_region_flag==2
            assert(value(T_min_real,'K')>=value(T_TLU2_min,'K'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_min_real_str,T_TLU2_min_str))
            assert(value(T_max_real,'K')>value(T_min_real,'K'),...
            message('physmod:simscape:compiler:patterns:checks:GreaterThan',T_max_real_str,T_min_real_str))
            assert(value(T_max_real,'K')<=value(T_TLU2_max,'K'),...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',T_max_real_str,T_TLU2_max_str))
            assert(p_min_real>=p_TLU2_min,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_min_real_str,p_TLU2_min_str))
            assert(p_max_real>p_min_real,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThan',p_max_real_str,p_min_real_str))
            assert(p_max_real<=p_TLU2_max,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_max_real_str,p_TLU2_max_str))
            assert(p_atm>=p_min_real,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_atm_str,p_min_real_str))
            assert(p_atm<=p_max_real,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_atm_str,p_max_real_str))

        else
            assert(all(size(pT_validity_TLU2)==[length(T_TLU2),length(p_TLU2)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',pT_validity_TLU2_str,T_TLU2_str,p_TLU2_str))
            assert(p_atm>=p_TLU2_min,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_atm_str,p_TLU2_min_str))
            assert(p_atm<=p_TLU2_max,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_atm_str,p_TLU2_max_str))
        end
    end

    if gas_spec==1


        T_min=T_min_perfect;
        T_max=T_max_perfect;
        p_min=p_min_perfect;
        p_max=p_max_perfect;


        p_TLU_unit=unit(p_min);
        T_TLU_unit=unit(T_min);
        h_TLU_unit=unit(h_ref);
        rho_TLU_unit=simscape.Unit('kg/m^3');
        cp_TLU_unit=unit(cp_ref);
        cv_TLU_unit=unit(cp_ref);
        mu_TLU_unit=unit(mu_ref);
        k_TLU_unit=unit(k_ref);
        a_TLU_unit=simscape.Unit('m/s');


        if value(T_max,T_TLU_unit)==inf
            T_max=1000*simscape.Value(value(T_min,'K'),T_TLU_unit);
        end

        if value(p_max,p_TLU_unit)==inf
            p_max=1000*p_atm;
        end


        p_min_val=value(p_min,p_TLU_unit);
        p_max_val=value(p_max,p_TLU_unit);
        p_TLU_val=logspace(log10(p_min_val),log10(p_max_val),30);
        p_TLU=simscape.Value(p_TLU_val,p_TLU_unit);




        T_min_val_K=value(T_min,'K');
        T_max_val_K=value(T_max,'K');
        T_TLU_val_K=logspace(log10(T_min_val_K),log10(T_max_val_K),30);
        T_TLU_K=simscape.Value(T_TLU_val_K,'K');
        T_TLU_val=value(T_TLU_K,T_TLU_unit);
        T_TLU=simscape.Value(T_TLU_val,T_TLU_unit);
        T_ref_K=simscape.Value(value(T_ref,'K')*ones(size(T_TLU_K)),'K');


        T_TLU=T_TLU(:);
        p_TLU=p_TLU(:);
        T_TLU_K=T_TLU_K(:);
        T_ref_K=T_ref_K(:);


        m=length(T_TLU);
        n=length(p_TLU);


        rho_TLU=(1./T_TLU_K)*(p_TLU'./(Z*R));


        h_TLU=repmat(h_ref+cp_ref*(T_TLU_K-T_ref_K),1,n);


        a_TLU=repmat(sqrt(cp_ref/(cp_ref-Z*R)*Z*R*T_TLU_K),1,n);


        cp_TLU=repmat(cp_ref,m,n);


        cv_TLU=cp_TLU-Z*R;


        mu_TLU=repmat(mu_ref,m,n);


        k_TLU=repmat(k_ref,m,n);


        Pr_TLU=repmat(cp_ref.*mu_ref./k_ref,m,n);


        rho_TLU_val=value(rho_TLU,rho_TLU_unit);
        h_TLU_val=value(h_TLU,h_TLU_unit);
        cp_TLU_val=value(cp_TLU,cp_TLU_unit);
        cv_TLU_val=value(cv_TLU,cv_TLU_unit);
        mu_TLU_val=value(mu_TLU,mu_TLU_unit);
        k_TLU_val=value(k_TLU,k_TLU_unit);
        a_TLU_val=value(a_TLU,a_TLU_unit);
        Pr_TLU_val=value(Pr_TLU,'1');


        fluidProps={
        ['Temperature',' (',char(T_TLU_unit),')'],T_TLU_val;
        ['Pressure',' (',char(p_TLU_unit),')'],p_TLU_val;
        ['Density',' (',char(rho_TLU_unit),')'],rho_TLU_val;
        ['Specific Enthalpy',' (',char(h_TLU_unit),')'],h_TLU_val;
        ['Specific Heat at Constant Pressure',' (',char(cp_TLU_unit),')'],cp_TLU_val;
        ['Specific Heat at Constant Volume',' (',char(cv_TLU_unit),')'],cv_TLU_val;
        ['Dynamic Viscosity',' (',char(mu_TLU_unit),')'],mu_TLU_val;
        ['Thermal Conductivity',' (',char(k_TLU_unit),')'],k_TLU_val;
        ['Speed of Sound',' (',char(a_TLU_unit),') '],a_TLU_val;
        'Prandtl Number',Pr_TLU_val;
        };

    elseif gas_spec==2


        p_TLU_unit=unit(p_min_semiperfect);
        T_TLU_unit=unit(T_TLU1);
        rho_TLU1_unit=simscape.Unit('kg/m^3');
        h_TLU1_unit=unit(h_TLU1);
        cp_TLU1_unit=unit(cp_TLU1);
        cv_TLU1_unit=unit(cp_TLU1);
        mu_TLU1_unit=unit(mu_TLU1);
        k_TLU1_unit=unit(k_TLU1);
        a_TLU1_unit=simscape.Unit('m/s');


        if T_range_flag==1
            T_min=T_TLU1_min;
            T_max=T_TLU1_max;

        else
            T_min=T_min_semiperfect;
            T_max=T_max_semiperfect;
        end


        p_min=p_min_semiperfect;
        p_max=p_max_semiperfect;


        if value(T_max,T_TLU_unit)==inf
            T_max=1000*simscape.Value(value(T_min,'K'),T_TLU_unit);
        end

        if value(p_max,p_TLU_unit)==inf
            p_max=1000*p_atm;
        end


        p_min_val=value(p_min,p_TLU_unit);
        p_max_val=value(p_max,p_TLU_unit);
        p_TLU_val=logspace(log10(p_min_val),log10(p_max_val),30);
        p_TLU1=simscape.Value(p_TLU_val,p_TLU_unit);


        T_TLU1_K=simscape.Value(value(T_TLU1,'K'),'K');


        p_TLU=p_TLU1(:);
        h_TLU1=h_TLU1(:);
        cp_TLU1=cp_TLU1(:);
        mu_TLU1=mu_TLU1(:);
        k_TLU1=k_TLU1(:);
        T_TLU1_K=T_TLU1_K(:);


        n=length(p_TLU);


        rho_TLU1=(1./T_TLU1_K)*(p_TLU'./(Z*R));


        h_TLU1=repmat(h_TLU1,1,n);


        a_TLU1=repmat(sqrt(cp_TLU1./(cp_TLU1-Z*R)*Z*R.*T_TLU1_K),1,n);


        cp_TLU1=repmat(cp_TLU1,1,n);


        cv_TLU1=cp_TLU1-Z*R;


        mu_TLU1=repmat(mu_TLU1,1,n);


        k_TLU1=repmat(k_TLU1,1,n);


        Pr_TLU1=cp_TLU1.*mu_TLU1./k_TLU1;


        T_TLU_val=value(T_TLU1,T_TLU_unit);
        rho_TLU1_val=value(rho_TLU1,rho_TLU1_unit);
        h_TLU1_val=value(h_TLU1,h_TLU1_unit);
        cp_TLU1_val=value(cp_TLU1,cp_TLU1_unit);
        cv_TLU1_val=value(cv_TLU1,cv_TLU1_unit);
        mu_TLU1_val=value(mu_TLU1,mu_TLU1_unit);
        k_TLU1_val=value(k_TLU1,k_TLU1_unit);
        a_TLU1_val=value(a_TLU1,a_TLU1_unit);
        Pr_TLU1_val=value(Pr_TLU1,'1');


        fluidProps={
        ['Temperature',' (',char(T_TLU_unit),')'],T_TLU_val;
        ['Pressure',' (',char(p_TLU_unit),')'],p_TLU_val;
        ['Density',' (',char(rho_TLU1_unit),')'],rho_TLU1_val;
        ['Specific Enthalpy',' (',char(h_TLU1_unit),')'],h_TLU1_val;
        ['Specific Heat at Constant Pressure',' (',char(cp_TLU1_unit),')'],cp_TLU1_val;
        ['Specific Heat at Constant Volume',' (',char(cv_TLU1_unit),')'],cv_TLU1_val;
        ['Dynamic Viscosity',' (',char(mu_TLU1_unit),')'],mu_TLU1_val;
        ['Thermal Conductivity',' (',char(k_TLU1_unit),')'],k_TLU1_val;
        ['Speed of Sound',' (',char(a_TLU1_unit),') '],a_TLU1_val;
        'Prandtl Number',Pr_TLU1_val;
        };


        T_min_val=value(T_min,T_TLU_unit);
        T_max_val=value(T_max,T_TLU_unit);
        p_min_val=value(p_min,p_TLU_unit);
        p_max_val=value(p_max,p_TLU_unit);


        for i=3:length(fluidProps)
            fluidPropTable=fluidProps{i,2};


            fluidPropTable((T_TLU_val<T_min_val)|(T_TLU_val>T_max_val),:)=nan;
            fluidPropTable(:,(p_TLU_val<p_min_val)|(p_TLU_val>p_max_val))=nan;
            fluidProps{i,2}=fluidPropTable;
        end

    else


        p_TLU_unit=unit(p_TLU2);
        T_TLU_unit=unit(T_TLU2);
        rho_TLU2_unit=unit(rho_TLU2);
        s_TLU2_unit=unit(s_TLU2);
        h_TLU2_unit=unit(h_TLU2);
        cp_TLU2_unit=unit(cp_TLU2);
        cv_TLU2_unit=unit(cp_TLU2);
        mu_TLU2_unit=unit(mu_TLU2);
        k_TLU2_unit=unit(k_TLU2);
        a_TLU2_unit=simscape.Unit('m/s');


        m=length(T_TLU2);
        n=length(p_TLU2);


        if pT_region_flag==1

            T_min=T_TLU2_min;
            T_max=T_TLU2_max;
            p_min=p_TLU2_min;
            p_max=p_TLU2_max;


            pT_validity_TLU2=simscape.Value(ones(m,n),'1');

        elseif pT_region_flag==2

            T_min=T_min_real;
            T_max=T_max_real;
            p_min=p_min_real;
            p_max=p_max_real;


            pT_validity_TLU2=simscape.Value(ones(m,n),'1');

        else

            T_min=T_TLU2_min;
            T_max=T_TLU2_max;
            p_min=p_TLU2_min;
            p_max=p_TLU2_max;

        end


        T_TLU2=T_TLU2(:);
        p_TLU2=p_TLU2(:);


        cv_TLU2=cp_TLU2-repmat(simscape.Value(value(T_TLU2,'K'),'K'),1,n).*alpha_TLU2.^2.*beta_TLU2./rho_TLU2;


        Pr_TLU2=cp_TLU2.*mu_TLU2./k_TLU2;


        a_TLU2=sqrt(cp_TLU2./cv_TLU2.*beta_TLU2./rho_TLU2);


        T_TLU_val=value(T_TLU2,T_TLU_unit);
        p_TLU_val=value(p_TLU2,p_TLU_unit);
        rho_TLU2_val=value(rho_TLU2,rho_TLU2_unit);
        h_TLU2_val=value(h_TLU2,h_TLU2_unit);
        s_TLU2_val=value(s_TLU2,s_TLU2_unit);
        cp_TLU2_val=value(cp_TLU2,cp_TLU2_unit);
        cv_TLU2_val=value(cv_TLU2,cv_TLU2_unit);
        mu_TLU2_val=value(mu_TLU2,mu_TLU2_unit);
        k_TLU2_val=value(k_TLU2,k_TLU2_unit);
        a_TLU2_val=value(a_TLU2,a_TLU2_unit);
        Pr_TLU2_val=value(Pr_TLU2,'1');


        fluidProps={
        ['Temperature',' (',char(T_TLU_unit),')'],T_TLU_val;
        ['Pressure',' (',char(p_TLU_unit),')'],p_TLU_val;
        ['Density',' (',char(rho_TLU2_unit),')'],rho_TLU2_val;
        ['Specific Enthalpy',' (',char(h_TLU2_unit),')'],h_TLU2_val;
        ['Specific Heat at Constant Pressure',' (',char(cp_TLU2_unit),')'],cp_TLU2_val;
        ['Specific Heat at Constant Volume',' (',char(cv_TLU2_unit),')'],cv_TLU2_val;
        ['Dynamic Viscosity',' (',char(mu_TLU2_unit),')'],mu_TLU2_val;
        ['Thermal Conductivity',' (',char(k_TLU2_unit),')'],k_TLU2_val;
        ['Speed of Sound',' (',char(a_TLU2_unit),') '],a_TLU2_val;
        'Prandtl Number',Pr_TLU2_val;
        ['Specific Entropy',' (',char(s_TLU2_unit),') '],s_TLU2_val;
        };


        T_min_val=value(T_min,T_TLU_unit);
        T_max_val=value(T_max,T_TLU_unit);
        p_min_val=value(p_min,p_TLU_unit);
        p_max_val=value(p_max,p_TLU_unit);

        for i=3:length(fluidProps)
            fluidPropTable=fluidProps{i,2};


            indx=value(pT_validity_TLU2,'1')==0;
            fluidPropTable(indx)=nan;


            fluidPropTable((T_TLU_val<T_min_val)|(T_TLU_val>T_max_val),:)=nan;
            fluidPropTable(:,(p_TLU_val<p_min_val)|(p_TLU_val>p_max_val))=nan;
            fluidProps{i,2}=fluidPropTable;
        end

    end

end

function plotFluidProperties(varargin)

    narginchk(2,3)


    fluidProps=varargin{1};
    hBlock=varargin{2};
    if nargin==3
        hFigure=varargin{3};
    end


    if nargin==3
        if~isgraphics(hFigure,'figure')
            hFigure=figure('Name',get_param(hBlock,'Name'));
            popUpValue=1;

        else
            index=arrayfun(@(s)strcmp(s.Type,'uicontrol'),hFigure.Children);
            popUpIndex=arrayfun(@(s)strcmp(s.Style,'popupmenu'),hFigure.Children(index));
            popUpValue=hFigure.Children(popUpIndex).Value;
        end
    else
        hFigure=figure("Tag","Gas Properties - Plot Gas Properties");
        popUpValue=1;
    end


    setappdata(hFigure,"blockPath",getfullname(hBlock))

    [nProps,~]=size(fluidProps);
    if popUpValue>nProps
        popUpValue=1;
    end

    hFigure.Units='normalized';
    clf(hFigure)
    set(hFigure,'Name',get_param(hBlock,'Name'),'Toolbar','figure')


    persistent figPosition axisPosition

    if nargin==2
        set(gca,'Units','pixel')
        set(hFigure,'Position',get(hFigure,'Position')+[0,0,0,0.01])

        axisPosition=get(gca,'OuterPosition');
        set(gca,'Units','Normalized')
        figPosition=get(hFigure,'Position');

    else
        set(gca,'Units','pixel')
        set(hFigure,'Position',figPosition)
        set(gca,'OuterPosition',axisPosition)

        set(gca,'Units','Normalized')
    end


    hPopup=uicontrol('Style','popupmenu','String',fluidProps(3:end,1),...
    'Units','normalized','Position',[0.3,0.95,0.431,0.05],...
    'Value',popUpValue,'Callback',@(hObject,eventData)plotProperties,...
    'FontWeight','bold');


    hAxes='';
plotProperties
    view(hAxes,-154,20)

    function plotProperties


        idx=get(hPopup,'Value')+2;


        hAxes=gca;
        [az,el]=view(hAxes);
        fluidPropTable=fluidProps{idx,2};


        Temperature=fluidProps{1,1};
        T_TLU_val=fluidProps{1,2};


        Pressure=fluidProps{2,1};
        p_TLU_val=fluidProps{2,2};

        surf(hAxes,p_TLU_val,T_TLU_val,fluidPropTable,'LineStyle',...
        '-','EdgeColor',[0.8,0.8,0.8],'LineWidth',0.5)

        hold on

        if strfind(fluidProps{idx,1},'Density')
            set(hAxes,'XScale','log')
            set(hAxes,'ZScale','log')
        else
            set(hAxes,'XScale','log')
        end

        view(hAxes,az,el)
        xlabel(Pressure)
        ylabel(Temperature)
        zlabel(fluidProps{idx,1})
        hold off
    end


    uiObj=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
    'Units','normalized','Position',[0.76,0.95,0.2,0.05],...
    'backgroundColor',[1,1,1],...
    'Callback',@(hObject,eventData,hBlock)pushbuttonCallback);

    hFigure=uiObj.Parent;

    function pushbuttonCallback
        foundation.internal.mask.plotGasProperties(hBlock,hFigure)
    end

end


function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end
