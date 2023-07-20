classdef SwitchedReluctanceMotor_class<ConvClass&handle



    properties

        OldParam=struct(...
        'StatorResistance',[],...
        'Inertia',[],...
        'Friction',[],...
        'InitialSpeed',[],...
        'TsPowergui',[],...
        'TsBlock',[],...
        'Lq',[],...
        'Ld',[],...
        'Lsat',[],...
        'MaximumCurrent',[],...
        'MaximumFluxLinkage',[],...
        'MagnetisationCharacteristic',[],...
        'RotorAngleVector',[],...
        'StatorCurrentVector',[]...
        )


        OldDropdown=struct(...
        'MachineType',[],...
        'MachineModel',[],...
        'Source',[],...
        'PlotCurves',[]...
        )


        NewDirectParam=struct(...
        'nPoleRotor',[],...
        'Rs',[],...
        'psi_sat',[],...
        'Lmax',[],...
        'Lmin',[],...
        'J',[],...
        'D',[],...
        'wrm0',[],...
        'thm0',[]...
        )


        NewDerivedParam=struct(...
        'iVec',[],...
        'xVec',[],...
        'FluxMatrix',[]...
        )


        NewDropdown=struct(...
        'stator_param',[]...
        )


        BlockOption={...
        {'MachineType','6/4'},'threePhase';...
        {'MachineType','8/6'},'fourPhase';...
        {'MachineType','10/8'},'fivePhase';...
        {'MachineType','6/4  (60 kw preset model)'},'threePhase';...
        {'MachineType','8/6  (75 kw preset model)'},'fourPhase';...
        {'MachineType','10/8  (10 kw preset model)'},'fivePhase';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Machines/Switched Reluctance Motor'
        NewPath='elec_conv_SwitchedReluctanceMotor/SwitchedReluctanceMotor'
    end

    methods
        function obj=objParamMappingDirect(obj)
            switch obj.OldDropdown.MachineType
            case{'6/4','6/4  (60 kw preset model)'}
                obj.NewDirectParam.nPoleRotor=4;
            case{'8/6','8/6  (75 kw preset model)'}
                obj.NewDirectParam.nPoleRotor=6;
            case{'10/8','10/8  (10 kw preset model)'}
                obj.NewDirectParam.nPoleRotor=8;
            end

            obj.NewDirectParam.Rs=obj.OldParam.StatorResistance;
            obj.NewDirectParam.psi_sat=obj.OldParam.MaximumFluxLinkage;
            obj.NewDirectParam.Lmax=obj.OldParam.Ld;
            obj.NewDirectParam.Lmin=obj.OldParam.Lq;
            obj.NewDirectParam.J=obj.OldParam.Inertia;
            obj.NewDirectParam.D=obj.OldParam.Friction;
            obj.NewDirectParam.wrm0=ConvClass.mapDirect(obj.OldParam.InitialSpeed,1);
            obj.NewDirectParam.thm0=ConvClass.mapDirect(obj.OldParam.InitialSpeed,2);
        end


        function obj=SwitchedReluctanceMotor_class(MachineType,MachineModel,MagnetisationCharacteristic,StatorCurrentVector,RotorAngleVector,Source)
            if nargin>0
                obj.OldDropdown.MachineType=MachineType;
                obj.OldDropdown.MachineModel=MachineModel;
                obj.OldParam.MagnetisationCharacteristic=MagnetisationCharacteristic;
                obj.OldParam.StatorCurrentVector=StatorCurrentVector;
                obj.OldParam.RotorAngleVector=RotorAngleVector;
                obj.OldDropdown.Source=Source;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.MachineType
            case{'6/4','8/6','10/8'}
                switch obj.OldDropdown.Source
                case 'MAT-file'
                    data=load(obj.OldParam.MagnetisationCharacteristic);
                    x_FluxMatrix=data.FTBL;
                    x_iVec=data.StatorCurrent;
                    x_xVec=data.RotorAngle;
                case 'Dialog'
                    x_FluxMatrix=obj.OldParam.MagnetisationCharacteristic;
                    x_iVec=obj.OldParam.StatorCurrentVector;
                    x_xVec=obj.OldParam.RotorAngleVector;
                end
            case '6/4  (60 kw preset model)'
                data=load('srm64_60kw.mat');
                x_FluxMatrix=data.FTBL;
                x_iVec=data.StatorCurrent;
                x_xVec=data.RotorAngle;
            case '8/6  (75 kw preset model)'
                data=load('srm86_75kw.mat');
                x_FluxMatrix=data.FTBL;
                x_iVec=data.StatorCurrent;
                x_xVec=data.RotorAngle;
            case '10/8  (10 kw preset model)'
                data=load('srm108_10kw.mat');
                x_FluxMatrix=data.FTBL;
                x_iVec=data.StatorCurrent;
                x_xVec=data.RotorAngle;
            end

            if(strcmp(obj.OldDropdown.MachineType,'6/4')&&strcmp(obj.OldDropdown.MachineModel,'Specific model'))||...
                (strcmp(obj.OldDropdown.MachineType,'8/6')&&strcmp(obj.OldDropdown.MachineModel,'Specific model'))||...
                (strcmp(obj.OldDropdown.MachineType,'10/8')&&strcmp(obj.OldDropdown.MachineModel,'Specific model'))||...
                strcmp(obj.OldDropdown.MachineType,'6/4  (60 kw preset model)')||...
                strcmp(obj.OldDropdown.MachineType,'8/6  (75 kw preset model)')||...
                strcmp(obj.OldDropdown.MachineType,'10/8  (10 kw preset model)')


                switch obj.OldDropdown.MachineType
                case{'6/4','6/4  (60 kw preset model)'}
                    new_xVec=linspace(0,360/4/2,91);
                case{'8/6','8/6  (75 kw preset model)'}
                    new_xVec=linspace(0,360/6/2,91);
                case{'10/8','10/8  (10 kw preset model)'}
                    new_xVec=linspace(0,360/8/2,91);
                end


                new_iVec=linspace(0,max(x_iVec),101);


                new_FM=zeros(length(x_iVec),length(new_xVec));
                for temp=1:length(x_iVec)
                    new_FM(temp,:)=spline(x_xVec,[0,x_FluxMatrix(temp,:),0],new_xVec);
                end
                new_FluxMatrix=interp1(x_iVec,new_FM,new_iVec,'pchip');

                obj.NewDerivedParam.FluxMatrix=[new_FluxMatrix(:,1:end-1),flip(new_FluxMatrix,2)];
                obj.NewDerivedParam.iVec=new_iVec;
                obj.NewDerivedParam.xVec=[new_xVec(1:end-1),2*new_xVec(end)-flip(new_xVec)];
            end



        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.PlotCurves,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Plot magnetization curves');
            end

            switch obj.OldDropdown.MachineType
            case '6/4'
                switch obj.OldDropdown.MachineModel
                case 'Generic model'
                    obj.NewDropdown.stator_param='1';
                case 'Specific model'
                    obj.NewDropdown.stator_param='3';
                end
            case{'8/6','10/8'}
                switch obj.OldDropdown.MachineModel
                case 'Generic model'
                    obj.NewDropdown.stator_param='1';
                case 'Specific model'
                    obj.NewDropdown.stator_param='2';
                end
            case '6/4  (60 kw preset model)'
                obj.NewDropdown.stator_param='3';
            case{'8/6  (75 kw preset model)','10/8  (10 kw preset model)'}
                obj.NewDropdown.stator_param='2';
            end

        end
    end

end
