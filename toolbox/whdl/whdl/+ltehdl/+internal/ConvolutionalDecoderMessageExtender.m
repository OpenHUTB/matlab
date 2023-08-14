classdef(StrictDefaults)ConvolutionalDecoderMessageExtender<matlab.System








%#codegen





    properties(Nontunable)



        TrainingLength=40;


        MaximumMessageLength=1024;

    end

    properties(Access=private)

        RAM1;
        RAM2;
        RAM3;
        ctrlDelay;

        dataIn;
        fsm;
        msgLen;

        dataOut;
        startOut;
        endExtOut;
        validOut;
        endMsgOut;

    end





    methods



        function obj=ConvolutionalDecoderMessageExtender(varargin)
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
            'Input stage of LTE tailbiting convolutional decoder. ',newline...
            ,'Serialized version of y = [x; x] where x is a column vector',newline...
            ,'containing the input data.'];

            header=matlab.system.display.Header('ltehdl.internal.ConvolutionalDecoderMessageExtender',...
            'Title','LTE Convolutional Decoder Frame Repeater',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function isVisible=showSimulateUsingImpl
            isVisible=true;
        end



    end

    methods(Access=protected)



        function icon=getIconImpl(~)
            icon='LTE Convolutional Decoder\nFrame Repeater';
        end



        function varargout=isInputDirectFeedthroughImpl(~,~,~,~,~)
            varargout={false,false,false,false};
        end



        function flag=getExecutionSemanticsImpl(~,~,~,~,~)
            flag={'Classic','Synchronous'};
        end



        function resetImpl(obj)

            initializeResettableProperties(obj,obj.dataIn);

        end



        function initializeResettableProperties(obj,dataInDT)

            obj.dataIn=zeros(size(dataInDT),'like',dataInDT);

            obj.ctrlDelay=false(1,4);


            ADDR_WIDTH=ceil(log2(obj.MaximumMessageLength));


            EXT_COUNT_WIDTH=ceil(log2(2*obj.TrainingLength));

            obj.fsm=struct(...
            'state',fi(0,0,2,0),...
            'addr',fi(0,0,ADDR_WIDTH,0,'OverflowAction','Wrap'),...
            'endAddr',fi(0,0,ADDR_WIDTH,0,'OverflowAction','Wrap'),...
            'extCount',fi(0,0,EXT_COUNT_WIDTH,0,'OverflowAction','Wrap'),...
            'startOut',false,...
            'endExtOut',false,...
            'validOut',false,...
            'endMsgOut',false,...
            'wrEn',false);

            obj.msgLen=0;

            obj.dataOut=zeros(size(dataInDT),'like',dataInDT);
            obj.startOut=false;
            obj.endExtOut=false;
            obj.validOut=false;
            obj.endMsgOut=false;

        end



        function setupImpl(obj,dataIn,~,~,~)

            obj.RAM1=hdl.RAM('RAMType','Single port','WriteOutputValue','New data');
            obj.RAM2=hdl.RAM('RAMType','Single port','WriteOutputValue','New data');
            obj.RAM3=hdl.RAM('RAMType','Single port','WriteOutputValue','New data');

            initializeResettableProperties(obj,dataIn);

        end



        function[dataOut,startOut,endExtOut,validOut,endMsgOut]=outputImpl(obj,~,~,~,~)

            dataOut=obj.dataOut;
            startOut=obj.startOut;
            endExtOut=obj.endExtOut;
            validOut=obj.validOut;
            endMsgOut=obj.endMsgOut;

        end



        function updateImpl(obj,dataIn,startIn,endIn,validIn)

            coder.extrinsic('coder.internal.warningIf');





            obj.dataOut=obj.readAndWriteRAM(obj.dataIn,obj.fsm.addr,obj.fsm.wrEn);





            obj.startOut=obj.ctrlDelay(1);
            obj.endExtOut=obj.ctrlDelay(2);
            obj.validOut=obj.ctrlDelay(3);
            obj.endMsgOut=obj.ctrlDelay(4);





            obj.ctrlDelay=[obj.fsm.startOut,obj.fsm.endExtOut,obj.fsm.validOut,obj.fsm.endMsgOut];






            obj.dataIn=dataIn;


            IDLE=0;
            STREAMING=1;
            START_REPEATING=2;
            REPEATING=3;


            fsmNext=obj.fsm;


            if validIn&&startIn


                fsmNext.state(:)=STREAMING;
                fsmNext.addr(:)=0;
                fsmNext.endAddr=obj.fsm.endAddr;
                fsmNext.extCount(:)=obj.fsm.extCount;
                fsmNext.startOut=true;
                fsmNext.endExtOut=false;
                fsmNext.validOut=true;
                fsmNext.endMsgOut=false;
                fsmNext.wrEn=true;


                obj.msgLen=1;

            else

                switch obj.fsm.state

                case STREAMING

                    if validIn


                        obj.msgLen=obj.msgLen+1;

                        if endIn
                            fsmNext.state(:)=START_REPEATING;
                            fsmNext.endMsgOut=true;


                            coder.internal.warningIf(...
                            (obj.msgLen>obj.MaximumMessageLength),...
                            'whdl:LTEConvolutionalDecoder:InvalidMsgLen',...
                            obj.msgLen,obj.MaximumMessageLength);

                        else
                            fsmNext.state(:)=STREAMING;
                            fsmNext.endMsgOut=false;
                        end

                        fsmNext.addr(:)=obj.fsm.addr+1;
                        fsmNext.endAddr=fsmNext.endAddr;
                        fsmNext.extCount(:)=obj.fsm.extCount;
                        fsmNext.startOut=false;
                        fsmNext.endExtOut=false;
                        fsmNext.validOut=true;
                        fsmNext.wrEn=true;

                    else

                        fsmNext.state(:)=STREAMING;
                        fsmNext.addr(:)=obj.fsm.addr;
                        fsmNext.endAddr=fsmNext.endAddr;
                        fsmNext.extCount(:)=obj.fsm.extCount;
                        fsmNext.startOut=false;
                        fsmNext.endExtOut=false;
                        fsmNext.validOut=false;
                        fsmNext.endMsgOut=false;
                        fsmNext.wrEn=false;

                    end

                case START_REPEATING

                    fsmNext.state(:)=REPEATING;
                    fsmNext.addr(:)=0;
                    fsmNext.endAddr=obj.fsm.addr;
                    fsmNext.extCount(:)=0;
                    fsmNext.startOut=false;
                    fsmNext.endExtOut=false;
                    fsmNext.validOut=true;
                    fsmNext.endMsgOut=false;
                    fsmNext.wrEn=false;

                case REPEATING


                    if obj.fsm.addr==obj.fsm.endAddr
                        fsmNext.addr(:)=0;
                    else
                        fsmNext.addr(:)=obj.fsm.addr+1;
                    end

                    if obj.fsm.extCount==((2*obj.TrainingLength)-2)

                        fsmNext.state(:)=IDLE;
                        fsmNext.endExtOut=true;
                    else
                        fsmNext.state(:)=REPEATING;
                        fsmNext.endExtOut=false;
                    end

                    fsmNext.endAddr=obj.fsm.endAddr;
                    fsmNext.extCount(:)=obj.fsm.extCount+1;
                    fsmNext.startOut=false;
                    fsmNext.validOut=true;

                    fsmNext.endMsgOut=obj.fsm.addr==(obj.fsm.endAddr-1);
                    fsmNext.wrEn=false;

                otherwise

                    fsmNext.state(:)=IDLE;
                    fsmNext.addr(:)=obj.fsm.addr;
                    fsmNext.endAddr=obj.fsm.endAddr;
                    fsmNext.extCount(:)=0;
                    fsmNext.startOut=false;
                    fsmNext.endExtOut=false;
                    fsmNext.validOut=false;
                    fsmNext.endMsgOut=false;
                    fsmNext.wrEn=false;

                end
            end

            obj.fsm=fsmNext;

        end



        function dataOut=readAndWriteRAM(obj,dataIn,addr,wrEn)




            if isa(dataIn,'single')||isa(dataIn,'double')


                dataOut1=step(obj.RAM1,dataIn(1),addr,wrEn);
                dataOut2=step(obj.RAM2,dataIn(2),addr,wrEn);
                dataOut3=step(obj.RAM3,dataIn(3),addr,wrEn);
                dataOut=[dataOut1;dataOut2;dataOut3];

            else


                if islogical(dataIn)
                    dataInFi=fi(dataIn,0,1,0);
                else
                    dataInFi=fi(dataIn);
                end

                ramDataIn=bitconcat(dataInFi);

                ramDataOut=step(obj.RAM1,ramDataIn,addr,wrEn);

                WL=dataInFi.WordLength;


                dataSplit=reinterpretcast([...
                bitsliceget(ramDataOut,3*WL,2*WL+1);...
                bitsliceget(ramDataOut,2*WL,WL+1);...
                bitsliceget(ramDataOut,WL,1)],...
                dataInFi.numerictype);

                dataOut=cast(dataSplit,'like',dataIn);

            end

        end



        function num=getNumInputsImpl(~)
            num=4;
        end



        function num=getNumOutputsImpl(~)
            num=5;
        end



        function varargout=getInputNamesImpl(~)
            varargout={'dataIn','startIn','endIn','validIn'};
        end



        function varargout=getOutputNamesImpl(~)
            varargout={'dataOut','startOut','endExtOut','validOut','endMsgOut'};
        end



        function validateInputsImpl(~,dataIn,startIn,endIn,validIn)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(dataIn,...
                {'single','double','embedded.fi','logical','int8','int16'},...
                {'size',[3,1]},...
                'ConvolutionalDecoderMessageExtender','dataIn');

                validateattributes(startIn,{'logical'},{'scalar'},...
                'ConvolutionalDecoderMessageExtender','startIn');

                validateattributes(endIn,{'logical'},{'scalar'},...
                'ConvolutionalDecoderMessageExtender','endIn');

                validateattributes(validIn,{'logical'},{'scalar'},...
                'ConvolutionalDecoderMessageExtender','validIn');

            end
        end





        function varargout=getOutputDataTypeImpl(obj)

            varargout={propagatedInputDataType(obj,1),'logical','logical','logical','logical'};

        end



        function varargout=isOutputComplexImpl(~,~)
            varargout={false,false,false,false,false};
        end



        function varargout=getOutputSizeImpl(~)
            varargout={3,1,1,1,1};
        end



        function varargout=isOutputFixedSizeImpl(~)
            varargout={true,true,true,true,true};
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
