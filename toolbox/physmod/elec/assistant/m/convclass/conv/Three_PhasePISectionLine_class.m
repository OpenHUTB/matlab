classdef Three_PhasePISectionLine_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Frequency',[],...
        'Resistances',[],...
        'Inductances',[],...
        'Capacitances',[],...
        'Length',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'length',[]...
        )


        NewDerivedParam=struct(...
        'R',[],...
        'Rm',[],...
        'L',[],...
        'M',[],...
        'Cl',[],...
        'Cg',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase PI Section Line'
        NewPath='elec_conv_Three_PhasePISectionLine/Three_PhasePISectionLine'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.length=obj.OldParam.Length;
        end


        function obj=Three_PhasePISectionLine_class(Resistances,Inductances,Capacitances)
            if nargin>0
                obj.OldParam.Resistances=Resistances;
                obj.OldParam.Inductances=Inductances;
                obj.OldParam.Capacitances=Capacitances;
            end
        end

        function obj=objParamMappingDerived(obj)

            R0=obj.OldParam.Resistances(2);
            R1=obj.OldParam.Resistances(1);
            L0=obj.OldParam.Inductances(2);
            L1=obj.OldParam.Inductances(1);
            C0=obj.OldParam.Capacitances(2);
            C1=obj.OldParam.Capacitances(1);
            obj.NewDerivedParam.R=(2*R1+R0)/3;
            obj.NewDerivedParam.Rm=(R0-R1)/3;
            obj.NewDerivedParam.L=(2*L1+L0)/3;
            obj.NewDerivedParam.M=(L0-L1)/3;
            obj.NewDerivedParam.Cl=(C1-C0)/3;
            obj.NewDerivedParam.Cg=C0;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','The line current might start from an undesired value.');
            logObj.addMessage(obj,'CustomMessage','Please select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');

        end
    end

end
