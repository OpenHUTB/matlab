classdef RectangularQAMModulator<matlab.system.SFunSystem&comm.internal.ConstellationBase










































































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ModulationOrder=16;



        PhaseOffset=0;









        SymbolMapping='Gray';









        CustomSymbolMapping=0:15;




        NormalizationMethod='Minimum distance between symbols';





        MinimumDistance=2;




        AveragePower=1;




        PeakPower=1;



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);















        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryGrayCustom');
        NormalizationMethodSet=comm.CommonSets.getSet('NormalizationMethods');
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods
        function obj=RectangularQAMModulator(varargin)
            warning(message('comm:shared:willBeRemovedReplacementRef',...
            'COMM.RECTANGULARQAMMODULATOR','QAMMOD',...
            'REMOVE_RectangularQAMModulator'));
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
            symbolMappingIdx=...
            getIndex(obj.SymbolMappingSet,...
            obj.SymbolMapping);
            normalizationMethodIdx=getIndex(obj.NormalizationMethodSet,...
            obj.NormalizationMethod);

            dtInfo=getSourceDataTypeInfo(obj);

            if(symbolMappingIdx==3)
                status=commblkuserdefinedmapping(obj.ModulationOrder,obj.CustomSymbolMapping,true);
                if~isempty(status.identifier)
                    coder.internal.errorIf(true,status.identifier);
                end
            end




            obj.compSetParameters({...
            obj.ModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.CustomSymbolMapping,...
            normalizationMethodIdx,...
            obj.MinimumDistance,...
            obj.AveragePower,...
            obj.PeakPower,...
            obj.PhaseOffset,...
            0,0,4,...
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
            if~strcmp(obj.SymbolMapping,'Custom')
                props{end+1}='CustomSymbolMapping';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props{end+1}='CustomOutputDataType';
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/Rectangular QAM Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'PhaseOffset',...
            'BitInput',...
            'SymbolMapping',...
            'CustomSymbolMapping',...
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






            matlab.system.dispFixptHelp('comm.RectangularQAMModulator',...
            comm.RectangularQAMModulator.getDisplayFixedPointPropertiesImpl);
        end
    end
end

