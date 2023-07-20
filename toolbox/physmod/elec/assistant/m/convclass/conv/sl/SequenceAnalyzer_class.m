classdef SequenceAnalyzer_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'n',[],...
        'InInit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'seq',[]...
        )


        NewDirectParam=struct(...
        'F',[],...
        'K',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'Seq',[]...
        )


        BlockOption={...
        {'seq','Positive Negative Zero'},'All';...
        {'seq','Positive'},'Single';...
        {'seq','Negative'},'Single';...
        {'seq','Zero'},'Single';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Measurements/Sequence Analyzer'
        NewPath='elec_conv_sl_SequenceAnalyzer/SequenceAnalyzer'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.F=obj.OldParam.Freq;
            obj.NewDirectParam.K=obj.OldParam.n;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=SequenceAnalyzer_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)


            switch obj.OldDropdown.seq
            case 'Positive'
                obj.NewDropdown.Seq='Positive';
            case 'Negative'
                obj.NewDropdown.Seq='Negative';
            case 'Zero'
                obj.NewDropdown.Seq='Zero';
            case 'Positive Negative Zero'

            end
        end
    end

end
