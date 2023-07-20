function plotTLProperties(varargin)










    narginchk(1,2)


    hBlock=varargin{1};

    if nargin==2
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        string(get_param(hBlock,"ComponentPath"))~="foundation.thermal_liquid.utilities.thermal_liquid_settings"


        if exist("hFigure","var")
            if isgraphics(hFigure,"figure")&&...
                string(hFigure.Tag)=="Thermal Liquid Settings (TL) - Plot Fluid Properties"
                blockPath=getappdata(hFigure,"blockPath");
                hBlock=getSimulinkBlockHandle(blockPath);


                if~is_simulink_handle(hBlock)||...
                    string(get_param(hBlock,"ComponentPath"))~="foundation.thermal_liquid.utilities.thermal_liquid_settings"
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


    table_dimensions=simscapeParameter(blockParams,'table_dimensions');
    T_TLU=simscapeParameter(blockParams,'T_TLU');
    p_TLU=simscapeParameter(blockParams,'p_TLU');
    p_atm=simscapeParameter(blockParams,'p_atm');
    pT_region_flag=simscapeParameter(blockParams,'pT_region_flag');
    T_min=simscapeParameter(blockParams,'T_min');
    T_max=simscapeParameter(blockParams,'T_max');
    p_min=simscapeParameter(blockParams,'p_min');
    p_max=simscapeParameter(blockParams,'p_max');
    T_min_1D=simscapeParameter(blockParams,'T_min_1D');
    T_max_1D=simscapeParameter(blockParams,'T_max_1D');
    p_min_1D=simscapeParameter(blockParams,'p_min_1D');
    p_max_1D=simscapeParameter(blockParams,'p_max_1D');
    pT_validity_TLU=simscapeParameter(blockParams,'pT_validity_TLU');
    rho_parameterization_2D=simscapeParameter(blockParams,'rho_parameterization_2D');
    rho_parameterization_1D=simscapeParameter(blockParams,'rho_parameterization_1D');
    rho_TLU=simscapeParameter(blockParams,'rho_TLU');
    beta_TLU=simscapeParameter(blockParams,'beta_TLU');
    alpha_TLU=simscapeParameter(blockParams,'alpha_TLU');
    rho_TLU_2=simscapeParameter(blockParams,'rho_TLU_2');
    rho_ref_3=simscapeParameter(blockParams,'rho_ref_3');
    T_ref_3=simscapeParameter(blockParams,'T_ref_3');
    p_ref_3=simscapeParameter(blockParams,'p_ref_3');
    beta_const_3=simscapeParameter(blockParams,'beta_const_3');
    alpha_const_3=simscapeParameter(blockParams,'alpha_const_3');
    rho_TLU_4=simscapeParameter(blockParams,'rho_TLU_4');
    beta_const_4=simscapeParameter(blockParams,'beta_const_4');
    p_ref_4=simscapeParameter(blockParams,'p_ref_4');
    rho_ref_5=simscapeParameter(blockParams,'rho_ref_5');
    T_ref_5=simscapeParameter(blockParams,'T_ref_5');
    p_ref_5=simscapeParameter(blockParams,'p_ref_5');
    beta_const_5=simscapeParameter(blockParams,'beta_const_5');
    alpha_const_5=simscapeParameter(blockParams,'alpha_const_5');
    u_parameterization_2D=simscapeParameter(blockParams,'u_parameterization_2D');
    u_parameterization_1D=simscapeParameter(blockParams,'u_parameterization_1D');
    u_TLU=simscapeParameter(blockParams,'u_TLU');
    cp_TLU=simscapeParameter(blockParams,'cp_TLU');
    u_TLU_2=simscapeParameter(blockParams,'u_TLU_2');
    cp_TLU_3=simscapeParameter(blockParams,'cp_TLU_3');
    u_TLU_4=simscapeParameter(blockParams,'u_TLU_4');
    cp_TLU_5=simscapeParameter(blockParams,'cp_TLU_5');
    nu_TLU=simscapeParameter(blockParams,'nu_TLU');
    nu_TLU_2=simscapeParameter(blockParams,'nu_TLU_2');
    k_TLU=simscapeParameter(blockParams,'k_TLU');
    k_TLU_2=simscapeParameter(blockParams,'k_TLU_2');


    fileID='physmod:simscape:library:comments:thermal_liquid:utilities:thermal_liquid_settings:';

    T_TLU_str=string(message([fileID,'T_TLU']));
    T_TLU_first_str=string(message([fileID,'T_TLU_first']));
    T_TLU_last_str=string(message([fileID,'T_TLU_last']));
    p_TLU_str=string(message([fileID,'p_TLU']));
    p_TLU_first_str=string(message([fileID,'p_TLU_first']));
    p_TLU_last_str=string(message([fileID,'p_TLU_last']));
    p_atm_str=string(message([fileID,'p_atm']));
    T_min_str=string(message([fileID,'T_min']));
    T_max_str=string(message([fileID,'T_max']));
    p_min_str=string(message([fileID,'p_min']));
    p_max_str=string(message([fileID,'p_max']));
    T_min_1D_str=string(message([fileID,'T_min_1D']));%#ok<NASGU>
    T_max_1D_str=string(message([fileID,'T_max_1D']));%#ok<NASGU>
    p_min_1D_str=string(message([fileID,'p_min_1D']));%#ok<NASGU>
    p_max_1D_str=string(message([fileID,'p_max_1D']));%#ok<NASGU>
    pT_validity_TLU_str=string(message([fileID,'pT_validity_TLU']));
    rho_TLU_str=string(message([fileID,'rho_TLU']));
    beta_TLU_str=string(message([fileID,'beta_TLU']));
    alpha_TLU_str=string(message([fileID,'alpha_TLU']));
    rho_TLU_2_str=string(message([fileID,'rho_TLU_2']));
    rho_ref_3_str=string(message([fileID,'rho_ref_3']));
    T_ref_3_str=string(message([fileID,'T_ref_3']));
    p_ref_3_str=string(message([fileID,'p_ref_3']));
    beta_const_3_str=string(message([fileID,'beta_const_3']));
    u_TLU_str=string(message([fileID,'u_TLU']));
    cp_TLU_str=string(message([fileID,'cp_TLU']));
    u_TLU_2_str=string(message([fileID,'u_TLU_2']));
    cp_TLU_3_str=string(message([fileID,'cp_TLU_3']));
    nu_TLU_str=string(message([fileID,'nu_TLU']));
    k_TLU_str=string(message([fileID,'k_TLU']));
    rho_TLU_4_str=string(message([fileID,'rho_TLU_4']));
    beta_const_4_str=string(message([fileID,'beta_const_4']));
    p_ref_4_str=string(message([fileID,'p_ref_4']));
    rho_ref_5_str=string(message([fileID,'rho_ref_5']));
    T_ref_5_str=string(message([fileID,'T_ref_5']));
    p_ref_5_str=string(message([fileID,'p_ref_5']));
    beta_const_5_str=string(message([fileID,'beta_const_5']));
    u_TLU_4_str=string(message([fileID,'u_TLU_4']));
    cp_TLU_5_str=string(message([fileID,'cp_TLU_5']));
    nu_TLU_2_str=string(message([fileID,'nu_TLU_2']));
    k_TLU_2_str=string(message([fileID,'k_TLU_2']));


    m=length(T_TLU);
    T_TLU_first=simscape.Value(value(T_TLU(1),'K'),'K');
    T_TLU_last=simscape.Value(value(T_TLU(end),'K'),'K');


    T_TLU_unit=unit(T_TLU);


    T_TLU=simscape.Value(value(T_TLU,'K'),'K');
    T_min=simscape.Value(value(T_min,'K'),'K');
    T_max=simscape.Value(value(T_max,'K'),'K');
    T_min_1D=simscape.Value(value(T_min_1D,'K'),'K');
    T_max_1D=simscape.Value(value(T_max_1D,'K'),'K');
    T_ref_3=simscape.Value(value(T_ref_3,'K'),'K');
    T_ref_5=simscape.Value(value(T_ref_5,'K'),'K');

    if table_dimensions==foundation.enum.table_dimensions_TL.two_dimensional

        n=length(p_TLU);
        p_TLU_first=p_TLU(1);
        p_TLU_last=p_TLU(end);

        if pT_region_flag==foundation.enum.pT_region_TL.min_max

            T_min_=T_min;
            T_max_=T_max;
            p_min_=p_min;
            p_max_=p_max;
            pT_validity_TLU_=ones(m,n);

        else

            T_min_=T_TLU_first;
            T_max_=T_TLU_last;
            p_min_=p_TLU_first;
            p_max_=p_TLU_last;
            pT_validity_TLU_=double(pT_validity_TLU>0);

        end

    else

        n=30;
        T_min_=T_min_1D;
        T_max_=T_max_1D;
        p_min_=p_min_1D;
        p_max_=p_max_1D;
        pT_validity_TLU_=ones(m,n);

    end


    assertssc(length(T_TLU)>=2,...
    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',T_TLU_str,'2'))
    assertssc(all(diff(T_TLU)>0),...
    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',T_TLU_str))
    assertssc(all(T_TLU(:)>0),...
    message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',T_TLU_str))
    assertssc(T_min_>=T_TLU_first,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_min_str,T_TLU_first_str))
    assertssc(T_max_>T_min_,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThan',T_max_str,T_min_str))
    assertssc(T_max_<=T_TLU_last,...
    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',T_max_str,T_TLU_last_str))
    assertssc(p_atm>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_atm_str))
    assertssc(p_min_<=p_atm,...
    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_min_str,p_atm_str))
    assertssc(p_max_>=p_atm,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_max_str,p_atm_str))

    if table_dimensions==foundation.enum.table_dimensions_TL.two_dimensional

        assertssc(length(p_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',p_TLU_str,'2'))
        assertssc(all(diff(p_TLU)>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',p_TLU_str))
        assertssc(all(p_TLU(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',p_TLU_str))
        assertssc(p_min_>=p_TLU_first,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_min_str,p_TLU_first_str))
        assertssc(p_max_>p_min_,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',p_max_str,p_min_str))
        assertssc(p_max_<=p_TLU_last,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_max_str,p_TLU_last_str))
        assertssc(all(size(pT_validity_TLU_)==[length(T_TLU),length(p_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',pT_validity_TLU_str,T_TLU_str,p_TLU_str))


        assertssc(all(sum(pT_validity_TLU_,1)>=2),...
        message('physmod:simscape:library:thermal_liquid:MinValidDataValidityMatrix',pT_validity_TLU_str,'2'))
        assertssc(all(sum(pT_validity_TLU_,2)>=2),...
        message('physmod:simscape:library:thermal_liquid:MinValidDataValidityMatrix',pT_validity_TLU_str,'2'))


        assertssc(all((sum(double(diff(pT_validity_TLU_,1,1)>0.5),1)==0)|...
        ((sum(double(diff(pT_validity_TLU_,1,1)>0.5),1)==1)&(pT_validity_TLU_(1,:)==0))),...
        message('physmod:simscape:library:thermal_liquid:InvalidDataPoints',pT_validity_TLU_str))
        assertssc(all((sum(double(diff(pT_validity_TLU_,1,2)>0.5),2)==0)|...
        ((sum(double(diff(pT_validity_TLU_,1,2)>0.5),2)==1)&(pT_validity_TLU_(:,1)==0))),...
        message('physmod:simscape:library:thermal_liquid:InvalidDataPoints',pT_validity_TLU_str))

        assertssc(all(size(nu_TLU)==[length(T_TLU),length(p_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',nu_TLU_str,T_TLU_str,p_TLU_str))
        assertssc(all(size(k_TLU)==[length(T_TLU),length(p_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',k_TLU_str,T_TLU_str,p_TLU_str))
        assertssc(all(nu_TLU(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',nu_TLU_str))
        assertssc(all(k_TLU(:)>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',k_TLU_str))

        if rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_beta_alpha

            assertssc(all(size(rho_TLU)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',rho_TLU_str,T_TLU_str,p_TLU_str))
            assertssc(all(size(beta_TLU)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',beta_TLU_str,T_TLU_str,p_TLU_str))
            assertssc(all(size(alpha_TLU)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',alpha_TLU_str,T_TLU_str,p_TLU_str))
            assertssc(all(rho_TLU(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',rho_TLU_str))
            assertssc(all(beta_TLU(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',beta_TLU_str))

        elseif rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_table

            assertssc(all(size(rho_TLU_2)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',rho_TLU_2_str,T_TLU_str,p_TLU_str))
            assertssc(all(rho_TLU_2(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',rho_TLU_2_str))
            assertssc(all(all(diff(rho_TLU_2,1,2)>0)),...
            message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',rho_TLU_2_str))

        else

            assertssc(rho_ref_3>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',rho_ref_3_str))
            assertssc(T_ref_3>=T_TLU_first,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_ref_3_str,T_TLU_first_str))
            assertssc(T_ref_3<=T_TLU_last,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',T_ref_3_str,T_TLU_last_str))
            assertssc(p_ref_3>=p_TLU_first,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_ref_3_str,p_TLU_first_str))
            assertssc(p_ref_3<=p_TLU_last,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_ref_3_str,p_TLU_last_str))
            assertssc(beta_const_3>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_3_str))

        end

        if u_parameterization_2D==foundation.enum.u_parameterization_2D.u_cp

            assertssc(all(size(u_TLU)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',u_TLU_str,T_TLU_str,p_TLU_str))
            assertssc(all(size(cp_TLU)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',cp_TLU_str,T_TLU_str,p_TLU_str))
            assertssc(all(cp_TLU(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',cp_TLU_str))

        elseif u_parameterization_2D==foundation.enum.u_parameterization_2D.u

            assertssc(all(size(u_TLU_2)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',u_TLU_2_str,T_TLU_str,p_TLU_str))

        else

            assertssc(all(size(cp_TLU_3)==[length(T_TLU),length(p_TLU)]),...
            message('physmod:simscape:compiler:patterns:checks:Size2DEqual',cp_TLU_3_str,T_TLU_str,p_TLU_str))
            assertssc(all(cp_TLU_3(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',cp_TLU_3_str))

        end

    else

        assertssc(p_min_>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',p_min_str))
        assertssc(p_max_>p_min_,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',p_max_str,p_min_str))
        assertssc(length(nu_TLU_2)==length(T_TLU),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',nu_TLU_2_str,T_TLU_str))
        assertssc(length(k_TLU_2)==length(T_TLU),...
        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',k_TLU_2_str,T_TLU_str))
        assertssc(all(nu_TLU_2>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',nu_TLU_2_str))
        assertssc(all(k_TLU_2>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',k_TLU_2_str))

        if rho_parameterization_1D==foundation.enum.rho_parameterization_1D.rho_vector

            assertssc(length(rho_TLU_4)==length(T_TLU),...
            message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',rho_TLU_4_str,T_TLU_str))
            assertssc(all(rho_TLU_4(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',rho_TLU_4_str))
            assertssc(beta_const_4>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_4_str))
            assertssc(p_ref_4>=p_min_,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_ref_4_str,p_min_str))
            assertssc(p_ref_4<=p_max_,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_ref_4_str,p_max_str))

        else

            assertssc(rho_ref_5>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',rho_ref_5_str))
            assertssc(T_ref_5>=T_TLU_first,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',T_ref_5_str,T_TLU_first_str))
            assertssc(T_ref_5<=T_TLU_last,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',T_ref_5_str,T_TLU_last_str))
            assertssc(p_ref_5>=p_min_,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',p_ref_5_str,p_min_str))
            assertssc(p_ref_5<=p_max_,...
            message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',p_ref_5_str,p_max_str))
            assertssc(beta_const_5>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',beta_const_5_str))

        end

        if u_parameterization_1D==foundation.enum.u_parameterization_1D.u

            assertssc(length(u_TLU_4)==length(T_TLU),...
            message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',u_TLU_4_str,T_TLU_str))

        else

            assertssc(length(cp_TLU_5)==length(T_TLU),...
            message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',cp_TLU_5_str,T_TLU_str))
            assertssc(all(cp_TLU_5(:)>0),...
            message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',cp_TLU_5_str))

        end

    end


    if table_dimensions==foundation.enum.table_dimensions_TL.two_dimensional


        T_TLU_=T_TLU(:);
        p_TLU_=p_TLU(:)';
        nu_TLU_=nu_TLU;
        k_TLU_=k_TLU;

        if rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_beta_alpha


            rho_TLU_=rho_TLU;
            beta_TLU_=beta_TLU;
            alpha_TLU_=alpha_TLU;

        elseif rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_table





            rho_TLU_=simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(rho_TLU_2,'kg/m^3'),value(T_TLU_,'K'),value(p_TLU_,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            pT_validity_TLU_),'kg/m^3');

            beta_TLU_=rho_TLU_./simscape.Value(simscape.library.thermal_liquid.finiteDifference(...
            value(rho_TLU_','kg/m^3'),value(p_TLU_','Pa'))','kg/m^3/Pa');

            alpha_TLU_=-simscape.Value(simscape.library.thermal_liquid.finiteDifference(...
            value(rho_TLU_,'kg/m^3'),value(T_TLU_,'K')),'kg/m^3/K')./rho_TLU_;

        else


            rho_TLU_=rho_ref_3*exp(-alpha_const_3*(T_TLU_-T_ref_3))*exp((p_TLU_-p_ref_3)/beta_const_3);
            beta_TLU_=repmat(beta_const_3,m,n);
            alpha_TLU_=repmat(alpha_const_3,m,n);

        end

        if u_parameterization_2D==foundation.enum.u_parameterization_2D.u_cp


            u_TLU_=u_TLU;
            cp_TLU_=cp_TLU;

        elseif u_parameterization_2D==foundation.enum.u_parameterization_2D.u




            u_TLU_=simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(u_TLU_2,'J/kg'),value(T_TLU_,'K'),value(p_TLU_,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            pT_validity_TLU_),'J/kg');

            cp_TLU_=simscape.Value(simscape.library.thermal_liquid.finiteDifference(...
            value(u_TLU_+repmat(p_TLU_,m,1)./rho_TLU_,'J/kg'),value(T_TLU_,'K')),'J/kg/K');

        else




            cp_TLU_tmp=simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(cp_TLU_3,'J/kg/K'),value(T_TLU_,'K'),value(p_TLU_,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            pT_validity_TLU_),'J/kg/K');
            cp_TLU_=cp_TLU_tmp;

            u_TLU_=simscape.Value(cumtrapz(value(T_TLU_,'K'),...
            value(cp_TLU_tmp-repmat(p_TLU_,m,1).*alpha_TLU_./rho_TLU_,'J/kg/K'),1),'J/kg');

        end

    else


        T_TLU_=T_TLU(:);
        p_TLU_=simscape.Value(logspace(log10(value(p_min_,'Pa')),log10(value(p_max_,'Pa')),n),'Pa');
        nu_TLU_=repmat(nu_TLU_2(:),1,n);
        k_TLU_=repmat(k_TLU_2(:),1,n);

        if rho_parameterization_1D==foundation.enum.rho_parameterization_1D.rho_vector





            rho_TLU_=simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(rho_TLU_4(:),'kg/m^3'),value(T_TLU_,'K'),value(p_atm,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            ones(m,1)),'kg/m^3')...
            *exp((p_TLU_-p_ref_4)/beta_const_4);

            beta_TLU_=repmat(beta_const_4,m,n);

            alpha_TLU_=-simscape.Value(simscape.library.thermal_liquid.finiteDifference(...
            value(rho_TLU_,'kg/m^3'),value(T_TLU_,'K')),'kg/m^3/K')./rho_TLU_;

        else


            rho_TLU_=rho_ref_5*exp(-alpha_const_5*(T_TLU_-T_ref_5))*exp((p_TLU_-p_ref_5)/beta_const_5);
            beta_TLU_=repmat(beta_const_5,m,n);
            alpha_TLU_=repmat(alpha_const_5,m,n);

        end

        if u_parameterization_1D==foundation.enum.u_parameterization_1D.u




            u_TLU_=repmat(simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(u_TLU_4(:),'J/kg'),value(T_TLU_,'K'),value(p_atm,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            ones(m,1)),'J/kg'),1,n);

            cp_TLU_=simscape.Value(simscape.library.thermal_liquid.finiteDifference(...
            value(u_TLU_+repmat(p_TLU_,m,1)./rho_TLU_,'J/kg'),value(T_TLU_,'K')),'J/kg/K');

        else




            cp_TLU_tmp=repmat(simscape.Value(simscape.library.thermal_liquid.invalidBoundaryReplace(...
            value(cp_TLU_5(:),'J/kg/K'),value(T_TLU_,'K'),value(p_atm,'Pa'),...
            value(T_min_,'K'),value(T_max_,'K'),value(p_min_,'Pa'),value(p_max_,'Pa'),...
            ones(m,1)),'J/kg/K'),1,n);
            cp_TLU_=cp_TLU_tmp;

            u_TLU_=simscape.Value(cumtrapz(value(T_TLU_,'K'),...
            value(cp_TLU_tmp-repmat(p_TLU_,m,1).*alpha_TLU_./rho_TLU_,'J/kg/K'),1),'J/kg');

        end

    end


    p_TLU_unit=unit(p_TLU);

    if table_dimensions==foundation.enum.table_dimensions_TL.two_dimensional


        if rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_beta_alpha

            rho_TLU_unit=unit(rho_TLU);
            beta_TLU_unit=unit(beta_TLU);
            alpha_TLU_unit=unit(alpha_TLU);

        elseif rho_parameterization_2D==foundation.enum.rho_parameterization_2D.rho_table

            rho_TLU_unit=unit(rho_TLU_2);
            beta_TLU_unit=simscape.Unit('GPa');
            alpha_TLU_unit=simscape.Unit('1/K');

        else

            rho_TLU_unit=unit(rho_ref_3);
            beta_TLU_unit=unit(beta_const_3);
            alpha_TLU_unit=unit(alpha_const_3);
        end


        if u_parameterization_2D==foundation.enum.u_parameterization_2D.u_cp

            u_TLU_unit=unit(u_TLU);
            cp_TLU_unit=unit(cp_TLU);

        elseif u_parameterization_2D==foundation.enum.u_parameterization_2D.u

            u_TLU_unit=unit(u_TLU_2);
            cp_TLU_unit=simscape.Unit('kJ/(kg*K)');

        else

            u_TLU_unit=simscape.Unit('kJ/kg');
            cp_TLU_unit=unit(cp_TLU_3);

        end


        nu_TLU_unit=unit(nu_TLU);


        k_TLU_unit=unit(k_TLU);

    else


        if rho_parameterization_1D==foundation.enum.rho_parameterization_1D.rho_vector

            rho_TLU_unit=unit(rho_TLU_4);
            beta_TLU_unit=unit(beta_const_4);
            alpha_TLU_unit=simscape.Unit('1/K');

        else

            rho_TLU_unit=unit(rho_ref_5);
            beta_TLU_unit=unit(beta_const_5);
            alpha_TLU_unit=unit(alpha_const_5);

        end


        if u_parameterization_1D==foundation.enum.u_parameterization_1D.u

            u_TLU_unit=unit(u_TLU_4);
            cp_TLU_unit=simscape.Unit('kJ/(kg*K)');

        else

            u_TLU_unit=simscape.Unit('kJ/kg');
            cp_TLU_unit=unit(cp_TLU_5);
        end


        nu_TLU_unit=unit(nu_TLU_2);


        k_TLU_unit=unit(k_TLU_2);

    end


    T_TLU_val=value(T_TLU_,T_TLU_unit);
    p_TLU_val=value(p_TLU_,p_TLU_unit);
    rho_TLU_val=value(rho_TLU_,rho_TLU_unit);
    beta_TLU_val=value(beta_TLU_,beta_TLU_unit);
    alpha_TLU_val=value(alpha_TLU_,alpha_TLU_unit);
    u_TLU_val=value(u_TLU_,u_TLU_unit);
    cp_TLU_val=value(cp_TLU_,cp_TLU_unit);
    nu_TLU_val=value(nu_TLU_,nu_TLU_unit);
    k_TLU_val=value(k_TLU_,k_TLU_unit);


    fluidProps={
    ['Temperature',' (',char(T_TLU_unit),')'],T_TLU_val;
    ['Pressure',' (',char(p_TLU_unit),')'],p_TLU_val;
    ['Density',' (',char(rho_TLU_unit),')'],rho_TLU_val;
    ['Isothermal Bulk Modulus',' (',char(beta_TLU_unit),')'],beta_TLU_val;
    ['Isobaric thermal expansion coefficient',' (',char(alpha_TLU_unit),')'],alpha_TLU_val;
    ['Specific internal energy',' (',char(u_TLU_unit),')'],u_TLU_val;
    ['Specific Heat at Constant Pressure',' (',char(cp_TLU_unit),')'],cp_TLU_val;
    ['Kinematic Viscosity',' (',char(nu_TLU_unit),')'],nu_TLU_val;
    ['Thermal Conductivity',' (',char(k_TLU_unit),')'],k_TLU_val;
    };


    T_min_val=value(T_min_,T_TLU_unit);
    T_max_val=value(T_max_,T_TLU_unit);
    p_min_val=value(p_min_,p_TLU_unit);
    p_max_val=value(p_max_,p_TLU_unit);

    for i=3:length(fluidProps)
        fluidPropTable=fluidProps{i,2};


        indx=pT_validity_TLU_==0;
        fluidPropTable(indx)=NaN;


        fluidPropTable((T_TLU_val<T_min_val)|(T_TLU_val>T_max_val),:)=NaN;
        fluidPropTable(:,(p_TLU_val<p_min_val)|(p_TLU_val>p_max_val))=NaN;
        fluidProps{i,2}=fluidPropTable;
    end

end



function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end



function assertssc(expr,msg)
    assert(logical(expr),msg)
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
        hFigure=figure("Tag","Thermal Liquid Settings (TL) - Plot Fluid Properties");
        popUpValue=1;
    end


    setappdata(hFigure,"blockPath",getfullname(hBlock))

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
        set(hAxes,'XScale','log')
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
        foundation.internal.mask.plotTLProperties(hBlock,hFigure)
    end

end