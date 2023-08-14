function plotFanCharacteristics(varargin)








    narginchk(1,2)


    hBlock=varargin{1};
    if nargin==1
        hFigure=[];
    else
        hFigure=varargin{2};
    end

    if ischar(hBlock)||isstring(hBlock)
        hBlock=getSimulinkBlockHandle(hBlock);
    end


    if~is_simulink_handle(hBlock)||...
        (string(get_param(hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.fan"&&...
        string(get_param(hBlock,"ComponentPath"))~="fluids.moist_air.turbomachinery.fan")


        if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
            string(hFigure.Tag)=="Fan (G) or Fan (MA) - Plot Fan Characteristics"
            blockPath=getappdata(hFigure,"blockPath");
            hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(hBlock)||...
                (string(get_param(hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.fan"&&...
                string(get_param(hBlock,"ComponentPath"))~="fluids.moist_air.turbomachinery.fan")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    [ssc,str]=extractParameters(hBlock);
    ssc=checkParameters(ssc,str);


    prepareFigure(hBlock,hFigure);


    plotFanCurves(ssc)

end




function[ssc,str]=extractParameters(hBlock)


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);


    ssc=cell2struct(...
    cellfun(@simscape.Value,blockParams.Value,blockParams.Unit,"UniformOutput",false),...
    blockParams.Row);



    str=cell2struct(blockParams.Prompt,blockParams.Row);

end




function[ssc,str]=checkParameters(ssc,str)


    if logical(ssc.fan_parameterization==1)


        ssc.flow_rate_max_max=ssc.pressure_max*ssc.flow_rate_nominal...
        /(ssc.pressure_max-ssc.pressure_nominal);
        str.flow_rate_max_max="(Maximum static pressure gain at zero flow) * (Nominal volumetric flow rate) / ((Maximum static pressure gain at zero flow) - (Nominal static pressure gain))";

        assertPattern(ssc.flow_rate_nominal>0,"GreaterThanZero",str.flow_rate_nominal)
        assertPattern(ssc.pressure_nominal>0,"GreaterThanZero",str.pressure_nominal)
        assertPattern(ssc.pressure_max>ssc.pressure_nominal,"GreaterThan",str.pressure_max,str.pressure_nominal)
        assertPattern(ssc.flow_rate_max>ssc.flow_rate_nominal,"GreaterThan",str.flow_rate_max,str.flow_rate_nominal)
        assertPattern(ssc.flow_rate_max<=ssc.flow_rate_max_max,"LessThanOrEqual",str.flow_rate_max,str.flow_rate_max_max)
        assertPattern(ssc.omega_ref_nominal>0,"GreaterThanZero",str.omega_ref_nominal)

        if logical(ssc.mechanical_power_spec==1)

            assertPattern(ssc.eta_nominal>0,"GreaterThanZero",str.eta_nominal)
            assertPattern(ssc.eta_nominal<=1,"LessThanOrEqual",str.eta_nominal,"1")

        else

            assertPattern(ssc.power_nominal>0,"GreaterThanZero",str.power_nominal)
        end

    elseif logical(ssc.fan_parameterization==2)


        assertPattern(length(ssc.flow_rate_1D_TLU)>=2,"LengthGreaterThanOrEqual",str.flow_rate_1D_TLU,"2")
        assertPattern(length(ssc.pressure_1D_TLU)==length(ssc.flow_rate_1D_TLU),"LengthEqualLength",str.pressure_1D_TLU,str.flow_rate_1D_TLU)

        assertPattern(all(diff(ssc.flow_rate_1D_TLU)>0),"StrictlyAscendingVec",str.flow_rate_1D_TLU)


        ssc.pressure_1D_TLU_zero=simscape.Value(...
        interp1(value(ssc.flow_rate_1D_TLU,"m^3/s"),value(ssc.pressure_1D_TLU,"Pa"),0,"linear","extrap"),...
        "Pa");
        str.pressure_1D_TLU_zero="Static pressure gain vector interpolated at zero volumetric flow rate";


        assertPattern(ssc.pressure_1D_TLU_zero>0,"GreaterThanZero",str.pressure_1D_TLU_zero)
        assertPattern(ssc.omega_ref_1D>0,"GreaterThanZero",str.omega_ref_1D)
        assertPattern(ssc.rho_ref_1D>0,"GreaterThanZero",str.rho_ref_1D)

        if logical(ssc.mechanical_power_spec==1)


            assertPattern(length(ssc.eta_1D_TLU)==length(ssc.flow_rate_1D_TLU),"LengthEqualLength",str.eta_1D_TLU,str.flow_rate_1D_TLU)


            assertPattern(all(ssc.flow_rate_1D_TLU(:)>=0),"ArrayGreaterThanOrEqualZero",str.flow_rate_1D_TLU)
            assertPattern(all(ssc.pressure_1D_TLU(:)>0),"ArrayGreaterThanZero",str.pressure_1D_TLU)
            assertPattern(all(ssc.eta_1D_TLU(:)>0),"ArrayGreaterThanZero",str.eta_1D_TLU)
            assertPattern(all(ssc.eta_1D_TLU(:)<=1),"ArrayLessThanOrEqual",str.eta_1D_TLU,"1")

        else


            assertPattern(length(ssc.power_1D_TLU)==length(ssc.flow_rate_1D_TLU),"LengthEqualLength",str.power_1D_TLU,str.flow_rate_1D_TLU)


            ssc.flow_rate_1D_TLU_last=ssc.flow_rate_1D_TLU(end);
            str.flow_rate_1D_TLU_last="last element of Volumetric flow rate vector";
            ssc.power_1D_TLU_zero=simscape.Value(...
            interp1(value(ssc.flow_rate_1D_TLU,"m^3/s"),value(ssc.power_1D_TLU,"W"),0,"linear","extrap"),...
            "W");
            str.power_1D_TLU_zero="Mechanical power vector interpolated at zero volumetric flow rate";



            assertPattern(ssc.flow_rate_1D_TLU_last>0,"GreaterThanZero",str.flow_rate_1D_TLU_last)
            assertPattern(ssc.power_1D_TLU_zero>0,"GreaterThanZero",str.power_1D_TLU_zero)
            assert(logical(all((ssc.power_1D_TLU(:)>0)>=(ssc.pressure_1D_TLU(:)>0))),...
            message("physmod:fluids:library:CorrespondingElementsAlsoPositive",str.power_1D_TLU,str.pressure_1D_TLU))
        end

    elseif logical(ssc.fan_parameterization==3)


        assertPattern(length(ssc.omega_dp_TLU)>=2,"LengthGreaterThanOrEqual",str.omega_dp_TLU,"2")
        assertPattern(length(ssc.flow_rate_dp_TLU)>=2,"LengthGreaterThanOrEqual",str.flow_rate_dp_TLU,"2")
        assertPattern(all(size(ssc.pressure_dp_TLU)==[length(ssc.omega_dp_TLU),length(ssc.flow_rate_dp_TLU)]),"Size2DEqual",str.pressure_dp_TLU,str.omega_dp_TLU,str.flow_rate_dp_TLU)

        assertPattern(all(diff(ssc.omega_dp_TLU)>0),"StrictlyAscendingVec",str.omega_dp_TLU)
        assertPattern(all(diff(ssc.flow_rate_dp_TLU)>0),"StrictlyAscendingVec",str.flow_rate_dp_TLU)

        assertPattern(all(ssc.omega_dp_TLU(:)>0),"ArrayGreaterThanZero",str.omega_dp_TLU)
        assertPattern(ssc.rho_ref_dp>0,"GreaterThanZero",str.rho_ref_dp)

        m=size(ssc.pressure_dp_TLU,1);
        n=size(ssc.pressure_dp_TLU,2);

        if logical(ssc.mechanical_power_spec==1)


            assertPattern(all(size(ssc.eta_dp_TLU)==[length(ssc.omega_dp_TLU),length(ssc.flow_rate_dp_TLU)]),"Size2DEqual",str.eta_dp_TLU,str.omega_dp_TLU,str.flow_rate_dp_TLU)

            assert(logical(all(isnan(ssc.pressure_dp_TLU(:))==isnan(ssc.eta_dp_TLU(:)))),...
            message("physmod:fluids:library:NaNSamePositions",str.eta_dp_TLU,str.pressure_dp_TLU))


            assertPattern(all(ssc.flow_rate_dp_TLU(:)>=0),"ArrayGreaterThanOrEqualZero",str.flow_rate_dp_TLU)
            assertPattern(all((ssc.pressure_dp_TLU(:)>0)|isnan(ssc.pressure_dp_TLU(:))),"ArrayGreaterThanZero",str.pressure_dp_TLU)
            assertPattern(all((ssc.eta_dp_TLU(:)>0)|isnan(ssc.eta_dp_TLU(:))),"ArrayGreaterThanZero",str.eta_dp_TLU)
            assertPattern(all((ssc.eta_dp_TLU(:)<=1)|isnan(ssc.eta_dp_TLU(:))),"ArrayLessThanOrEqual",str.eta_dp_TLU,"1")


            ssc.torque_dp_TLU=repmat(ssc.flow_rate_dp_TLU(:)',m,1).*ssc.pressure_dp_TLU./ssc.eta_dp_TLU./repmat(ssc.omega_dp_TLU(:),1,n);




            if logical(ssc.flow_rate_dp_TLU(1)==0)
                ssc.torque_dp_TLU(:,1)=ssc.flow_rate_dp_TLU(2).*ssc.pressure_dp_TLU(:,1)./ssc.eta_dp_TLU(:,2)./ssc.omega_dp_TLU(:);
            end

        else


            assertPattern(all(size(ssc.power_dp_TLU)==[length(ssc.omega_dp_TLU),length(ssc.flow_rate_dp_TLU)]),"Size2DEqual",str.power_dp_TLU,str.omega_dp_TLU,str.flow_rate_dp_TLU)

            assert(logical(all(isnan(ssc.pressure_dp_TLU(:))==isnan(ssc.power_dp_TLU(:)))),...
            message("physmod:fluids:library:NaNSamePositions",str.power_dp_TLU,str.pressure_dp_TLU))


            ssc.flow_rate_dp_TLU_last=ssc.flow_rate_dp_TLU(end);
            str.flow_rate_dp_TLU_last="last element of Volumetric flow rate vector, q,";



            assertPattern(ssc.flow_rate_dp_TLU_last>0,"GreaterThanZero",str.flow_rate_dp_TLU_last)
            assert(logical(all((ssc.power_dp_TLU(:)>0)>=(ssc.pressure_dp_TLU(:)>0))),...
            message("physmod:fluids:library:CorrespondingElementsAlsoPositive",str.power_dp_TLU,str.pressure_dp_TLU))


            ssc.torque_dp_TLU=ssc.power_dp_TLU./repmat(ssc.omega_dp_TLU(:),1,n);
        end


        [omega_dp_TLU_ext_val,...
        flow_rate_dp_TLU_ext_val,...
        pressure_dp_TLU_ext_val,...
        torque_dp_TLU_ext_val,...
        pressure_dp_TLU_zero_val,...
        torque_dp_TLU_zero_val,...
        exitflag]...
        =fluids.internal.turbomachinery.extendCharacteristicCurves(...
        value(ssc.omega_dp_TLU,"rad/s"),...
        value(ssc.flow_rate_dp_TLU,"m^3/s"),...
        value(ssc.pressure_dp_TLU,"Pa"),...
        value(ssc.torque_dp_TLU,"N*m"));

        ssc.omega_dp_TLU_ext=simscape.Value(omega_dp_TLU_ext_val,"rad/s");
        ssc.flow_rate_dp_TLU_ext=simscape.Value(flow_rate_dp_TLU_ext_val,"m^3/s");
        ssc.pressure_dp_TLU_ext=simscape.Value(pressure_dp_TLU_ext_val,"Pa");
        ssc.torque_dp_TLU_ext=simscape.Value(torque_dp_TLU_ext_val,"N*m");


        ssc.pressure_dp_TLU_zero=simscape.Value(pressure_dp_TLU_zero_val,"Pa");
        str.pressure_dp_TLU_zero="Static pressure gain table, dp(w,q), interpolated at zero volumetric flow rate";
        ssc.power_dp_TLU_zero=simscape.Value(torque_dp_TLU_zero_val(:),"N*m").*ssc.omega_dp_TLU(:);
        str.power_dp_TLU_zero="Mechanical power table, W(w,q), interpolated at zero volumetric flow rate";


        assertPattern(all(ssc.pressure_dp_TLU_zero(:)>0),"ArrayGreaterThanZero",str.pressure_dp_TLU_zero)

        assertPattern(all(diff(ssc.pressure_dp_TLU_zero)>0),"StrictlyAscendingVec",str.pressure_dp_TLU_zero)

        if exitflag==-1
            assert(false,message("physmod:fluids:library:NonNaNInEachRow",str.pressure_dp_TLU))
        elseif exitflag==-2
            assert(false,message("physmod:fluids:library:NaNConsecutiveEndOfRow",str.pressure_dp_TLU))
        elseif exitflag==-3
            assert(false,message("physmod:fluids:library:DecreasingNumberOfNaN",str.pressure_dp_TLU))
        end

        if logical(ssc.mechanical_power_spec==2)

            assertPattern(all(ssc.power_dp_TLU_zero(:)>0),"ArrayGreaterThanZero",str.power_dp_TLU_zero)

            assertPattern(all(diff(ssc.power_dp_TLU_zero)>0),"StrictlyAscendingVec",str.power_dp_TLU_zero)
        end

    else


        assertPattern(length(ssc.omega_q_TLU)>=2,"LengthGreaterThanOrEqual",str.omega_q_TLU,"2")
        assertPattern(length(ssc.pressure_q_TLU)>=2,"LengthGreaterThanOrEqual",str.pressure_q_TLU,"2")
        assertPattern(all(size(ssc.flow_rate_q_TLU)==[length(ssc.omega_q_TLU),length(ssc.pressure_q_TLU)]),"Size2DEqual",str.flow_rate_q_TLU,str.omega_q_TLU,str.pressure_q_TLU)

        assertPattern(all(diff(ssc.omega_q_TLU)>0),"StrictlyAscendingVec",str.omega_q_TLU)
        assertPattern(all(diff(ssc.pressure_q_TLU)>0),"StrictlyAscendingVec",str.pressure_q_TLU)

        assertPattern(all(ssc.omega_q_TLU(:)>0),"ArrayGreaterThanZero",str.omega_q_TLU)
        assertPattern(ssc.rho_ref_q>0,"GreaterThanZero",str.rho_ref_q)

        m=size(ssc.flow_rate_q_TLU,1);
        n=size(ssc.flow_rate_q_TLU,2);

        if logical(ssc.mechanical_power_spec==1)


            assertPattern(all(size(ssc.eta_q_TLU)==[length(ssc.omega_q_TLU),length(ssc.pressure_q_TLU)]),"Size2DEqual",str.eta_q_TLU,str.omega_q_TLU,str.pressure_q_TLU)

            assert(logical(all(isnan(ssc.flow_rate_q_TLU(:))==isnan(ssc.eta_q_TLU(:)))),...
            message("physmod:fluids:library:NaNSamePositions",str.eta_q_TLU,str.flow_rate_q_TLU))


            assertPattern(all(ssc.pressure_q_TLU(:)>=0),"ArrayGreaterThanOrEqualZero",str.pressure_q_TLU)
            assertPattern(all((ssc.flow_rate_q_TLU(:)>0)|isnan(ssc.flow_rate_q_TLU(:))),"ArrayGreaterThanZero",str.flow_rate_q_TLU)
            assertPattern(all((ssc.eta_q_TLU(:)>0)|isnan(ssc.eta_q_TLU(:))),"ArrayGreaterThanZero",str.eta_q_TLU)
            assertPattern(all((ssc.eta_q_TLU(:)<=1)|isnan(ssc.eta_q_TLU(:))),"ArrayLessThanOrEqual",str.eta_q_TLU,"1")


            ssc.torque_q_TLU=ssc.flow_rate_q_TLU.*repmat(ssc.pressure_q_TLU(:)',m,1)./ssc.eta_q_TLU./repmat(ssc.omega_q_TLU(:),1,n);




            if logical(ssc.pressure_q_TLU(1)==0)
                ssc.torque_q_TLU(:,1)=ssc.flow_rate_q_TLU(:,1).*ssc.pressure_q_TLU(2)./ssc.eta_q_TLU(:,2)./ssc.omega_q_TLU(:);
            end

        else


            assertPattern(all(size(ssc.power_q_TLU)==[length(ssc.omega_q_TLU),length(ssc.pressure_q_TLU)]),"Size2DEqual",str.power_q_TLU,str.omega_q_TLU,str.pressure_q_TLU)

            assert(logical(all(isnan(ssc.flow_rate_q_TLU(:))==isnan(ssc.power_q_TLU(:)))),...
            message("physmod:fluids:library:NaNSamePositions",str.power_q_TLU,str.flow_rate_q_TLU))


            ssc.pressure_q_TLU_last=ssc.pressure_q_TLU(end);
            str.pressure_q_TLU_last="last element of Static pressure gain vector, dp,";



            assertPattern(ssc.pressure_q_TLU_last>0,"GreaterThanZero",str.pressure_q_TLU_last)
            assert(logical(all((ssc.power_q_TLU(:)>0)>=(ssc.flow_rate_q_TLU(:)>0))),...
            message("physmod:fluids:library:CorrespondingElementsAlsoPositive",str.power_q_TLU,str.flow_rate_q_TLU))


            ssc.torque_q_TLU=ssc.power_q_TLU./repmat(ssc.omega_q_TLU(:),1,n);
        end



        [omega_q_TLU_ext_val,...
        pressure_q_TLU_ext_val,...
        flow_rate_q_TLU_ext_val,...
        torque_q_TLU_ext_val,...
        flow_rate_q_TLU_zero_val,...
        torque_q_TLU_zero_val,...
        exitflag]...
        =fluids.internal.turbomachinery.extendCharacteristicCurves(...
        value(ssc.omega_q_TLU,"rad/s"),...
        value(ssc.pressure_q_TLU,"Pa"),...
        value(ssc.flow_rate_q_TLU,"m^3/s"),...
        value(ssc.torque_q_TLU,"N*m"));

        ssc.omega_q_TLU_ext=simscape.Value(omega_q_TLU_ext_val,"rad/s");
        ssc.pressure_q_TLU_ext=simscape.Value(pressure_q_TLU_ext_val,"Pa");
        ssc.flow_rate_q_TLU_ext=simscape.Value(flow_rate_q_TLU_ext_val,"m^3/s");
        ssc.torque_q_TLU_ext=simscape.Value(torque_q_TLU_ext_val,"N*m");


        ssc.flow_rate_q_TLU_zero=simscape.Value(flow_rate_q_TLU_zero_val,"Pa");
        str.flow_rate_q_TLU_zero="Volumetric flow rate table, q(w,dp), interpolated at zero static pressure gain";
        ssc.power_q_TLU_zero=simscape.Value(torque_q_TLU_zero_val(:),"N*m").*ssc.omega_q_TLU(:);
        str.power_q_TLU_zero="Mechanical power table, W(w,dp), interpolated at zero static pressure gain";


        assertPattern(all(ssc.flow_rate_q_TLU_zero(:)>0),"ArrayGreaterThanZero",str.flow_rate_q_TLU_zero)

        assertPattern(all(diff(ssc.flow_rate_q_TLU_zero)>0),"StrictlyAscendingVec",str.flow_rate_q_TLU_zero)

        if exitflag==-1
            assert(false,message("physmod:fluids:library:NonNaNInEachRow",str.flow_rate_q_TLU))
        elseif exitflag==-2
            assert(false,message("physmod:fluids:library:NaNConsecutiveEndOfRow",str.flow_rate_q_TLU))
        elseif exitflag==-3
            assert(false,message("physmod:fluids:library:DecreasingNumberOfNaN",str.flow_rate_q_TLU))
        end

        if logical(ssc.mechanical_power_spec==2)

            assertPattern(all(ssc.power_q_TLU_zero(:)>0),"ArrayGreaterThanZero",str.power_q_TLU_zero)

            assertPattern(all(diff(ssc.power_q_TLU_zero)>0),"StrictlyAscendingVec",str.power_q_TLU_zero)
        end

    end

    assertPattern(ssc.diameter_ratio>0,"GreaterThanZero",str.diameter_ratio)





end




function assertPattern(cond,msgID,varargin)

    assert(logical(cond),message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:}))

end




function prepareFigure(hBlock,hFigure)

    if~isempty(hFigure)&&isgraphics(hFigure,"figure")&&...
        string(hFigure.Tag)=="Fan (G) or Fan (MA) - Plot Fan Characteristics"

        figure(hFigure)

        hButton=getappdata(hFigure,"hButton");
    else


        hFigure=figure("Tag","Fan (G) or Fan (MA) - Plot Fan Characteristics");


        hButton=uicontrol(hFigure,"Style","pushbutton","backgroundColor",[1,1,1],...
        "Units","normalized","Position",[0.02,0.95,0.2,0.05],...
        "String","Reload Data","FontWeight","bold","FontSize",8);
        hButton.Units="pixels";

        setappdata(hFigure,"hButton",hButton)
    end


    setappdata(hFigure,"blockPath",getfullname(hBlock))


    hButton.Callback=@(hObject,eventData)fluids.internal.mask.plotFanCharacteristics(hBlock,hFigure);


    hFigure.Name=get_param(hBlock,"Name");


    tiledlayout(hFigure,2,2,"TileSpacing","compact")
    nexttile;
    nexttile;
    nexttile;
    nexttile;


    leftMargin=hButton.Position(1);
    topMargin=hFigure.Position(4)-hButton.Position(2);

    hFigure.SizeChangedFcn=@(hObject,eventData)maintainSize(hObject,hButton,leftMargin,topMargin);

end




function maintainSize(hFigure,hButton,leftMargin,topMargin)

    hButton.Position(1)=leftMargin;
    hButton.Position(2)=hFigure.Position(4)-topMargin;

end




function plotFanCurves(ssc)


    frac_ext=0.1;

    if logical(ssc.fan_parameterization==1)

        if logical(ssc.mechanical_power_spec==1)
            ssc.eta_nominal_used=ssc.eta_nominal;
        else
            ssc.eta_nominal_used=ssc.flow_rate_nominal*ssc.pressure_nominal/ssc.power_nominal;
        end



        c0=ssc.pressure_max;
        c1=simscape.Value(0,"Pa/(m^3/s)");
        c2=(ssc.pressure_nominal-ssc.pressure_max)/ssc.flow_rate_nominal^2;

        c3=ssc.flow_rate_max*(2*ssc.pressure_max*(ssc.flow_rate_max-ssc.flow_rate_nominal)-ssc.pressure_nominal*ssc.flow_rate_max)...
        /(ssc.flow_rate_max-ssc.flow_rate_nominal)^2;
        c4=2*(ssc.pressure_max*ssc.flow_rate_nominal^2-(ssc.pressure_max-ssc.pressure_nominal)*ssc.flow_rate_max^2)...
        /ssc.flow_rate_nominal/(ssc.flow_rate_max-ssc.flow_rate_nominal)^2;
        c5=((2*ssc.pressure_max-ssc.pressure_nominal)*(ssc.flow_rate_max-ssc.flow_rate_nominal)-ssc.pressure_nominal*ssc.flow_rate_max)...
        /ssc.flow_rate_nominal/(ssc.flow_rate_max-ssc.flow_rate_nominal)^2;


        d0=ssc.flow_rate_nominal^2*ssc.pressure_max/ssc.eta_nominal_used;
        d1=(ssc.pressure_max-ssc.pressure_nominal)/ssc.eta_nominal_used;
        d2=(2*ssc.pressure_max*(ssc.flow_rate_max-ssc.flow_rate_nominal)-ssc.pressure_nominal*ssc.flow_rate_max)*ssc.flow_rate_nominal/(ssc.eta_nominal_used*ssc.flow_rate_nominal);
        d3=(ssc.pressure_nominal*ssc.flow_rate_max-(2*ssc.pressure_max-ssc.pressure_nominal)*(ssc.flow_rate_max-ssc.flow_rate_nominal))/(ssc.eta_nominal_used*ssc.flow_rate_nominal);
        d4=ssc.flow_rate_max-2*ssc.flow_rate_nominal;


        ssc.flow_rate_ref=linspace(-frac_ext*ssc.flow_rate_max,(1+frac_ext)*ssc.flow_rate_max,1000);




        ssc.delta_p_ref=...
        logical(ssc.flow_rate_ref<0).*...
        (c0*ones(size(ssc.flow_rate_ref)))+...
        logical(ssc.flow_rate_ref>=0&ssc.flow_rate_ref<=ssc.flow_rate_nominal).*...
        (c0+c1*ssc.flow_rate_ref+c2*ssc.flow_rate_ref.^2)+...
        logical(ssc.flow_rate_ref>ssc.flow_rate_nominal&ssc.flow_rate_ref<=ssc.flow_rate_max).*...
        (c3+c4*ssc.flow_rate_ref+c5*ssc.flow_rate_ref.^2)+...
        logical(ssc.flow_rate_ref>ssc.flow_rate_max).*...
        (c4+2*c5*ssc.flow_rate_max).*(ssc.flow_rate_ref-ssc.flow_rate_max);



        ssc.power_ref=...
        logical(ssc.flow_rate_ref<0).*...
        (d0/(2*ssc.flow_rate_nominal)*ones(size(ssc.flow_rate_ref)))+...
        logical(ssc.flow_rate_ref>=0&ssc.flow_rate_ref<=ssc.flow_rate_nominal).*...
        (d0-d1*ssc.flow_rate_ref.^2)./(2*ssc.flow_rate_nominal-ssc.flow_rate_ref)+...
        logical(ssc.flow_rate_ref>ssc.flow_rate_nominal&ssc.flow_rate_ref<=ssc.flow_rate_max).*...
        ssc.flow_rate_ref.*(d2+d3*ssc.flow_rate_ref)./(d4+ssc.flow_rate_ref)+...
        logical(ssc.flow_rate_ref>ssc.flow_rate_max).*...
        (ssc.flow_rate_max*(d2+d3*ssc.flow_rate_max)/(d4+ssc.flow_rate_max)*ones(size(ssc.flow_rate_ref)));


        ssc.torque_ref=ssc.power_ref/ssc.omega_ref_nominal;


        ssc.eta_ref=...
        logical(ssc.flow_rate_ref<=ssc.flow_rate_nominal).*...
        (ssc.eta_nominal_used*ssc.flow_rate_ref.*(2*ssc.flow_rate_nominal-ssc.flow_rate_ref))/ssc.flow_rate_nominal^2+...
        logical(ssc.flow_rate_ref>ssc.flow_rate_nominal).*...
        (ssc.eta_nominal_used*(ssc.flow_rate_max-ssc.flow_rate_ref).*(ssc.flow_rate_max-2*ssc.flow_rate_nominal+ssc.flow_rate_ref))/(ssc.flow_rate_max-ssc.flow_rate_nominal)^2;


        ssc.eta_ref((ssc.flow_rate_ref<0)|(ssc.flow_rate_ref>ssc.flow_rate_max))=NaN;


        ssc.flow_rate_ref_data=[0;ssc.flow_rate_nominal;ssc.flow_rate_max];
        ssc.delta_p_ref_data=[ssc.pressure_max;ssc.pressure_nominal;0];
        if logical(ssc.mechanical_power_spec==1)
            ssc.eta_ref_data=[simscape.Value(NaN,"1");ssc.eta_nominal;simscape.Value(NaN,"1")];
            ssc.power_ref_data=simscape.Value([NaN;NaN;NaN],"W");
        else
            ssc.eta_ref_data=simscape.Value([NaN;NaN;NaN],"1");
            ssc.power_ref_data=[simscape.Value(NaN,"W");ssc.power_nominal;simscape.Value(NaN,"W")];
        end


        q_unit=string(unit(ssc.flow_rate_nominal));
        p_unit=string(unit(ssc.pressure_nominal));
        if logical(ssc.mechanical_power_spec==1)
            power_unit="W";
        else
            power_unit=string(unit(ssc.power_nominal));
        end
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_ref_nominal));


        legend_str=string(num2str(value(ssc.omega_ref_nominal,omega_unit)))+" "+omega_unit;

    elseif logical(ssc.fan_parameterization==2)

        if logical(ssc.mechanical_power_spec==1)

            ssc.torque_1D_TLU=ssc.flow_rate_1D_TLU(:).*ssc.pressure_1D_TLU(:)./ssc.eta_1D_TLU(:)/ssc.omega_ref_1D;




            if logical(ssc.flow_rate_1D_TLU(1)==0)
                ssc.torque_1D_TLU(1)=ssc.flow_rate_1D_TLU(2)*ssc.pressure_1D_TLU(1)/ssc.eta_1D_TLU(2)/ssc.omega_ref_1D;
            end
        else

            ssc.torque_1D_TLU=ssc.power_1D_TLU/ssc.omega_ref_1D;
        end


        ssc.flow_rate_ref=[
        min(0,ssc.flow_rate_1D_TLU(1)-frac_ext*(ssc.flow_rate_1D_TLU(end)-ssc.flow_rate_1D_TLU(1)));
        ssc.flow_rate_1D_TLU(:);
        ssc.flow_rate_1D_TLU(end)+frac_ext*(ssc.flow_rate_1D_TLU(end)-ssc.flow_rate_1D_TLU(1))];


        ssc.delta_p_ref=[
        max(ssc.pressure_1D_TLU(1),(ssc.pressure_1D_TLU(2)-ssc.pressure_1D_TLU(1))/(ssc.flow_rate_1D_TLU(2)-ssc.flow_rate_1D_TLU(1))*(ssc.flow_rate_ref(1)-ssc.flow_rate_1D_TLU(1))+ssc.pressure_1D_TLU(1));
        ssc.pressure_1D_TLU(:);
        min(ssc.pressure_1D_TLU(end),(ssc.pressure_1D_TLU(end-1)-ssc.pressure_1D_TLU(end))/(ssc.flow_rate_1D_TLU(end-1)-ssc.flow_rate_1D_TLU(end))*(ssc.flow_rate_ref(end)-ssc.flow_rate_1D_TLU(end))+ssc.pressure_1D_TLU(end))];


        ssc.torque_ref=[
        ssc.torque_1D_TLU(1);
        ssc.torque_1D_TLU(:);
        ssc.torque_1D_TLU(end)];


        ssc.power_ref=ssc.torque_ref*ssc.omega_ref_1D;


        ssc.eta_ref=ssc.flow_rate_ref.*ssc.delta_p_ref./ssc.power_ref;


        ssc.eta_ref(...
        (ssc.power_ref<=0)|...
        (ssc.flow_rate_ref<0)|...
        (ssc.flow_rate_ref>ssc.flow_rate_1D_TLU(end))|...
        (ssc.delta_p_ref<0))=NaN;


        ssc.flow_rate_ref_data=ssc.flow_rate_1D_TLU(:);
        ssc.delta_p_ref_data=ssc.pressure_1D_TLU(:);
        if logical(ssc.mechanical_power_spec==1)
            ssc.eta_ref_data=ssc.eta_1D_TLU(:);
            ssc.power_ref_data=simscape.Value(NaN(size(ssc.eta_1D_TLU(:))),"W");
        else
            ssc.eta_ref_data=simscape.Value(NaN(size(ssc.power_1D_TLU(:))),"1");
            ssc.power_ref_data=ssc.power_1D_TLU(:);
        end


        q_unit=string(unit(ssc.flow_rate_1D_TLU));
        p_unit=string(unit(ssc.pressure_1D_TLU));
        if logical(ssc.mechanical_power_spec==1)
            power_unit="W";
        else
            power_unit=string(unit(ssc.power_1D_TLU));
        end
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_ref_1D));


        legend_str=string(num2str(value(ssc.omega_ref_1D,omega_unit)))+" "+omega_unit;

    elseif logical(ssc.fan_parameterization==3)


        ssc.flow_rate_ref=[
        min(0,ssc.flow_rate_dp_TLU(1)-frac_ext*(ssc.flow_rate_dp_TLU(end)-ssc.flow_rate_dp_TLU(1)));
        ssc.flow_rate_dp_TLU(:);
        ssc.flow_rate_dp_TLU(end)+frac_ext*(ssc.flow_rate_dp_TLU(end)-ssc.flow_rate_dp_TLU(1))];


        ssc.delta_p_ref=[
        (ssc.pressure_dp_TLU_ext(3:end,2)-ssc.pressure_dp_TLU_ext(3:end,1))/(ssc.flow_rate_dp_TLU_ext(2)-ssc.flow_rate_dp_TLU_ext(1))*(ssc.flow_rate_ref(1)-ssc.flow_rate_dp_TLU_ext(1))+ssc.pressure_dp_TLU_ext(3:end,1),...
        ssc.pressure_dp_TLU_ext(3:end,2:end-1),...
        (ssc.pressure_dp_TLU_ext(3:end,end-1)-ssc.pressure_dp_TLU_ext(3:end,end))/(ssc.flow_rate_dp_TLU_ext(end-1)-ssc.flow_rate_dp_TLU_ext(end))*(ssc.flow_rate_ref(end)-ssc.flow_rate_dp_TLU_ext(end))+ssc.pressure_dp_TLU_ext(3:end,end)];


        ssc.torque_ref=[
        (ssc.torque_dp_TLU_ext(3:end,2)-ssc.torque_dp_TLU_ext(3:end,1))/(ssc.flow_rate_dp_TLU_ext(2)-ssc.flow_rate_dp_TLU_ext(1))*(ssc.flow_rate_ref(1)-ssc.flow_rate_dp_TLU_ext(1))+ssc.torque_dp_TLU_ext(3:end,1),...
        ssc.torque_dp_TLU_ext(3:end,2:end-1),...
        (ssc.torque_dp_TLU_ext(3:end,end-1)-ssc.torque_dp_TLU_ext(3:end,end))/(ssc.flow_rate_dp_TLU_ext(end-1)-ssc.flow_rate_dp_TLU_ext(end))*(ssc.flow_rate_ref(end)-ssc.flow_rate_dp_TLU_ext(end))+ssc.torque_dp_TLU_ext(3:end,end)];

        m=size(ssc.delta_p_ref,1);
        n=size(ssc.delta_p_ref,2);


        ssc.power_ref=ssc.torque_ref.*repmat(ssc.omega_dp_TLU(:),1,n);


        ssc.eta_ref=repmat(ssc.flow_rate_ref(:)',m,1).*ssc.delta_p_ref./ssc.power_ref;


        ssc.eta_ref(...
        (ssc.power_ref<=0)|...
        (ssc.flow_rate_ref(:)'<0)|...
        (ssc.flow_rate_ref(:)'>ssc.flow_rate_dp_TLU(end))|...
        (ssc.delta_p_ref<0))=NaN;


        ssc.flow_rate_ref_data=ssc.flow_rate_dp_TLU(:);
        ssc.delta_p_ref_data=ssc.pressure_dp_TLU;
        if logical(ssc.mechanical_power_spec==1)
            ssc.eta_ref_data=ssc.eta_dp_TLU;
            ssc.power_ref_data=simscape.Value(NaN(size(ssc.eta_dp_TLU)),"W");
        else
            ssc.eta_ref_data=simscape.Value(NaN(size(ssc.power_dp_TLU)),"1");
            ssc.power_ref_data=ssc.power_dp_TLU;
        end


        q_unit=string(unit(ssc.flow_rate_dp_TLU));
        p_unit=string(unit(ssc.pressure_dp_TLU));
        if logical(ssc.mechanical_power_spec==1)
            power_unit="W";
        else
            power_unit=string(unit(ssc.power_dp_TLU));
        end
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_dp_TLU));


        legend_str=string(num2str(value(ssc.omega_dp_TLU(:),omega_unit)))+" "+omega_unit;

    else


        ssc.delta_p_ref=[
        min(0,ssc.pressure_q_TLU(1)-frac_ext*(ssc.pressure_q_TLU(end)-ssc.pressure_q_TLU(1)));
        ssc.pressure_q_TLU(:);
        ssc.pressure_q_TLU(end)+frac_ext*(ssc.pressure_q_TLU(end)-ssc.pressure_q_TLU(1))];


        ssc.flow_rate_ref=[
        (ssc.flow_rate_q_TLU_ext(3:end,2)-ssc.flow_rate_q_TLU_ext(3:end,1))/(ssc.pressure_q_TLU_ext(2)-ssc.pressure_q_TLU_ext(1))*(ssc.delta_p_ref(1)-ssc.pressure_q_TLU_ext(1))+ssc.flow_rate_q_TLU_ext(3:end,1),...
        ssc.flow_rate_q_TLU_ext(3:end,2:end-1),...
        (ssc.flow_rate_q_TLU_ext(3:end,end-1)-ssc.flow_rate_q_TLU_ext(3:end,end))/(ssc.pressure_q_TLU_ext(end-1)-ssc.pressure_q_TLU_ext(end))*(ssc.delta_p_ref(end)-ssc.pressure_q_TLU_ext(end))+ssc.flow_rate_q_TLU_ext(3:end,end)];


        ssc.torque_ref=[
        (ssc.torque_q_TLU_ext(3:end,2)-ssc.torque_q_TLU_ext(3:end,1))/(ssc.pressure_q_TLU_ext(2)-ssc.pressure_q_TLU_ext(1))*(ssc.delta_p_ref(1)-ssc.pressure_q_TLU_ext(1))+ssc.torque_q_TLU_ext(3:end,1),...
        ssc.torque_q_TLU_ext(3:end,2:end-1),...
        (ssc.torque_q_TLU_ext(3:end,end-1)-ssc.torque_q_TLU_ext(3:end,end))/(ssc.pressure_q_TLU_ext(end-1)-ssc.pressure_q_TLU_ext(end))*(ssc.delta_p_ref(end)-ssc.pressure_q_TLU_ext(end))+ssc.torque_q_TLU_ext(3:end,end)];

        m=size(ssc.flow_rate_ref,1);
        n=size(ssc.flow_rate_ref,2);


        ssc.power_ref=ssc.torque_ref.*repmat(ssc.omega_q_TLU(:),1,n);


        ssc.eta_ref=ssc.flow_rate_ref.*repmat(ssc.delta_p_ref(:)',m,1)./ssc.power_ref;


        ssc.eta_ref(...
        (ssc.power_ref<=0)|...
        (ssc.flow_rate_ref<0)|...
        (ssc.delta_p_ref(:)'<0)|...
        (ssc.delta_p_ref(:)'>ssc.pressure_q_TLU(end)))=NaN;


        ssc.flow_rate_ref_data=ssc.flow_rate_q_TLU;
        ssc.delta_p_ref_data=ssc.pressure_q_TLU(:);
        if logical(ssc.mechanical_power_spec==1)
            ssc.eta_ref_data=ssc.eta_q_TLU;
            ssc.power_ref_data=simscape.Value(NaN(size(ssc.eta_q_TLU)),"W");
        else
            ssc.eta_ref_data=simscape.Value(NaN(size(ssc.power_q_TLU)),"1");
            ssc.power_ref_data=ssc.power_q_TLU;
        end


        q_unit=string(unit(ssc.flow_rate_q_TLU));
        p_unit=string(unit(ssc.pressure_q_TLU));
        if logical(ssc.mechanical_power_spec==1)
            power_unit="W";
        else
            power_unit=string(unit(ssc.power_q_TLU));
        end
        torque_unit="N*m";
        omega_unit=string(unit(ssc.omega_q_TLU));


        legend_str=string(num2str(value(ssc.omega_q_TLU(:),omega_unit)))+" "+omega_unit;
    end


    ssc.flow_rate=ssc.flow_rate_ref*ssc.diameter_ratio^3;
    ssc.flow_rate_data=ssc.flow_rate_ref_data*ssc.diameter_ratio^3;


    ssc.delta_p=ssc.delta_p_ref*ssc.diameter_ratio^2;
    ssc.delta_p_data=ssc.delta_p_ref_data*ssc.diameter_ratio^2;


    ssc.power=ssc.power_ref*ssc.diameter_ratio^5;
    ssc.power_data=ssc.power_ref_data*ssc.diameter_ratio^5;


    ssc.torque=ssc.torque_ref*ssc.diameter_ratio^5;


    ssc.eta=ssc.eta_ref;
    ssc.eta_data=ssc.eta_ref_data;


    hAxis(1)=nexttile(1);
    plot(value(ssc.flow_rate',q_unit),value(ssc.delta_p',p_unit),"-")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.flow_rate_data',q_unit),value(ssc.delta_p_data',p_unit),"x")
    hold off
    grid on
    ylabel("Static Pressure Gain ("+p_unit+")")


    hAxis(2)=nexttile(2);
    plot(value(ssc.flow_rate',q_unit),value(ssc.eta',"1"),"-")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.flow_rate_data',q_unit),value(ssc.eta_data',"1"),"x")
    hold off
    grid on
    set(gca,"YAxisLocation","right");
    ylabel("Efficiency")


    hAxis(3)=nexttile(3);
    plot(value(ssc.flow_rate',q_unit),value(ssc.power',power_unit),"-")
    hold on
    set(gca,"ColorOrderIndex",1)
    plot(value(ssc.flow_rate_data',q_unit),value(ssc.power_data',power_unit),"x")
    hold off
    grid on
    ylabel("Mechanical Power ("+power_unit+")")
    xlabel("Volumetric Flow Rate ("+q_unit+")")


    hAxis(4)=nexttile(4);
    plot(value(ssc.flow_rate',q_unit),value(ssc.torque',torque_unit),"-")
    grid on
    set(gca,"YAxisLocation","right");
    ylabel("Shaft Torque ("+torque_unit+")")
    xlabel("Volumetric Flow Rate ("+q_unit+")")

    linkaxes(hAxis,'x')


    nexttile(2)
    legend(legend_str,"Location","best")

end