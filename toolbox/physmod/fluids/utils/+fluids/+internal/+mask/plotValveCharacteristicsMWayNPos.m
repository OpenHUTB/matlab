classdef plotValveCharacteristicsMWayNPos<handle

    properties(Access=private)
hBlock
ssc
hFigure
p_diff
htext_p_diff1
htext_p_diff2
hEditText
hErrorText
hAxes
hAxesSpoolPosition
hLines
hLegend


hButton
plotUnits
    end

    methods
        function obj=plotValveCharacteristicsMWayNPos(hBlock)

            if nargin==1
                obj.hBlock=hBlock;














                checkValidBlockHandle(obj);

                createFigure(obj);

            end
        end


        function blockParameterUpdated(obj,~,~)









            Simulink.Block.eval(obj.hBlock);

            updateFigure(obj);

        end


        function changePdiffCallback(obj,~)
            obj.p_diff=simscape.Value(str2double(obj.hEditText.String),obj.htext_p_diff2.String);
            updateFigure(obj);
        end






























        function checkValidBlockHandle(obj)

            if ischar(obj.hBlock)||isstring(obj.hBlock)
                obj.hBlock=getSimulinkBlockHandle(obj.hBlock);
            end

            supportedBlocks={'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_M_way_N_position'};


            if~is_simulink_handle(obj.hBlock)||~any(strcmp(get_param(obj.hBlock,'ComponentPath'),supportedBlocks))


                if~isempty(obj.hFigure)&&isgraphics(obj.hFigure,"figure")&&...
                    string(obj.hFigure.Tag)=="Directional Valve - Plot Valve Characteristics"
                    blockPath=getappdata(obj.hFigure,"blockPath");
                    obj.hBlock=getSimulinkBlockHandle(blockPath);


                    if~is_simulink_handle(obj.hBlock)||~any(strcmp(get_param(obj.hBlock,'ComponentPath'),supportedBlocks))
                        error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
                    end
                else
                    error(message('physmod:simscape:utils:plottingFunctions:InvalidHandle'))
                end
            end

        end


        function createFigure(obj)


            obj.hFigure=figure('Tag','Directional Valve - Plot Valve Characteristics','visible','off');
            obj.hFigure.Name=get_param(obj.hBlock,'Name');

            position=get(obj.hFigure,'Position');
            position(3:4)=position(3:4)*1.3;
            set(obj.hFigure,'Position',position)






            obj.hButton=uicontrol(obj.hFigure,"Style","pushbutton","backgroundColor",[1,1,1],...
            "Units","normalized","Position",[0.02,0.9357,0.2,0.05],...
            "String","Reload Data","FontWeight","bold","FontSize",8);


            obj.hButton.Callback=@(Obj,eventData)updateFigure(obj);


            obj.htext_p_diff1=uicontrol(obj.hFigure,'Units','normalized','OuterPosition',...
            [0.2905,0.9306,0.1695,0.0494],'Style','text','String',"Pressure drop: ",'FontSize',10,...
            'HorizontalAlignment','left','Visible','off');

            obj.htext_p_diff2=uicontrol(obj.hFigure,'Units','normalized','OuterPosition',...
            [0.59,0.94,0.06,0.04],'Style','text','String',"MPa",'FontSize',...
            10,'HorizontalAlignment','left','Visible','off');

            obj.p_diff=simscape.Value(1,'MPa');
            p_diff_str=num2str(value(obj.p_diff,'MPa'));
            obj.hEditText=uicontrol(obj.hFigure,'Style','edit','String',p_diff_str,...
            'Units','normalized','Position',[0.459,0.935,0.12,0.05],...
            'FontWeight','bold','Visible','off');


            obj.hEditText.Callback=@(Obj,eventData)changePdiffCallback(obj);


            obj.hErrorText=annotation('textbox',[0.3053,0.2452,0.6669,0.6333],'String','Error',...
            'Color',[1,0,0],'FontSize',12,'BackgroundColor',[1,1,1],'FaceAlpha',0.75,...
            'HorizontalAlignment','center','VerticalAlignment','middle','Visible','off');


            setappdata(obj.hFigure,"blockPath",getfullname(obj.hBlock));

            obj.hFigure.Units='normalized';

            obj.hAxes=axes(obj.hFigure);

            obj.hAxes.Units='normalized';
            obj.hAxes.XLabel.String='Spool Travel (m)';
            obj.hAxes.XLabel.FontSize=10;


            obj.hAxes.YLabel.FontSize=10;
            obj.hAxes.Title.FontSize=10;

            obj.hLegend=legend(obj.hAxes);
            obj.hLegend.Visible='on';
            obj.hLegend.Location='westoutside';
            obj.hLegend.ItemHitFcn=@obj.Legend_callback;

            obj.hAxes.PositionConstraint='innerposition';
            obj.hAxes.Position=[0.3053,0.2452,0.6669,0.6333];

            obj.hAxesSpoolPosition=axes(obj.hFigure);
            obj.hAxesSpoolPosition.Units='normalized';
            obj.hAxesSpoolPosition.PositionConstraint='innerposition';
            obj.hAxesSpoolPosition.Position=[0.3053,0.1095,0.6669,0.0001];
            obj.hAxesSpoolPosition.XLabel.String='Spool Position Index';
            obj.hAxesSpoolPosition.XLabel.FontSize=10;

            linkaxes([obj.hAxes,obj.hAxesSpoolPosition],'x')

            fontsize(obj.hAxesSpoolPosition,10,"points")
            fontsize(obj.hAxes,10,"points")

            updateFigure(obj);

            obj.hFigure.Visible='on';
        end


        function updateFigure(obj)



            blockParams=foundation.internal.mask.getEvaluatedBlockParameters(obj.hBlock,false);
            obj.ssc.SourceFile=get_param(obj.hBlock,'SourceFile');


            for j=1:height(blockParams)
                param_name=blockParams.Properties.RowNames{j};
                paramValue=blockParams{param_name,'Value'}{1};
                if ischar(paramValue)

                    paramValue=NaN;
                end
                paramUnit=blockParams{param_name,'Unit'}{1};
                obj.ssc.(param_name)=simscape.Value(paramValue,paramUnit);
                obj.ssc.([param_name,'_prompt'])=blockParams.Prompt{param_name};
            end


            checkParameters(obj);

            if obj.ssc.Error==0

                if obj.ssc.valve_spec==2
                    obj.htext_p_diff1.Visible='on';
                    obj.htext_p_diff2.Visible='on';
                    obj.hEditText.Visible='on';
                else
                    obj.htext_p_diff1.Visible='off';
                    obj.htext_p_diff2.Visible='off';
                    obj.hEditText.Visible='off';
                end


                getBlockConfigurationOptions(obj);


                getPlotUnits(obj);


                get_valve_data(obj);


                plotProperties(obj);
            end

        end


        function checkParameters(obj)



            obj.ssc.Error=0;
            obj.hErrorText.Visible='off';

            SSC=obj.ssc;
            num_orifices=double(SSC.num_orifices);


            obj.assertPattern(all(diff(SSC.spool_position_displacements)>0),"StrictlyAscendingVec",SSC.spool_position_displacements_prompt)
            obj.assertPattern(length(SSC.spool_position_displacements)==SSC.num_positions,"LengthEqual",SSC.spool_position_displacements_prompt,SSC.num_positions_prompt)


            if SSC.valve_spec==1
                obj.assertPattern(SSC.leakage_area_fraction>0,"GreaterThanZero",SSC.leakage_area_fraction_prompt)
                obj.assertPattern(SSC.leakage_area_fraction<1,"LessThan",SSC.leakage_area_fraction_prompt,'1')
                obj.assertPattern(SSC.area>0,"GreaterThanZero",SSC.area_prompt)
                obj.assertPattern(SSC.smoothing_factor>=0,"GreaterThanOrEqualZero",SSC.smoothing_factor_prompt)
                obj.assertPattern(SSC.smoothing_factor<=1,"LessThanOrEqual",SSC.smoothing_factor_prompt,'1')
            else
                obj.assertPattern(SSC.leakage_flow_fraction>0,"GreaterThanZero",SSC.leakage_flow_fraction_prompt)
                obj.assertPattern(SSC.leakage_flow_fraction<1,"LessThan",SSC.leakage_flow_fraction_prompt,'1')
            end


            if SSC.area_spec==1
                obj.assertPattern(SSC.spool_travel_fully_open_fraction>=0,"GreaterThanZero",SSC.spool_travel_fully_open_fraction_prompt)
                obj.assertPattern(SSC.spool_travel_fully_open_fraction<1,"LessThan",SSC.spool_travel_fully_open_fraction_prompt,'1')
                obj.assertPattern(SSC.del_S_fraction>0,"GreaterThanZero",SSC.del_S_fraction_prompt)
                obj.assertPattern(length(SSC.spool_travel_fully_open_fraction)==1,"LengthEqual",SSC.spool_travel_fully_open_fraction_prompt,'1')
                obj.assertPattern(length(SSC.del_S_fraction)==1,"LengthEqual",SSC.del_S_fraction_prompt,'1')

                if SSC.valve_spec==2
                    obj.assertPattern(length(SSC.p_diff_TLU)>=2,"LengthGreaterThanOrEqual",SSC.p_diff_TLU_prompt,'1')
                    obj.assertPattern(numel(SSC.vol_flow_TLU_max)==numel(SSC.p_diff_TLU),"LengthEqualLength",SSC.vol_flow_TLU_max_prompt,SSC.p_diff_TLU_prompt)
                    obj.assertPattern(all(diff(SSC.p_diff_TLU)>0),"StrictlyAscendingVec",SSC.p_diff_TLU_prompt)
                    obj.assertPattern(all(diff(SSC.vol_flow_TLU_max)>0),"StrictlyAscendingVec",SSC.vol_flow_TLU_max_prompt)
                    obj.assertPattern(logical(all(value(SSC.p_diff_TLU,'MPa').*value(SSC.vol_flow_TLU_max,'m^3/s')>=0)),...
                    message("physmod:fluids:library:OrificePressureFlowSign",SSC.p_diff_TLU_prompt,SSC.vol_flow_TLU_max_prompt))

                else
                    obj.assertPattern(all(diff(SSC.area_max)>0),"StrictlyAscendingVec",SSC.area_max_prompt)
                end
            end


            for i=1:num_orifices
                obj.assertPattern(length(SSC.(['OR',num2str(i),'_ports']))==2,"LengthEqual",SSC.(['OR',num2str(i),'_ports_prompt']),'2')
                obj.assertPattern(SSC.(['OR',num2str(i),'_ports'])(1)~=SSC.(['OR',num2str(i),'_ports'])(2),"NotEqual",...
                ['First element of Ports connected by orifice ',num2str(i)],['Second element of Ports connected by orifice ',num2str(i)])
                obj.assertPattern(all(SSC.(['OR',num2str(i),'_ports'])>=1),"ArrayGreaterThanOrEqual",SSC.(['OR',num2str(i),'_ports_prompt']),'1')
                obj.assertPattern(all(SSC.(['OR',num2str(i),'_ports'])<=SSC.num_ports),"ArrayLessThanOrEqual",SSC.(['OR',num2str(i),'_ports_prompt']),SSC.num_ports_prompt)
                obj.assertPattern(all(SSC.(['OR',num2str(i),'_open_pos'])>=1),"ArrayGreaterThanOrEqual",SSC.(['OR',num2str(i),'_open_pos_prompt']),'1')
                obj.assertPattern(all(SSC.(['OR',num2str(i),'_open_pos'])<=SSC.num_positions),"ArrayLessThanOrEqual",SSC.(['OR',num2str(i),'_open_pos_prompt']),SSC.num_positions_prompt)
                obj.assertPattern(all(diff(SSC.(['OR',num2str(i),'_open_pos']))>0),"StrictlyAscendingVec",SSC.(['OR',num2str(i),'_open_pos_prompt']))

                if SSC.area_spec==2
                    obj.assertPattern(SSC.(['OR',num2str(i),'_spool_travel_fully_open'])>=0,"GreaterThanZero",SSC.(['OR',num2str(i),'_spool_travel_fully_open_prompt']))
                    obj.assertPattern(SSC.(['OR',num2str(i),'_del_S'])>0,"GreaterThanZero",SSC.(['OR',num2str(i),'_del_S_prompt']))

                    if SSC.valve_spec==1
                        obj.assertPattern(SSC.(['OR',num2str(i),'_area_max'])>0,"GreaterThanZero",SSC.(['OR',num2str(i),'_area_max_prompt']))

                    else
                        p_diff_TLU=SSC.(['OR',num2str(i),'_p_diff_TLU']);
                        p_diff_TLU_prompt=SSC.(['OR',num2str(i),'_p_diff_TLU_prompt']);
                        vol_flow_TLU_max=SSC.(['OR',num2str(i),'_vol_flow_TLU_max']);
                        vol_flow_TLU_max_prompt=SSC.(['OR',num2str(i),'_vol_flow_TLU_max_prompt']);

                        obj.assertPattern(length(p_diff_TLU)>=2,"LengthGreaterThanOrEqual",p_diff_TLU_prompt,'1')
                        obj.assertPattern(numel(vol_flow_TLU_max)==numel(p_diff_TLU),"LengthEqualLength",vol_flow_TLU_max_prompt,p_diff_TLU_prompt)
                        obj.assertPattern(all(diff(p_diff_TLU)>0),"StrictlyAscendingVec",p_diff_TLU_prompt)
                        obj.assertPattern(all(diff(vol_flow_TLU_max)>0),"StrictlyAscendingVec",vol_flow_TLU_max_prompt)
                        obj.assertPattern(all(value(p_diff_TLU,'MPa').*value(vol_flow_TLU_max,'m^3/s')>=0),...
                        message("physmod:fluids:library:OrificePressureFlowSign",p_diff_TLU_prompt,vol_flow_TLU_max_prompt))

                    end

                end
            end
        end


        function getBlockConfigurationOptions(obj)



            SSC=obj.ssc;

            if strcmp(SSC.SourceFile,'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_M_way_N_position')


                num_orifices=value(SSC.num_orifices);


                num_open_positions=NaN(num_orifices,1);

                OR_open_positions=NaN(num_orifices,10);

                OR_spool_travel_fully_open=NaN(num_orifices,1);

                OR_del_S=NaN(num_orifices,1);

                OR_ports=NaN(num_orifices,2);
                for i=1:num_orifices
                    num_open_positions(i)=length(SSC.(['OR',num2str(i),'_open_pos']));
                    OR_open_positions(i,1:num_open_positions(i))=SSC.(['OR',num2str(i),'_open_pos']);
                    OR_ports(i,1:2)=SSC.(['OR',num2str(i),'_ports']);
                    if SSC.area_spec==1
                        OR_spool_travel_fully_open(i)=SSC.spool_travel_fully_open_fraction;

                        OR_del_S(i)=SSC.del_S_fraction;
                    else
                        OR_spool_travel_fully_open(i)=value(SSC.(['OR',num2str(i),'_spool_travel_fully_open']),'m');
                        OR_del_S(i)=value(SSC.(['OR',num2str(i),'_del_S']),'m');
                    end
                end
                SSC.num_open_positions=num_open_positions;
                SSC.OR_open_positions=OR_open_positions;
                SSC.OR_spool_travel_fully_open=OR_spool_travel_fully_open;
                SSC.OR_del_S=OR_del_S;
                SSC.OR_ports=OR_ports;


                SSC.OR_type=2-(SSC.num_open_positions==SSC.num_positions);

                [variable_orifice_indices,TLU_lengths,valve_S_TLUs,del_S_TLUs,~,~,~,~]=...
                fluids.internal.directional_control_valves.MwayNposValveConfiguration(...
                num_orifices,...
                SSC.OR_type,...
                SSC.OR_open_positions,...
                value(SSC.num_positions),...
                SSC.area_spec,...
                SSC.OR_spool_travel_fully_open,...
                SSC.OR_del_S,...
                value(SSC.spool_position_displacements,'m'),...
                SSC.OR_ports);

                SSC.variable_orifice_indices=variable_orifice_indices;
                SSC.TLU_lengths=TLU_lengths;
                SSC.valve_S_TLUs=valve_S_TLUs;
                SSC.del_S_TLUs=del_S_TLUs;

            end

            obj.ssc=SSC;
        end


        function get_valve_data(obj)



            p_diff_plot=obj.p_diff;
            SSC=obj.ssc;
            num_orifices=double(SSC.num_orifices);



            determine_orifice_S_points(obj);


            for i=1:num_orifices
                i_str=num2str(i);
                S=obj.ssc.orifice_response.(['S_',i_str]);

                if SSC.OR_type(i)==1
                    always_open_orifice_response(obj,i,S,p_diff_plot);

                else


                    del_S_vec=interp1(SSC.valve_S_TLUs(i,1:SSC.TLU_lengths(i)),SSC.del_S_TLUs(i,1:SSC.TLU_lengths(i)),value(S,'m'),'linear','extrap');

                    if SSC.valve_spec==1

                        variable_linear_orifice_response(obj,i,del_S_vec);
                    else

                        variable_vol_flow_tabulated_orifice_response(obj,i,p_diff_plot,del_S_vec);
                    end

                end
            end
        end


        function determine_orifice_S_points(obj)



            SSC=obj.ssc;



            spool_travel_range=value(SSC.spool_position_displacements(end)-SSC.spool_position_displacements(1),'m');
            S_min_plot=value(SSC.spool_position_displacements(1),'m')-0.1*spool_travel_range;
            S_max_plot=value(SSC.spool_position_displacements(end),'m')+0.1*spool_travel_range;

            num_orifices=double(SSC.num_orifices);
            for i=1:num_orifices


                orifice_response.(['S_',num2str(i)])=[];
                S=[];%#ok<*AGROW> 
                k=1;
                if SSC.OR_type(i)==2

                    OR_open_positions=SSC.(['OR',num2str(i),'_open_pos']);
                    num_open_positions=length(OR_open_positions);
                    for j=1:num_open_positions


                        pos=value(OR_open_positions(j));
                        s_pos=SSC.spool_position_displacements(pos);



                        if SSC.area_spec==1
                            if pos~=1

                                del_s_full_open_left=SSC.spool_travel_fully_open_fraction*(s_pos-SSC.spool_position_displacements(pos-1))*2;
                                del_s_transition_left=SSC.del_S_fraction*(s_pos-SSC.spool_position_displacements(pos-1));
                            end
                            if pos~=SSC.num_positions

                                del_s_full_open_right=SSC.spool_travel_fully_open_fraction*(SSC.spool_position_displacements(pos+1)-s_pos)*2;
                                del_s_transition_right=SSC.del_S_fraction*(SSC.spool_position_displacements(pos+1)-s_pos);
                            end
                        else
                            if pos~=1
                                del_s_full_open_left=SSC.(['OR',num2str(i),'_spool_travel_fully_open']);
                                del_s_transition_left=SSC.(['OR',num2str(i),'_del_S']);
                            end
                            if pos~=SSC.num_positions
                                del_s_full_open_right=SSC.(['OR',num2str(i),'_spool_travel_fully_open']);
                                del_s_transition_right=SSC.(['OR',num2str(i),'_del_S']);
                            end
                        end


                        if pos==1
                            S(k:k+1)=value([s_pos-max(del_s_full_open_right/2,del_s_transition_right),s_pos],'m');
                            k=k+2;
                        elseif j==1||value(OR_open_positions(j-1))<pos-1


                            S_smooth=get_smoothed_S_points(obj,value([s_pos-del_s_full_open_left/2-del_s_transition_left,s_pos-del_s_full_open_left/2],'m'));
                            num_new_points=length(S_smooth);
                            S(k:k+num_new_points)=[S_smooth,value(s_pos,'m')];
                            k=k+num_new_points+1;
                        end



                        if j~=1&&j~=num_open_positions&&value(OR_open_positions(j-1))==pos-1&&value(OR_open_positions(j+1))==pos+1
                            S(k)=value(s_pos,'m');
                            k=k+1;
                        end


                        if pos==SSC.num_positions
                            S(k)=value(s_pos+max(del_s_full_open_left/2,del_s_transition_left),'m');
                            k=k+1;
                        elseif j==num_open_positions||value(OR_open_positions(j+1))>pos+1


                            S_smooth=get_smoothed_S_points(obj,value([s_pos+del_s_full_open_right/2,s_pos+del_s_full_open_right/2+del_s_transition_right],'m'));
                            num_new_points=length(S_smooth);
                            S(k:k+num_new_points)=[value(s_pos,'m'),S_smooth];
                            k=k+num_new_points+1;
                        end
                    end





                    S=union(S,SSC.valve_S_TLUs(i,1:SSC.TLU_lengths(i)));

                    orifice_response.(['S_',num2str(i)])=S;


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

                S_min_plot=-1;
                S_max_plot=1;
            end
            S_limits=[S_min_plot,S_max_plot];





            for i=1:num_orifices
                S=orifice_response.(['S_',num2str(i)]);
                if~isempty(S)
                    S=union(S_limits,S);
                else
                    S=S_limits;
                end
                orifice_response.(['S_',num2str(i)])=simscape.Value(S,'m');
            end

            obj.ssc.orifice_response=orifice_response;
        end


        function S_vec_smoothed=get_smoothed_S_points(obj,S_lim)


            if obj.ssc.valve_spec==1&&obj.ssc.smoothing_factor~=0
                smooth_factor_sat=max(obj.ssc.smoothing_factor,1e-6);
                k=smooth_factor_sat/2;

                del_S_trans=diff(S_lim);

                delS_startSmooth_Aleak=-2*k*del_S_trans;


                delS_endSmooth_Aleak=k*del_S_trans;


                delS_startSmooth_Amax=(1-k)*del_S_trans;


                delS_endSmooth_Amax=(1+2*k)*del_S_trans;

                S_vec_smoothed_start=linspace(delS_startSmooth_Aleak,delS_endSmooth_Aleak,15)+S_lim(1);
                S_vec_smoothed_end=linspace(delS_startSmooth_Amax,delS_endSmooth_Amax,15)+S_lim(1);
                S_vec_smoothed_intermediate=linspace(S_vec_smoothed_start(end),S_vec_smoothed_end(1),4);
                S_vec_smoothed=[S_vec_smoothed_start,S_vec_smoothed_intermediate(2:end-1),S_vec_smoothed_end];
            else
                S_vec_smoothed=S_lim;
            end

        end


        function always_open_orifice_response(obj,i,S,p_diff_plot)


            SSC=obj.ssc;
            orifice_response=obj.ssc.orifice_response;

            if SSC.valve_spec==1

                if SSC.area_spec==1
                    area_const=SSC.area_max;
                else
                    area_const=SSC.(['OR',num2str(i),'_area_max']);
                end
                area_opening=area_const.*ones(1,length(S));
                orifice_response.(['Area_',num2str(i)])=area_opening;
            else
                if SSC.area_spec==1
                    p_diff_TLU_const=SSC.p_diff_TLU;
                    vol_flow_TLU_const=SSC.vol_flow_TLU_max;
                else
                    p_diff_TLU_const=SSC.(['OR',num2str(i),'_p_diff_TLU']);
                    vol_flow_TLU_const=SSC.(['OR',num2str(i),'_vol_flow_TLU_max']);
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
                orifice_response.(['vol_flow_',num2str(i)])=vol_flow;
            end

            obj.ssc.orifice_response=orifice_response;
        end


        function variable_linear_orifice_response(obj,i,del_S_orifice)

            SSC=obj.ssc;


            del_S_max=1;

            if SSC.area_spec==1
                area_max=SSC.area_max;
            else
                area_max=SSC.(['OR',num2str(i),'_area_max']);
            end
            area_max_used=area_max;
            area_leak_used=SSC.leakage_area_fraction*area_max;




            smooth_factor_sat=max(SSC.smoothing_factor,1e-6);


            area_opening=(area_max_used-area_leak_used)/del_S_max*del_S_orifice+area_leak_used;


            if SSC.smoothing_factor==0
                area_steady=area_opening;

                area_steady=min(area_steady,area_max_used);
                area_steady=max(area_steady,area_leak_used);
            else
                area_steady=obj.smoothLimit(area_opening,area_leak_used,area_max_used,smooth_factor_sat);
            end

            obj.ssc.orifice_response.(['Area_',num2str(i)])=area_steady;

        end


        function variable_vol_flow_tabulated_orifice_response(obj,i,p_diff_plot,del_S)



            SSC=obj.ssc;
            pressure_units=obj.plotUnits.pressure_units;
            vol_flow_units=obj.plotUnits.flow_rate_units;


            del_S_vol_flow_TLU=[0,1];

            if SSC.area_spec==1
                p_diff_TLU=SSC.p_diff_TLU;
                vol_flow_TLU=[SSC.leakage_flow_fraction;1]*SSC.vol_flow_TLU_max;
            else
                p_diff_TLU=SSC.(['OR',num2str(i),'_p_diff_TLU']);
                vol_flow_TLU=[SSC.leakage_flow_fraction;1]*SSC.(['OR',num2str(i),'_vol_flow_TLU_max']);
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
                if any(p_diff_TLU==0)
                    p_diff_TLU_ext=p_diff_TLU;
                    vol_flow_TLU_ext=vol_flow_TLU;
                else
                    p_diff_TLU_ext=[p_diff_TLU,{0,pressure_units}].*([p_diff_TLU,{0,pressure_units}]<0)+[{0,pressure_units},p_diff_TLU].*([{0,pressure_units},p_diff_TLU]>0);
                    vol_flow_TLU_ext=[vol_flow_TLU,{[0;0],vol_flow_units}].*([vol_flow_TLU,{[0;0],vol_flow_units}]<0)+[{[0;0],vol_flow_units},vol_flow_TLU].*([{[0;0],vol_flow_units},vol_flow_TLU]>0);
                end
            end


            del_S_saturate=max(del_S_vol_flow_TLU(1),min(del_S,del_S_vol_flow_TLU(end)))';



            P_diff=repmat(value(p_diff_plot,pressure_units),size(del_S_saturate));

            F=griddedInterpolant({del_S_vol_flow_TLU,value(p_diff_TLU_ext,pressure_units)},value(vol_flow_TLU_ext,vol_flow_units));
            vol_flow=simscape.Value(F(del_S_saturate,P_diff),vol_flow_units);

            obj.ssc.orifice_response.(['vol_flow_',num2str(i)])=vol_flow;
        end


        function plotProperties(obj)


            SSC=obj.ssc;
            orifice_response_vs_S=SSC.orifice_response;
            num_orifices=double(SSC.num_orifices);


            LineWidth_list={1.5,1,1,1,1,1,1};
            LineStyle_list={'-','--','-.','--','-.','-','-'};

            LineColor=colororder;
            Marker=['+','x','s','o','*','^','d'];
            MarkerSize_list={6,6,6,6,6,5,6};


            delete(obj.hLines(num_orifices+1:end))
            obj.hLines(num_orifices+1:end)=[];

            obj.hAxes.Box='on';
            obj.hAxes.XGrid='on';
            obj.hAxes.YGrid='on';
            obj.hAxes.XLimitMethod='padded';
            obj.hAxes.YLimitMethod='padded';
            hold(obj.hAxes,'on')

            for i=1:num_orifices
                i_str=num2str(i);

                ports=value(SSC.(['OR',num2str(i),'_ports']));
                port1=num2str(ports(1));
                port2=num2str(ports(2));
                orifice_label=['Orifice ',i_str,': Ports ',port1,'-',port2];

                S=orifice_response_vs_S.(['S_',i_str]);

                if SSC.valve_spec==1
                    yValues=value(orifice_response_vs_S.(['Area_',i_str]),obj.plotUnits.area_units);
                else
                    yValues=value(orifice_response_vs_S.(['vol_flow_',i_str]),obj.plotUnits.flow_rate_units);
                end



                if i<=7
                    iLineColor=i;
                    iLineStyle=i;
                    iMarker=i;
                    iMarkerEdgeColor=i;
                    MarkerFaceColor='none';
                elseif i<=14
                    iLineColor=i-7;
                    iLineStyle=mod(i,7)+1;
                    iMarker=mod(i,7)+1;
                    iMarkerEdgeColor=iLineColor;
                    MarkerFaceColor='none';
                else
                    iLineColor=i-14;
                    iLineStyle=mod(i+1,7)+1;
                    iMarker=mod(i+1,7)+1;
                    iMarkerEdgeColor=iLineColor;
                    MarkerFaceColor=LineColor(iLineColor,:);
                end

                if length(obj.hLines)>=i&&isgraphics(obj.hLines(i))
                    set(obj.hLines(i),...
                    'XData',value(S,obj.plotUnits.Spool_pos),...
                    'yData',yValues,...
                    'DisplayName',orifice_label,...
                    'MarkerIndices',2:length(yValues)-1);
                else
                    obj.hLines(i)=plot(obj.hAxes,value(S,obj.plotUnits.Spool_pos),yValues,'DisplayName',orifice_label,...
                    'Color',LineColor(iLineColor,:),...
                    'LineWidth',LineWidth_list{iLineStyle},...
                    'LineStyle',LineStyle_list{iLineStyle},...
                    'Marker',Marker(iMarker),...
                    'MarkerEdgeColor',LineColor(iMarkerEdgeColor,:),...
                    'MarkerFaceColor',MarkerFaceColor,...
                    'MarkerSize',MarkerSize_list{iMarker},...
                    'MarkerIndices',2:length(yValues)-1);
                end
            end


            if SSC.valve_spec==1
                obj.hAxes.YLabel.String=['Orifice Area (',obj.plotUnits.area_units,')'];
                obj.hAxes.Title.String='Area vs. Spool Position for Each Orifice';
            else
                obj.hAxes.YLabel.String=['Volumetric Flow Rate (',obj.plotUnits.flow_rate_units,')'];
                obj.hAxes.Title.String='Flow Rate vs. Spool Position for Each Orifice';

                obj.hEditText.String=num2str(value(obj.p_diff,obj.plotUnits.pressure_units));
                obj.htext_p_diff2.String=obj.plotUnits.pressure_units;
            end

            S=value(S,obj.plotUnits.Spool_pos);
            S_plot_min=S(1);
            S_plot_max=S(end);
            obj.hAxes.XLim=[S_plot_min,S_plot_max];

            obj.hAxesSpoolPosition.XTick=value(obj.ssc.spool_position_displacements,obj.plotUnits.Spool_pos);
            obj.hAxesSpoolPosition.XTickLabel=string(num2cell(1:value(obj.ssc.num_positions)));
            obj.hAxes.XLabel.String=['Spool Travel (',obj.plotUnits.Spool_pos,')'];

        end


        function getPlotUnits(obj)


            SSC=obj.ssc;

            obj.plotUnits.Spool_pos=char(unit(SSC.spool_position_displacements));

            if double(SSC.valve_spec)==1
                if double(SSC.area_spec)==1
                    obj.plotUnits.area_units=char(unit(SSC.area_max));
                else


                    num_orifices=double(SSC.num_orifices);
                    ORs_area_max_unit=cell(1,num_orifices);
                    for i=1:num_orifices
                        ORs_area_max_unit{i}=char(unit(SSC.(['OR',num2str(i),'_area_max'])));
                    end
                    all_area_units_match=all(strcmp(ORs_area_max_unit{1},ORs_area_max_unit));
                    if all_area_units_match
                        obj.plotUnits.area_units=ORs_area_max_unit{1};
                    else
                        obj.plotUnits.area_units='m^2';
                    end
                end
            else
                if double(SSC.area_spec)==1
                    obj.plotUnits.flow_rate_units=char(unit(SSC.vol_flow_TLU_max));
                    obj.plotUnits.pressure_units=char(unit(SSC.p_diff_TLU));

                else

                    num_orifices=double(SSC.num_orifices);
                    ORs_vol_flow_TLU_unit=cell(1,num_orifices);
                    ORs_p_diff_TLU_unit=cell(1,num_orifices);
                    for i=1:num_orifices
                        ORs_vol_flow_TLU_unit{i}=char(unit(SSC.(['OR',num2str(i),'_vol_flow_TLU_max'])));
                        ORs_p_diff_TLU_unit{i}=char(unit(SSC.(['OR',num2str(i),'_p_diff_TLU'])));
                    end



                    all_vol_flow_TLU_units_match=all(strcmp(ORs_vol_flow_TLU_unit{1},ORs_vol_flow_TLU_unit));
                    if all_vol_flow_TLU_units_match
                        obj.plotUnits.flow_rate_units=ORs_vol_flow_TLU_unit{1};
                    else
                        obj.plotUnits.flow_rate_units='m^3/s';
                    end



                    all_p_diff_TLU_units_match=all(strcmp(ORs_p_diff_TLU_unit{1},ORs_p_diff_TLU_unit));
                    if all_p_diff_TLU_units_match
                        obj.plotUnits.pressure_units=ORs_p_diff_TLU_unit{1};
                    else
                        obj.plotUnits.pressure_units='MPa';
                    end

                end
            end
        end


        function assertPattern(obj,cond,msgID,varargin)





            if~logical(cond)
                obj.ssc.Error=1;
                obj.hErrorText.Visible='on';

                if isstring(msgID)
                    msg=message("physmod:simscape:compiler:patterns:checks:"+msgID,varargin{:});
                else
                    msg=msgID;
                end


                causeException=MException(msg);
                obj.hErrorText.String=['Error: ',causeException.message];
            end
        end

    end

    methods(Static)

        function ULim=smoothLimit(U,a,b,s)









            U_norm=(U-a)./(b-a);


            ULim_norm=(1+sqrt(U_norm.^2+(s/4)^2)-sqrt((U_norm-1).^2+(s/4)^2))/2;



            ULim=ULim_norm.*(b-a)+a;
        end


        function Legend_callback(~,event)



            if strcmp(event.Peer.Visible,'on')
                event.Peer.Visible='off';
            else
                event.Peer.Visible='on';
            end

        end
    end

end