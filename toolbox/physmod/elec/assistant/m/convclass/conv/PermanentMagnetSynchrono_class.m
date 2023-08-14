classdef PermanentMagnetSynchrono_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Resistance',[],...
        'Inductance',[],...
        'dqInductances',[],...
        'La',[],...
        'Flux',[],...
        'VoltageCst',[],...
        'TorqueCst',[],...
        'Flat',[],...
        'Mechanical',[],...
        'PolePairs',[],...
        'InitialConditions',[],...
        'InitialConditions5ph',[],...
        'TsPowergui',[],...
        'TsBlock',[]...
        )


        OldDropdown=struct(...
        'NbPhases',[],...
        'FluxDistribution',[],...
        'RotorType',[],...
        'MechanicalLoad',[],...
        'PresetModel',[],...
        'MachineConstant',[],...
        'RefAngle',[],...
        'ShowDetailedParameters',[],...
        'MeasurementBus',[]...
        )


        NewDirectParam=struct(...
        'Ld',[],...
        'Lq',[],...
        'L0',[],...
        'nPolePairs',[],...
        'Rs',[],...
        'J',[],...
        'lam',[],...
        'angular_velocity',[],...
        'angular_position',[]...
        )


        NewDerivedParam=struct(...
        'Tf',[],...
        'pm_flux_linkage',[],...
        'theta_constant',[],...
        'i_d',[],...
        'i_q',[],...
        'i_x',[],...
        'i_y',[],...
        'AngleOffset',[],...
        'AngleOffsetTrap',[],...
        'TrapLUTAngle',[],...
        'TrapLUTdPhidt',[]...
        )


        NewDropdown=struct(...
        'pmflux_param',[],...
        'stator_param',[],...
        'zero_sequence',[],...
        'axes_param',[],...
        'AxisAlignment',[],...
        'rotor_param',[],...
        'angular_velocity_priority',[]...
        )


        BlockOption={...
        {'NbPhases','3';'MechanicalLoad','Torque Tm';'FluxDistribution','Sinusoidal'},'TmSine';...
        {'NbPhases','3';'MechanicalLoad','Torque Tm';'FluxDistribution','Trapezoidal'},'TmTrap';...
        {'NbPhases','3';'MechanicalLoad','Speed w';'FluxDistribution','Sinusoidal'},'wSine';...
        {'NbPhases','3';'MechanicalLoad','Speed w';'FluxDistribution','Trapezoidal'},'wTrap';...
        {'NbPhases','3';'MechanicalLoad','Mechanical rotational port';'FluxDistribution','Sinusoidal'},'RotationalPortSine';...
        {'NbPhases','3';'MechanicalLoad','Mechanical rotational port';'FluxDistribution','Trapezoidal'},'RotationalPortTrap';...
        {'NbPhases','5';'MechanicalLoad','Torque Tm'},'TmFive';...
        {'NbPhases','5';'MechanicalLoad','Speed w'},'wFive';...
        {'NbPhases','5';'MechanicalLoad','Mechanical rotational port'},'RotationalPortFive';...
        {},'Others';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Machines/Permanent Magnet Synchronous Machine'
        NewPath='elec_conv_PermanentMagnetSynchrono/PermanentMagnetSynchrono'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.L0=1e-9;
            obj.NewDirectParam.Rs=obj.OldParam.Resistance;

            if strcmp(obj.OldDropdown.NbPhases,'3')
                switch obj.OldDropdown.FluxDistribution
                case 'Sinusoidal'
                    switch obj.OldDropdown.RotorType
                    case 'Salient-pole'
                        obj.NewDirectParam.Ld=ConvClass.mapDirect(obj.OldParam.dqInductances,1);
                        obj.NewDirectParam.Lq=ConvClass.mapDirect(obj.OldParam.dqInductances,2);
                    case 'Round'
                        obj.NewDirectParam.Ld=obj.OldParam.La;
                        obj.NewDirectParam.Lq=obj.OldParam.La;
                    end
                case 'Trapezoidal'
                    obj.NewDirectParam.Ld=obj.OldParam.Inductance;
                    obj.NewDirectParam.Lq=obj.OldParam.Inductance;
                end
                obj.NewDirectParam.angular_velocity=ConvClass.mapDirect(obj.OldParam.InitialConditions,1);
                obj.NewDirectParam.angular_position=ConvClass.mapDirect(obj.OldParam.InitialConditions,2);
            else
                obj.NewDirectParam.Ld=obj.OldParam.La;
                obj.NewDirectParam.Lq=obj.OldParam.La;
                obj.NewDirectParam.angular_velocity=ConvClass.mapDirect(obj.OldParam.InitialConditions5ph,1);
                obj.NewDirectParam.angular_position=ConvClass.mapDirect(obj.OldParam.InitialConditions5ph,2);
            end

            switch obj.OldDropdown.MechanicalLoad
            case{'Torque Tm','Mechanical rotational port'}
                obj.NewDirectParam.J=ConvClass.mapDirect(obj.OldParam.Mechanical,1);
                obj.NewDirectParam.lam=ConvClass.mapDirect(obj.OldParam.Mechanical,2);
                obj.NewDirectParam.nPolePairs=ConvClass.mapDirect(obj.OldParam.Mechanical,3);
            case 'Speed w'
                obj.NewDirectParam.nPolePairs=obj.OldParam.PolePairs;
            end
        end


        function obj=PermanentMagnetSynchrono_class(MechanicalLoad,Mechanical,PolePairs,MachineConstant,...
            Flux,VoltageCst,TorqueCst,RefAngle,InitialConditions,...
            FluxDistribution,Flat,NbPhases,InitialConditions5ph)
            if nargin>0
                obj.OldDropdown.MechanicalLoad=MechanicalLoad;
                obj.OldParam.Mechanical=Mechanical;
                obj.OldParam.PolePairs=PolePairs;
                obj.OldDropdown.MachineConstant=MachineConstant;
                obj.OldParam.Flux=Flux;
                obj.OldParam.VoltageCst=VoltageCst;
                obj.OldParam.TorqueCst=TorqueCst;
                obj.OldDropdown.RefAngle=RefAngle;
                obj.OldParam.InitialConditions=InitialConditions;
                obj.OldDropdown.FluxDistribution=FluxDistribution;
                obj.OldParam.Flat=Flat;
                obj.OldDropdown.NbPhases=NbPhases;
                obj.OldParam.InitialConditions5ph=InitialConditions5ph;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.MechanicalLoad
            case 'Torque Tm'
                nPolePairs=obj.OldParam.Mechanical(3);
            case{'Speed w','Mechanical rotational port'}
                nPolePairs=obj.OldParam.PolePairs;
            end

            if strcmp(obj.OldDropdown.MechanicalLoad,'Torque Tm')||...
                strcmp(obj.OldDropdown.MechanicalLoad,'Mechanical rotational port')
                if size(obj.OldParam.Mechanical,2)==4
                    obj.NewDerivedParam.Tf=obj.OldParam.Mechanical(4);
                else
                    obj.NewDerivedParam.Tf=0;
                end
            end

            switch obj.OldDropdown.RefAngle
            case '90 degrees behind phase A axis (modified Park)'
                rotor_offset=-pi/2;
                obj.NewDerivedParam.AngleOffset=0;
                obj.NewDerivedParam.AngleOffsetTrap=-pi/2;
            case 'Aligned with phase A axis (original Park)'
                rotor_offset=0;
                obj.NewDerivedParam.AngleOffset=pi/2;
                obj.NewDerivedParam.AngleOffsetTrap=0;
            end

            if strcmp(obj.OldDropdown.NbPhases,'3')

                switch obj.OldDropdown.FluxDistribution
                case 'Sinusoidal'
                    switch obj.OldDropdown.MachineConstant
                    case 'Flux linkage established by magnets (V.s)'
                        x_flux=obj.OldParam.Flux;
                    case 'Voltage Constant (V_peak L-L / krpm)'
                        x_flux=obj.OldParam.VoltageCst*60/(2*pi*1000*nPolePairs*sqrt(3));
                    case 'Torque Constant (N.m / A_peak)'
                        x_flux=obj.OldParam.TorqueCst*2/(3*nPolePairs);
                    end
                    obj.NewDerivedParam.pm_flux_linkage=x_flux;

                case 'Trapezoidal'
                    switch obj.OldDropdown.MachineConstant
                    case 'Flux linkage established by magnets (V.s)'
                        h=obj.OldParam.Flux;
                    case 'Voltage Constant (V_peak L-L / krpm)'
                        h=obj.OldParam.VoltageCst*60/(2*pi*1000*nPolePairs*2);
                    case 'Torque Constant (N.m / A_peak)'
                        h=obj.OldParam.TorqueCst/(2*nPolePairs);
                    end
                    ThetaF=obj.OldParam.Flat;
                    ThetaW=(180-obj.OldParam.Flat)/2;
                    obj.NewDerivedParam.pm_flux_linkage=(h/2)*(ThetaW+ThetaF)*pi/180;
                    obj.NewDerivedParam.theta_constant=obj.OldParam.Flat/nPolePairs;
                    obj.NewDerivedParam.TrapLUTAngle=[-ThetaW,0,ThetaW,ThetaW+ThetaF,180+ThetaW,360-ThetaW,360,360+ThetaW];
                    obj.NewDerivedParam.TrapLUTdPhidt=[h,0,-h,-h,h,h,0,-h];
                end


                InitialElecAngle=obj.OldParam.InitialConditions(2)*nPolePairs*(pi/180);
                shift_3ph=[0,-2*pi/3,2*pi/3];
                electrical_angle_vec_dq=rotor_offset+shift_3ph+InitialElecAngle;
                abc2d=(2/3)*cos(electrical_angle_vec_dq);
                abc2q=-(2/3)*sin(electrical_angle_vec_dq);
                ia=obj.OldParam.InitialConditions(3);
                ib=obj.OldParam.InitialConditions(4);
                ic=-ia-ib;
                obj.NewDerivedParam.i_d=abc2d*[ia;ib;ic];
                obj.NewDerivedParam.i_q=abc2q*[ia;ib;ic];

            else
                switch obj.OldDropdown.MachineConstant
                case 'Flux linkage established by magnets (V.s)'
                    x_flux=obj.OldParam.Flux;
                case 'Voltage Constant (V_peak L-L / krpm)'
                    x_flux=obj.OldParam.VoltageCst*60/(2*pi*1000*nPolePairs*2*sin(pi/5));
                case 'Torque Constant (N.m / A_peak)'
                    x_flux=obj.OldParam.TorqueCst*2/(5*nPolePairs);
                end
                obj.NewDerivedParam.pm_flux_linkage=x_flux;


                InitialElecAngle=obj.OldParam.InitialConditions5ph(2)*nPolePairs*(pi/180);
                shift_5ph_dq=[0,-2*pi/5,-4*pi/5,4*pi/5,2*pi/5];
                shift_5ph_xy=[0,4*pi/5,-2*pi/5,2*pi/5,-4*pi/5];
                electrical_angle_vec_dq=rotor_offset+shift_5ph_dq+InitialElecAngle;
                electrical_angle_vec_xy=rotor_offset+shift_5ph_xy+InitialElecAngle;
                abcde2d=(2/5)*cos(electrical_angle_vec_dq);
                abcde2q=-(2/5)*sin(electrical_angle_vec_dq);
                abcde2x=(2/5)*cos(electrical_angle_vec_xy);
                abcde2y=-(2/5)*sin(electrical_angle_vec_xy);
                ia=obj.OldParam.InitialConditions5ph(3);
                ib=obj.OldParam.InitialConditions5ph(4);
                ic=obj.OldParam.InitialConditions5ph(5);
                id=obj.OldParam.InitialConditions5ph(6);
                ie=-ia-ib-ic-id;
                obj.NewDerivedParam.i_d=abcde2d*[ia;ib;ic;id;ie];
                obj.NewDerivedParam.i_q=abcde2q*[ia;ib;ic;id;ie];
                obj.NewDerivedParam.i_x=abcde2x*[ia;ib;ic;id;ie];
                obj.NewDerivedParam.i_y=abcde2y*[ia;ib;ic;id;ie];
            end


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if~strcmp(obj.OldDropdown.PresetModel,'No')
                logObj.addMessage(obj,'OptionNotSupported','Preset Model','Preset Models');
            end

            switch obj.OldDropdown.RefAngle
            case '90 degrees behind phase A axis (modified Park)'
                obj.NewDropdown.axes_param='1';
                obj.NewDropdown.AxisAlignment='Q-axis';
            case 'Aligned with phase A axis (original Park)'
                obj.NewDropdown.axes_param='2';
                obj.NewDropdown.AxisAlignment='D-axis';
            end

            switch obj.OldDropdown.MechanicalLoad
            case 'Torque Tm'
                obj.NewDropdown.angular_velocity_priority='High';
            case 'Speed w'
                obj.NewDropdown.angular_velocity_priority='None';
            otherwise
                obj.NewDropdown.angular_velocity_priority='Low';
            end

            obj.NewDropdown.zero_sequence='0';
            obj.NewDropdown.stator_param='1';
            obj.NewDropdown.rotor_param='1';
            obj.NewDropdown.pmflux_param='1';
        end
    end

end
