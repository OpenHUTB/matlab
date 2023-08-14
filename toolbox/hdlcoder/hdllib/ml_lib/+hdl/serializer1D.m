classdef(StrictDefaults,Hidden)serializer1D<matlab.System























%#codegen
%#ok<*EMCLS>



    properties(Nontunable)


        Ratio=1;



        IdleCycles=0;
    end

    properties(Access=private)
        pCnt;
        pMatrixBuffer;
        pDataInValid;
    end

    methods
        function obj=serializer1D(varargin)
            coder.allowpcode('plain');
            obj.pCnt=int32(0);
            setProperties(obj,nargin,varargin{:});
        end

        function set.Ratio(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'','Ratio');%#ok<EMCA>
            obj.Ratio=val;
        end

        function set.IdleCycles(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>=',0},'','IdleCycles');%#ok<EMCA>
            obj.IdleCycles=val;
        end

    end

    methods(Access=protected)
        function[dataOut,startOut,validOut]=stepImpl(obj,dataIn,validIn)

            dataInLen=length(dataIn);
            dataOutLen=(dataInLen-mod(dataInLen,obj.Ratio))/obj.Ratio;
            dataOutCol=obj.Ratio;

            if obj.pCnt==0
                obj.pDataInValid=validIn;
            end

            if obj.Ratio==1
                dataOut=dataIn;
            else
                dataIntemp=reshape(dataIn,1,dataInLen);
                dataInBegin=dataIntemp(1:dataOutLen).';
                dataInToLoad=dataIntemp(dataOutLen+1:end);
                dataEnd=dataIntemp(dataInLen-dataOutLen+1:dataInLen).';
                if obj.pCnt==0
                    dataOutTemp=dataInBegin;
                else
                    dataOutTemp=obj.pMatrixBuffer(:,1);
                end

                dataOut=dataOutTemp;

                if obj.pCnt==0
                    obj.pMatrixBuffer=reshape(dataInToLoad,dataOutLen,dataOutCol-1);
                else
                    matrixBufferTemp=obj.pMatrixBuffer(:,(2:end));
                    obj.pMatrixBuffer=[matrixBufferTemp,dataEnd];
                end
            end

            startOut=((obj.pCnt==0)&&obj.pDataInValid);
            validOut=obj.pDataInValid&&(obj.pCnt<obj.Ratio);


            if obj.pCnt==int32(obj.Ratio+obj.IdleCycles-1)
                obj.pCnt=int32(0);
            else
                obj.pCnt=obj.pCnt+int32(1);
            end

        end



        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='dataIn';
            varargout{2}='validIn';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='dataOut';
            varargout{2}='startOut';
            varargout{3}='validOut';
        end

        function flag=isInactivePropertyImpl(~,~)
            flag=false;
        end

        function icon=getIconImpl(~)
            icon=sprintf('Serializer\n1D');
        end

        function resetImpl(obj)
            obj.pCnt=int32(0);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.pCnt=obj.pCnt;
                s.pMatrixBuffer=obj.pMatrixBuffer;
                s.pDataInValid=obj.pDataInValid;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.pCnt=s.pCnt;
                obj.pMatrixBuffer=s.pMatrixBuffer;
                obj.pDataInValid=s.pDataInValid;
            end

            loadObjectImpl@matlab.System(obj,s);
        end

        function setupImpl(obj,dataIn,validIn)

            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');%#ok<EMCA>
            end

            obj.pCnt=int32(0);
            obj.pDataInValid=true;

            dataInLen=length(dataIn);
            dataOutLen=(dataInLen-mod(dataInLen,obj.Ratio))/obj.Ratio;
            dataOutCol=obj.Ratio;

            obj.pMatrixBuffer=cast(zeros(dataOutLen,dataOutCol-1),'like',dataIn);


        end



        function varargout=getOutputSizeImpl(obj)
            a=propagatedInputSize(obj,1);
            if a(1)>=a(2)
                dataInLen=a(1);
                coder.internal.errorIf((a(2)~=1),...
                'hdlsllib:hdlsllib:InputVector');
            else
                dataInLen=a(2);
                coder.internal.errorIf((a(1)~=1),...
                'hdlsllib:hdlsllib:InputVector');
            end

            coder.internal.errorIf((mod(dataInLen,obj.Ratio)~=0),...
            'hdlsllib:hdlsllib:InvalidSerRatio','Serializer1D');

            dataOutLen=(dataInLen-mod(dataInLen,obj.Ratio))/obj.Ratio;

            varargout{1}=dataOutLen;
            varargout{2}=1;
            varargout{3}=1;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}='logical';
            varargout{3}='logical';
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=true;
            varargout{3}=true;
        end

        function varargout=isOutputComplexImpl(obj)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;
        end

        function modes=getExecutionSemanticsImpl(obj)%#ok<MANU>

            modes={'Classic','Synchronous'};%#ok<EMCA>
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('hdl.serializer1D',...
            'Title','One dimension serializer');
        end

        function group=getPropertyGroupsImpl
            p1=matlab.system.display.internal.Property('Ratio',...
            'Description','Ratio (Input Vector Size/Output Vector Size)');
            p2=matlab.system.display.internal.Property('IdleCycles',...
            'Description','Idle Cycles');

            group=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{p1,p2});%#ok<EMCA>
        end

    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end
end


