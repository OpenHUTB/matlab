function plotPosDispCompressorCharacteristics(varargin)





    if isstruct(varargin{1})
        h=varargin{1};
    else
        h.hBlock=varargin{1};
        h.hFigure=[];
        h.hReload=[];
        h.hPropBlock=-1;
        h.propBlockPath="";
    end


    h.foundationPropPath="foundation.two_phase_fluid.utilities.two_phase_fluid_properties";
    h.fluidsPropPath="fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties";

    if ischar(h.hBlock)||isstring(h.hBlock)
        h.hBlock=getSimulinkBlockHandle(h.hBlock);
    end


    if~is_simulink_handle(h.hBlock)||...
        (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.positive_displacement_compressor"&&...
        string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.positive_displacement_compressor")


        if~isempty(h.hFigure)&&isgraphics(h.hFigure,"figure")&&...
            string(h.hFigure.Tag)=="Positive Displacement Compressor (G) or Positive Displacement Compressor (2P) - Plot Compressor Characteristics"
            blockPath=getappdata(h.hFigure,"blockPath");
            h.hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(h.hBlock)||...
                (string(get_param(h.hBlock,"ComponentPath"))~="fluids.gas.turbomachinery.positive_displacement_compressor"&&...
                string(get_param(h.hBlock,"ComponentPath"))~="fluids.two_phase_fluid.fluid_machines.positive_displacement_compressor")
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(h.hBlock);


    for j=1:height(blockParams)
        param_name=blockParams.Properties.RowNames{j};
        blockStruct.(param_name)=simscapeParameter(blockParams,param_name);
        blockStruct.([param_name,'_str'])=blockParams.Prompt{param_name};
    end


    checkParameters(blockStruct)


createFigure


    validatePropBlock(false)


    plotVolumetricEfficiency(blockStruct);


    h.hReload.Callback{2}=h;




    function createFigure

        if isempty(h.hFigure)||~isgraphics(h.hFigure,"figure")||...
            string(h.hFigure.Tag)~="Positive Displacement Compressor (G) or Positive Displacement Compressor (2P) - Plot Compressor Characteristics"

            h.hFigure=figure("Name",get_param(h.hBlock,"Name"),...
            "Tag","Positive Displacement Compressor (G) or Positive Displacement Compressor (2P) - Plot Compressor Characteristics");


            h.hReload=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
            'Units','normalized','Position',[0.005,0.95,0.15,0.05],...
            'backgroundColor',[1,1,1],...
            'Callback',{@(~,~,h)fluids.internal.mask.plotPosDispCompressorCharacteristics(h),h});
        else

            h.hFigure.Name=get_param(h.hBlock,"Name");


            h.hReload.Callback{2}=h;
        end


        setappdata(h.hFigure,"blockPath",getfullname(h.hBlock));
    end




    function plotVolumetricEfficiency(blockStruct)

        efficiencySpec=value(blockStruct.efficiencySpec,'1');

        if logical(efficiencySpec==1)

            if isfield(blockStruct,'nominalSpec')

                nominalSpec=value(blockStruct.nominalSpec,'1');
                if logical(nominalSpec==1)

                    pr_nom_plot=value(blockStruct.pr_nom,'1');

                else


                    selected=fluidPropertiesDialog;
                    if~selected
                        return
                    end


                    validatePropBlock(true)
                    [p_TLU,T_liq,T_vap,p_crit]=getFluidProperties;
                    p_TLU_val=value(p_TLU,'MPa');
                    T_liq_val=value(T_liq,'K');
                    T_vap_val=value(T_vap,'K');
                    p_crit_val=value(p_crit,'MPa');


                    T_sat_liq_TLU_val=T_liq_val(end,:);
                    T_sat_vap_TLU_val=T_vap_val(1,:);


                    T_sat_liq_max_val=interp1(p_TLU_val,T_sat_liq_TLU_val,p_crit_val,'linear');
                    if isnan(T_sat_liq_max_val)
                        T_sat_liq_max_val=T_sat_liq_TLU_val(end);
                    end
                    T_sat_liq_min_val=T_sat_liq_TLU_val(1);

                    T_sat_vap_max_val=interp1(p_TLU_val,T_sat_vap_TLU_val,p_crit_val,'linear');
                    if isnan(T_sat_vap_max_val)
                        T_sat_vap_max_val=T_sat_vap_TLU_val(end);
                    end
                    T_sat_vap_min_val=T_sat_vap_TLU_val(1);





                    T_sat_vap_min_str="Minimum vapor saturation temperature";
                    T_sat_vap_max_str="Maximum vapor saturation temperature";
                    T_sat_liq_min_str="Minimum liquid saturation temperature";
                    T_sat_liq_max_str="Maximum liquid saturation temperature";

                    T_evap_nom_val=value(blockStruct.T_evap_nom,'K');
                    T_cond_nom_val=value(blockStruct.T_cond_nom,'K');
                    assert(T_evap_nom_val>=T_sat_vap_min_val,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',blockStruct.T_evap_nom_str,T_sat_vap_min_str))
                    assert(T_evap_nom_val<=T_sat_vap_max_val,...
                    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',blockStruct.T_evap_nom_str,T_sat_vap_max_str))
                    assert(T_cond_nom_val>=T_sat_liq_min_val,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',blockStruct.T_cond_nom_str,T_sat_liq_min_str))
                    assert(T_cond_nom_val<=T_sat_liq_max_val,...
                    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',blockStruct.T_cond_nom_str,T_sat_liq_max_str))
                    p_evap_nom=interp1(T_sat_vap_TLU_val,p_TLU_val,T_evap_nom_val,'linear');
                    p_cond_nom=interp1(T_sat_liq_TLU_val,p_TLU_val,T_cond_nom_val,'linear');
                    pr_nom_plot=p_cond_nom/p_evap_nom;
                end

            else
                pr_nom_plot=value(blockStruct.pr_nom,'1');
            end

            n_plot=value(blockStruct.n,'1');
            eta_nom_plot=value(blockStruct.eta_nom,'1');

            C_vf_plot=(1-eta_nom_plot)/(pr_nom_plot^(1/n_plot)-1);

            pressure_ratio_max=((1+C_vf_plot)/C_vf_plot)^n_plot;

            pressure_ratio=linspace(1,min(3*pr_nom_plot,pressure_ratio_max),1000);
            eta_used=1+C_vf_plot-C_vf_plot.*(pressure_ratio.^(1/n_plot));


            figure(h.hFigure)
            cla(gca)
            plot(pressure_ratio,eta_used)
            title(newline+"Volumetric Efficiency vs. Pressure Ratio")

        else

            omega_TLU_plot=value(blockStruct.omega_TLU);
            omega_TLU_unit=char(unit(blockStruct.omega_TLU));
            pr_TLU_plot=value(blockStruct.pr_TLU,'1');
            eta_TLU_plot=value(blockStruct.eta_TLU,'1');


            figure(h.hFigure)
            cla(gca)

            legend_str=cell(length(omega_TLU_plot),1);
            for i=1:length(omega_TLU_plot)
                plot(pr_TLU_plot,eta_TLU_plot(:,i))
                legend_str{i}=[num2str(omega_TLU_plot(i)),' ',omega_TLU_unit];
                hold on
            end
            legend(legend_str,'Location','best')
            hold off
            title(newline+"Volumetric Efficiency vs. Speed ("+omega_TLU_unit+") and Pressure Ratio")

        end

        xlabel('Pressure Ratio')
        ylabel('Volumetric Efficiency')
        grid on

    end




    function selected=fluidPropertiesDialog


        propBlockSearchList=find_system(bdroot(h.hBlock),...
        "LookUnderMasks","all","MatchFilter",@Simulink.match.allVariants,"RegExp","on",...
        "ComponentPath",h.fluidsPropPath+"|"+h.foundationPropPath);


        if~isempty(propBlockSearchList)
            hPropList=get_param(propBlockSearchList,"Handle");
            if iscell(hPropList)
                hPropList=cell2mat(hPropList);
            end


            propBlockPathList=getPropBlockPath(hPropList);


            hPropList=[-1;hPropList];
            propBlockPathList=["Default Fluid - Water";propBlockPathList];


            listRowInit=find(hPropList==h.hPropBlock,1);
            if isempty(listRowInit)
                listRowInit=1;
            end


            listRow=listdlg("Name","Select Fluid Properties",...
            "PromptString",["Select a Two-Phase Fluid Properties (2P) or Two-Phase Fluid"
            "Predefined Properties (2P) block in the model"],...
            "ListString",propBlockPathList,"InitialValue",listRowInit,...
            "ListSize",[350,250],"SelectionMode","single");


            if~isempty(listRow)
                h.hPropBlock=hPropList(listRow);
                h.propBlockPath=propBlockPathList(listRow);
                selected=true;
            else
                selected=false;
            end
        else

            h.hPropBlock=-1;
            h.propBlockPath="Default Fluid - Water";
            selected=true;
        end
    end




    function propBlockPath=getPropBlockPath(hPropList)


        modelName=string(get_param(bdroot(h.hBlock),"Name"));
        tmpPropBlockPath=string(getfullname(hPropList));
        propBlockPath=regexprep(extractAfter(tmpPropBlockPath,modelName+"/"),"\s+"," ");

    end




    function[p_TLU,T_liq,T_vap,p_crit]=getFluidProperties

        blk=h.hPropBlock;


        if blk==-1||string(get_param(blk,"ComponentPath"))==h.foundationPropPath
            if blk==-1


                load_system("fl_lib")
                blk=getSimulinkBlockHandle("fl_lib/Two-Phase Fluid/Utilities/Two-Phase Fluid Properties (2P)",true);
            end


            paramList=["p_TLU","T_liq","T_vap","p_crit"];
            n=length(paramList);


            Simulink.Block.eval(blk)
            maskWS=get_param(blk,"MaskWSVariables");
            [~,~,idx]=intersect([paramList,paramList+"_unit"],{maskWS.Name},"stable");
            maskWSValues={maskWS(idx).Value};


            p_TLU=getSimscapeValue(maskWSValues{1},maskWSValues{1+n});
            T_liq=getSimscapeValue(maskWSValues{2},maskWSValues{2+n});
            T_vap=getSimscapeValue(maskWSValues{3},maskWSValues{3+n});
            p_crit=getSimscapeValue(maskWSValues{4},maskWSValues{4+n});
        else

            fluidEnum=eval(get_param(blk,"fluid"));


            [~,~,~,~,p_TLU_val,...
            ~,~,~,~,T_liq_val,T_vap_val,...
            ~,~,~,~,~,~,...
            ~,~,p_crit_val]=...
            fluids.internal.two_phase_fluid.utilities.TwoPhaseFluidPredefinedProperties.extractTables(fluidEnum);
            p_TLU=simscape.Value(p_TLU_val,"MPa");
            T_liq=simscape.Value(T_liq_val,"K");
            T_vap=simscape.Value(T_vap_val,"K");
            p_crit=simscape.Value(p_crit_val,"MPa");
        end

    end




    function validatePropBlock(errFlag)

        if~isfield(h,'hPropBlock')||~isfield(h,'propBlockPath')
            h.hPropBlock=-1;
            h.propBlockPath="";
            return
        end


        if h.hPropBlock==-1
            h.propBlockPath="";
            return
        end

        try

            if string(get_param(h.hPropBlock,"ComponentPath"))==h.fluidsPropPath...
                ||string(get_param(h.hPropBlock,"ComponentPath"))==h.foundationPropPath

                h.propBlockPath=getPropBlockPath(h.hPropBlock);
            elseif errFlag

                modelName=string(get_param(bdroot(h.hBlock),"Name"));
                throw(MException(message("physmod:fluids:diagrams:PropBlockNotFound",...
                modelName+"/"+h.propBlockPath)))
            else

                h.hPropBlock=-1;
                h.propBlockPath="";
            end
        catch

            modelName=string(get_param(bdroot(h.hBlock),"Name"));
            hPropBlockCheck=getSimulinkBlockHandle(modelName+"/"+h.propBlockPath,true);

            if(hPropBlockCheck~=-1)&&...
                (string(get_param(hPropBlockCheck,"ComponentPath"))==h.fluidsPropPath...
                ||string(get_param(hPropBlockCheck,"ComponentPath"))==h.foundationPropPath)

                h.hPropBlock=hPropBlockCheck;
            elseif errFlag

                modelName=string(get_param(bdroot(h.hBlock),"Name"));
                throw(MException(message("physmod:fluids:diagrams:PropBlockNotFound",...
                modelName+"/"+h.propBlockPath)))
            else

                h.hPropBlock=-1;
                h.propBlockPath="";
            end
        end

    end

end




function ssc=getSimscapeValue(maskWSValue,maskWSUnit)
    if isa(maskWSValue,"Simulink.Parameter")

        value=maskWSValue.Value;
    else
        value=maskWSValue;
    end

    if isempty(value)

        throw(MException(message("physmod:fluids:diagrams:UnrecognizedVariables")))
    end

    if isempty(maskWSUnit)

        unit="1";
    else
        unit=maskWSUnit;
    end


    ssc=simscape.Value(value,unit);

end



function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end



function checkParameters(blockStruct)

    dispSpec=value(blockStruct.dispSpec,'1');
    efficiencySpec=value(blockStruct.efficiencySpec,'1');

    assert(value(blockStruct.n,'1')>=1,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual',blockStruct.n_str,"1"))
    assert(value(blockStruct.mechanical_efficiency,'1')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.mechanical_efficiency_str))
    assert(value(blockStruct.area_A,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_A_str))
    assert(value(blockStruct.area_B,'m^2')>0,...
    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_B_str))

    if logical(dispSpec==2)||logical(efficiencySpec==1)


        assert(value(blockStruct.pr_nom,'1')>1,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.pr_nom_str,"1"))
    end

    if logical(dispSpec==1)
        assert(value(blockStruct.v_disp,'m^3/rev')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.v_disp_str))
    else
        assert(value(blockStruct.mdot_nom,'kg/s')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.mdot_nom_str))
        assert(value(blockStruct.omega_nom,'rpm')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.omega_nom_str))


    end

    if logical(efficiencySpec==1)
        assert(value(blockStruct.eta_nom,'1')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.eta_nom_str))
        assert(value(blockStruct.eta_nom,'1')<=1,...
        message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',blockStruct.eta_nom_str,"1"))

        if isfield(blockStruct,'nominalSpec')
            if value(blockStruct.nominalSpec,'1')==1

            else
                assert(value(blockStruct.T_cond_nom,'K')>value(blockStruct.T_evap_nom,'K'),...
                message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.T_cond_nom_str,blockStruct.T_evap_nom_str))


            end
        end

    else


        assert(length(blockStruct.pr_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.pr_TLU_str,"2"))
        assert(length(blockStruct.omega_TLU)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.omega_TLU_str,"2"))
        assert(all(size(blockStruct.eta_TLU)==[length(blockStruct.pr_TLU),length(blockStruct.omega_TLU)]),...
        message('physmod:simscape:compiler:patterns:checks:Size2DEqual',blockStruct.eta_TLU_str,blockStruct.pr_TLU_str,blockStruct.omega_TLU_str))


        assert(all(diff(value(blockStruct.pr_TLU,'1'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.pr_TLU_str))
        assert(all(diff(value(blockStruct.omega_TLU,'rpm'))>0),...
        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.omega_TLU_str))


        assert(all(value(blockStruct.omega_TLU,'rpm')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',blockStruct.omega_TLU_str))
        assert(all(all(value(blockStruct.pr_TLU,'1')>0)),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',blockStruct.pr_TLU_str))
        assert(all(value(blockStruct.eta_TLU(:),'1')>0),...
        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',blockStruct.eta_TLU_str))
        assert(all(value(blockStruct.eta_TLU(:),'1')<=1),...
        message('physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual',blockStruct.eta_TLU_str,"1"))
    end
end