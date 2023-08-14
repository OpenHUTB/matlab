classdef(StrictDefaults,Hidden)deserializer1D<matlab.System

































%#codegen
%#ok<*EMCLS>



    properties(Nontunable)


        Ratio=1;



        IdleCycles=0;



        InitialCondition=0;



        StartInPortEnb(1,1)logical=false;



        ValidInPortEnb(1,1)logical=false;

    end

    properties(Access=private)
        pCnt;
        pCntValidOut;
        pMatrixBuffer;
        pDataBuffer;
        pValidOutBuffer;
        pStartsCollect;
    end

    methods
        function obj=deserializer1D(varargin)
            coder.allowpcode('plain');
            obj.pCnt=int32(0);
            obj.pCntValidOut=int32(0);
            obj.pValidOutBuffer=false;
            obj.pStartsCollect=false;
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

        function set.InitialCondition(obj,val)
            validateattributes(val,{'numeric'},{'scalar'},'','InitialCondition');%#ok<EMCA>
            obj.InitialCondition=val;
        end
    end

    methods(Access=protected)
        function[dataOut,validOut]=outputImpl(obj,dataIn,startIn,validIn)%#ok<INUSD>
            dataInLen=length(dataIn);
            dataOutLen=dataInLen*obj.Ratio;



            if obj.pCntValidOut==int32(obj.Ratio+obj.IdleCycles)
                obj.pCntValidOut=int32(0);
                obj.pValidOutBuffer=false;
            end

            if obj.pCnt==int32(obj.Ratio)
                obj.pDataBuffer=reshape(obj.pMatrixBuffer,1,dataOutLen);
                obj.pValidOutBuffer=true;
                obj.pCntValidOut=int32(0);
                obj.pMatrixBuffer=cast(repmat(obj.InitialCondition,dataInLen,obj.Ratio),'like',dataIn);
            else
                obj.pDataBuffer=obj.pDataBuffer;
            end

            dataOut=obj.pDataBuffer.';

            validOut=obj.pValidOutBuffer;

        end

        function updateImpl(obj,dataIn,startIn,validIn)
            dataInLen=length(dataIn);
            if(~obj.ValidInPortEnb&&obj.StartInPortEnb&&startIn)||(obj.ValidInPortEnb&&obj.StartInPortEnb&&startIn&&validIn)
                if(obj.pCnt>int32(0))&&(obj.pCnt<int32(obj.Ratio))
                    obj.pMatrixBuffer=cast(repmat(obj.InitialCondition,dataInLen,obj.Ratio),'like',dataIn);
                end
            end


            if(obj.StartInPortEnb&&startIn)||(~obj.StartInPortEnb&&obj.ValidInPortEnb&&validIn)
                obj.pStartsCollect=true;
            end


            if~obj.ValidInPortEnb&&~obj.StartInPortEnb
                if obj.pCnt==int32(obj.Ratio+obj.IdleCycles)
                    obj.pCnt=int32(0);
                end
            elseif~obj.ValidInPortEnb&&obj.StartInPortEnb
                if startIn
                    obj.pCnt=int32(0);
                elseif obj.pCnt==int32(obj.Ratio+obj.IdleCycles+1)
                    obj.pCnt=obj.pCnt;
                end
            elseif obj.ValidInPortEnb&&~obj.StartInPortEnb
                if obj.pCnt==int32(obj.Ratio)
                    obj.pCnt=int32(0);
                end
            elseif obj.ValidInPortEnb&&obj.StartInPortEnb
                if startIn&&validIn
                    obj.pCnt=int32(0);
                elseif obj.pCnt==int32(obj.Ratio+1)
                    obj.pCnt=obj.pCnt;
                end
            end


            if~obj.ValidInPortEnb
                if~obj.StartInPortEnb||(obj.StartInPortEnb&&obj.pStartsCollect)
                    obj.pCnt=obj.pCnt+int32(1);
                    if obj.pCnt<=int32(obj.Ratio)
                        dataInTemp=reshape(dataIn,dataInLen,1);
                        obj.pMatrixBuffer(:,obj.pCnt)=dataInTemp;
                    end
                end
            else
                if validIn&&(obj.pCnt<=int32(obj.Ratio))&&obj.pStartsCollect
                    obj.pCnt=obj.pCnt+int32(1);
                    if obj.pCnt<=int32(obj.Ratio)
                        dataInTemp=reshape(dataIn,dataInLen,1);
                        obj.pMatrixBuffer(:,obj.pCnt)=dataInTemp;
                    end
                elseif~validIn&&(obj.pCnt==int32(obj.Ratio))
                    obj.pCnt=obj.pCnt+int32(1);
                end
            end

            if obj.pValidOutBuffer
                obj.pCntValidOut=obj.pCntValidOut+int32(1);
            end

        end

        function[flag1,flag2,flag3]=isInputDirectFeedthroughImpl(obj,dataIn,startIn,validIn)%#ok<INUSD>
            flag1=false;
            flag2=false;
            flag3=false;
        end

        function num=getNumInputsImpl(~)
            num=3;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='dataIn';
            varargout{2}='startIn';
            varargout{3}='validIn';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='dataOut';
            varargout{2}='validOut';
        end

        function flag=isInactivePropertyImpl(~,~)
            flag=false;
        end

        function icon=getIconImpl(~)
            icon=sprintf('Deserializer\n1D');
        end

        function resetImpl(obj)
            obj.pCnt=int32(0);
            obj.pCntValidOut=int32(0);
            obj.pValidOutBuffer=false;
            obj.pStartsCollect=false;
        end

        function setupImpl(obj,dataIn,startIn,validIn)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(startIn,{'logical'},{'scalar'},'','startIn');%#ok<EMCA>
                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');%#ok<EMCA>
            end

            obj.pCnt=int32(0);
            obj.pCntValidOut=int32(0);
            obj.pValidOutBuffer=false;
            obj.pStartsCollect=false;

            dataInLen=length(dataIn);
            dataOutLen=dataInLen*obj.Ratio;
            obj.pMatrixBuffer=cast(repmat(obj.InitialCondition,dataInLen,obj.Ratio),'like',dataIn);
            obj.pDataBuffer=cast(repmat(obj.InitialCondition,1,dataOutLen),'like',dataIn);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.pCnt=obj.pCnt;
                s.pCntValidOut=obj.pCntValidOut;
                s.pMatrixBuffer=obj.pMatrixBuffer;
                s.pDataBuffer=obj.pDataBuffer;
                s.pValidOutBuffer=obj.pValidOutBuffer;
                s.pStartsCollect=obj.pStartsCollect;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.pCnt=s.pCnt;
                obj.pCntValidOut=s.pCntValidOut;
                obj.pMatrixBuffer=s.pMatrixBuffer;
                obj.pDataBuffer=s.pDataBuffer;
                obj.pValidOutBuffer=s.pValidOutBuffer;
                obj.pStartsCollect=s.pStartsCollect;
            end

            loadObjectImpl@matlab.System(obj,s);
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
            dataOutLen=dataInLen*obj.Ratio;

            varargout{1}=dataOutLen;
            varargout{2}=1;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}='logical';
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=true;
        end

        function varargout=isOutputComplexImpl(obj)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
        end

        function modes=getExecutionSemanticsImpl(obj)%#ok<MANU>

            modes={'Classic','Synchronous'};%#ok<EMCA>
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('hdl.deserializer1D',...
            'Title','One dimension deserializer');
        end

        function group=getPropertyGroupsImpl
            p1=matlab.system.display.internal.Property('Ratio',...
            'Description','Ratio (Output Vector Size/Input Vector Size)');
            p2=matlab.system.display.internal.Property('IdleCycles',...
            'Description','Idle Cycles');
            p3=matlab.system.display.internal.Property('InitialCondition',...
            'Description','Initial condition');
            p4=matlab.system.display.internal.Property('StartInPortEnb',...
            'Description','startIn');
            p5=matlab.system.display.internal.Property('ValidInPortEnb',...
            'Description','validIn');

            group=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{p1,p2,p3,p4,p5});%#ok<EMCA>
        end

    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end
end


