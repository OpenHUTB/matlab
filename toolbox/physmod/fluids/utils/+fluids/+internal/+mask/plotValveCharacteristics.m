function plotValveCharacteristics(varargin)


















    if isstruct(varargin{1})
        h=varargin{1};
    else
        h.hBlock=varargin{1};
        h.hFigure=[];
        h.hReload=[];
        h.hbp1=[];
        h.hbp2=[];
        h.hEditText=[];
        h.p_diff_plot=simscape.Value(1,'MPa');
    end

    if ischar(h.hBlock)||isstring(h.hBlock)
        h.hBlock=getSimulinkBlockHandle(h.hBlock);
    end

    supportedBlocks={'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_3_position';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_2_position';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_3_way';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_2_way';
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_4_way_3_position';
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way';
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_2_way'};


    if~is_simulink_handle(h.hBlock)||~any(strcmp(get_param(h.hBlock,'ComponentPath'),supportedBlocks))


        if~isempty(h.hFigure)&&isgraphics(h.hFigure,"figure")&&...
            string(h.hFigure.Tag)=="Directional Valve - Plot Valve Characteristics"
            blockPath=getappdata(h.hFigure,"blockPath");
            h.hBlock=getSimulinkBlockHandle(blockPath);


            if~is_simulink_handle(h.hBlock)||~any(strcmp(get_param(h.hBlock,'ComponentPath'),supportedBlocks))
                error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
            end
        else
            error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
        end
    end


    blockParams=foundation.internal.mask.getEvaluatedBlockParameters(h.hBlock);
    blockStruct.SourceFile=get_param(h.hBlock,'SourceFile');


    for j=1:height(blockParams)
        param_name=blockParams.Properties.RowNames{j};
        blockStruct.(param_name)=simscapeParameter(blockParams,param_name);
        blockStruct.([param_name,'_prompt'])=blockParams.Prompt{param_name};
    end




    [blockStruct,orifice_list,orifice_display_name]=getBlockConfigurationOptions(blockStruct);


    checkParameters(blockStruct,orifice_list,orifice_display_name);


    orifice_response_vs_S=get_valve_data(blockStruct,orifice_list,h.p_diff_plot);




    createFigure(h,h.p_diff_plot,blockStruct);


    plotProperties(blockStruct,orifice_response_vs_S,orifice_list,orifice_display_name);

end



function[OR_pos,OR_neu,OR_neg]=orifice_open_connections(OR,blockStruct)




    OR_ind=blockStruct.OR_ind(OR);


    spool=blockStruct.pos_ind;



    OR_is_open=blockStruct.spool_orifice_open_settings(:,OR_ind);

    OR_pos=any(blockStruct.open_orifices_pos==OR_is_open{spool('+')});
    OR_neg=any(blockStruct.open_orifices_neg==OR_is_open{spool('-')});
    if blockStruct.numPositions==3
        OR_neu=any(blockStruct.open_orifices_neu==OR_is_open{spool('0')});
    else
        OR_neu=0;
    end

end



function orifice_response=get_valve_data(blockStruct,orifice_list,p_diff_plot)




    orifice_response=determine_orifice_S_points(blockStruct,orifice_list);


    for i=1:length(orifice_list)
        OR=orifice_list{i};
        S=orifice_response.(['S_',OR]);

        [OR_pos,OR_neu,OR_neg]=orifice_open_connections(OR,blockStruct);


        if(~(OR_pos||OR_neu||OR_neg))
            orifice_response=always_closed_orifice_response(orifice_response,blockStruct,OR,S);

        elseif(OR_pos&&OR_neg&&(blockStruct.numPositions==2||OR_neu))
            orifice_response=always_open_orifice_response(orifice_response,blockStruct,OR,S,p_diff_plot);
        else

            S_max=blockStruct.(['S_max_',OR]);



            [del_S_max,~]=get_del_S(OR,blockStruct);


            del_S_vec=transform_S_to_del_S_orifice(blockStruct.numPositions,OR_pos,OR_neu,OR_neg,S,S_max,del_S_max);

            if blockStruct.valve_spec==1
                area_steady=variable_linear_orifice_response(blockStruct,OR,del_S_max,del_S_vec);
                orifice_response.(['Area_',OR])=area_steady;
            elseif blockStruct.valve_spec==2
                area=variable_area_tabulated_orifice_response(blockStruct,OR,del_S_vec);
                orifice_response.(['Area_',OR])=area;
            elseif blockStruct.valve_spec==3
                vol_flow=variable_vol_flow_tabulated_orifice_response(blockStruct,OR,p_diff_plot,del_S_vec);
                orifice_response.(['vol_flow_',OR])=vol_flow;
            else
                mdot=variable_mdot_tabulated_orifice_response(blockStruct,OR,p_diff_plot,del_S_vec);
                orifice_response.(['mdot_',OR])=mdot;
            end
        end
    end
end


function orifice_response=determine_orifice_S_points(blockStruct,orifice_list)



    S_min_plot=[];
    S_max_plot=[];
    for i=1:length(orifice_list)
        OR=orifice_list{i};
        [OR_pos,OR_neu,OR_neg]=orifice_open_connections(OR,blockStruct);


        orifice_response.(['S_',OR])=[];



        if orificeIsVariable(blockStruct,OR)

            S_max=blockStruct.(['S_max_',OR]);

            if(~OR_pos&&OR_neu&&~OR_neg)||(OR_pos&&~OR_neu&&OR_neg)
                S_max=abs(S_max);
            end

            open_sign=get_open_sign_orifice(OR_pos,OR_neu,OR_neg);
            [del_S_max,del_S_vec]=get_del_S(OR,blockStruct);


            S=(del_S_vec-del_S_max)*open_sign+S_max;
            if open_sign==-1
                S=fliplr(S);
            end



            if(~OR_pos&&~OR_neg&&OR_neu)||(OR_pos&&OR_neg&&~OR_neu)

                S_pos=S(S>=0);
                S=unique(value([-S_pos,0,S_pos],'m'),'sorted');
                S=simscape.Value(S,'m');
            end


            S=[S(1)-0.1*del_S_max,S,S(end)+0.1*del_S_max];%#ok<AGROW>

            orifice_response.(['S_',OR])=S;


            if~isempty(S_min_plot)
                S_min_plot=min(S_min_plot,min(S));
                S_max_plot=max(S_max_plot,max(S));
            else
                S_min_plot=min(S);
                S_max_plot=max(S);
            end
        end
    end


    if isempty(S_min_plot)
        S_min_plot=simscape.Value(-1,'m');
        S_max_plot=simscape.Value(1,'m');
    end
    S_limits=[S_min_plot,S_max_plot];


    for i=1:length(orifice_list)
        OR=orifice_list{i};
        S=orifice_response.(['S_',OR]);
        if~isempty(S)

            S=union(value(S_limits,'m'),value(S,'m'));
            S=simscape.Value(S,'m');
        else
            S=S_limits;
        end
        orifice_response.(['S_',OR])=S;
    end
end


function orifice_response=always_closed_orifice_response(orifice_response,blockStruct,OR,S)


    if blockStruct.valve_spec==1||blockStruct.valve_spec==2

        area_opening=simscape.Value(zeros(1,length(S)),'m^2');
        orifice_response.(['Area_',OR])=area_opening;
    elseif blockStruct.valve_spec==3
        vol_flow=simscape.Value(zeros(1,length(S)),'m^3/s');
        orifice_response.(['vol_flow_',OR])=vol_flow;
    else
        mdot=simscape.Value(zeros(1,length(S)),'kg/s');
        orifice_response.(['mdot_',OR])=mdot;
    end
end


function orifice_response=always_open_orifice_response(orifice_response,blockStruct,OR,S,p_diff_plot)


    if blockStruct.valve_spec==1||blockStruct.valve_spec==2

        if blockStruct.area_spec==1
            area_const=blockStruct.area_const;
        else
            area_const=blockStruct.(['area_const_',OR]);
        end
        area_opening=area_const.*ones(1,length(S));
        orifice_response.(['Area_',OR])=area_opening;
    elseif blockStruct.valve_spec==3
        if blockStruct.area_spec==1
            p_diff_TLU_const=blockStruct.p_diff_TLU_const;
            vol_flow_TLU_const=blockStruct.vol_flow_TLU_const;
        else
            p_diff_TLU_const=blockStruct.(['p_diff_TLU_const_',OR]);
            vol_flow_TLU_const=blockStruct.(['vol_flow_TLU_const_',OR]);
        end


        if(p_diff_TLU_const(1)>=0)
            vol_flow_TLU_const_ver=reshape(vol_flow_TLU_const,numel(vol_flow_TLU_const),1);
            p_diff_TLU_const_ver=reshape(p_diff_TLU_const,numel(p_diff_TLU_const),1);
            if p_diff_TLU_const_ver(1)==0
                ip=2;
            else
                ip=1;
            end
            p_diff_TLU_constant_ext=[-p_diff_TLU_const_ver(end:-1:ip);p_diff_TLU_const_ver];
            vol_flow_TLU_constant_ext=[-vol_flow_TLU_const_ver(:,end:-1:ip);vol_flow_TLU_const_ver];
        else
            p_diff_TLU_constant_ext=p_diff_TLU_const;
            vol_flow_TLU_constant_ext=vol_flow_TLU_const;
        end


        p_diff_plot_sat=max(min(p_diff_plot,p_diff_TLU_constant_ext(end)),p_diff_TLU_constant_ext(1));
        vol_flow=interp1(value(p_diff_TLU_constant_ext,'MPa'),value(vol_flow_TLU_constant_ext,'m^3/s'),value(p_diff_plot_sat,'MPa'))...
        .*ones(1,length(S));
        vol_flow=simscape.Value(vol_flow,'m^3/s');
        orifice_response.(['vol_flow_',OR])=vol_flow;
    else
        if blockStruct.area_spec==1
            p_diff_TLU_const=blockStruct.p_diff_TLU_const;
            mdot_TLU_const=blockStruct.mdot_TLU_const;
        else
            p_diff_TLU_const=blockStruct.(['p_diff_TLU_const_',OR]);
            mdot_TLU_const=blockStruct.(['mdot_TLU_const_',OR]);
        end


        if(p_diff_TLU_const(1)>=0)
            mdot_TLU_const_ver=reshape(mdot_TLU_const,numel(mdot_TLU_const),1);
            p_diff_TLU_const_ver=reshape(p_diff_TLU_const,numel(p_diff_TLU_const),1);
            if p_diff_TLU_const_ver(1)==0
                ip=2;
            else
                ip=1;
            end
            p_diff_TLU_constant_ext=[-p_diff_TLU_const_ver(end:-1:ip);p_diff_TLU_const_ver];
            mdot_TLU_constant_ext=[-mdot_TLU_const_ver(:,end:-1:ip);mdot_TLU_const_ver];
        else
            p_diff_TLU_constant_ext=p_diff_TLU_const;
            mdot_TLU_constant_ext=mdot_TLU_const;
        end


        p_diff_plot_sat=max(min(p_diff_plot,p_diff_TLU_constant_ext(end)),p_diff_TLU_constant_ext(1));
        mdot=interp1(value(p_diff_TLU_constant_ext,'MPa'),value(mdot_TLU_constant_ext,'kg/s'),value(p_diff_plot_sat,'MPa'))...
        .*ones(1,length(S));
        mdot=simscape.Value(mdot,'kg/s');
        orifice_response.(['mdot_',OR])=mdot;
    end
end


function area_steady=variable_linear_orifice_response(blockStruct,OR,del_S_max,del_S_orifice)
    if blockStruct.area_spec==1
        area_max=blockStruct.area_max;
    else
        area_max=blockStruct.(['area_max_',OR]);
    end
    area_max_used=area_max;
    area_leak_used=blockStruct.area_leak;




    smooth_factor_sat=max(blockStruct.smoothing_factor,1e-6);


    area_opening=(area_max_used-area_leak_used)/del_S_max*del_S_orifice+area_leak_used;


    if blockStruct.smoothing_factor==0
        area_steady=area_opening;

        area_steady=min(area_steady,area_max_used);
        area_steady=max(area_steady,area_leak_used);
    else
        area_steady=smoothLimit(area_opening,area_leak_used,area_max_used,smooth_factor_sat);
    end

end


function area=variable_area_tabulated_orifice_response(blockStruct,OR,del_S)
    if blockStruct.area_spec==1
        valve_area_TLU=blockStruct.valve_area_TLU;
    else
        valve_area_TLU=blockStruct.(['valve_area_TLU_',OR]);
    end

    if blockStruct.area_spec==1
        del_S_TLU=blockStruct.del_S_TLU;
    else
        del_S_TLU=blockStruct.(['del_S_TLU_',OR]);
    end

    del_S_saturated=max(del_S_TLU(1),min(del_S,del_S_TLU(end)));

    area_steady=interp1(value(del_S_TLU,'m'),value(valve_area_TLU,'m^2'),value(del_S_saturated,'m'),'linear');
    area=simscape.Value(area_steady,'m^2');
end


function vol_flow=variable_vol_flow_tabulated_orifice_response(blockStruct,OR,p_diff_plot,del_S)

    if blockStruct.area_spec==1
        del_S_vol_flow_TLU=blockStruct.del_S_vol_flow_TLU;
    else
        del_S_vol_flow_TLU=blockStruct.(['del_S_vol_flow_TLU_',OR]);
    end

    if blockStruct.area_spec==1
        p_diff_TLU=blockStruct.p_diff_TLU;
        vol_flow_TLU=blockStruct.vol_flow_TLU;
    else
        p_diff_TLU=blockStruct.(['p_diff_TLU_',OR]);
        vol_flow_TLU=blockStruct.(['vol_flow_TLU_',OR]);
    end


    if(p_diff_TLU(1)>=0)
        p_diff_TLU_ver=reshape(p_diff_TLU,numel(p_diff_TLU),1);

        if p_diff_TLU_ver(1)==0
            ip=2;
        else
            ip=1;
        end

        p_diff_TLU_ext=[-p_diff_TLU_ver(end:-1:ip);p_diff_TLU_ver];
        vol_flow_TLU_ext=[-vol_flow_TLU(:,end:-1:ip),vol_flow_TLU];
    else
        p_diff_TLU_ext=p_diff_TLU;
        vol_flow_TLU_ext=vol_flow_TLU;
    end


    del_S_saturate=max(value(del_S_vol_flow_TLU(1),'m'),min(value(del_S,'m'),value(del_S_vol_flow_TLU(end),'m')))';



    p_diff=repmat(value(p_diff_plot,'MPa'),size(del_S_saturate));

    F=griddedInterpolant({value(del_S_vol_flow_TLU,'m'),value(p_diff_TLU_ext,'MPa')},value(vol_flow_TLU_ext,'m^3/s'));
    vol_flow=simscape.Value(F(del_S_saturate,p_diff),'m^3/s');
end


function mdot=variable_mdot_tabulated_orifice_response(blockStruct,OR,p_diff_plot,del_S)

    if blockStruct.area_spec==1
        del_S_mdot_TLU=blockStruct.del_S_mdot_TLU;
    else
        del_S_mdot_TLU=blockStruct.(['del_S_mdot_TLU_',OR]);
    end

    if blockStruct.area_spec==1
        p_diff_TLU=blockStruct.p_diff_TLU;
        mdot_TLU=blockStruct.mdot_TLU;
    else
        p_diff_TLU=blockStruct.(['p_diff_TLU_',OR]);
        mdot_TLU=blockStruct.(['mdot_TLU_',OR]);
    end


    if(p_diff_TLU(1)>=0)
        p_diff_TLU_ver=reshape(p_diff_TLU,numel(p_diff_TLU),1);

        if p_diff_TLU_ver(1)==0
            ip=2;
        else
            ip=1;
        end

        p_diff_TLU_ext=[-p_diff_TLU_ver(end:-1:ip);p_diff_TLU_ver];
        mdot_TLU_ext=[-mdot_TLU(:,end:-1:ip),mdot_TLU];
    else
        p_diff_TLU_ext=p_diff_TLU;
        mdot_TLU_ext=mdot_TLU;
    end


    del_S_saturate=max(value(del_S_mdot_TLU(1),'m'),min(value(del_S,'m'),value(del_S_mdot_TLU(end),'m')))';



    p_diff=repmat(value(p_diff_plot,'MPa'),size(del_S_saturate));

    F=griddedInterpolant({value(del_S_mdot_TLU,'m'),value(p_diff_TLU_ext,'MPa')},value(mdot_TLU_ext,'kg/s'));
    mdot=simscape.Value(F(del_S_saturate,p_diff),'kg/s');
end


function open_sign=get_open_sign_orifice(OR_pos,OR_neu,OR_neg)

    if(OR_neg||OR_neu)&&~OR_pos

        open_sign=-1;
    else
        open_sign=1;
    end
end


function[del_S_max,del_S_vec]=get_del_S(OR,blockStruct)
    if blockStruct.valve_spec==1
        if blockStruct.area_spec==1
            del_S_max=blockStruct.del_S_max;
        else
            del_S_max=blockStruct.(['del_S_max_',OR]);
        end









        if blockStruct.smoothing_factor==0

            del_S_vec=linspace(simscape.Value(0,'m'),del_S_max,10);

        else
            smooth_factor_sat=max(blockStruct.smoothing_factor,1e-6);
            k=smooth_factor_sat/2;


            delS_startSmooth_Aleak=-2*k*del_S_max;


            delS_endSmooth_Aleak=k*del_S_max;


            delS_startSmooth_Amax=(1-k)*del_S_max;


            delS_endSmooth_Amax=(1+2*k)*del_S_max;

            del_S_vec_smoothed_start=linspace(delS_startSmooth_Aleak,delS_endSmooth_Aleak,15);
            del_S_vec_smoothed_end=linspace(delS_startSmooth_Amax,delS_endSmooth_Amax,15);
            del_S_vec_smoothed_intermediate=linspace(del_S_vec_smoothed_start(end),del_S_vec_smoothed_end(1),12);
            del_S_vec_smoothed=[del_S_vec_smoothed_start,del_S_vec_smoothed_intermediate(2:11),del_S_vec_smoothed_end];
            del_S_vec=del_S_vec_smoothed;
        end

    elseif blockStruct.valve_spec==2
        if blockStruct.area_spec==1
            del_S_TLU=blockStruct.del_S_TLU;
        else
            del_S_TLU=blockStruct.(['del_S_TLU_',OR]);
        end
        del_S_max=abs(del_S_TLU(1)-del_S_TLU(end));
        del_S_vec=del_S_TLU;


    else

        if blockStruct.area_spec==1
            del_S_vol_flow_TLU=blockStruct.del_S_vol_flow_TLU;
        else
            del_S_vol_flow_TLU=blockStruct.(['del_S_vol_flow_TLU_',OR]);
        end
        del_S_max=abs(del_S_vol_flow_TLU(1)-del_S_vol_flow_TLU(end));
        del_S_vec=del_S_vol_flow_TLU;

    end
end


function ULim=smoothLimit(U,a,b,s)









    U_norm=(U-a)./(b-a);


    ULim_norm=(1+sqrt(U_norm.^2+(s/4)^2)-sqrt((U_norm-1).^2+(s/4)^2))/2;



    ULim=ULim_norm.*(b-a)+a;

end


function del_S=transform_S_to_del_S_orifice(numPositions,OR_pos,OR_neu,OR_neg,S,S_max,del_S_max)




    if numPositions==3
        if~(OR_pos&&OR_neu&&OR_neg)&&(OR_pos||OR_neu||OR_neg)


            if OR_pos&&OR_neg
                del_S=abs(S)-abs(S_max)+del_S_max;
            elseif OR_pos
                del_S=S-S_max+del_S_max;
            elseif OR_neg
                del_S=-S+S_max+del_S_max;
            else
                del_S=-abs(S)+abs(S_max)+del_S_max;
            end
        else
            del_S=0.*S;
        end
    else
        if~(OR_pos&&OR_neg)&&(OR_pos||OR_neg)

            if OR_pos
                del_S=S-S_max+del_S_max;
            else
                del_S=-S+S_max+del_S_max;
            end
        else
            del_S=0.*S;
        end
    end

end


function createFigure(h,p_diff_plot,blockStruct)

    if isempty(h.hFigure)
        h.hFigure=figure("Tag","Directional Valve - Plot Valve Characteristics");


        h.hbp1=uicontrol('Units','normalized','OuterPosition',...
        [0.19,0.94,0.18,0.04],'Style','text','String',"Pressure drop: ",'FontSize',...
        10,'FontWeight','bold','HorizontalAlignment','left','Visible','off');

        h.hbp2=uicontrol('Units','normalized','OuterPosition',...
        [0.5,0.94,0.06,0.04],'Style','text','String',"MPa",'FontSize',...
        10,'FontWeight','bold','HorizontalAlignment','left','Visible','off');

        p_diff_str=num2str(value(p_diff_plot,'MPa'));
        h.hEditText=uicontrol('Style','edit','String',p_diff_str,...
        'Units','normalized','Position',[0.37,0.935,0.12,0.05],...
        'Callback',{@pushbuttonCallback,h},...
        'FontWeight','bold','Visible','off');


        h.hReload=uicontrol('Style','pushbutton','String','Reload Data','FontWeight','bold',...
        'Units','normalized','Position',[0.65,0.935,0.2,0.05],...
        'backgroundColor',[1,1,1],...
        'Callback',{@pushbuttonCallback,h});


        h.hEditText.Callback{2}=h;
        h.hReload.Callback{2}=h;


        setappdata(h.hFigure,"blockPath",getfullname(h.hBlock))
    else
        if~isgraphics(h.hFigure,'figure')
            h.hFigure=figure('Name',get_param(h.hBlock,'Name'));
        end
    end



    if blockStruct.valve_spec>=3

        h.hbp1.Visible='on';
        h.hbp2.Visible='on';
        h.hEditText.Visible='on';
    else
        h.hbp1.Visible='off';
        h.hbp2.Visible='off';
        h.hEditText.Visible='off';
    end

    h.hFigure.Units='normalized';

    set(h.hFigure,'Name',get_param(h.hBlock,'Name'),'Toolbar','figure')

    hAxes=gca;
    hAxes.Units='normalized';
    set(hAxes,'OuterPosition',[0.0043,0.0294,0.9936,0.8972]);
    cla(hAxes)

end


function plotProperties(blockStruct,orifice_response_vs_S,orifice_list,orifice_display_name)


    box on
    grid on

    hold on
    legend('Location','best')


    LineWidth_list={1.5,1,1,1,1,1};
    LineStyle_list={'-','--','-.',':','-.','-'};
    LineColor=colororder;
    Marker=['+','x','s','o','*','^'];
    MarkerSize_list={6,6,6,6,6,5};

    for i=1:length(orifice_list)
        OR=orifice_list{i};

        orifice_label=['Orifice ',orifice_display_name{i}];

        S=orifice_response_vs_S.(['S_',OR]);

        if blockStruct.valve_spec==1||blockStruct.valve_spec==2

            yValues=value(orifice_response_vs_S.(['Area_',OR]),'m^2');
        elseif blockStruct.valve_spec==3
            yValues=value(orifice_response_vs_S.(['vol_flow_',OR]),'m^3/s');
        else
            yValues=value(orifice_response_vs_S.(['mdot_',OR]),'kg/s');
        end

        if sum(yValues)~=0
            plot(value(S,'m'),yValues,'DisplayName',orifice_label,...
            'Color',LineColor(i,:),'LineWidth',LineWidth_list{i},'LineStyle',LineStyle_list{i},...
            'Marker',Marker(i),'MarkerSize',MarkerSize_list{i});
        end
    end


    if blockStruct.valve_spec==1||blockStruct.valve_spec==2

        ylabel('Orifice Area (m^2)','FontWeight','bold')
        title('Area vs. Spool Position for Each Orifice')
    elseif blockStruct.valve_spec==3
        ylabel('Volumetric Flow Rate (m^3/s)','FontWeight','bold')
        title('Flow Rate vs. Spool Position for Each Orifice')
    else
        ylabel('Mass Flow Rate (kg/s)','FontWeight','bold')
        title('Flow Rate vs. Spool Position at Reference Inflow Conditions')
    end

    xlabel('Spool position (m)','FontWeight','bold')
    axis padded

end


function pushbuttonCallback(~,~,h)
    h.p_diff_plot=simscape.Value(str2double(h.hEditText.String),'MPa');
    fluids.internal.mask.plotValveCharacteristics(h);
end


function param=simscapeParameter(tableData,paramName)
    paramValue=tableData{paramName,'Value'}{1};
    paramUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(paramValue,paramUnit);
end


function[blockStruct,orifice_list,orifice_display_name]=getBlockConfigurationOptions(blockStruct)
    if strcmp(blockStruct.SourceFile,'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_3_position')||...
        strcmp(blockStruct.SourceFile,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_4_way_3_position')
        blockStruct.numPositions=3;
        blockStruct.ConstantOrificesPermitted=1;
        blockStruct.OrificesAreConfigurable=1;
        blockStruct.CheckForConsistentSmax=0;
        orifice_list={'PA','PB','AT','BT','PT','AB'};
        orifice_display_name={'P-A','P-B','A-T','B-T','P-T','A-B'};





        blockStruct.spool_orifice_open_settings={...
...
        [1,2,4,6],[2,3,5,6],3,1,[],6
        [1,2,4,6],[2,3,5,6],3,1,[],6
        [1,3,4,5,10,13,14,16],[1,5,6,7,11,14,15,16],[1,2,3,6,8,13,16],[1,2,4,7,9,15,16],[12,13,15,16],14};


        if strcmp(blockStruct.SourceFile,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_4_way_3_position')
            OR_strs={'','_PA','_PB','_AT','_BT','_PT','_AB'};
            for i=1:length(OR_strs)
                blockStruct.(['del_S_vol_flow_TLU',OR_strs{i}])=blockStruct.(['del_S_flow_TLU',OR_strs{i}]);
                blockStruct.(['del_S_vol_flow_TLU',OR_strs{i},'_prompt'])=blockStruct.(['del_S_flow_TLU',OR_strs{i},'_prompt']);
                blockStruct.(['del_S_mdot_TLU',OR_strs{i}])=blockStruct.(['del_S_flow_TLU',OR_strs{i}]);
                blockStruct.(['del_S_mdot_TLU',OR_strs{i},'_prompt'])=blockStruct.(['del_S_flow_TLU',OR_strs{i},'_prompt']);
            end
        end

    elseif strcmp(blockStruct.SourceFile,'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_2_position')
        blockStruct.numPositions=2;
        blockStruct.ConstantOrificesPermitted=1;
        blockStruct.OrificesAreConfigurable=1;
        blockStruct.CheckForConsistentSmax=0;
        orifice_list={'PA','PB','AT','BT'};
        orifice_display_name={'P-A','P-B','A-T','B-T'};

        blockStruct.spool_orifice_open_settings={...
...
        [1,2,4,6],[2,3,5,6],[3,6],[1,6]
        [1,2,4,6],[2,3,5,6],[3,6],[1,6]};

    elseif strcmp(blockStruct.SourceFile,'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_3_way')||...
        strcmp(blockStruct.SourceFile,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way')
        blockStruct.numPositions=2;
        blockStruct.ConstantOrificesPermitted=0;
        blockStruct.OrificesAreConfigurable=1;
        blockStruct.CheckForConsistentSmax=1;
        orifice_list={'PA','AT','PT'};
        orifice_display_name={'P-A','A-T','P-T'};

        blockStruct.spool_orifice_open_settings={...
...
        [1,2],[1,3],[1,4]
        [1,2],[1,3],[1,4],};


        if strcmp(blockStruct.SourceFile,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way')
            OR_strs={'','_PA','_AT','_PT'};
            for i=1:length(OR_strs)
                blockStruct.(['del_S_vol_flow_TLU',OR_strs{i}])=blockStruct.(['del_S_flow_TLU',OR_strs{i}]);
                blockStruct.(['del_S_vol_flow_TLU',OR_strs{i},'_prompt'])=blockStruct.(['del_S_flow_TLU',OR_strs{i},'_prompt']);
                blockStruct.(['del_S_mdot_TLU',OR_strs{i}])=blockStruct.(['del_S_flow_TLU',OR_strs{i}]);
                blockStruct.(['del_S_mdot_TLU',OR_strs{i},'_prompt'])=blockStruct.(['del_S_flow_TLU',OR_strs{i},'_prompt']);
            end
        end

    else

        blockStruct.numPositions=2;
        blockStruct.ConstantOrificesPermitted=0;
        blockStruct.OrificesAreConfigurable=0;
        blockStruct.CheckForConsistentSmax=0;
        orifice_list={''};
        orifice_display_name={''};

        blockStruct.spool_orifice_open_settings={...
...
1
        1};

        blockStruct.open_orifices_pos=1;
        blockStruct.open_orifices_neg=0;
        blockStruct.area_spec=1;

        blockStruct.S_max_=blockStruct.S_max;
        blockStruct.S_max_Prompt=blockStruct.S_max_prompt;


        if strcmp(blockStruct.SourceFile,'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_2_way')
            blockStruct.valve_area_TLU=blockStruct.orifice_area_TLU;
            blockStruct.valve_area_TLU_prompt=blockStruct.orifice_area_TLU_prompt;
        else
            blockStruct.del_S_vol_flow_TLU=blockStruct.del_S_flow_TLU;
            blockStruct.del_S_vol_flow_TLU_prompt=blockStruct.del_S_flow_TLU_prompt;
            blockStruct.del_S_mdot_TLU=blockStruct.del_S_flow_TLU;
            blockStruct.del_S_mdot_TLU_prompt=blockStruct.del_S_flow_TLU_prompt;
        end

    end


    keySet=orifice_list;
    valueSet=1:length(keySet);
    blockStruct.OR_ind=containers.Map(keySet,valueSet);


    if blockStruct.numPositions==3
        keySet={'+','-','0'};
    else
        keySet={'+','-'};
    end
    valueSet=1:blockStruct.numPositions;
    blockStruct.pos_ind=containers.Map(keySet,valueSet);

end


function checkParameters(blockStruct,orifice_list,orifice_display_name)



    if contains(blockStruct.SourceFile,'fluids.thermal_liquid')
        assert(value(blockStruct.area,'m^2')>0,...
        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_prompt))
    end

    if blockStruct.area_spec==1
        if blockStruct.valve_spec==3


            if blockStruct.ConstantOrificesPermitted&&atLeast1OrificeIsConstant(blockStruct,orifice_list)
                assert(numel(blockStruct.p_diff_TLU_const)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.p_diff_TLU_const_prompt,"2"))
                assert(all(value(diff(blockStruct.p_diff_TLU_const),'MPa')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.p_diff_TLU_const_prompt))
                assert(numel(blockStruct.vol_flow_TLU_const)==numel(blockStruct.p_diff_TLU_const),...
                message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',blockStruct.vol_flow_TLU_const_prompt,blockStruct.p_diff_TLU_const_prompt))
                assert(all(diff(value(blockStruct.vol_flow_TLU_const,'m^3/s'))>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.vol_flow_TLU_const_prompt))
                assert(all(blockStruct.p_diff_TLU_const.*blockStruct.vol_flow_TLU_const>=0),...
                message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.p_diff_TLU_const_prompt,blockStruct.vol_flow_TLU_const_prompt))
            end


            if atLeast1OrificeIsVariable(blockStruct,orifice_list)
                assert(numel(blockStruct.del_S_vol_flow_TLU)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.del_S_vol_flow_TLU_prompt,"2"))
                assert(numel(blockStruct.p_diff_TLU)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.p_diff_TLU_prompt,"2"))
                assert(all(size(blockStruct.vol_flow_TLU)==[numel(blockStruct.del_S_vol_flow_TLU),numel(blockStruct.p_diff_TLU)]),...
                message('physmod:simscape:compiler:patterns:checks:Size2DEqual',blockStruct.vol_flow_TLU_prompt,blockStruct.del_S_vol_flow_TLU_prompt,blockStruct.p_diff_TLU_prompt))
                assert(all(value(diff(blockStruct.del_S_vol_flow_TLU),'m')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.del_S_vol_flow_TLU_prompt))
                del_S_vol_flow_TLU_first=value(blockStruct.del_S_vol_flow_TLU(1),'m');
                del_S_vol_flow_TLU_first_prompt=['first element of ',blockStruct.del_S_vol_flow_TLU_prompt];
                assert(del_S_vol_flow_TLU_first==0,...
                message('physmod:simscape:compiler:patterns:checks:Equal',del_S_vol_flow_TLU_first_prompt,'0'))
                assert(all(value(diff(blockStruct.p_diff_TLU),'Pa')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.p_diff_TLU_prompt))

                assert(all(all(diff(value(blockStruct.vol_flow_TLU,'m^3/s'),1,2)>0)),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',blockStruct.vol_flow_TLU_prompt))

                assert(all(all(diff(value(blockStruct.vol_flow_TLU,'m^3/s'),1,1)>=0,1)|all(diff(value(blockStruct.vol_flow_TLU,'m^3/s'),1,1)<=0,1)),...
                message('physmod:fluids:library:AscendingOrDescendingColumns',blockStruct.vol_flow_TLU_prompt))

                vol_flow_TLU_sign=value(times(repmat(sign(blockStruct.p_diff_TLU(:)'),size(blockStruct.vol_flow_TLU,1),1),blockStruct.vol_flow_TLU),'m^3/s');
                assert(all(vol_flow_TLU_sign(:)>=0),message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.p_diff_TLU_prompt,blockStruct.vol_flow_TLU_prompt))

            end
        elseif blockStruct.valve_spec==4


            if blockStruct.ConstantOrificesPermitted&&atLeast1OrificeIsConstant(blockStruct,orifice_list)
                assert(numel(blockStruct.p_diff_TLU_const)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.p_diff_TLU_const_prompt,"2"))
                assert(all(value(diff(blockStruct.p_diff_TLU_const),'MPa')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.p_diff_TLU_const_prompt))
            end


            if atLeast1OrificeIsVariable(blockStruct,orifice_list)
                assert(numel(blockStruct.del_S_mdot_TLU)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.del_S_mdot_TLU_prompt,"2"))
                assert(numel(blockStruct.p_diff_TLU)>=2,...
                message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.p_diff_TLU_prompt,"2"))
                assert(all(size(blockStruct.mdot_TLU)==[numel(blockStruct.del_S_mdot_TLU),numel(blockStruct.p_diff_TLU)]),...
                message('physmod:simscape:compiler:patterns:checks:Size2DEqual',blockStruct.mdot_TLU_prompt,blockStruct.del_S_mdot_TLU_prompt,blockStruct.p_diff_TLU_prompt))
                assert(all(value(diff(blockStruct.del_S_mdot_TLU),'m')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.del_S_mdot_TLU_prompt))
                del_S_mdot_TLU_first=value(blockStruct.del_S_mdot_TLU(1),'m');
                del_S_mdot_TLU_first_prompt=['first element of ',blockStruct.del_S_mdot_TLU_prompt];
                assert(del_S_mdot_TLU_first==0,...
                message('physmod:simscape:compiler:patterns:checks:Equal',del_S_mdot_TLU_first_prompt,'0'))
                assert(all(value(diff(blockStruct.p_diff_TLU),'Pa')>0),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.p_diff_TLU_prompt))

                assert(all(all(diff(value(blockStruct.mdot_TLU,'kg/s'),1,2)>0)),...
                message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',blockStruct.vol_flow_TLU_prompt))

                assert(all(all(diff(value(blockStruct.mdot_TLU,'kg/s'),1,1)>=0,1)|all(diff(value(blockStruct.mdot_TLU,'kg/s'),1,1)<=0,1)),...
                message('physmod:fluids:library:AscendingOrDescendingColumns',blockStruct.mdot_TLU_prompt))

                mdot_TLU_sign=value(times(repmat(sign(blockStruct.p_diff_TLU(:)'),size(blockStruct.mdot_TLU,1),1),blockStruct.mdot_TLU),'kg/s');
                assert(all(mdot_TLU_sign(:)>=0),message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.p_diff_TLU_prompt,blockStruct.mdot_TLU_prompt))

            end
        else

            assert(value(blockStruct.area,'m^2')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_prompt))
            assert(value(blockStruct.Cd,'1')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.Cd_prompt))
            assert(value(blockStruct.Re_c,'1')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.Re_c_prompt))


            if blockStruct.ConstantOrificesPermitted&&atLeast1OrificeIsConstant(blockStruct,orifice_list)

                assert(value(blockStruct.area_const,'m^2')>0,...
                message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_const_prompt))
                assert(value(blockStruct.area_const,'m^2')<value(blockStruct.area,'m^2'),...
                message('physmod:simscape:compiler:patterns:checks:LessThan',blockStruct.area_const_prompt,blockStruct.area_prompt))
            end


            if atLeast1OrificeIsVariable(blockStruct,orifice_list)

                if blockStruct.valve_spec==fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_spec.linear

                    assert(value(blockStruct.area_leak,'m^2')>0,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_leak_prompt))
                    assert(value(blockStruct.area_max,'m^2')>value(blockStruct.area_leak,'m^2'),...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.area_max_prompt,blockStruct.area_leak_prompt))
                    assert(value(blockStruct.area,'m^2')>value(blockStruct.area_max,'m^2'),...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.area_prompt,blockStruct.area_max_prompt))
                    assert(value(blockStruct.del_S_max,'m')>0,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.del_S_max_prompt))
                    assert(value(blockStruct.smoothing_factor,'1')>=0,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqualZero',blockStruct.smoothing_factor_prompt))
                    assert(value(blockStruct.smoothing_factor,'1')<=1,...
                    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',blockStruct.smoothing_factor_prompt,"1"))

                elseif blockStruct.valve_spec==fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_spec.table1D_area_opening

                    assert(numel(blockStruct.del_S_TLU)>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.del_S_TLU_prompt,"2"))
                    assert(numel(blockStruct.valve_area_TLU)==numel(blockStruct.del_S_TLU),...
                    message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',blockStruct.valve_area_TLU_prompt,blockStruct.del_S_TLU_prompt))
                    assert(all(value(diff(blockStruct.del_S_TLU),'m')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.del_S_TLU_prompt))
                    del_S_TLU_first=value(blockStruct.del_S_TLU(1),'m');
                    del_S_TLU_first_prompt=['first element of ',blockStruct.del_S_TLU_prompt];
                    assert(del_S_TLU_first==0,...
                    message('physmod:simscape:compiler:patterns:checks:Equal',del_S_TLU_first_prompt,'0'))
                    assert(all(value(diff(blockStruct.valve_area_TLU),'m^2')>0),...
                    message('physmod:simscape:compiler:patterns:checks:AscendingVec',blockStruct.valve_area_TLU_prompt))
                    assert(all(value(blockStruct.valve_area_TLU,'m^2')>0),...
                    message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',blockStruct.valve_area_TLU_prompt))
                    assert(all(value(blockStruct.valve_area_TLU,'m^2')<value(blockStruct.area,'m^2')),...
                    message('physmod:simscape:compiler:patterns:checks:ArrayLessThan',blockStruct.valve_area_TLU_prompt,blockStruct.area_prompt))

                end
            end
        end

    else
        if blockStruct.valve_spec==3
            for i=1:length(orifice_list)
                OR=orifice_list{i};


                if blockStruct.ConstantOrificesPermitted&&orificeIsConstant(blockStruct,OR)
                    assert(numel(blockStruct.(['p_diff_TLU_const_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['p_diff_TLU_const_',OR,'_prompt']),"2"))
                    assert(all(value(diff(blockStruct.(['p_diff_TLU_const_',OR])),'MPa')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['p_diff_TLU_const_',OR,'_prompt'])))
                    assert(numel(blockStruct.(['vol_flow_TLU_const_',OR]))==numel(blockStruct.(['p_diff_TLU_const_',OR])),...
                    message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',blockStruct.(['vol_flow_TLU_const_',OR,'_prompt']),blockStruct.(['p_diff_TLU_const_',OR,'_prompt'])))
                    assert(all(diff(value(blockStruct.(['vol_flow_TLU_const_',OR]),'m^3/s'))>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['vol_flow_TLU_const_',OR,'_prompt'])))
                    assert(all(blockStruct.(['p_diff_TLU_const_',OR]).*blockStruct.(['vol_flow_TLU_const_',OR])>=0),...
                    message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.(['p_diff_TLU_const_',OR,'_prompt']),blockStruct.(['vol_flow_TLU_const_',OR,'_prompt'])))
                end


                if orificeIsVariable(blockStruct,OR)

                    assert(numel(blockStruct.(['del_S_vol_flow_TLU_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['del_S_vol_flow_TLU_',OR,'_prompt']),"2"))
                    assert(numel(blockStruct.(['p_diff_TLU_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['p_diff_TLU_',OR,'_prompt']),"2"))
                    assert(all(size(blockStruct.(['vol_flow_TLU_',OR]))==[numel(blockStruct.(['del_S_vol_flow_TLU_',OR])),numel(blockStruct.(['p_diff_TLU_',OR]))]),...
                    message('physmod:simscape:compiler:patterns:checks:Size2DEqual',blockStruct.(['vol_flow_TLU_',OR,'_prompt']),blockStruct.(['del_S_vol_flow_TLU_',OR,'_prompt']),blockStruct.(['p_diff_TLU_',OR,'_prompt'])))
                    assert(all(value(diff(blockStruct.(['del_S_vol_flow_TLU_',OR])),'m')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['del_S_vol_flow_TLU_',OR,'_prompt'])))
                    del_S_vol_flow_TLU_OR_first=value(blockStruct.(['del_S_vol_flow_TLU_',OR])(1),'m');
                    del_S_vol_flow_TLU_OR_first_prompt=['first element of ',blockStruct.(['del_S_vol_flow_TLU_',OR,'_prompt'])];
                    assert(del_S_vol_flow_TLU_OR_first==0,...
                    message('physmod:simscape:compiler:patterns:checks:Equal',del_S_vol_flow_TLU_OR_first_prompt,'0'))
                    assert(all(value(diff(blockStruct.(['p_diff_TLU_',OR])),'Pa')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['p_diff_TLU_',OR,'_prompt'])))

                    assert(all(all(diff(value(blockStruct.(['vol_flow_TLU_',OR]),'m^3/s'),1,2)>0)),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',blockStruct.(['vol_flow_TLU_',OR,'_prompt'])))

                    assert(all(all(diff(value(blockStruct.(['vol_flow_TLU_',OR]),'m^3/s'),1,1)>=0,1)|all(diff(value(blockStruct.(['vol_flow_TLU_',OR]),'m^3/s'),1,1)<=0,1)),...
                    message('physmod:fluids:library:AscendingOrDescendingColumns',blockStruct.(['vol_flow_TLU_',OR,'_prompt'])))

                    vol_flow_TLU_OR_sign=value(times(repmat(sign(blockStruct.(['p_diff_TLU_',OR])(:)'),size(blockStruct.(['vol_flow_TLU_',OR]),1),1),blockStruct.(['vol_flow_TLU_',OR])),'m^3/s');
                    assert(all(vol_flow_TLU_OR_sign(:)>=0),message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.(['p_diff_TLU_',OR,'_prompt']),blockStruct.(['vol_flow_TLU_',OR,'_prompt'])))
                end
            end
        elseif blockStruct.valve_spec==4
            for i=1:length(orifice_list)
                OR=orifice_list{i};


                if blockStruct.ConstantOrificesPermitted&&orificeIsConstant(blockStruct,OR)
                    assert(numel(blockStruct.(['p_diff_TLU_const_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['p_diff_TLU_const_',OR,'_prompt']),"2"))
                    assert(all(value(diff(blockStruct.(['p_diff_TLU_const_',OR])),'MPa')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['p_diff_TLU_const_',OR,'_prompt'])))
                    assert(numel(blockStruct.(['mdot_TLU_const_',OR]))==numel(blockStruct.(['p_diff_TLU_const_',OR])),...
                    message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',blockStruct.(['mdot_TLU_const_',OR,'_prompt']),blockStruct.(['p_diff_TLU_const_',OR,'_prompt'])))
                    assert(all(diff(value(blockStruct.(['mdot_TLU_const_',OR]),'kg/s'))>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['mdot_TLU_const_',OR,'_prompt'])))
                    assert(all(blockStruct.(['p_diff_TLU_const_',OR]).*blockStruct.(['mdot_TLU_const_',OR])>=0),...
                    message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.(['p_diff_TLU_const_',OR,'_prompt']),blockStruct.(['mdot_TLU_const_',OR,'_prompt'])))
                end


                if orificeIsVariable(blockStruct,OR)

                    assert(numel(blockStruct.(['del_S_mdot_TLU_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['del_S_mdot_TLU_',OR,'_prompt']),"2"))
                    assert(numel(blockStruct.(['p_diff_TLU_',OR]))>=2,...
                    message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['p_diff_TLU_',OR,'_prompt']),"2"))
                    assert(all(size(blockStruct.(['mdot_TLU_',OR]))==[numel(blockStruct.(['del_S_mdot_TLU_',OR])),numel(blockStruct.(['p_diff_TLU_',OR]))]),...
                    message('physmod:simscape:compiler:patterns:checks:Size2DEqual',blockStruct.(['mdot_TLU_',OR,'_prompt']),blockStruct.(['del_S_mdot_TLU_',OR,'_prompt']),blockStruct.(['p_diff_TLU_',OR,'_prompt'])))
                    assert(all(value(diff(blockStruct.(['del_S_mdot_TLU_',OR])),'m')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['del_S_mdot_TLU_',OR,'_prompt'])))
                    del_S_mdot_TLU_OR_first=value(blockStruct.(['del_S_mdot_TLU_',OR])(1),'m');
                    del_S_mdot_TLU_OR_first_prompt=['first element of ',blockStruct.(['del_S_mdot_TLU_',OR,'_prompt'])];
                    assert(del_S_mdot_TLU_OR_first==0,...
                    message('physmod:simscape:compiler:patterns:checks:Equal',del_S_mdot_TLU_OR_first_prompt,'0'))
                    assert(all(value(diff(blockStruct.(['p_diff_TLU_',OR])),'Pa')>0),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['p_diff_TLU_',OR,'_prompt'])))

                    assert(all(all(diff(value(blockStruct.(['mdot_TLU_',OR]),'kg/s'),1,2)>0)),...
                    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows',blockStruct.(['mdot_TLU_',OR,'_prompt'])))

                    assert(all(all(diff(value(blockStruct.(['mdot_TLU_',OR]),'kg/s'),1,1)>=0,1)|all(diff(value(blockStruct.(['mdot_TLU_',OR]),'kg/s'),1,1)<=0,1)),...
                    message('physmod:fluids:library:AscendingOrDescendingColumns',blockStruct.(['vol_flow_TLU_',OR,'_prompt'])))

                    mdot_TLU_OR_sign=value(times(repmat(sign(blockStruct.(['p_diff_TLU_',OR])(:)'),size(blockStruct.(['mdot_TLU_',OR]),1),1),blockStruct.(['mdot_TLU_',OR])),'kg/s');
                    assert(all(mdot_TLU_OR_sign(:)>=0),message('physmod:fluids:library:OrificePressureFlowSign',blockStruct.(['p_diff_TLU_',OR,'_prompt']),blockStruct.(['mdot_TLU_',OR,'_prompt'])))
                end
            end
        else

            assert(value(blockStruct.area,'m^2')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_prompt))
            assert(value(blockStruct.Cd,'1')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.Cd_prompt))
            assert(value(blockStruct.Re_c,'1')>0,...
            message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.Re_c_prompt))



            if blockStruct.ConstantOrificesPermitted
                for i=1:length(orifice_list)
                    OR=orifice_list{i};

                    if orificeIsConstant(blockStruct,OR)
                        assert(value(blockStruct.(['area_const_',OR]),'m^2')>0,...
                        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.(['area_const_',OR,'_prompt'])))
                        assert(value(blockStruct.(['area_const_',OR]),'m^2')<value(blockStruct.area,'m^2'),...
                        message('physmod:simscape:compiler:patterns:checks:LessThan',blockStruct.(['area_const_',OR,'_prompt']),blockStruct.area_prompt))
                    end
                end
            end


            if blockStruct.valve_spec==fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_spec.linear

                if atLeast1OrificeIsVariable(blockStruct,orifice_list)
                    assert(value(blockStruct.area_leak,'m^2')>0,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.area_leak_prompt))
                    assert(value(blockStruct.smoothing_factor,'1')>=0,...
                    message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqualZero',blockStruct.smoothing_factor_prompt))
                    assert(value(blockStruct.smoothing_factor,'1')<=1,...
                    message('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',blockStruct.smoothing_factor_prompt,"1"))
                end


                for i=1:length(orifice_list)
                    OR=orifice_list{i};


                    if orificeIsVariable(blockStruct,OR)
                        assert(value(blockStruct.(['area_max_',OR]),'m^2')>value(blockStruct.area_leak,'m^2'),...
                        message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.(['area_max_',OR,'_prompt']),blockStruct.area_leak_prompt))
                        assert(value(blockStruct.area,'m^2')>value(blockStruct.(['area_max_',OR]),'m^2'),...
                        message('physmod:simscape:compiler:patterns:checks:GreaterThan',blockStruct.area_prompt,blockStruct.(['area_max_',OR,'_prompt'])))
                        assert(value(blockStruct.(['del_S_max_',OR]),'m')>0,...
                        message('physmod:simscape:compiler:patterns:checks:GreaterThanZero',blockStruct.(['del_S_max_',OR,'_prompt'])))
                    end
                end

            elseif blockStruct.valve_spec==fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_spec.table1D_area_opening


                for i=1:length(orifice_list)
                    OR=orifice_list{i};


                    if orificeIsVariable(blockStruct,OR)

                        assert(numel(blockStruct.(['del_S_TLU_',OR]))>=2,...
                        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',blockStruct.(['del_S_TLU_',OR,'_prompt']),"2"))
                        assert(numel(blockStruct.(['valve_area_TLU_',OR]))==numel(blockStruct.(['del_S_TLU_',OR])),...
                        message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',blockStruct.(['valve_area_TLU_',OR,'_prompt']),blockStruct.(['del_S_TLU_',OR,'_prompt'])))
                        assert(all(diff(value(blockStruct.(['del_S_TLU_',OR]),'m'))>0),...
                        message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',blockStruct.(['del_S_TLU_',OR,'_prompt'])))
                        del_S_TLU_OR_first=value(blockStruct.(['del_S_TLU_',OR])(1),'m');
                        del_S_TLU_OR_first_prompt=['first element of ',blockStruct.(['del_S_TLU_',OR,'_prompt'])];
                        assert(del_S_TLU_OR_first==0,...
                        message('physmod:simscape:compiler:patterns:checks:Equal',del_S_TLU_OR_first_prompt,'0'))
                        assert(all(value(diff(blockStruct.(['valve_area_TLU_',OR])),'m^2')>0),...
                        message('physmod:simscape:compiler:patterns:checks:AscendingVec',blockStruct.(['valve_area_TLU_',OR,'_prompt'])))
                        assert(all(value(blockStruct.(['valve_area_TLU_',OR]),'m^2')>0),...
                        message('physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero',blockStruct.(['valve_area_TLU_',OR,'_prompt'])))
                        assert(all(value(blockStruct.(['valve_area_TLU_',OR]),'m^2')<value(blockStruct.area,'m^2')),...
                        message('physmod:simscape:compiler:patterns:checks:ArrayLessThan',blockStruct.(['valve_area_TLU_',OR,'_prompt']),blockStruct.area_prompt))
                    end
                end

            end
        end
    end



    if blockStruct.numPositions==3
        for i=1:length(orifice_list)

            OR=orifice_list{i};
            [OR_pos,OR_neu,OR_neg]=orifice_open_connections(OR,blockStruct);


            if(~(OR_pos&&OR_neg&&OR_neu)&&...
                (OR_pos||OR_neg))



                [del_S_max_OR_use,~]=get_del_S(OR,blockStruct);
                S_max_OR=blockStruct.(['S_max_',OR]);

                if OR_pos&&OR_neg


                    S_min_OR=abs(S_max_OR)-del_S_max_OR_use;
                    orientation_OR=1;
                elseif OR_pos

                    S_min_OR=S_max_OR-del_S_max_OR_use;
                    orientation_OR=1;
                else
                    S_min_OR=S_max_OR+del_S_max_OR_use;
                    orientation_OR=-1;
                end



                if blockStruct.neutral_assert_action==simscape.enum.assert.action.error

                    if OR_neu
                        assert(-orientation_OR*value(S_min_OR,'m')>0,...
                        message('physmod:fluids:library:OrificeNeutralOpening',...
                        [orifice_display_name{i},' orifice'],'open',blockStruct.open_orifices_neu_prompt,...
                        blockStruct.(['S_max_',OR,'_prompt']),blockStruct.neutral_assert_action_prompt));
                    else
                        assert(-orientation_OR*value(S_min_OR,'m')<0,...
                        message('physmod:fluids:library:OrificeNeutralOpening',...
                        [orifice_display_name{i},' orifice'],'closed',blockStruct.open_orifices_neu_prompt,...
                        blockStruct.(['S_max_',OR,'_prompt']),blockStruct.neutral_assert_action_prompt));
                    end
                elseif blockStruct.neutral_assert_action==simscape.enum.assert.action.warn
                    if OR_neu

                        try
                            assert(-orientation_OR*value(S_min_OR,'m')>0,...
                            message('physmod:fluids:library:OrificeNeutralOpening',...
                            [orifice_display_name{i},' orifice'],'open',blockStruct.(['S_max_',OR,'_prompt']),...
                            blockStruct.open_orifices_neu_prompt,blockStruct.neutral_assert_action_prompt));
                        catch e
                            warning(e.message)
                        end
                    else
                        try
                            assert(-orientation_OR*value(S_min_OR,'m')<0,...
                            message('physmod:fluids:library:OrificeNeutralOpening',...
                            [orifice_display_name{i},' orifice'],'closed',blockStruct.(['S_max_',OR,'_prompt']),...
                            blockStruct.open_orifices_neu_prompt,blockStruct.neutral_assert_action_prompt));
                        catch e
                            warning(e.message)
                        end
                    end
                end
            end
        end
    end



    if blockStruct.CheckForConsistentSmax
        for i=1:length(orifice_list)
            OR=orifice_list{i};
            [OR_pos,~,OR_neg]=orifice_open_connections(OR,blockStruct);
            S_max=blockStruct.(['S_max_',OR]);
            S_max_prompt=blockStruct.(['S_max_',OR,'_prompt']);

            if OR_pos
                assert(value(S_max,'m')>=0,...
                message('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqualZero',S_max_prompt));
            elseif OR_neg
                assert(value(S_max,'m')<=0,...
                message('physmod:simscape:compiler:patterns:checks:LessThanOrEqualZero',S_max_prompt));
            end

        end
    end



    if blockStruct.OrificesAreConfigurable&&~blockStruct.ConstantOrificesPermitted


        for i=1:length(orifice_list)
            OR=orifice_list{i};

            assert(~orificeIsConstant(blockStruct,OR),...
            message('physmod:fluids:library:OrificeMultipleSpoolPositions',orifice_display_name{i},blockStruct.open_orifices_pos_prompt,blockStruct.open_orifices_neg_prompt))
        end
    end


end


function boolean=atLeast1OrificeIsVariable(blockStruct,orifice_list)


    boolean=0;
    for i=1:length(orifice_list)
        OR=orifice_list{i};
        boolean=boolean+orificeIsVariable(blockStruct,OR);
    end

end


function boolean=atLeast1OrificeIsConstant(blockStruct,orifice_list)


    boolean=0;
    for i=1:length(orifice_list)
        OR=orifice_list{i};
        boolean=boolean+orificeIsConstant(blockStruct,OR);
    end

end


function boolean=orificeIsVariable(blockStruct,OR)




    OR_ind=blockStruct.OR_ind(OR);


    spool=blockStruct.pos_ind;



    OR_is_open=blockStruct.spool_orifice_open_settings(:,OR_ind);


    if blockStruct.numPositions==3
        boolean=~(any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})&&any(blockStruct.open_orifices_neg==OR_is_open{spool('-')})&&any(blockStruct.open_orifices_neu==OR_is_open{spool('0')}))&&...
        (any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})||any(blockStruct.open_orifices_neg==OR_is_open{spool('-')})||any(blockStruct.open_orifices_neu==OR_is_open{spool('0')}));
    else
        boolean=~(any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})&&any(blockStruct.open_orifices_neg==OR_is_open{spool('-')}))&&...
        (any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})||any(blockStruct.open_orifices_neg==OR_is_open{spool('-')}));
    end
end


function boolean=orificeIsConstant(blockStruct,OR)



    OR_ind=blockStruct.OR_ind(OR);


    spool=blockStruct.pos_ind;



    OR_is_open=blockStruct.spool_orifice_open_settings(:,OR_ind);

    if blockStruct.numPositions==3
        boolean=(any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})&&any(blockStruct.open_orifices_neg==OR_is_open{spool('-')})&&any(blockStruct.open_orifices_neu==OR_is_open{spool('0')}));
    else
        boolean=(any(blockStruct.open_orifices_pos==OR_is_open{spool('+')})&&any(blockStruct.open_orifices_neg==OR_is_open{spool('-')}));
    end
end
