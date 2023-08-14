classdef PSKModulator<matlab.system.SFunSystem&comm.internal.ConstellationBase




































































%#function mcomapskmod4

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ModulationOrder=8;



        PhaseOffset=pi/8;










        SymbolMapping='Gray';










        CustomSymbolMapping=0:7;



        OutputDataType='double';










        CustomOutputDataType=numerictype([],16);
















        BitInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryGrayCustom');
        OutputDataTypeSet=dsp.CommonSets.getSet('DoubleSingleUsr');
    end

    methods

        function obj=PSKModulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomapskmod4');
            setProperties(obj,nargin,varargin{:},'ModulationOrder','PhaseOffset');
            setEmptyAllowedStatus(obj,true);
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomOutputDataType=val;
        end

        function set.ModulationOrder(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','integer','>=',2},'',...
            'ModulationOrder');
            obj.ModulationOrder=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;
            symbolMappingIdx=getIndex(...
            obj.SymbolMappingSet,obj.SymbolMapping);
            dtInfo=getSourceDataTypeInfo(obj);



            if(symbolMappingIdx==3)
                status=commblkuserdefinedmapping(obj.ModulationOrder,...
                obj.CustomSymbolMapping,false);
                if~isempty(status.identifier)
                    coder.internal.errorIf(true,status.identifier);
                end
            end




            obj.compSetParameters({...
            obj.ModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.CustomSymbolMapping,...
            1,1,1,1,...
            obj.PhaseOffset,...
            zeros(obj.ModulationOrder,1),zeros(obj.ModulationOrder,1),1,...
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
            if~strcmp(obj.SymbolMapping,'Custom')
                props(end+1)={'CustomSymbolMapping'};
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props(end+1)={'CustomOutputDataType'};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/M-PSK Modulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'PhaseOffset',...
            'BitInput',...
            'SymbolMapping',...
            'CustomSymbolMapping',...
            'OutputDataType'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder','PhaseOffset'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.PSKModulator',...
            comm.PSKModulator.getDisplayFixedPointPropertiesImpl);
        end
    end

end

