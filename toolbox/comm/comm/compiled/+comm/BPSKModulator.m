classdef BPSKModulator<matlab.system.SFunSystem&comm.internal.ConstellationBase


























































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        PhaseOffset=0;



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods

        function obj=BPSKModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomapskmod4');
            setProperties(obj,nargin,varargin{:},'PhaseOffset');
            setEmptyAllowedStatus(obj,true);
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomOutputDataType=val;
        end

        function set.PhaseOffset(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite'},'',...
            'PhaseOffset');
            obj.PhaseOffset=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            dtInfo=getSourceDataTypeInfo(obj);




            obj.compSetParameters({...
            2,...
            2,...
            2,...
            0:1,...
            1,1,1,1,...
            obj.PhaseOffset,...
            zeros(2,1),zeros(2,1),1,...
            dtInfo.Id,...
            dtInfo.WordLength,...
            dtInfo.IsScaled+1,...
            dtInfo.FractionLength...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props(end+1)={'CustomOutputDataType'};
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/BPSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseOffset',...
            'OutputDataType'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'PhaseOffset'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.BPSKModulator',...
            comm.BPSKModulator.getDisplayFixedPointPropertiesImpl);
        end
    end
end

