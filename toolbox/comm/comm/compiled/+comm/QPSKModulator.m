classdef QPSKModulator<matlab.system.SFunSystem&comm.internal.ConstellationBase





























































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        PhaseOffset=pi/4;







        SymbolMapping='Gray';



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);














        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods

        function obj=QPSKModulator(varargin)
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
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;
            symbolMappingIdx=getIndex(...
            obj.SymbolMappingSet,obj.SymbolMapping);
            dtInfo=getSourceDataTypeInfo(obj);




            obj.compSetParameters({...
            4,...
            inputFormatIdx,...
            symbolMappingIdx,...
            0:3,...
            1,1,1,1,...
            obj.PhaseOffset,...
            zeros(4,1),zeros(4,1),1,...
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
            a='commdigbbndpm3/QPSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseOffset',...
            'BitInput',...
            'SymbolMapping',...
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






            matlab.system.dispFixptHelp('comm.QPSKModulator',...
            comm.QPSKModulator.getDisplayFixedPointPropertiesImpl);
        end
    end
end
