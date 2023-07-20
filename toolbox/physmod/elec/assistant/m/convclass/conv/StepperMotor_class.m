classdef StepperMotor_class<ConvClass&handle



    properties

        OldParam=struct(...
        'L',[],...
        'Lmax',[],...
        'Lmin',[],...
        'R',[],...
        'Step_angle',[],...
        'Psim',[],...
        'Tdm',[],...
        'J',[],...
        'B',[],...
        'w0',[],...
        'pos0',[],...
        'TsPowergui',[],...
        'TsBlock',[]...
        )


        OldDropdown=struct(...
        'MotorType',[],...
        'NumberOfPhases_1',[],...
        'NumberOfPhases_2',[],...
        'PresetModel_1',[],...
        'PresetModel_2',[]...
        )


        NewDirectParam=struct(...
        'Td',[],...
        'Step',[],...
        'J',[],...
        'D',[],...
        'wrm0',[],...
        'thm0',[],...
        'Rs',[]...
        )


        NewDerivedParam=struct(...
        'Ra',[],...
        'La',[],...
        'Km',[],...
        'nPoleRotor',[],...
        'xVec',[],...
        'iVec',[],...
        'FluxMatrix',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'MotorType','Permanent-magnet / Hybrid';'NumberOfPhases_1','2'},'PM2';...
        {'MotorType','Permanent-magnet / Hybrid';'NumberOfPhases_1','4'},'PM4';...
        {'MotorType','Variable reluctance';'NumberOfPhases_2','3'},'VR3';...
        {'MotorType','Variable reluctance';'NumberOfPhases_2','4'},'VR4';...
        {'MotorType','Variable reluctance';'NumberOfPhases_2','5'},'VR5';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Machines/Stepper Motor'
        NewPath='elec_conv_StepperMotor/StepperMotor'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Td=obj.OldParam.Tdm;
            obj.NewDirectParam.Step=obj.OldParam.Step_angle;
            obj.NewDirectParam.J=obj.OldParam.J;
            obj.NewDirectParam.D=obj.OldParam.B;
            obj.NewDirectParam.wrm0=obj.OldParam.w0;
            obj.NewDirectParam.thm0=obj.OldParam.pos0;
            obj.NewDirectParam.Rs=obj.OldParam.R;
        end


        function obj=StepperMotor_class(R,L,Step_angle,Psim,NumberOfPhases_1,MotorType,NumberOfPhases_2,Lmax,Lmin)
            if nargin>0
                obj.OldParam.R=R;
                obj.OldParam.L=L;
                obj.OldParam.Step_angle=Step_angle;
                obj.OldParam.Psim=Psim;
                obj.OldDropdown.NumberOfPhases_1=NumberOfPhases_1;
                obj.OldDropdown.MotorType=MotorType;
                obj.OldDropdown.NumberOfPhases_2=NumberOfPhases_2;
                obj.OldParam.Lmax=Lmax;
                obj.OldParam.Lmin=Lmin;
            end
        end

        function obj=objParamMappingDerived(obj)



            if strcmp(obj.OldDropdown.MotorType,'Permanent-magnet / Hybrid')&&strcmp(obj.OldDropdown.NumberOfPhases_1,'2')
                obj.NewDerivedParam.Ra=obj.OldParam.R;
                obj.NewDerivedParam.La=obj.OldParam.L;
            elseif strcmp(obj.OldDropdown.MotorType,'Permanent-magnet / Hybrid')&&strcmp(obj.OldDropdown.NumberOfPhases_1,'4')
                obj.NewDerivedParam.Ra=obj.OldParam.R/2;
                obj.NewDerivedParam.La=obj.OldParam.L/2;
            end

            step=obj.OldParam.Step_angle;
            phi=obj.OldParam.Psim;
            obj.NewDerivedParam.Km=(90/step)*phi;


            if strcmp(obj.OldDropdown.MotorType,'Variable reluctance')
                if strcmp(obj.OldDropdown.NumberOfPhases_2,'3')
                    nPoleRotor=360/(3*step);
                elseif strcmp(obj.OldDropdown.NumberOfPhases_2,'4')
                    nPoleRotor=360/(4*step);
                elseif strcmp(obj.OldDropdown.NumberOfPhases_2,'5')
                    nPoleRotor=360/(5*step);
                end
                obj.NewDerivedParam.nPoleRotor=nPoleRotor;

                if floor(360/nPoleRotor)~=360/nPoleRotor
                    AngleVector=[0:1:floor(360/nPoleRotor),360/nPoleRotor];
                else
                    AngleVector=(0:1:floor(360/nPoleRotor));
                end
                obj.NewDerivedParam.xVec=AngleVector;

                MaxCurrent=50;
                CurrentVector=linspace(0,MaxCurrent,MaxCurrent+1);
                obj.NewDerivedParam.iVec=CurrentVector;


                L0=0.5*(obj.OldParam.Lmax+obj.OldParam.Lmin);
                Lmag=0.5*(obj.OldParam.Lmax-obj.OldParam.Lmin);
                LVector=L0+Lmag*cosd(AngleVector*nPoleRotor);


                FluxMatrix=CurrentVector'*LVector;
                FluxMatrix(:,end)=FluxMatrix(:,1);
                obj.NewDerivedParam.FluxMatrix=FluxMatrix;
            end


        end

        function obj=objDropdownMapping(obj)

        end
    end

end
