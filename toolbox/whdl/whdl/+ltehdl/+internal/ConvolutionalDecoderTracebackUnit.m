classdef(StrictDefaults)ConvolutionalDecoderTracebackUnit<matlab.System






%#codegen





    properties(Nontunable)


        TrainingLength=40;

        MaximumMessageLength=1024;
    end

    properties(Access=private)


        trelDec;
        trelDecRAM;


        msgLoc;


        msgBuf;
        msgBufRAM;


        dataOut;
        startOut;
        endOut;
        validOut;

    end





    methods



        function obj=ConvolutionalDecoderTracebackUnit(varargin)
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
            'Trellis decoder stage of LTE tailbiting',newline...
            ,'convolutional decoder.'];

            header=matlab.system.display.Header('ltehdl.internal.ConvolutionalDecoderTracebackUnit',...
            'Title','LTE Convolutional Decoder Trellis Decoder',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function isVisible=showSimulateUsingImpl
            isVisible=true;
        end



    end

    methods(Access=protected)



        function icon=getIconImpl(~)
            icon='LTE Convolutional Decoder\nTrellis Decoder';
        end



        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            varargout={false,false,false,false,false,false,false};
        end



        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end



        function initializeResettableProperties(obj,decisionsDT)

            TRELLIS_ADDR_WIDTH=ceil(log2(obj.MaximumMessageLength+2*obj.TrainingLength));
            MSG_ADDR_WIDTH=ceil(log2(obj.MaximumMessageLength));

            trellisAddrDT=fi(0,0,TRELLIS_ADDR_WIDTH,0,hdlfimath);
            msgAddrDT=fi(0,0,MSG_ADDR_WIDTH,0,hdlfimath);



            obj.trelDec=struct(...
            'state',fi(0,0,3,0,hdlfimath),...
            'stateReg',fi(0,0,3,0,hdlfimath),...
            'count',trellisAddrDT,...
            'countReg',repmat(trellisAddrDT,1,2),...
            'RAMOutReg',fi(0,0,64,0,hdlfimath),...
            'tracingBack',false,...
            'trellisStart',false,...
            'trellisEnd',false,...
            'decisionsReg',cast(zeros(size(decisionsDT)),'like',decisionsDT),...
            'endExtInReg',false,...
            'validInReg',false,...
            'winningState',fi(0,0,6,0,hdlfimath));



            obj.msgLoc=struct(...
            'counting',false,...
            'inputCount',trellisAddrDT,...
            'startMsg',false,...
            'msgStartAddr',trellisAddrDT,...
            'msgLengthMinus1',trellisAddrDT,...
            'msgLengthAquired',false);



            obj.msgBuf=struct(...
            'state',fi(0,0,2,0,hdlfimath),...
            'tbTrainingStartAddr',trellisAddrDT,...
            'sliceB_offset',trellisAddrDT,...
            'RAMDataIn',fi(0,0,1,0,hdlfimath),...
            'RAMWrAddr',msgAddrDT,...
            'RAMWr',false,...
            'RAMRdAddr',msgAddrDT,...
            'RAMEndAddr',msgAddrDT,...
            'lastWrite',false,...
            'FSMCtrlOut',coder.const(false(1,3)),...
            'RAMCtrlOut',coder.const(false(1,3)));



            obj.dataOut=false;
            obj.startOut=false;
            obj.endOut=false;
            obj.validOut=false;

        end



        function resetImpl(obj)

            initializeResettableProperties(obj,obj.trelDec.decisionsReg);

        end



        function setupImpl(obj,decisionsDT,~,~,~,~,~,~)

            obj.trelDecRAM=hdl.RAM('RAMType','Single port');

            obj.msgBufRAM=hdl.RAM('RAMType','Simple dual port');

            initializeResettableProperties(obj,decisionsDT);

        end



        function[dataOut,startOut,endOut,validOut]=outputImpl(obj,~,~,~,~,~,~,~)

            dataOut=obj.dataOut;
            startOut=obj.startOut;
            endOut=obj.endOut;
            validOut=obj.validOut;

        end



        function updateImpl(obj,decisions,startIn,endExtIn,validIn,winner,winnerValid,endMsgIn)

            [tracebackCountOut,tracebackDataOut,trellisStart,trellisEnd,tracingBack]=...
            updateTrellisDecoder(obj,...
            decisions,startIn,endExtIn,validIn,winner,winnerValid);

            [msgLengthMinus1,msgStartAddr]=...
            updateMessageLocator(obj,...
            startIn,endMsgIn,validIn);

            [obj.dataOut,obj.startOut,obj.endOut,obj.validOut]=...
            updateMessageBuffer(obj,...
            tracebackCountOut,trellisStart,trellisEnd,tracebackDataOut,...
            tracingBack,msgLengthMinus1,msgStartAddr);

        end



        function[tracebackCountOut,dataOut,trellisStart,trellisEnd,tracingBack]=updateTrellisDecoder(obj,...
            decisions,startIn,endExtIn,validIn,winner,winnerValid)


            IDLE=0;
            STORING_DECISIONS=1;
            WAITING_FOR_WINNER=2;
            TRELLIS_END=3;
            TRACING_BACK=4;


            trelDecNext=obj.trelDec;





            if winnerValid

                trelDecNext.winningState(:)=winner;
            elseif obj.trelDec.tracingBack

                previousStateLSB=bitget(obj.trelDec.RAMOutReg,obj.trelDec.winningState+1);
                trelDecNext.winningState(:)=bitconcat(bitsliceget(obj.trelDec.winningState,5,1),previousStateLSB);
            end

            trelDecNext.decisionsReg=decisions;
            trelDecNext.endExtInReg=endExtIn;
            trelDecNext.validInReg=validIn;





            if validIn&&startIn

                trelDecNext.state(:)=STORING_DECISIONS;
                trelDecNext.count(:)=0;

            else

                switch obj.trelDec.state

                case STORING_DECISIONS

                    if obj.trelDec.validInReg
                        if obj.trelDec.endExtInReg
                            trelDecNext.state(:)=TRELLIS_END;
                            trelDecNext.count(:)=obj.trelDec.count+1;
                        else
                            trelDecNext.state(:)=STORING_DECISIONS;
                            trelDecNext.count(:)=obj.trelDec.count+1;
                        end
                    end

                case TRELLIS_END

                    trelDecNext.state(:)=WAITING_FOR_WINNER;
                    trelDecNext.count(:)=obj.trelDec.count;

                case WAITING_FOR_WINNER

                    if winnerValid
                        trelDecNext.state(:)=TRACING_BACK;
                        trelDecNext.count(:)=obj.trelDec.count-1;
                    else
                        trelDecNext.state(:)=WAITING_FOR_WINNER;
                        trelDecNext.count(:)=obj.trelDec.count;
                    end

                case TRACING_BACK

                    if obj.trelDec.count~=0
                        trelDecNext.state(:)=TRACING_BACK;
                        trelDecNext.count(:)=obj.trelDec.count-1;
                    else
                        trelDecNext.state(:)=IDLE;
                        trelDecNext.count(:)=0;
                    end

                otherwise

                    trelDecNext.state(:)=IDLE;
                    trelDecNext.count(:)=0;

                end
            end






            ramDataIn=vecToFi(obj,obj.trelDec.decisionsReg);
            wrEn=(obj.trelDec.state==STORING_DECISIONS);

            trelDecNext.RAMOutReg(:)=step(obj.trelDecRAM,ramDataIn,obj.trelDec.count,wrEn);

            trelDecNext.tracingBack(:)=(obj.trelDec.stateReg==TRACING_BACK);
            trelDecNext.trellisStart(:)=(obj.trelDec.stateReg==STORING_DECISIONS)&&(trelDecNext.countReg(1)==0);
            trelDecNext.trellisEnd(:)=(obj.trelDec.stateReg==TRELLIS_END);


            trelDecNext.stateReg(:)=obj.trelDec.state;
            trelDecNext.countReg(:)=[obj.trelDec.count,obj.trelDec.countReg(1)];





            tracebackCountOut=obj.trelDec.countReg(end);
            trellisStart=obj.trelDec.trellisStart;
            trellisEnd=obj.trelDec.trellisEnd;
            tracingBack=obj.trelDec.tracingBack;
            dataOut=logical(bitget(obj.trelDec.winningState,6));





            obj.trelDec=trelDecNext;

        end



        function[msgLengthMinus1,msgStartAddr]=updateMessageLocator(obj,startIn,endMsgIn,validIn)

            msgLengthMinus1=obj.msgLoc.msgLengthMinus1;
            msgStartAddr=obj.msgLoc.msgStartAddr;

            msgLocNext=obj.msgLoc;

            if validIn&&startIn

                msgLocNext.counting=true;
                msgLocNext.inputCount(:)=1;
                msgLocNext.startMsg=false;
                msgLocNext.msgStartAddr(:)=0;
                msgLocNext.msgLengthMinus1(:)=0;
                msgLocNext.msgLengthAquired=false;

            elseif validIn


                msgLocNext.startMsg=endMsgIn;

                if obj.msgLoc.counting



                    if(obj.msgLoc.inputCount>=obj.TrainingLength)&&obj.msgLoc.startMsg

                        msgLocNext.counting=false;
                        msgLocNext.inputCount(:)=0;
                        msgLocNext.msgStartAddr=obj.msgLoc.inputCount;
                    else
                        msgLocNext.counting=true;
                        msgLocNext.inputCount(:)=obj.msgLoc.inputCount+1;
                        msgLocNext.msgStartAddr(:)=0;
                    end


                    if~obj.msgLoc.msgLengthAquired
                        if endMsgIn

                            msgLocNext.msgLengthMinus1=obj.msgLoc.inputCount;
                            msgLocNext.msgLengthAquired=true;
                        else
                            msgLocNext.msgLengthMinus1(:)=0;
                            msgLocNext.msgLengthAquired=false;
                        end
                    else
                        msgLocNext.msgLengthMinus1=obj.msgLoc.msgLengthMinus1;
                        msgLocNext.msgLengthAquired=true;
                    end

                else


                    msgLocNext.counting=false;
                    msgLocNext.inputCount(:)=0;

                    msgLocNext.msgStartAddr=obj.msgLoc.msgStartAddr;
                    msgLocNext.msgLengthMinus1=obj.msgLoc.msgLengthMinus1;
                    msgLocNext.msgLengthAquired=obj.msgLoc.msgLengthAquired;

                end
            end

            obj.msgLoc=msgLocNext;

        end



        function[dataOut,startOut,endOut,validOut]=updateMessageBuffer(obj,...
            tracebackCount,trellisStart,trellisEnd,dataIn,validIn,msgLengthMinus1,msgStartAddr)





            msgBufNext=obj.msgBuf;






            if trellisEnd
                msgBufNext.tbTrainingStartAddr(:)=tracebackCount-obj.TrainingLength;
                msgBufNext.sliceB_offset(:)=msgStartAddr-(msgLengthMinus1+1);
            end





            msgBufNext.RAMDataIn(:)=dataIn;

            if validIn
                if(tracebackCount>=obj.TrainingLength)&&(tracebackCount<obj.msgBuf.tbTrainingStartAddr)
                    if tracebackCount>=msgStartAddr

                        msgBufNext.RAMWrAddr(:)=tracebackCount-msgStartAddr;
                        msgBufNext.RAMWr(:)=true;
                    else

                        msgBufNext.RAMWrAddr(:)=tracebackCount-obj.msgBuf.sliceB_offset;
                        msgBufNext.RAMWr(:)=true;
                    end
                else
                    msgBufNext.RAMWrAddr(:)=tracebackCount;
                    msgBufNext.RAMWr(:)=false;
                end
            else
                msgBufNext.RAMWrAddr(:)=tracebackCount;
                msgBufNext.RAMWr(:)=false;
            end

            msgBufNext.lastWrite(:)=validIn&&(tracebackCount==obj.TrainingLength);






            IDLE=0;
            WAITING_FOR_LAST_WRITE=1;
            READING_RAM=2;

            if trellisStart
                msgBufNext.state(:)=WAITING_FOR_LAST_WRITE;
                msgBufNext.RAMRdAddr(:)=0;
                msgBufNext.FSMCtrlOut(:)=[0,0,0];
            else
                switch msgBufNext.state
                case WAITING_FOR_LAST_WRITE
                    if obj.msgBuf.lastWrite
                        msgBufNext.state(:)=READING_RAM;
                        msgBufNext.RAMRdAddr(:)=0;
                        msgBufNext.FSMCtrlOut(:)=[1,0,1];
                    else
                        msgBufNext.state(:)=WAITING_FOR_LAST_WRITE;
                        msgBufNext.RAMRdAddr(:)=0;
                        msgBufNext.FSMCtrlOut(:)=[0,0,0];
                    end
                case READING_RAM
                    if obj.msgBuf.RAMRdAddr==(msgLengthMinus1-1)
                        msgBufNext.state(:)=IDLE;

                        msgBufNext.RAMRdAddr(:)=obj.msgBuf.RAMRdAddr+1;
                        msgBufNext.FSMCtrlOut(:)=[0,1,1];
                    else
                        msgBufNext.state(:)=READING_RAM;
                        msgBufNext.RAMRdAddr(:)=obj.msgBuf.RAMRdAddr+1;
                        msgBufNext.FSMCtrlOut(:)=[0,0,1];
                    end
                otherwise

                    msgBufNext.state(:)=IDLE;
                    msgBufNext.RAMRdAddr(:)=0;
                    msgBufNext.FSMCtrlOut(:)=[0,0,0];

                end
            end






            dataOut=logical(...
            step(obj.msgBufRAM,obj.msgBuf.RAMDataIn,obj.msgBuf.RAMWrAddr,...
            obj.msgBuf.RAMWr,obj.msgBuf.RAMRdAddr));

            msgBufNext.RAMCtrlOut=obj.msgBuf.FSMCtrlOut;





            startOut=obj.msgBuf.RAMCtrlOut(1);
            endOut=obj.msgBuf.RAMCtrlOut(2);
            validOut=obj.msgBuf.RAMCtrlOut(3);





            obj.msgBuf=msgBufNext;

        end



        function y=vecToFi(~,x)


            N=length(x);
            y=fi(0,0,N,0);
            for k=1:N
                y=bitset(y,k,x(k));
            end

        end



        function num=getNumInputsImpl(~)
            num=7;
        end



        function num=getNumOutputsImpl(~)
            num=4;
        end



        function varargout=getInputNamesImpl(~)
            varargout={'decisions','start','endExt','valid','winner','winnerValid','endMsg'};
        end



        function varargout=getOutputNamesImpl(~)
            varargout={'data','start','end','valid'};
        end



        function validateInputsImpl(~,varargin)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{1},...
                {'logical'},...
                {'size',[64,1]},...
                'ConvolutionalDecoderTracebackUnit','decisions');

                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','start');

                validateattributes(varargin{3},{'logical'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','end');

                validateattributes(varargin{4},{'logical'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','valid');

                validateattributes(varargin{5},{'embedded.fi'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','winner');



                validateattributes(varargin{6},{'logical'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','winnerValid');

                validateattributes(varargin{7},{'logical'},{'scalar'},...
                'ConvolutionalDecoderTracebackUnit','end');

            end
        end





        function varargout=getOutputDataTypeImpl(~)

            varargout={'logical','logical','logical','logical'};

        end



        function varargout=isOutputComplexImpl(~,~)
            varargout={false,false,false,false};
        end



        function varargout=getOutputSizeImpl(~)
            varargout={1,1,1,1};
        end



        function varargout=isOutputFixedSizeImpl(~)
            varargout={true,true,true,true};
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
