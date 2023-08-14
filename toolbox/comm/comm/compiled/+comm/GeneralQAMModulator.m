classdef GeneralQAMModulator<matlab.system.SFunSystem


























































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        Constellation=exp(2*pi*1i*(0:7)/8);



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods
        function obj=GeneralQAMModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomapskmod4');
            setProperties(obj,nargin,varargin{:},'Constellation');
            setEmptyAllowedStatus(obj,true);
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomOutputDataType=val;
        end

        function set.Constellation(obj,val)
            validateattributes(val,{'double'},{},'','Constellation');
            obj.Constellation=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            dtInfo=getSourceDataTypeInfo(obj);

            obj.compSetParameters({4,2,1,0,1,1,1,1,0,...
            real(obj.Constellation),...
            imag(obj.Constellation),...
            5,...
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
                props={'CustomOutputDataType'};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.GeneralQAMModulator',...
            comm.GeneralQAMModulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/General QAM Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Constellation',...
            'OutputDataType'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'Constellation'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

