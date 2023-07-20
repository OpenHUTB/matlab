classdef Model<handle








    properties
blockname
        blockinfo(1,1)struct
        plotdata(1,1)struct
    end

    events
ValueChanged
    end

    methods(Access=public)

        function obj=Model(blk)




            if ishandle(blk)
                name=get_param(blk,'Name');
                parent=get_param(blk,'Parent');
                obj.blockname=[parent,'/',name];
            elseif ischar(blk)||isstring(blk)
                obj.blockname=blk;
            end


            try
                componentPath=get_param(blk,'ComponentPath');
                if~ee.internal.mask.isComponentMotorDrive(componentPath)
                    pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidBlockClickBefore',...
                    obj.blockname,...
                    'Motor & Drive (System Level)',...
                    'physmod:ee:library:comments:utils:contextmenu:label_PlotEfficiencyMap');
                end
            catch
                pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidBlockClickBefore',...
                obj.blockname,...
                'Motor & Drive (System Level)',...
                'physmod:ee:library:comments:utils:contextmenu:label_PlotEfficiencyMap');
            end



            obj.updateBlockInfo();
            obj.updatePlotData();

        end

        function updateBlockInfo(obj)







            blk=obj.blockname;
            info=struct();

            info.BlockVariant=get_param(blk,'ComponentPath');


            blockParams=foundation.internal.mask.getEvaluatedBlockParameters(blk);


            info.DropdownChoices.torque_speed_param=blockParams{'torque_speed_param','Value'}{1};
            info.DropdownChoices.losses_param=blockParams{'losses_param','Value'}{1};
            info.DropdownChoices.overtorque_param=blockParams{'overtorque_param','Value'}{1};



            info.NumericData.torque_max_Nm=lgetValue(blockParams,'torque_max','N*m');
            info.NumericData.torque_max_intermittent_Nm=lgetValue(blockParams,'torque_max_intermittent','N*m');
            info.NumericData.power_max_W=lgetValue(blockParams,'power_max','W');
            info.NumericData.power_max_intermittent_W=lgetValue(blockParams,'power_max_intermittent','W');

            info.NumericData.torque_vec_Nm=lgetValue(blockParams,'T_t','N*m');
            info.NumericData.torque_vec_intermittent_Nm=lgetValue(blockParams,'T_t_intermittent','N*m');
            info.NumericData.w_vec_rpm=lgetValue(blockParams,'w_t','rpm');

            info.NumericData.torque_mat_Nm=lgetValue(blockParams,'T_t_2D','N*m');
            info.NumericData.torque_mat_intermittent_Nm=lgetValue(blockParams,'T_t_intermittent_2D','N*m');
            info.NumericData.v_vec_V=lgetValue(blockParams,'vdc_t','V');

            info.NumericData.eff=lgetValue(blockParams,'eff','1');
            info.NumericData.w_eff_rpm=lgetValue(blockParams,'w_eff','rpm');
            info.NumericData.trq_eff_Nm=lgetValue(blockParams,'T_eff','N*m');
            info.NumericData.Piron_W=lgetValue(blockParams,'Piron','W');
            info.NumericData.Pbase_W=lgetValue(blockParams,'Pbase','W');


            info.NumericData.w_eff_vec_rpm=lgetValue(blockParams,'w_eff_vec','rpm');
            info.NumericData.trq_eff_vec_Nm=lgetValue(blockParams,'T_eff_vec','N*m');
            info.NumericData.v_eff_vec_V=lgetValue(blockParams,'v_eff_vec','V');
            info.NumericData.losses_mat_W=lgetValue(blockParams,'losses_mat','W');
            info.NumericData.losses_mat_3D_W=lgetValue(blockParams,'losses_mat_3D','W');
            info.NumericData.efficiency_mat=lgetValue(blockParams,'efficiency_mat','1');
            info.NumericData.efficiency_mat_3D=lgetValue(blockParams,'efficiency_mat_3D','1');

            if strcmp(info.BlockVariant,'ee.electromech.motor_and_drive_thermal')
                info.NumericData.Tmeas_K=lgetValue(blockParams,'Tmeas','K');
                info.NumericData.Tmeas2_K=lgetValue(blockParams,'Tmeas2','K');
                info.NumericData.losses_mat_T2_W=lgetValue(blockParams,'losses_mat_T2','W');
                info.NumericData.efficiency_mat_T2=lgetValue(blockParams,'efficiency_mat_T2','1');
                info.NumericData.losses_mat_3D_T2_W=lgetValue(blockParams,'losses_mat_3D_T2','W');
                info.NumericData.efficiency_mat_3D_T2=lgetValue(blockParams,'efficiency_mat_3D_T2','1');
            end

            obj.blockinfo=info;

            obj.checkInvalidParameterValues()

        end

        function updatePlotData(obj)


            info=obj.blockinfo;

            obj.plotdata=struct();

            numPointsW=200;
            numPointsT=200;



            obj.plotdata.voltageSliderIsActive=false;
            obj.plotdata.temperatureSliderIsActive=false;


            switch info.DropdownChoices.torque_speed_param
            case ee.enum.electromech.envelope.torque_power
                obj.computeSpeedTorqueGrid_MaxTorPow(numPointsW,numPointsT);

            case ee.enum.electromech.envelope.tabulated
                obj.computeSpeedTorqueGrid_TabulTor(numPointsW,numPointsT);

            case ee.enum.electromech.envelope.tabulated2D
                obj.computeSpeedTorqueGrid_TabulTorWithVoltage(numPointsW,numPointsT);
                obj.plotdata.voltageSliderIsActive=true;

            otherwise
                pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParam',...
                string(info.DropdownChoices.torque_speed_param),'torque_speed_param');
            end



            if strcmp(info.BlockVariant,'ee.electromech.motor_and_drive')||...
                (strcmp(info.BlockVariant,'ee.electromech.motor_and_drive_thermal')&&isequal(info.NumericData.Tmeas_K,info.NumericData.Tmeas2_K))


                obj.plotdata.temperatureSliderIsActive=false;
                switch info.DropdownChoices.losses_param
                case 1
                    obj.computeGridEfficiency_SingleEffMeas();
                case 2
                    obj.computeGridEfficiency_LossTab2D();
                case 3
                    obj.computeGridEfficiency_EffTab2D();
                case 4
                    obj.compute3DGridEfficiency_LossTab3D();
                    obj.plotdata.voltageSliderIsActive=true;
                case 5
                    obj.compute3DGridEfficiency_EffTab3D();
                    obj.plotdata.voltageSliderIsActive=true;
                otherwise
                    pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParam',...
                    string(info.DropdownChoices.losses_param),'losses_param');
                end
            else
                switch info.DropdownChoices.losses_param
                case 1
                    obj.computeGridEfficiency_SingleEffMeas();
                case 2
                    obj.computeGridEfficiency_LossTab2DWithTemp();
                    obj.plotdata.temperatureSliderIsActive=true;
                case 3
                    obj.computeGridEfficiency_EffTab2DWithTemp();
                    obj.plotdata.temperatureSliderIsActive=true;
                case 4
                    obj.compute3DGridEfficiency_LossTab3DWithTemp();
                    obj.plotdata.voltageSliderIsActive=true;
                    obj.plotdata.temperatureSliderIsActive=true;
                case 5
                    obj.compute3DGridEfficiency_EffTab3DWithTemp();
                    obj.plotdata.voltageSliderIsActive=true;
                    obj.plotdata.temperatureSliderIsActive=true;
                otherwise
                    pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParam',...
                    string(info.DropdownChoices.losses_param),'losses_param');
                end
            end


            numLevels=10;
            if isfield(obj.plotdata,'eff2d')
                contour_levels=computeContourLevels(obj.plotdata.eff2d,numLevels);
            elseif isfield(obj.plotdata,'eff3d')
                contour_levels=computeContourLevels(obj.plotdata.eff3d,numLevels);
            elseif isfield(obj.plotdata,'eff2dT1')
                eff3dFlat=[obj.plotdata.eff2dT1(:);obj.plotdata.eff2dT2(:)];
                contour_levels=computeContourLevels(eff3dFlat,numLevels);
            elseif isfield(obj.plotdata,'eff3dT1')
                eff4dFlat=[obj.plotdata.eff3dT1(:);obj.plotdata.eff3dT2(:)];
                contour_levels=computeContourLevels(eff4dFlat,numLevels);
            end
            obj.plotdata.contour_levels=contour_levels;

        end

    end

    methods(Access=protected)

        function checkInvalidParameterValues(obj)



            slmodel=bdroot;
            if strcmp(get_param(slmodel,'BlockDiagramType'),'model')
                try
                    set_param(slmodel,'SimulationCommand','Update');
                catch ME
                    throwAsCaller(ME);
                end
            end


            info=obj.blockinfo;

            switch info.DropdownChoices.torque_speed_param
            case{ee.enum.electromech.envelope.tabulated,ee.enum.electromech.envelope.tabulated2D}
                w_t=info.NumericData.w_vec_rpm;
                if any(w_t<0)

                    pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParamFirstQuadrantOnly',...
                    string(mat2str(w_t)),getString(message('physmod:ee:library:comments:electromech:motor_and_drive_base_all:w_t')))
                end
            otherwise

            end

        end


        function computeSpeedTorqueGrid_MaxTorPow(obj,numPointsW,numPointsT)


            info=obj.blockinfo;
            data=info.NumericData;


            torque_max_Nm=data.torque_max_Nm;
            power_max_W=data.power_max_W;


            spd_max_rpm=5*round(power_max_W/torque_max_Nm*60/2/pi,...
            4,'significant');

            w_vec=linspace(1,spd_max_rpm,numPointsW)*2*pi/60;

            torque_envelope_Nm=min(power_max_W./w_vec,torque_max_Nm);


            overtorque_choice=info.DropdownChoices.overtorque_param;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)
                trq_vec=linspace(0,torque_max_Nm,numPointsT)';
                torque_intermittent_envelope_Nm=[];
            else
                torque_max_intermittent_Nm=data.torque_max_intermittent_Nm;
                power_max_intermittent_W=data.power_max_intermittent_W;
                trq_vec=linspace(0,torque_max_intermittent_Nm,numPointsT)';
                torque_intermittent_envelope_Nm=min(power_max_intermittent_W./w_vec,torque_max_intermittent_Nm);
            end


            [w,trq]=ndgrid(w_vec,trq_vec);



            obj.plotdata.trqnd_Nm=trq;
            obj.plotdata.wnd_radps=w;
            obj.plotdata.torque_envelope_Nm=torque_envelope_Nm;
            obj.plotdata.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;

        end

        function computeSpeedTorqueGrid_TabulTor(obj,numPointsW,numPointsT)


            info=obj.blockinfo;
            data=info.NumericData;

            w_vec=linspace(0,max(data.w_vec_rpm),numPointsW)*2*pi/60;

            torque_envelope_Nm=interp1(data.w_vec_rpm*2*pi/60,data.torque_vec_Nm,w_vec);

            overtorque_choice=info.DropdownChoices.overtorque_param;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)
                trq_vec=linspace(0,max(torque_envelope_Nm),numPointsT)';
                torque_intermittent_envelope_Nm=[];
            else
                torque_intermittent_envelope_Nm=interp1(data.w_vec_rpm*2*pi/60,data.torque_vec_intermittent_Nm,w_vec);
                trq_vec=linspace(0,max(torque_intermittent_envelope_Nm),numPointsT)';
            end


            [w,trq]=ndgrid(w_vec,trq_vec);



            obj.plotdata.trqnd_Nm=trq;
            obj.plotdata.wnd_radps=w;
            obj.plotdata.torque_envelope_Nm=torque_envelope_Nm;
            obj.plotdata.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;


        end

        function computeSpeedTorqueGrid_TabulTorWithVoltage(obj,numPointsW,numPointsT)


            info=obj.blockinfo;
            data=info.NumericData;

            w_vec=linspace(0,max(data.w_vec_rpm),numPointsW)*2*pi/60;
            v_vec=data.v_vec_V;

            torque_envelope_Nm=interp1(data.w_vec_rpm*2*pi/60,data.torque_mat_Nm,w_vec);

            overtorque_choice=info.DropdownChoices.overtorque_param;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)
                trq_vec=linspace(0,max(torque_envelope_Nm(:)),numPointsT)';
                torque_intermittent_envelope_Nm=[];
            else
                torque_intermittent_envelope_Nm=interp1(data.w_vec_rpm*2*pi/60,data.torque_mat_intermittent_Nm,w_vec);
                trq_vec=linspace(0,max(torque_intermittent_envelope_Nm(:)),numPointsT)';
            end


            [w,trq]=ndgrid(w_vec,trq_vec);



            obj.plotdata.trqnd_Nm=trq;
            obj.plotdata.wnd_radps=w;
            obj.plotdata.v_vec_V=v_vec;
            obj.plotdata.torque_envelope_Nm=torque_envelope_Nm;
            obj.plotdata.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;


        end


        function computeGridEfficiency_SingleEffMeas(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;

            Pbase_W=data.Pbase_W;
            eff=data.eff/100;
            w_eff_rpm=data.w_eff_rpm;
            w_eff_radps=w_eff_rpm*2*pi/60;
            trq_eff_Nm=data.trq_eff_Nm;
            Piron_W=data.Piron_W;


            mechpow_eff=w_eff_radps*trq_eff_Nm;
            total_loss_eff=mechpow_eff/eff-mechpow_eff;
            iron_loss_eff=Piron_W;
            copper_loss_eff=total_loss_eff-iron_loss_eff-Pbase_W;
            if(copper_loss_eff<0)
                pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_CopperLossNegative')
            end
            trq_elec_eff=trq_eff_Nm;
            k_copper=copper_loss_eff/trq_elec_eff^2;
            k_iron=iron_loss_eff/w_eff_radps^2;


            Pb=Pbase_W*ones(size(w));

            kc=k_copper;
            ki=k_iron;

            trq_elec=abs(trq);
            Lc=kc*trq_elec.^2;
            Li=ki*w.^2;
            L_elec=Pb+Lc+Li;
            L_total=L_elec;
            mech_power=trq.*w;
            eff2d=100*abs(mech_power)./(L_total+abs(mech_power));


            obj.plotdata.eff2d=eff2d;

        end

        function computeGridEfficiency_LossTab2D(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            loss_mat=data.losses_mat_W;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;


            [wngrid,trqngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm);
            lossInterpolant=griddedInterpolant(wngrid,trqngrid,loss_mat,'linear','nearest');
            L_elec=lossInterpolant(w,trq);


            trq_elec=abs(trq);
            L_total=L_elec;
            mech_power=trq_elec.*w;
            eff2d=100*abs(mech_power)./(L_total+abs(mech_power));


            obj.plotdata.eff2d=eff2d;
        end

        function computeGridEfficiency_EffTab2D(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            eff_mat=data.efficiency_mat;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;


            [wngrid,trqngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm);
            effInterpolant=griddedInterpolant(wngrid,trqngrid,eff_mat,'linear','nearest');
            eff_elec=effInterpolant(w,trq);


            eff2d=eff_elec;


            obj.plotdata.eff2d=eff2d;


        end

        function compute3DGridEfficiency_LossTab3D(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            v_eff_vec_V=data.v_eff_vec_V;


            loss_mat_3D=data.losses_mat_3D_W;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;


            [wngrid,trqngrid,vngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm,v_eff_vec_V);
            lossInterpolant=griddedInterpolant(wngrid,trqngrid,vngrid,loss_mat_3D,'linear','nearest');
            w3d=repmat(w,1,1,length(v_eff_vec_V));
            trq3d=repmat(trq,1,1,length(v_eff_vec_V));
            v3d=nan([size(w),length(v_eff_vec_V)]);
            for idz=1:length(v_eff_vec_V)
                v3d(:,:,idz)=v_eff_vec_V(idz);
            end
            L_elec=lossInterpolant(w3d,trq3d,v3d);

            trq_elec=abs(trq);
            L_total=L_elec;
            mech_power=trq_elec.*w;
            eff3d=100*abs(mech_power)./(L_total+abs(mech_power));


            obj.plotdata.eff3d=eff3d;
            obj.plotdata.v_eff_vec_V=v_eff_vec_V;
        end

        function compute3DGridEfficiency_EffTab3D(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            v_eff_vec_V=data.v_eff_vec_V;


            eff_mat_3D=data.efficiency_mat_3D;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;


            [wngrid,trqngrid,vngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm,v_eff_vec_V);
            effInterpolant=griddedInterpolant(wngrid,trqngrid,vngrid,eff_mat_3D,'linear','nearest');
            w3d=repmat(w,1,1,length(v_eff_vec_V));
            trq3d=repmat(trq,1,1,length(v_eff_vec_V));
            v3d=nan([size(w),length(v_eff_vec_V)]);
            for idz=1:length(v_eff_vec_V)
                v3d(:,:,idz)=v_eff_vec_V(idz);
            end
            eff_elec=effInterpolant(w3d,trq3d,v3d);


            eff3d=eff_elec;


            obj.plotdata.eff3d=eff3d;
            obj.plotdata.v_eff_vec_V=v_eff_vec_V;

        end

        function computeGridEfficiency_LossTab2DWithTemp(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            loss_mat_T1=data.losses_mat_W;
            loss_mat_T2=data.losses_mat_T2_W;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;
            Tmeas_K=data.Tmeas_K;
            Tmeas2_K=data.Tmeas2_K;
            T_vec_K=[Tmeas_K,Tmeas2_K];


            [wngrid,trqngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm);
            lossInterpolantT1=griddedInterpolant(wngrid,trqngrid,loss_mat_T1,'linear','nearest');
            lossInterpolantT2=griddedInterpolant(wngrid,trqngrid,loss_mat_T2,'linear','nearest');
            L_elecT1=lossInterpolantT1(w,trq);
            L_elecT2=lossInterpolantT2(w,trq);


            trq_elec=abs(trq);
            mech_power=trq_elec.*w;
            L_totalT1=L_elecT1;
            L_totalT2=L_elecT2;
            eff2dT1=100*abs(mech_power)./(L_totalT1+abs(mech_power));
            eff2dT2=100*abs(mech_power)./(L_totalT2+abs(mech_power));


            obj.plotdata.eff2dT1=eff2dT1;
            obj.plotdata.eff2dT2=eff2dT2;
            obj.plotdata.T_vec_K=T_vec_K;
        end

        function computeGridEfficiency_EffTab2DWithTemp(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            eff_mat_T1=data.efficiency_mat;
            eff_mat_T2=data.efficiency_mat_T2;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;
            Tmeas_K=data.Tmeas_K;
            Tmeas2_K=data.Tmeas2_K;
            T_vec_K=[Tmeas_K,Tmeas2_K];


            [wngrid,trqngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm);
            effInterpolantT1=griddedInterpolant(wngrid,trqngrid,eff_mat_T1,'linear','nearest');
            effInterpolantT2=griddedInterpolant(wngrid,trqngrid,eff_mat_T2,'linear','nearest');
            eff_elecT1=effInterpolantT1(w,trq);
            eff_elecT2=effInterpolantT2(w,trq);


            eff2dT1=eff_elecT1;
            eff2dT2=eff_elecT2;


            obj.plotdata.eff2dT1=eff2dT1;
            obj.plotdata.eff2dT2=eff2dT2;
            obj.plotdata.T_vec_K=T_vec_K;

        end

        function compute3DGridEfficiency_LossTab3DWithTemp(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            v_eff_vec_V=data.v_eff_vec_V;


            loss_mat_3D_T1=data.losses_mat_3D_W;
            loss_mat_3D_T2=data.losses_mat_3D_T2_W;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;
            Tmeas_K=data.Tmeas_K;
            Tmeas2_K=data.Tmeas2_K;
            T_vec_K=[Tmeas_K,Tmeas2_K];


            [wngrid,trqngrid,vngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm,v_eff_vec_V);
            lossInterpolantT1=griddedInterpolant(wngrid,trqngrid,vngrid,loss_mat_3D_T1,'linear','nearest');
            lossInterpolantT2=griddedInterpolant(wngrid,trqngrid,vngrid,loss_mat_3D_T2,'linear','nearest');
            w3d=repmat(w,1,1,length(v_eff_vec_V));
            trq3d=repmat(trq,1,1,length(v_eff_vec_V));
            v3d=nan([size(w),length(v_eff_vec_V)]);
            for idz=1:length(v_eff_vec_V)
                v3d(:,:,idz)=v_eff_vec_V(idz);
            end
            L_elecT1=lossInterpolantT1(w3d,trq3d,v3d);
            L_elecT2=lossInterpolantT2(w3d,trq3d,v3d);

            trq_elec=abs(trq);
            mech_power=trq_elec.*w;
            L_totalT1=L_elecT1;
            L_totalT2=L_elecT2;
            eff3dT1=100*abs(mech_power)./(L_totalT1+abs(mech_power));
            eff3dT2=100*abs(mech_power)./(L_totalT2+abs(mech_power));


            obj.plotdata.eff3dT1=eff3dT1;
            obj.plotdata.eff3dT2=eff3dT2;
            obj.plotdata.v_eff_vec_V=v_eff_vec_V;
            obj.plotdata.T_vec_K=T_vec_K;
        end

        function compute3DGridEfficiency_EffTab3DWithTemp(obj)


            data=obj.blockinfo.NumericData;
            w=obj.plotdata.wnd_radps;
            trq=obj.plotdata.trqnd_Nm;


            v_eff_vec_V=data.v_eff_vec_V;


            eff_mat_3D_T1=data.efficiency_mat_3D;
            eff_mat_3D_T2=data.efficiency_mat_3D_T2;
            w_eff_vec_rpm=data.w_eff_vec_rpm;
            w_eff_vec_radps=w_eff_vec_rpm*2*pi/60;
            trq_eff_vec_Nm=data.trq_eff_vec_Nm;
            Tmeas_K=data.Tmeas_K;
            Tmeas2_K=data.Tmeas2_K;
            T_vec_K=[Tmeas_K,Tmeas2_K];


            [wngrid,trqngrid,vngrid]=ndgrid(w_eff_vec_radps,trq_eff_vec_Nm,v_eff_vec_V);
            effInterpolantT1=griddedInterpolant(wngrid,trqngrid,vngrid,eff_mat_3D_T1,'linear','nearest');
            effInterpolantT2=griddedInterpolant(wngrid,trqngrid,vngrid,eff_mat_3D_T2,'linear','nearest');
            w3d=repmat(w,1,1,length(v_eff_vec_V));
            trq3d=repmat(trq,1,1,length(v_eff_vec_V));
            v3d=nan([size(w),length(v_eff_vec_V)]);
            for idz=1:length(v_eff_vec_V)
                v3d(:,:,idz)=v_eff_vec_V(idz);
            end
            eff_elecT1=effInterpolantT1(w3d,trq3d,v3d);
            eff_elecT2=effInterpolantT2(w3d,trq3d,v3d);


            eff3dT1=eff_elecT1;
            eff3dT2=eff_elecT2;


            obj.plotdata.eff3dT1=eff3dT1;
            obj.plotdata.eff3dT2=eff3dT2;
            obj.plotdata.v_eff_vec_V=v_eff_vec_V;
            obj.plotdata.T_vec_K=T_vec_K;

        end

    end


    methods(Access=public)

        function interpolatedPlotData=getInterpolatedPlotData(obj,voltage,temperature)

            if isfield(obj.plotdata,'eff2d')
                interpolatedPlotData=obj.getInterpolatedPlotData_Map2D(voltage);

            elseif isfield(obj.plotdata,'eff3d')
                interpolatedPlotData=obj.getInterpolatedPlotData_Map3DVoltage(voltage);

            elseif isfield(obj.plotdata,'eff2dT1')
                interpolatedPlotData=obj.getInterpolatedPlotData_Map3DTemp(voltage,temperature);

            elseif isfield(obj.plotdata,'eff3dT1')
                interpolatedPlotData=obj.getInterpolatedPlotData_Map4DVoltageTemp(voltage,temperature);

            end
        end

    end

    methods(Access=protected)

        function interpolatedPlotData=getInterpolatedPlotData_Map2D(obj,voltage)


            w=obj.plotdata.wnd_radps;
            wrpm=w*60/2/pi;
            w_rpm_vec=wrpm(:,1);
            trq=obj.plotdata.trqnd_Nm;
            torque_envelope_Nm=obj.plotdata.torque_envelope_Nm;
            overtorque_choice=obj.blockinfo.DropdownChoices.overtorque_param;
            torque_intermittent_envelope_Nm=obj.plotdata.torque_intermittent_envelope_Nm;
            eff=obj.plotdata.eff2d;



            if obj.blockinfo.DropdownChoices.torque_speed_param==ee.enum.electromech.envelope.tabulated2D
                v_vec=obj.plotdata.v_vec_V;
                torqueEnvelopeInterpolant=griddedInterpolant(v_vec,torque_envelope_Nm','linear','nearest');
                torque_envelope_Nm=torqueEnvelopeInterpolant(voltage);
                if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                    torqueIntermittentEnvelopeInterpolant=griddedInterpolant(v_vec,torque_intermittent_envelope_Nm','linear','nearest');
                    torque_intermittent_envelope_Nm=torqueIntermittentEnvelopeInterpolant(voltage);
                end
            end



            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)

                valid_region_mat=trq<torque_envelope_Nm';
            else
                valid_region_mat=trq<torque_intermittent_envelope_Nm';
            end


            effValid=valid_region_mat.*eff;


            interpolatedPlotData=struct();
            interpolatedPlotData.effValid=effValid;
            interpolatedPlotData.wrpm=wrpm;
            interpolatedPlotData.trq=trq;
            interpolatedPlotData.w_rpm_vec=w_rpm_vec;
            interpolatedPlotData.torque_envelope_Nm=torque_envelope_Nm;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                interpolatedPlotData.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;
            end

        end


        function interpolatedPlotData=getInterpolatedPlotData_Map3DVoltage(obj,voltage)


            w=obj.plotdata.wnd_radps;
            w_vec=w(:,1);
            wrpm=w*60/2/pi;
            w_rpm_vec=wrpm(:,1);
            trq=obj.plotdata.trqnd_Nm;
            trq_vec=obj.plotdata.trqnd_Nm(1,:);
            v_eff_vec=obj.plotdata.v_eff_vec_V;
            torque_envelope_Nm=obj.plotdata.torque_envelope_Nm;
            torque_intermittent_envelope_Nm=obj.plotdata.torque_intermittent_envelope_Nm;
            overtorque_choice=obj.blockinfo.DropdownChoices.overtorque_param;
            eff3d=obj.plotdata.eff3d;




            if obj.blockinfo.DropdownChoices.torque_speed_param==ee.enum.electromech.envelope.tabulated2D
                v_vec=obj.plotdata.v_vec_V;
                torqueEnvelopeInterpolant=griddedInterpolant(v_vec,torque_envelope_Nm','linear','nearest');
                torque_envelope_Nm=torqueEnvelopeInterpolant(voltage);
                if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                    torqueIntermittentEnvelopeInterpolant=griddedInterpolant(v_vec,torque_intermittent_envelope_Nm','linear','nearest');
                    torque_intermittent_envelope_Nm=torqueIntermittentEnvelopeInterpolant(voltage);
                end
            end



            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)

                valid_region_mat=trq<torque_envelope_Nm';
            else
                valid_region_mat=trq<torque_intermittent_envelope_Nm';
            end


            [wngrid,trqngrid,vngrid]=ndgrid(w_vec,trq_vec,v_eff_vec);
            effInterpolant=griddedInterpolant(wngrid,trqngrid,vngrid,eff3d,'linear','nearest');

            eff=effInterpolant(w,trq,voltage*ones(size(w)));


            effValid=valid_region_mat.*eff;


            interpolatedPlotData=struct();
            interpolatedPlotData.effValid=effValid;
            interpolatedPlotData.wrpm=wrpm;
            interpolatedPlotData.trq=trq;
            interpolatedPlotData.w_rpm_vec=w_rpm_vec;
            interpolatedPlotData.torque_envelope_Nm=torque_envelope_Nm;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                interpolatedPlotData.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;
            end

        end


        function interpolatedPlotData=getInterpolatedPlotData_Map3DTemp(obj,voltage,temperature)


            w=obj.plotdata.wnd_radps;
            w_vec=w(:,1);
            wrpm=w*60/2/pi;
            w_rpm_vec=wrpm(:,1);
            trq=obj.plotdata.trqnd_Nm;
            trq_vec=obj.plotdata.trqnd_Nm(1,:);
            torque_envelope_Nm=obj.plotdata.torque_envelope_Nm;
            overtorque_choice=obj.blockinfo.DropdownChoices.overtorque_param;
            torque_intermittent_envelope_Nm=obj.plotdata.torque_intermittent_envelope_Nm;
            eff2dT1=obj.plotdata.eff2dT1;
            eff2dT2=obj.plotdata.eff2dT2;
            T_vec_K=obj.plotdata.T_vec_K;



            if obj.blockinfo.DropdownChoices.torque_speed_param==ee.enum.electromech.envelope.tabulated2D
                v_vec=obj.plotdata.v_vec_V;
                torqueEnvelopeInterpolant=griddedInterpolant(v_vec,torque_envelope_Nm','linear','nearest');
                torque_envelope_Nm=torqueEnvelopeInterpolant(voltage);
                if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                    torqueIntermittentEnvelopeInterpolant=griddedInterpolant(v_vec,torque_intermittent_envelope_Nm','linear','nearest');
                    torque_intermittent_envelope_Nm=torqueIntermittentEnvelopeInterpolant(voltage);
                end
            end



            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)

                valid_region_mat=trq<torque_envelope_Nm';
            else
                valid_region_mat=trq<torque_intermittent_envelope_Nm';
            end


            eff3d(:,:,1)=eff2dT1;
            eff3d(:,:,2)=eff2dT2;

            [wngrid,trqngrid,Tngrid]=ndgrid(w_vec,trq_vec,T_vec_K);
            effInterpolant=griddedInterpolant(wngrid,trqngrid,Tngrid,eff3d,'linear','nearest');

            eff=effInterpolant(w,trq,temperature*ones(size(w)));


            effValid=valid_region_mat.*eff;


            interpolatedPlotData=struct();
            interpolatedPlotData.effValid=effValid;
            interpolatedPlotData.wrpm=wrpm;
            interpolatedPlotData.trq=trq;
            interpolatedPlotData.w_rpm_vec=w_rpm_vec;
            interpolatedPlotData.torque_envelope_Nm=torque_envelope_Nm;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                interpolatedPlotData.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;
            end

        end


        function interpolatedPlotData=getInterpolatedPlotData_Map4DVoltageTemp(obj,voltage,temperature)


            w=obj.plotdata.wnd_radps;
            w_vec=w(:,1);
            wrpm=w*60/2/pi;
            w_rpm_vec=wrpm(:,1);
            trq=obj.plotdata.trqnd_Nm;
            trq_vec=obj.plotdata.trqnd_Nm(1,:);
            torque_envelope_Nm=obj.plotdata.torque_envelope_Nm;
            overtorque_choice=obj.blockinfo.DropdownChoices.overtorque_param;
            torque_intermittent_envelope_Nm=obj.plotdata.torque_intermittent_envelope_Nm;
            eff3dT1=obj.plotdata.eff3dT1;
            eff3dT2=obj.plotdata.eff3dT2;
            v_eff_vec=obj.plotdata.v_eff_vec_V;
            T_vec_K=obj.plotdata.T_vec_K;




            if obj.blockinfo.DropdownChoices.torque_speed_param==ee.enum.electromech.envelope.tabulated2D
                v_vec=obj.plotdata.v_vec_V;
                torqueEnvelopeInterpolant=griddedInterpolant(v_vec,torque_envelope_Nm','linear','nearest');
                torque_envelope_Nm=torqueEnvelopeInterpolant(voltage);
                if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                    torqueIntermittentEnvelopeInterpolant=griddedInterpolant(v_vec,torque_intermittent_envelope_Nm','linear','nearest');
                    torque_intermittent_envelope_Nm=torqueIntermittentEnvelopeInterpolant(voltage);
                end
            end



            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)

                valid_region_mat=trq<torque_envelope_Nm';
            else
                valid_region_mat=trq<torque_intermittent_envelope_Nm';
            end


            eff4d(:,:,:,1)=eff3dT1;
            eff4d(:,:,:,2)=eff3dT2;

            [wngrid,trqngrid,vngrid,Tngrid]=ndgrid(w_vec,trq_vec,v_eff_vec,T_vec_K);
            effInterpolant=griddedInterpolant(wngrid,trqngrid,vngrid,Tngrid,eff4d,'linear','nearest');

            eff=effInterpolant(w,trq,voltage*ones(size(w)),temperature*ones(size(w)));


            effValid=valid_region_mat.*eff;


            interpolatedPlotData=struct();
            interpolatedPlotData.effValid=effValid;
            interpolatedPlotData.wrpm=wrpm;
            interpolatedPlotData.trq=trq;
            interpolatedPlotData.w_rpm_vec=w_rpm_vec;
            interpolatedPlotData.torque_envelope_Nm=torque_envelope_Nm;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                interpolatedPlotData.torque_intermittent_envelope_Nm=torque_intermittent_envelope_Nm;
            end

        end

    end

end


function paramValue=lgetValue(tableData,paramName,desiredUnit)
    originalParamValue=tableData{paramName,'Value'}{1};
    if isempty(originalParamValue)
        pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParam',...
        '[]',paramName);
    elseif~isnumeric(originalParamValue)
        pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_InvalidValueForParam',...
        string(originalParamValue),paramName);
    end
    originalUnit=tableData{paramName,'Unit'}{1};
    param=simscape.Value(originalParamValue,originalUnit);
    paramValue=param.value(desiredUnit);
end


function cntrlvls=computeContourLevels(effmat,npts)

    unqvals=sort(unique(round(effmat,5)));
    if numel(unqvals)<npts
        npts=numel(unqvals);
    end


    effMin=min(effmat(:));
    effMax=max(effmat(:));
    cntrlvls=unique([0,round(100-logspace(log10(100-effMin),log10(100-effMax),npts)),100]);


end
