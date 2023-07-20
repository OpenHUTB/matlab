classdef CPMDemodulatorBase<matlab.system.SFunSystem





%#function mcomcpmdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        InitialPhaseOffset=0;



        SamplesPerSymbol=8;






        TracebackDepth=16;





        OutputDataType='double';
    end

    properties(Hidden,Transient)
        OutputDataTypeSet=matlab.system.StringSet({'double'});
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


        BitOutput(1,1)logical
    end

    properties(Nontunable,Hidden)
        pBitDataType='double'
        pIntDataType='double'
    end

    properties(Hidden,Transient)
        pBitDataTypeSet=comm.CommonSets.getSet('LogicalOrDouble');
        pIntDataTypeSet=comm.CommonSets.getSet('SignedOutDataType');
        pFrequencyPulseSet=comm.CommonSets.getSet('FrequencyPulseShapes');
        pSymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
    end

    methods(Access=protected)
        function obj=CPMDemodulatorBase()
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomcpmdemod');
            setVarSizeAllowedStatus(obj,false);
            setForceInputRealToComplex(obj,1,true);
        end
    end

    methods
        function set.SamplesPerSymbol(obj,val)


            validateattributes(val,{'double'},...
            {'real','scalar','positive','integer'},'',...
            'SamplesPerSymbol');
            obj.SamplesPerSymbol=val;
        end

        function value=get.OutputDataTypeSet(obj)
            if obj.BitOutput
                value=obj.pBitDataTypeSet;
            else
                value=obj.pIntDataTypeSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputFormatIdx=~obj.BitOutput+1;

            frequencyPulseIdx=getIndex(obj.pFrequencyPulseSet,...
            obj.pFrequencyPulse);

            symbolMappingIdx=getIndex(...
            obj.pSymbolMappingSet,obj.pSymbolMapping);

            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);

            if isempty(outputDataTypeIdx)
                coder.internal.errorIf(true,'comm:system:CPMDemodulatorBase:invalidOutputDataType',obj.OutputDataType,class(obj));
            else
                if obj.BitOutput
                    outputDataTypeIdx=1+4*(outputDataTypeIdx>1);
                else
                    outputDataTypeIdx=outputDataTypeIdx+1;
                end
            end

            [eStr,params]=commblkcpmdemod(obj,'init',...
            obj.pModulationOrder,...
            obj.pModulationIndex,...
            obj.pBandwidthTimeProduct,...
            obj.pMainLobeDuration,...
            obj.pRolloffFactor,...
            obj.pPulseLength,...
            obj.pSymbolPrehistory,...
            obj.SamplesPerSymbol,...
            obj.TracebackDepth,...
            true);

            if(eStr.ecode==1)
                colons=coder.internal.const(strfind(eStr.eID,':'));
                final_token=eStr.eID(colons(end)+1:end);
                coder.internal.errorIf(true,['comm:system:cpmmodulator:',final_token]);
            elseif(eStr.ecode==2)
                colons=coder.internal.const(strfind(eStr.eID,':'));
                final_token=eStr.eID(colons(end)+1:end);
                warning(message(['comm:system:cpmmodulator:',final_token]));
            end






            obj.compSetParameters({...
            obj.pModulationOrder,...
            outputFormatIdx,...
            symbolMappingIdx,...
            frequencyPulseIdx,...
            obj.pBandwidthTimeProduct,...
            obj.pMainLobeDuration,...
            obj.pRolloffFactor,...
            obj.pPulseLength,...
            obj.InitialPhaseOffset,...
            obj.SamplesPerSymbol,...
            1,...
            params.gMod,...
            params.preHistory,...
            0,...
            obj.TracebackDepth,...
            params.modidx,...
            params.p,...
outputDataTypeIdx...
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

