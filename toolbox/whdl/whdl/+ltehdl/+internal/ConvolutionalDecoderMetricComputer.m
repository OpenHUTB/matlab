classdef(StrictDefaults)ConvolutionalDecoderMetricComputer<matlab.System






%#codegen





    properties(Access=private,Nontunable)

        trellis;
        candidateSymbols;
        branchOutputsA;
        branchOutputsB;
        prevStateA;
        prevStateB;

    end

    properties(Access=private)


        maxValidPipe;
        maxMetrics;
        maxStates;


        decisions;
        stateMetrics;
        startOutPipe;
        endOutPipe;
        validOutPipe;


        adjustedBranchMetrics;
        branchMetrics;
        dataInReg;
        startInPipe;
        endInPipe;
        validInPipe;
        resetInPipe;

    end





    methods



        function obj=ConvolutionalDecoderMetricComputer(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:});
        end



    end

    methods(Static,Access=protected)



        function header=getHeaderImpl(~)

            text=[...
            'Branch Metric Calculation (BMC) and Add-Compare-Select (ACS)',newline...
            ,'stages of an LTE tailbiting convolutional decoder.'];

            header=matlab.system.display.Header('ltehdl.internal.ConvolutionalDecoderMetricComputer',...
            'Title','LTE Convolutional Decoder Metric Computer',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function isVisible=showSimulateUsingImpl
            isVisible=true;
        end



    end

    methods(Access=protected)



        function icon=getIconImpl(~)
            icon='LTE Convolutional Decoder\nMetric Computer';
        end



        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            varargout={false,false,false,false};
        end



        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end



        function resetImpl(obj)

            initializeResettableProperties(obj,obj.dataInReg);

        end



        function initializeResettableProperties(obj,dataInDT)

            dataTypes=determineDataTypes(obj,dataInDT);


            obj.trellis=poly2trellis(7,[133,171,165]);


            obj.candidateSymbols=cast([0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1],'like',dataTypes.candidateSymbolDT);


            maxPipeLen=log2(obj.trellis.numStates)+1;
            obj.maxValidPipe=false(1,maxPipeLen);
            obj.maxMetrics=zeros(64,1,'like',dataTypes.stateMetricDT);
            obj.maxStates=zeros(64,1,'like',dataTypes.stateDT);


            states=(0:obj.trellis.numStates-1);
            outputIndexesA=2*states;
            outputIndexesB=2*states+1;

            obj.branchOutputsA=obj.trellis.outputs(outputIndexesA+1);
            obj.branchOutputsB=obj.trellis.outputs(outputIndexesB+1);

            obj.prevStateA=mod(outputIndexesA,obj.trellis.numStates);
            obj.prevStateB=mod(outputIndexesB,obj.trellis.numStates);


            obj.decisions=false(64,1);
            obj.stateMetrics=zeros(64,1,'like',dataTypes.stateMetricDT);
            ctrlOutPipeLen=1;
            obj.startOutPipe=false(1,ctrlOutPipeLen);
            obj.endOutPipe=false(1,ctrlOutPipeLen);
            obj.validOutPipe=false(1,ctrlOutPipeLen);


            obj.branchMetrics=zeros(8,1,'like',dataTypes.branchMetricDT);
            obj.dataInReg=zeros(size(dataInDT),'like',dataTypes.dataInRegDT);
            ctrlInPipeLen=2;
            obj.startInPipe=false(1,ctrlInPipeLen);
            obj.endInPipe=false(1,ctrlInPipeLen);
            obj.validInPipe=false(1,ctrlInPipeLen);
            obj.resetInPipe=false(1,ctrlInPipeLen);

        end



        function setupImpl(obj,dataIn,~,~,~)

            initializeResettableProperties(obj,dataIn);

        end



        function[decisionsOut,startOut,endOut,validOut,winner,winnerValid]=outputImpl(...
            obj,~,~,~,~)

            decisionsOut=obj.decisions;
            startOut=obj.startOutPipe;
            endOut=obj.endOutPipe;
            validOut=obj.validOutPipe;
            winner=obj.maxStates(1);
            winnerValid=obj.maxValidPipe(end);

        end



        function updateImpl(obj,dataIn,startIn,endIn,validIn)






            resetIn=startIn&&validIn;

            [~,stateMetricsOut,~,endOut,~]=updateStateMetrics(obj,...
            obj.branchMetrics,resetIn,obj.startInPipe(end),obj.endInPipe(end),obj.validInPipe(end));

            findMaxMetric(obj,obj.resetInPipe(end),stateMetricsOut,endOut);





            obj.branchMetrics(:)=calculateBranchMetrics(obj,obj.dataInReg);
            obj.dataInReg(:)=dataIn;

            obj.startInPipe(:)=[startIn,obj.startInPipe(1:end-1)];
            obj.endInPipe(:)=[endIn,obj.endInPipe(1:end-1)];
            obj.validInPipe(:)=[validIn,obj.validInPipe(1:end-1)];
            obj.resetInPipe(:)=[resetIn,obj.resetInPipe(1:end-1)];

        end



        function branchMetrics=calculateBranchMetrics(obj,dataIn)

            numBranchMetrics=size(obj.candidateSymbols,1);

            bitsPerSymbol=size(obj.candidateSymbols,2);

            branchMetrics=zeros(numBranchMetrics,1,'like',obj.branchMetrics);

            if(isa(dataIn,'embedded.fi')&&isfixed(dataIn))&&~issigned(dataIn)




                high=cast((2^dataIn.WordLength-1)/2^dataIn.FractionLength,'like',branchMetrics);

                for ks=1:numBranchMetrics
                    branchMetrics(ks)=cast(0,'like',branchMetrics);
                    for kb=1:bitsPerSymbol
                        if obj.candidateSymbols(ks,kb)
                            branchMetrics(ks)=branchMetrics(ks)+dataIn(kb);
                        else
                            branchMetrics(ks)=branchMetrics(ks)+high-dataIn(kb);
                        end
                    end
                end

            else



                for ks=1:numBranchMetrics
                    branchMetrics(ks)=cast(0,'like',branchMetrics);
                    for kb=1:bitsPerSymbol
                        if obj.candidateSymbols(ks,kb)
                            branchMetrics(ks)=branchMetrics(ks)+dataIn(kb);
                        else
                            branchMetrics(ks)=branchMetrics(ks)-dataIn(kb);
                        end
                    end
                end

            end

        end



        function[decisionsOut,stateMetricsOut,startOut,endOut,validOut]=...
            updateStateMetrics(obj,branchMetrics,resetIn,startIn,endIn,validIn)


            decisionsOut=obj.decisions;
            stateMetricsOut=obj.stateMetrics;
            startOut=obj.startOutPipe;
            endOut=obj.endOutPipe;
            validOut=obj.validOutPipe;

            if resetIn


                obj.stateMetrics(:)=0;

            elseif validIn



                oldStateMetrics=obj.stateMetrics;


                for m=1:obj.trellis.numStates

                    stateBranchMetricA=branchMetrics(obj.branchOutputsA(m)+1);
                    stateBranchMetricB=branchMetrics(obj.branchOutputsB(m)+1);


                    newStateMetricA=cast(...
                    oldStateMetrics(obj.prevStateA(m)+1)+stateBranchMetricA,'like',obj.stateMetrics);
                    newStateMetricB=cast(...
                    oldStateMetrics(obj.prevStateB(m)+1)+stateBranchMetricB,'like',obj.stateMetrics);


                    diff=cast(newStateMetricA-newStateMetricB,'like',newStateMetricA);

                    if diff>=0
                        obj.stateMetrics(m)=newStateMetricA;
                        obj.decisions(m)=false;
                    else
                        obj.stateMetrics(m)=newStateMetricB;
                        obj.decisions(m)=true;
                    end

                end

            end


            obj.startOutPipe(:)=startIn;
            obj.endOutPipe(:)=endIn;
            obj.validOutPipe(:)=validIn;

        end



        function[maxState,maxValid]=findMaxMetric(obj,resetIn,stateMetricsIn,stateMetricsValid)


            maxState=obj.maxStates(1);
            maxValid=obj.maxValidPipe(end);


            if stateMetricsValid

                for k=0:length(obj.maxStates)-1
                    obj.maxStates(k+1)=k;
                end
                obj.maxMetrics=stateMetricsIn;
            else

                for k=0:(length(obj.maxStates)/2)-1

                    diff=cast(obj.maxMetrics(2*k+1)-obj.maxMetrics(2*k+2),'like',obj.maxMetrics(2*k+1));

                    if diff>=0
                        obj.maxMetrics(k+1)=obj.maxMetrics(2*k+1);
                        obj.maxStates(k+1)=obj.maxStates(2*k+1);
                    else
                        obj.maxMetrics(k+1)=obj.maxMetrics(2*k+2);
                        obj.maxStates(k+1)=obj.maxStates(2*k+2);
                    end

                end
            end


            if resetIn
                obj.maxValidPipe(:)=false(size(obj.maxValidPipe));
            else
                obj.maxValidPipe(:)=[stateMetricsValid,obj.maxValidPipe(1:end-1)];
            end

        end



        function dataTypes=determineDataTypes(~,dataInDT)

            if isa(dataInDT,'single')||isa(dataInDT,'double')

                dataInRegDT=dataInDT;
                candidateSymbolDT=dataInDT;
                branchMetricDT=dataInDT;
                stateMetricDT=dataInDT;

            elseif islogical(dataInDT)||isinteger(dataInDT)||(isa(dataInDT,'embedded.fi')&&isfixed(dataInDT))


                if islogical(dataInDT)
                    dataInRegDT=fi(0,0,1,0,hdlfimath);
                else
                    dataInRegDT=fi(dataInDT,hdlfimath);
                end

                s=issigned(dataInRegDT);
                inputWL=dataInRegDT.WordLength;
                inputFL=dataInRegDT.FractionLength;

                candidateSymbolDT=false;
                branchMetricDT=fi(0,s,inputWL+2,inputFL,hdlfimath);



                stateMetricDT=fi(0,1,inputWL+6,inputFL,hdlfimath);

            end


            stateDT=fi(0,0,6,0,hdlfimath);

            dataTypes=struct(...
            'dataInRegDT',dataInRegDT,...
            'candidateSymbolDT',candidateSymbolDT,...
            'branchMetricDT',branchMetricDT,...
            'stateMetricDT',stateMetricDT,...
            'stateDT',stateDT);

        end



        function num=getNumInputsImpl(~)
            num=4;
        end



        function num=getNumOutputsImpl(~)
            num=6;
        end



        function varargout=getInputNamesImpl(~)
            varargout={'dataIn','startIn','endIn','validIn'};
        end



        function varargout=getOutputNamesImpl(~)
            varargout={'decisions','startOut','endOut','validOut','winner','winnerValid'};
        end



        function validateInputsImpl(~,varargin)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{1},...
                {'single','double','embedded.fi','logical','int8','int16'},...
                {'size',[3,1]},...
                'ConvolutionalDecoderMetricComputer','dataIn');

                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'ConvolutionalDecoderMetricComputer','startIn');

                validateattributes(varargin{3},{'logical'},{'scalar'},...
                'ConvolutionalDecoderMetricComputer','endIn');

                validateattributes(varargin{4},{'logical'},{'scalar'},...
                'ConvolutionalDecoderMetricComputer','validIn');

            end
        end





        function varargout=getOutputDataTypeImpl(~)

            varargout={...
'logical'...
            ,'logical',...
            'logical',...
            'logical',...
            numerictype(0,6,0),...
            'logical'};

        end



        function varargout=isOutputComplexImpl(~,~)
            varargout={false,false,false,false,false,false};
        end



        function varargout=getOutputSizeImpl(~)
            varargout={64,1,1,1,1,1};
        end



        function varargout=isOutputFixedSizeImpl(~)
            varargout={true,true,true,true,true,true};
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);




        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end

end
