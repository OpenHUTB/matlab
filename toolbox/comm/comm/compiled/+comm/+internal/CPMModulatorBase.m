classdef CPMModulatorBase<matlab.system.SFunSystem





%#function mcomcpmmod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        InitialPhaseOffset=0;





        SamplesPerSymbol=8;



        OutputDataType='double';
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=comm.CommonSets.getSet('DoubleOrSingle');
    end

    properties(Hidden,SetAccess=protected,Nontunable)


        pFrequencyPulse='Rectangular';
    end
    properties(Access=protected,Nontunable)
        pModulationOrder=4;
        pSymbolMapping='Binary';
        pModulationIndex=0.5;
        pMainLobeDuration=1;
        pRolloffFactor=0.2;
        pBandwidthTimeProduct=0.3;
        pPulseLength=1;
        pSymbolPrehistory=1;
    end
    properties(Abstract,Nontunable)


        BitInput(1,1)logical
    end

    properties(Access=private)
        pFrequencyPulseSet=comm.CommonSets.getSet('FrequencyPulseShapes');
        pSymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods(Access=protected)
        function obj=CPMModulatorBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomcpmmod');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods
        function set.SamplesPerSymbol(obj,val)


            validateattributes(val,{'double'},...
            {'real','scalar','positive','integer'},'',...
            'SamplesPerSymbol');
            obj.SamplesPerSymbol=val;
        end

        function set.InitialPhaseOffset(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','finite'},'',...
            'InitialPhaseOffset');
            obj.InitialPhaseOffset=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            inputFormatIdx=~obj.BitInput+1;

            frequencyPulseIdx=getIndex(obj.pFrequencyPulseSet,...
            obj.pFrequencyPulse);

            symbolMappingIdx=getIndex(...
            obj.pSymbolMappingSet,obj.pSymbolMapping);

            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);

            [eStr,params]=commblkcpmmod(obj,'init',...
            obj.pBandwidthTimeProduct,...
            obj.pMainLobeDuration,...
            obj.pRolloffFactor,...
            obj.pPulseLength,...
            obj.SamplesPerSymbol...
            );
            if eStr.ecode~=0
                colons=coder.internal.const(strfind(eStr.eID,':'));
                final_token=eStr.eID(colons(end)+1:end);
                coder.internal.errorIf(true,['comm:system:cpmmodulator:',final_token]);
            end





            obj.compSetParameters({...
            obj.pModulationOrder,...
            inputFormatIdx,...
            symbolMappingIdx,...
            obj.pModulationIndex,...
            frequencyPulseIdx,...
            obj.pBandwidthTimeProduct,...
            obj.pMainLobeDuration,...
            obj.pRolloffFactor,...
            obj.pPulseLength,...
            obj.InitialPhaseOffset,...
            obj.SamplesPerSymbol,...
            1,...
            params.gMod,...
            obj.pSymbolPrehistory,...
            0,...
            outputDataTypeIdx,...
            });
        end
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);
            s.pModulationOrder=obj.pModulationOrder;
            s.pSymbolMapping=obj.pSymbolMapping;
            s.pModulationIndex=obj.pModulationIndex;
            s.pMainLobeDuration=obj.pMainLobeDuration;
            s.pRolloffFactor=obj.pRolloffFactor;
            s.pBandwidthTimeProduct=obj.pBandwidthTimeProduct;
            s.pPulseLength=obj.pPulseLength;
            s.pSymbolPrehistory=obj.pSymbolPrehistory;
            s.pFrequencyPulse=obj.pFrequencyPulse;
        end
        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s,wasLocked);
            fnames=fieldnames(s);
            for i=1:length(fnames)
                obj.(fnames{i})=s.(fnames{i});
            end
        end
    end

    methods(Static,Hidden)
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end

