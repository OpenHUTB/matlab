classdef Three_PhaseMutualInducta_class<ConvClass&handle



    properties

        OldParam=struct(...
        'PositiveSequence',[],...
        'ZeroSequence',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'L',[],...
        'Lm',[],...
        'R',[],...
        'Rm',[]...
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
        OldPath='powerlib/Elements/Three-Phase Mutual Inductance Z1-Z0'
        NewPath='elec_conv_Three_PhaseMutualInducta/Three_PhaseMutualInducta'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=Three_PhaseMutualInducta_class(PositiveSequence,ZeroSequence)
            if nargin>0
                obj.OldParam.PositiveSequence=PositiveSequence;
                obj.OldParam.ZeroSequence=ZeroSequence;
            end
        end

        function obj=objParamMappingDerived(obj)

            R1=obj.OldParam.PositiveSequence(1);
            L1=obj.OldParam.PositiveSequence(2);
            R0=obj.OldParam.ZeroSequence(1);
            L0=obj.OldParam.ZeroSequence(2);

            obj.NewDerivedParam.L=(L0+2*L1)/3;
            obj.NewDerivedParam.Lm=(L0-L1)/3;
            obj.NewDerivedParam.R=(R0+2*R1)/3;
            obj.NewDerivedParam.Rm=(R0-R1)/3;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
            logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');

        end
    end

end
