classdef(StrictDefaults)ConvolutionalDecoder<matlab.System








%#codegen





    properties(Access=private,Constant)




        TrainingLength=40;


        MaxMsgLenRange=[6,2048];

    end

    properties(Nontunable)


        MaximumMessageLength=1024;

    end

    properties(Access=private)


        messageExtender;
        delayBalancer;
        metricComputer;
        tracebackUnit;


        dataOut;
        ctrlOut;

    end





    methods



        function obj=ConvolutionalDecoder(varargin)
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



        function set.MaximumMessageLength(obj,val)

            coder.internal.errorIf(...
            (val<obj.MaxMsgLenRange(1))||(val>obj.MaxMsgLenRange(2)),...
            'whdl:LTEConvolutionalDecoder:InvalidMaxMsgLen',...
            val,obj.MaxMsgLenRange(1),obj.MaxMsgLenRange(2));

            obj.MaximumMessageLength=val;

        end

    end

    methods(Static,Access=protected)



        function header=getHeaderImpl(~)

            text=[...
            'Decode LTE tailbiting convolutionally encoded data using a wrap-around Viterbi algorithm. ',newline...
            ,newline...
            ,'To represent hard decisions use ufix1 or boolean input. ',newline...
            ,'To represent soft decisions use sfix input with a wordlength from 2 to 16 bits. '...
            ];

            header=matlab.system.display.Header('ltehdl.internal.ConvolutionalDecoder',...
            'Title','LTE Convolutional Decoder',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end



    end

    methods(Access=protected)



        function icon=getIconImpl(~)
            icon='LTE Convolutional\nDecoder';
        end



        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end



        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            varargout={false,false,false,false};
        end



        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end



        function resetImpl(obj)

            reset(obj.messageExtender);
            reset(obj.delayBalancer);
            reset(obj.metricComputer);
            reset(obj.tracebackUnit);

            obj.dataOut=false;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);

        end



        function setupImpl(obj,~,~)

            obj.messageExtender=ltehdl.internal.ConvolutionalDecoderMessageExtender(...
            'TrainingLength',obj.TrainingLength,...
            'MaximumMessageLength',obj.MaximumMessageLength);

            obj.delayBalancer=dsp.Delay(3);

            obj.metricComputer=ltehdl.internal.ConvolutionalDecoderMetricComputer;

            obj.tracebackUnit=ltehdl.internal.ConvolutionalDecoderTracebackUnit(...
            'TrainingLength',obj.TrainingLength,...
            'MaximumMessageLength',obj.MaximumMessageLength);

            obj.dataOut=false;

            obj.ctrlOut=struct('start',false,'end',false,'valid',false);

        end



        function[dataOut,ctrlOut]=outputImpl(obj,~,~,~,~)

            dataOut=obj.dataOut;
            ctrlOut=obj.ctrlOut;

        end



        function updateImpl(obj,dataIn,ctrlIn)


            [extData,extStart,extEndExt,extValid,extEndMsg]=...
            obj.messageExtender(dataIn,ctrlIn.start,ctrlIn.end,ctrlIn.valid);


            extEndMsgDelayed=obj.delayBalancer(extEndMsg);


            [decisions,decisionsStart,decisionsEnd,decicionsValid,winner,winnerValid]=...
            obj.metricComputer(extData,extStart,extEndExt,extValid);


            [tbDataOut,tbCtrlOut.start,tbCtrlOut.end,tbCtrlOut.valid]=...
            obj.tracebackUnit(decisions,decisionsStart,decisionsEnd,decicionsValid,...
            winner,winnerValid,extEndMsgDelayed);

            if tbCtrlOut.valid
                obj.dataOut=tbDataOut;
            else

                obj.dataOut=false;
            end

            obj.ctrlOut=tbCtrlOut;

        end



        function num=getNumInputsImpl(~)
            num=2;
        end



        function num=getNumOutputsImpl(~)
            num=2;
        end



        function varargout=getInputNamesImpl(~)
            varargout={'data','ctrl'};
        end



        function varargout=getOutputNamesImpl(~)
            varargout={'data','ctrl'};
        end



        function validateInputsImpl(~,dataIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(dataIn,...
                {'single','double','logical','embedded.fi','int8','int16'},...
                {'size',[3,1]},...
                'ConvolutionalDecoder','dataIn');


                if isa(dataIn,'embedded.fi')
                    maxWordLength=16;
                    if issigned(dataIn)
                        coder.internal.errorIf(...
                        (dataIn.WordLength>maxWordLength),...
                        'whdl:LTEConvolutionalDecoder:InvalidInputWordLengthSigned',...
                        tostringInternalSlName(dataIn.numerictype),maxWordLength);
                    else
                        coder.internal.errorIf(...
                        (dataIn.WordLength>1),...
                        'whdl:LTEConvolutionalDecoder:InvalidInputWordLengthUnsigned',...
                        tostringInternalSlName(dataIn.numerictype),maxWordLength);
                    end
                end

                validateattributes(ctrlIn.start,{'logical'},{'scalar'},'ConvolutionalDecoder','startIn');
                validateattributes(ctrlIn.end,{'logical'},{'scalar'},'ConvolutionalDecoder','endIn');
                validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'ConvolutionalDecoder','validIn');

            end

        end





        function varargout=getOutputDataTypeImpl(~)
            varargout={'logical',samplecontrolbustype};
        end



        function varargout=isOutputComplexImpl(~)
            varargout={false,false};
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
