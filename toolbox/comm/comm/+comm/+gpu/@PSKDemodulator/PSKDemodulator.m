classdef(StrictDefaults)PSKDemodulator<comm.gpu.internal.GPUSystem&comm.internal.ConstellationBase


















































































    properties(Nontunable)



        ModulationOrder=8;



        PhaseOffset=pi/8;









        BitOutput(1,1)logical=false;










        SymbolMapping='Gray';










        CustomSymbolMapping=0:7;






        DecisionMethod='Hard decision';






        VarianceSource='Property';
    end
    properties











        Variance=1;
    end
    properties(Nontunable)



        OutputDataType='Full precision';
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryGrayCustom');
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');
        DecisionMethodSet=comm.CommonSets.getSet('DecisionOptions');
        OutputDataTypeSet=matlab.system.StringSet({'Full precision'});
    end

    properties(Access=private)
        pPhaseCorrection;
        pConstellation;
        pMinIndex0;
        pMinIndex1;
        pVarianceFromPort;
        pOutputSize;
        pSymbols0;
        pSymbols1;
        fh;
        pS0;
        pS1;
        pMapping;
        pPowersOfTwo;
        pIA;
        pAddPerBit;
        pConstellationTable;
    end

    properties(Access=private,Dependent)
        pBitsPerSymbol;
    end

    methods
        function v=get.pBitsPerSymbol(obj)
            v=log2(obj.ModulationOrder);
        end
    end

    methods

        function obj=PSKDemodulator(varargin)
            setProperties(obj,nargin,varargin{:},'ModulationOrder','PhaseOffset');
        end

        function set.ModulationOrder(obj,val)
            validateattributes(val,...
            {'numeric'},{'integer','positive','scalar','finite'},'','ModulationOrder');
            obj.ModulationOrder=val;
        end

        function set.PhaseOffset(obj,val)
            validateattributes(val,...
            {'numeric'},{'real','scalar','finite'},'','PhaseOffset');
            obj.PhaseOffset=val;
        end

        function set.Variance(obj,val)
            validateattributes(val,...
            {'numeric'},{'real','nonnegative','scalar','finite'},'','Variance');
            obj.Variance=val;
        end

    end

    methods(Access=protected)
        function validatePropertiesImpl(obj)
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,obj.SymbolMapping);
            if symbolMappingIdx==3
                status=commblkuserdefinedmapping(obj.ModulationOrder,...
                obj.CustomSymbolMapping,false);
                if~isempty(status.identifier)
                    error(message(status.identifier));
                end
            end
            if(obj.BitOutput)||strcmp(obj.SymbolMapping,'Gray')




                bitsPerSymbol=obj.pBitsPerSymbol;
                if((abs(bitsPerSymbol-fix(bitsPerSymbol))>2*eps*bitsPerSymbol)||...
                    (fix(bitsPerSymbol)<1))
                    error(message('comm:system:PSKDemodulator:bitInMNotPow2'));
                end
            end
        end

        function setupGPUImpl(obj,inputSignal,varargin)
            bitsPerSymbol=obj.pBitsPerSymbol;
            if abs(obj.PhaseOffset)>eps
                obj.pPhaseCorrection=gpuArray(exp(-1i*obj.PhaseOffset));
            else
                obj.pPhaseCorrection=gpuArray(1);
            end

            if strcmp(obj.SymbolMapping,'Gray')
                k=(0:(obj.ModulationOrder-1)).';
                obj.pMapping=bitxor(k,floor(k/2));
            elseif strcmp(obj.SymbolMapping,'Binary')
                obj.pMapping=(0:(obj.ModulationOrder-1)).';
            else
                obj.pMapping=reshape(obj.CustomSymbolMapping,...
                numel(obj.CustomSymbolMapping),1);
            end

            if~comm.gpu.internal.GPUBase.isfloat(inputSignal)
                error(message('comm:system:gpu:PSKDemodulator:inDataTypeNotFloat'));
            end
            if(nargin>2)
                theVariance=varargin{1};
                if~comm.gpu.internal.GPUBase.isRealBuiltinFloat(theVariance)
                    error(message('comm:system:gpu:PSKDemodulator:VarianceTypeNotRealFloat'));
                end
            end


            if size(inputSignal,2)>1
                error(message('comm:system:PSKDemodulator:inputNot1D2DColVec'));
            end
            if isreal(inputSignal)
                error(message('comm:system:PSKDemodulator:invalidComplexity'));
            end


            theClass=underlyingType(inputSignal);
            obj.pMapping=gpuArray(cast(obj.pMapping,theClass));

            if obj.BitOutput

                obj.pOutputSize=[bitsPerSymbol*size(inputSignal,1),1];
            end

            decisionMethodIdx=getIndex(obj.DecisionMethodSet,...
            obj.DecisionMethod);
            if decisionMethodIdx==1
                if obj.BitOutput&&(bitsPerSymbol>1)
                    obj.fh=@obj.hardDecisionBit;


                    obj.pPowersOfTwo=gpuArray(cast(...
                    repmat(2.^(bitsPerSymbol-1:-1:0).',...
                    size(inputSignal,1),1),theClass));


                    [ia,~]=meshgrid(...
                    gpuArray.colon(1,size(inputSignal,1)),...
                    gpuArray.colon(1,bitsPerSymbol));
                    obj.pIA=gpuArray(cast(ia,theClass));
                else

                    obj.fh=@obj.hardDecisionInt;
                end
            else


                obj.pConstellation=createConstellation(obj.ModulationOrder,...
                obj.PhaseOffset);
                zeroPhaseConstellation=createConstellation(...
                obj.ModulationOrder,0);
                tmpConstellation=exp(1i*(1:2:(4*obj.ModulationOrder-1))*pi/...
                (2*obj.ModulationOrder));

                obj.pS0=findValue(obj.pMapping,obj.ModulationOrder,...
                bitsPerSymbol,0);
                obj.pS1=findValue(obj.pMapping,obj.ModulationOrder,...
                bitsPerSymbol,1);

                obj.pVarianceFromPort=strcmp(obj.VarianceSource,...
                'Input port');

                if decisionMethodIdx==2
                    obj.fh=@obj.softDecisionExact;
                    baseIndex=gpuArray(0:(bitsPerSymbol-1));



                    halfMod=obj.ModulationOrder/2;
                    symbols0=gpuArray.zeros(bitsPerSymbol,halfMod);
                    symbols1=symbols0;
                    for symbolIdx=1:halfMod
                        indx=baseIndex*halfMod+symbolIdx;
                        symbols0(:,symbolIdx)=obj.pConstellation(...
                        obj.pS0(indx));
                        symbols1(:,symbolIdx)=obj.pConstellation(...
                        obj.pS1(indx));
                    end
                    obj.pSymbols0=symbols0;
                    obj.pSymbols1=symbols1;
                else
                    obj.fh=@obj.softDecisionApprox;
                    [indx0,indx1]=computeNearestNeighborIndex(...
                    obj.ModulationOrder,...
                    bitsPerSymbol,...
                    tmpConstellation,...
                    zeroPhaseConstellation,...
                    obj.pMapping,...
                    obj.pS0,...
                    obj.pS1);






                    min0=gpuArray(obj.pConstellation(indx0));
                    min1=gpuArray(obj.pConstellation(indx1));
                    obj.pConstellationTable=[min0,min1];
                    obj.pAddPerBit=reshape((gpuArray.ones(...
                    size(inputSignal))*(1:bitsPerSymbol)).',[],1);
                end
            end
        end

        function y=stepGPUImpl(obj,inputSignal,varargin)
            if nargin>2

                theVariance=gather(varargin{1});
                if(theVariance<0)||~isfinite(theVariance)
                    error(message('comm:system:PSKDemodulator:noiseVarNotRealPosScl'));
                end
            end
            y=obj.fh(inputSignal,varargin{:});
        end

        function bitOut=hardDecisionBit(obj,inputSignal,~)

            if strcmp(obj.SymbolMapping,'Gray')&&obj.ModulationOrder==4
                newIndex=derotateAndRound(inputSignal,obj.pPhaseCorrection,...
                obj.ModulationOrder);
                bitOut=arrayfun(@Gray_default_hard_4pskd,newIndex(obj.pIA,1),...
                obj.pPowersOfTwo);

            elseif strcmp(obj.SymbolMapping,'Gray')&&obj.ModulationOrder==8
                newIndex=derotateAndRound(inputSignal,obj.pPhaseCorrection,...
                obj.ModulationOrder);
                bitOut=arrayfun(@Gray_default_hard_8pskd,newIndex(obj.pIA,1),...
                obj.pPowersOfTwo);

            else
                newIndex=derotateAndRound(inputSignal,obj.pPhaseCorrection,...
                obj.ModulationOrder);
                intout=obj.pMapping(newIndex+1);

                bitOut=arrayfun(@demodConvertBitToInt,intout(obj.pIA,1),...
                obj.pPowersOfTwo);

            end

        end


        function out=hardDecisionInt(obj,inputSignal,~)
            newIndex=derotateAndRound(inputSignal,obj.pPhaseCorrection,...
            obj.ModulationOrder);
            out=obj.pMapping(newIndex+1);
        end




        function exactLLR=softDecisionExact(obj,inputSignal,varargin)
            bitsPerSymbol=obj.pBitsPerSymbol;

            N=size(inputSignal,1);

            if obj.pVarianceFromPort
                theVariance=varargin{1};
            else
                theVariance=gpuArray(obj.Variance);
            end


            if strcmp(obj.SymbolMapping,'Gray')&&obj.ModulationOrder==2
                s0=obj.pSymbols0;
                s1=obj.pSymbols1;

                exactLLR=arrayfun(@Gray_default_exactLLR_2pskd,s0,s1,...
                inputSignal,theVariance);


            elseif strcmp(obj.SymbolMapping,'Gray')&&obj.ModulationOrder==4
                s0_a=obj.pSymbols0(1,1);
                s0_b=obj.pSymbols0(1,2);
                s0_c=obj.pSymbols0(2,1);
                s0_d=obj.pSymbols0(2,2);

                s1_a=obj.pSymbols1(1,1);
                s1_b=obj.pSymbols1(1,2);
                s1_c=obj.pSymbols1(2,1);
                s1_d=obj.pSymbols1(2,2);

                [r1,r2]=arrayfun(@Gray_default_exactLLR_4pskd,...
                s0_a,s0_b,s0_c,s0_d,...
                s1_a,s1_b,s1_c,s1_d,...
                inputSignal,theVariance);

                exactLLR=[r1,r2];

                exactLLR=reshape(exactLLR',obj.pOutputSize);


            elseif strcmp(obj.SymbolMapping,'Gray')&&obj.ModulationOrder==8

                s0_11=obj.pSymbols0(1,1);
                s0_12=obj.pSymbols0(1,2);
                s0_13=obj.pSymbols0(1,3);
                s0_14=obj.pSymbols0(1,4);

                s0_21=obj.pSymbols0(2,1);
                s0_22=obj.pSymbols0(2,2);
                s0_23=obj.pSymbols0(2,3);
                s0_24=obj.pSymbols0(2,4);

                s0_31=obj.pSymbols0(3,1);
                s0_32=obj.pSymbols0(3,2);
                s0_33=obj.pSymbols0(3,3);
                s0_34=obj.pSymbols0(3,4);

                s1_11=obj.pSymbols1(1,1);
                s1_12=obj.pSymbols1(1,2);
                s1_13=obj.pSymbols1(1,3);
                s1_14=obj.pSymbols1(1,4);

                s1_21=obj.pSymbols1(2,1);
                s1_22=obj.pSymbols1(2,2);
                s1_23=obj.pSymbols1(2,3);
                s1_24=obj.pSymbols1(2,4);

                s1_31=obj.pSymbols1(3,1);
                s1_32=obj.pSymbols1(3,2);
                s1_33=obj.pSymbols1(3,3);
                s1_34=obj.pSymbols1(3,4);

                r1=arrayfun(@Gray_default_exactLLR_8pskd,...
                s0_11,s0_12,s0_13,s0_14,...
                s1_11,s1_12,s1_13,s1_14,...
                inputSignal,theVariance);

                r2=arrayfun(@Gray_default_exactLLR_8pskd,...
                s0_21,s0_22,s0_23,s0_24,...
                s1_21,s1_22,s1_23,s1_24,...
                inputSignal,theVariance);

                r3=arrayfun(@Gray_default_exactLLR_8pskd,...
                s0_31,s0_32,s0_33,s0_34,...
                s1_31,s1_32,s1_33,s1_34,...
                inputSignal,theVariance);


                exactLLR=[r1,r2,r3];

                exactLLR=reshape(exactLLR',obj.pOutputSize);


            else
                halfMod=obj.ModulationOrder/2;
                inputInterleaved=reshape(...
                repmat(inputSignal.',bitsPerSymbol,1),...
                obj.pOutputSize);
                inputExpanded=repmat(inputInterleaved,1,halfMod);
                s0=repmat(obj.pSymbols0,N,1);
                s1=repmat(obj.pSymbols1,N,1);
                [expSumS0,expSumS1]=arrayfun(@exactLLRCalculation,...
                s0,s1,inputExpanded,theVariance);
                exactLLR=arrayfun(@exactLLRLogSum,sum(expSumS0,2),...
                sum(expSumS1,2));

            end
        end





        function approxLLR=softDecisionApprox(obj,inputSignal,varargin)
            bitsPerSymbol=obj.pBitsPerSymbol;
            if obj.pVarianceFromPort
                theVariance=varargin{1};
            else
                theVariance=gpuArray(obj.Variance);
            end


            signalCell=cell(bitsPerSymbol,1);
            signalCell(:)={inputSignal.'};
            inputInterleaved=reshape(cat(1,signalCell{:}),obj.pOutputSize);


            indx=arrayfun(@getBaseIndex,...
            inputInterleaved,...
            bitsPerSymbol,...
            obj.pAddPerBit,...
            obj.pPhaseCorrection,...
            obj.ModulationOrder);





            minVals=obj.pConstellationTable(indx,:);


            approxLLR=arrayfun(@magsqMod,minVals(:,1),minVals(:,2),...
            inputInterleaved,theVariance);
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=strcmp(prop,'CustomSymbolMapping')&&...
            ~strcmp(obj.SymbolMapping,'Custom');
            if~obj.BitOutput
                flag=flag||...
                (strcmp(prop,'DecisionMethod')||...
                strcmp(prop,'VarianceSource')||...
                strcmp(prop,'Variance'));
            elseif strcmp(obj.DecisionMethod,'Hard decision')
                flag=flag||(strcmp(prop,'VarianceSource')||...
                strcmp(prop,'Variance'));
            elseif strcmp(obj.VarianceSource,'Input port')
                flag=flag||(strcmp(prop,'Variance')||...
                strcmp(prop,'OutputDataType'));
            else

                flag=flag||strcmp(prop,'OutputDataType');
            end
        end
        function n=getNumInputsImpl(obj)
            if strcmp(obj.VarianceSource,'Input port')
                n=2;
            else
                n=1;
            end
        end
    end


    methods(Access=protected)
        function varargout=getOutputSizeImpl(obj)
            if~(obj.BitOutput)
                varargout{1}=propagatedInputSize(obj,1);
            else
                sz=propagatedInputSize(obj,1);
                varargout{1}=[sz(1)*log2(obj.ModulationOrder),sz(2)];
            end
        end
        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
        end
        function varargout=isOutputComplexImpl(obj)%#ok
            varargout{1}=false;
        end

        function varargout=isOutputFixedSizeImpl(obj)%#ok
            varargout{1}=true;
        end
    end

    methods(Static,Hidden)
        function flag=generatesCode()
            flag=false;
        end
    end

end

function v=magsq(x)
    v=real(x).*real(x)+imag(x).*imag(x);
end



function baseIndex=derotateAndRound(inputSignal,phaseCorrection,...
    modulationOrder)
    derotatedSignal=inputSignal*phaseCorrection;
    theta=angle(derotatedSignal);
    baseIndex=round(theta*modulationOrder/(2*pi));
    baseIndex=baseIndex+modulationOrder*(baseIndex<0);
end





function constellation=createConstellation(M,initialPhase)
    tmpPhase=2*pi/M;
    constellation=exp(1i*(initialPhase+(0:(M-1)).'*tmpPhase));
end




function s=findValue(mapping,M,nBits,value)
    s=zeros(1,M*nBits/2);
    counter=zeros(1,nBits);
    for symbolIndex=1:M
        symbol=uint32(mapping(symbolIndex));
        for bitIndex=1:nBits
            if bitand(symbol,1)==value
                s(fix(M/2)*(nBits-bitIndex)+counter(bitIndex)+1)=symbolIndex;
                counter(bitIndex)=counter(bitIndex)+1;
            end
            symbol=bitshift(symbol,-1);
        end

    end
end




function[minIndex0,minIndex1]=computeNearestNeighborIndex(M,nBits,...
    tmpConstellation,constellation,mapping,s0,s1)
    nBins=2*M;
    minIndex0=zeros(nBins*nBits,1);
    minIndex1=zeros(nBins*nBits,1);
    for ix=1:nBins
        currentConstellationPoint=tmpConstellation(ix);
        mappingIndex=mod(fix(ix/2),M)+1;
        currentSymbol=uint32(mapping(mappingIndex));
        for bitIndex=1:nBits
            index=(ix-1)*nBits+bitIndex;
            if bitand(currentSymbol,cast(2^(nBits-bitIndex),'uint32'))==0

                minIndex0(index)=mappingIndex;
                minIndex1(index)=findNearestSymbolIndex(currentConstellationPoint,...
                constellation,s1,M,bitIndex);
            else

                minIndex1(index)=mappingIndex;
                minIndex0(index)=findNearestSymbolIndex(currentConstellationPoint,...
                constellation,s0,M,bitIndex);
            end
        end
    end

end

function minIndex=findNearestSymbolIndex(currentConstellationPoint,...
    constellation,indexValue,M,bitIndex)

    MDiv2=fix(M/2);
    offset=MDiv2*(bitIndex-1);
    min=Inf;
    minIndex=1;

    for symbolIndex=1:MDiv2
        dist=magsq(currentConstellationPoint-constellation(indexValue(offset+symbolIndex)));
        if dist<min
            min=dist;
            minIndex=indexValue(offset+symbolIndex);
        end
    end
end
