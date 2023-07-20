classdef PAMModulator<matlab.system.SFunSystem&comm.internal.ConstellationBase







































































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        ModulationOrder=4;







        SymbolMapping='Gray';




        NormalizationMethod='Minimum distance between symbols';





        MinimumDistance=2;




        AveragePower=1;




        PeakPower=1;



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);















        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        NormalizationMethodSet=comm.CommonSets.getSet...
        ('NormalizationMethods');
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods

        function obj=PAMModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomapskmod4');
            setProperties(obj,nargin,varargin{:},'ModulationOrder');
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
            normalizationMethodIdx=getIndex(obj.NormalizationMethodSet,...
            obj.NormalizationMethod);
            dtInfo=getSourceDataTypeInfo(obj);




            obj.compSetParameters({...
            obj.ModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            0,...
            normalizationMethodIdx,...
            obj.MinimumDistance,...
            obj.AveragePower,...
            obj.PeakPower,...
            0,0,0,3,...
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
            switch obj.NormalizationMethod
            case 'Minimum distance between symbols'
                props={'AveragePower','PeakPower'};
            case 'Average power'
                props={'MinimumDistance','PeakPower'};
            case 'Peak power'
                props={'MinimumDistance','AveragePower'};
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props(end+1)={'CustomOutputDataType'};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/M-PAM Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'BitInput',...
            'SymbolMapping',...
            'NormalizationMethod',...
            'MinimumDistance',...
            'AveragePower',...
            'PeakPower',...
            'OutputDataType'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.PAMModulator',...
            comm.PAMModulator.getDisplayFixedPointPropertiesImpl);
        end
    end
end

