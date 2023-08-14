classdef(StrictDefaults)RSEncoder<matlab.System




%#codegen
%#ok<*EMCLS>

    properties(Nontunable)

















        CodewordLength=7;




        MessageLength=3;







        PrimitivePolynomialSource='Auto';










        PrimitivePolynomial=[1,0,1,1];





        BSource='Auto';





        B=1;



        PuncturePatternSource(1,1)logical=false;









        PuncturePattern=[ones(2,1);zeros(2,1)];
    end
    properties(Constant,Hidden)
        PrimitivePolynomialSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});



        BSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Access=private)

        MultTable;
        PowerTable;
        Corr;
        WordSize;

        InReg;
        StartReg;
        EndReg;
        DVReg;
        PrevReg;
        States;

        CodeCount;
        InPacket;
        OutputCode;
        inPorts;

        nextFrame;
        nextFrameCounter;
        counterLoad;
        InpacketNxt;
        dataOutDelay;
        startOutDelay;
        endOutDelay;
        validOutDelay;
        samplecount;
        samplecountload;
        sendEndOut;
        sendEndOutDel;
    end
    methods(Access=public)
        function latency=getLatency(obj)
            if obj.PuncturePatternSource
                latency=2;
            else
                latency=1;
            end
        end
    end
    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('commhdl.internal.RSEncoder',...
            'ShowSourceLink',false,...
            'Title','RS Encoder');
        end
    end

    methods
        function obj=RSEncoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'CodewordLength','MessageLength');
        end
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


            s.MultTable=obj.MultTable;
            s.PowerTable=obj.PowerTable;
            s.Corr=obj.Corr;
            s.WordSize=obj.WordSize;



            s.InReg=obj.InReg;
            s.StartReg=obj.StartReg;
            s.EndReg=obj.EndReg;
            s.DVReg=obj.DVReg;
            s.PrevReg=obj.PrevReg;
            s.States=obj.States;

            s.CodeCount=obj.CodeCount;
            s.InPacket=obj.InPacket;
            s.OutputCode=obj.OutputCode;

            s.nextFrame=obj.nextFrame;
            s.nextFrameCounter=obj.nextFrameCounter;
            s.counterLoad=obj.counterLoad;
            s.InpacketNxt=obj.InpacketNxt;
            s.dataOutDelay=obj.dataOutDelay;
            s.startOutDelay=obj.startOutDelay;
            s.endOutDelay=obj.endOutDelay;
            s.validOutDelay=obj.validOutDelay;
            s.samplecount=obj.samplecount;
            s.samplecountload=obj.samplecountload;
        end


        function obj=loadObjectImpl(obj,s,~)


            loadObjectImpl@matlab.System(obj,s);

            f=fieldnames(s);
            for ii=1:numel(f)
                obj.(f{ii})=s.(f{ii});
            end

        end

        function resetImpl(obj)
            obj.resetStates;

            obj.InReg=uint32(0);
            obj.StartReg=false;
            obj.EndReg=false;
            obj.DVReg=false;
            obj.PrevReg=uint32(0);
        end
    end

    methods(Access=protected)

        function[varargout]=outputImpl(obj,x,startIn,endIn,validIn,varargin)%#ok<INUSD>
            obj_InPacket=obj.InPacket;
            obj_OutputCode=obj.OutputCode;



            y=cast(obj.PrevReg,'like',x);
            startOut=obj.StartReg;
            endOut=false;
            if obj_InPacket
                validOut=obj.DVReg;
            else
                validOut=false;
            end

            if obj.StartReg&&obj.DVReg
                obj_InPacket=true;
                obj_OutputCode=false;
                startOut=true;
            end





            if obj_InPacket&&obj.DVReg

                y=cast(obj.InReg,'like',x);
                validOut=true;
            end

            if obj_OutputCode&&~obj.StartReg
                if obj.PuncturePatternSource
                    states=obj.States(logical(obj.PuncturePattern));
                    paritySize=sum(obj.PuncturePattern);
                else
                    states=obj.States;
                    paritySize=2*obj.Corr;
                end

                y=cast(states(obj.CodeCount),'like',x);

                validOut=true;

                if obj.CodeCount==paritySize
                    endOut=true;
                else
                    endOut=false;
                end




            end

            if obj.PuncturePatternSource
                ctrl.start=obj.startOutDelay;
                ctrl.end=obj.endOutDelay;
                ctrl.valid=obj.validOutDelay;
                if ctrl.valid
                    varargout{1}=obj.dataOutDelay;
                else
                    varargout{1}=cast(0,'like',obj.dataOutDelay);
                end

                varargout{2}=ctrl;
                obj.dataOutDelay=y;
                obj.startOutDelay=startOut;
                obj.endOutDelay=endOut;
                obj.validOutDelay=validOut;

            else
                ctrl.start=startOut;
                ctrl.end=endOut;
                ctrl.valid=validOut;
                if ctrl.valid
                    varargout{1}=y;
                else
                    varargout{1}=cast(0,'like',y);
                end

                varargout{2}=ctrl;

            end
            varargout{3}=obj.nextFrame;
        end

        function updateImpl(obj,x,ctrl)

            startIn=ctrl.start;
            if ctrl.start&&ctrl.valid
                obj.samplecountload=true;
                obj.samplecount=uint32(0);
            end
            if obj.samplecountload&&ctrl.valid
                obj.samplecount(:)=obj.samplecount+1;
                validIn=ctrl.valid;
                obj.sendEndOutDel=obj.sendEndOut;
                if~obj.sendEndOutDel
                    obj.resetStates;
                end
                if obj.samplecount==obj.MessageLength
                    if ctrl.end
                        obj.samplecountload=false;
                        obj.samplecount=uint32(0);
                        endIn=true;
                    else
                        endIn=false;
                        obj.sendEndOut=false;
                        obj.nextFrame=true;

                    end
                else
                    if ctrl.end
                        obj.samplecountload=false;
                        obj.samplecount=uint32(0);
                        endIn=true;
                    else
                        endIn=false;
                    end
                end
            else
                startIn=false;
                validIn=false;
                endIn=false;
            end




            if isempty(obj.States)
                obj.resetStates;
                obj.InReg=uint32(0);
                obj.StartReg=false;
                obj.EndReg=false;
                obj.DVReg=false;
                obj.PrevReg=uint32(0);
                obj.samplecount=uint32(0);
            end



            y=cast(obj.PrevReg,'like',x);

            if obj.StartReg&&obj.DVReg
                obj.resetStates;
                obj.InPacket=true;
                obj.OutputCode=false;


            end

            if obj.InPacket&&obj.DVReg
                gfx=obj.InReg;
                gtemp=bitand(bitxor(gfx,obj.States(1)),(2^obj.WordSize)-1);
                gvec=obj.MultTable(:,gtemp+1);
                for ii=1:2*obj.Corr-1
                    obj.States(ii)=bitxor(obj.States(ii+1),gvec(ii));
                end

                tmpindex=2*obj.Corr;
                obj.States(tmpindex)=gvec(tmpindex);
                y=cast(obj.InReg,'like',x);


            end

            if obj.OutputCode&&~obj.StartReg
                if obj.PuncturePatternSource
                    states=obj.States(logical(obj.PuncturePattern));
                    paritySize=sum(obj.PuncturePattern);
                else
                    states=obj.States;
                    paritySize=2*obj.Corr;
                end

                y=cast(states(obj.CodeCount),'like',x);


                if obj.CodeCount==paritySize

                    obj.CodeCount=1;
                    obj.OutputCode=false;
                else
                    obj.CodeCount=obj.CodeCount+1;
                end
            end

            if obj.InPacket&&obj.EndReg&&obj.DVReg
                obj.OutputCode=true;
                obj.InPacket=false;
                obj.CodeCount=1;
            end


            obj.InReg=uint32(x);
            obj.StartReg=startIn&&validIn;
            obj.EndReg=endIn&&validIn;
            obj.DVReg=validIn;
            obj.PrevReg=uint32(y);
            nextFrameCtrl(obj);
        end

        function nextFrameCtrl(obj)
            if obj.StartReg&&obj.DVReg
                obj.nextFrame=false;
                obj.nextFrameCounter(:)=0;
                obj.counterLoad=false;
                obj.InpacketNxt=true;
            end
            if obj.InpacketNxt&&obj.EndReg
                obj.InpacketNxt=false;
                obj.counterLoad=true;
                obj.nextFrameCounter(:)=0;
            end
            if obj.counterLoad
                obj.nextFrameCounter(:)=obj.nextFrameCounter(:)+1;
                if obj.nextFrameCounter(:)>2*obj.Corr
                    obj.nextFrameCounter(:)=0;
                    obj.counterLoad=false;
                    obj.nextFrame=true;
                end
            end
        end
        function varargout=getOutputSizeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));

            varargout{1}=1;
            varargout{2}=propagatedInputSize(obj,2);
            varargout{3}=1;
        end

        function varargout=isOutputComplexImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputDataType(obj,1);

            varargout{2}=samplecontrolbustype;
            varargout{3}='logical';
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;

        end

        function resetStates(obj)
            obj.States=zeros(2*obj.Corr,1,'uint32');
            obj.InPacket=false;
            obj.OutputCode=false;
            obj.CodeCount=1;
            obj.sendEndOut=true;
            obj.sendEndOutDel=true;
        end

        function validateInputsImpl(obj,varargin)
            dataIn=varargin{1};
            ctrlIn=varargin{2};


            validateattributes(dataIn,{'numeric','embedded.fi','logical'},{'scalar'},'RSEncoder','dataIn');
            wl=ceil(log2(obj.CodewordLength));
            if isa(dataIn,'int8')||isa(dataIn,'int16')
                coder.internal.error('whdl:RSCode:InputUnsigned');
            end
            if isa(dataIn,'embedded.fi')
                if strcmp(dataIn.Signedness,'Signed')&&dataIn.FractionLength>0
                    coder.internal.error('whdl:RSCode:InputUnsignedFracLenZero');
                end
                if strcmp(dataIn.Signedness,'Signed')
                    coder.internal.error('whdl:RSCode:InputUnsigned');
                end
                if dataIn.FractionLength>0
                    coder.internal.error('whdl:RSCode:InputFracLenZero');
                end
            end
            if~(isa(dataIn,'double')||isa(dataIn,'single'))
                [inWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(dataIn);
                coder.internal.errorIf(inWL~=ceil(log2(obj.CodewordLength)),...
                'whdl:RSCode:InputWLMisMatch',wl,obj.CodewordLength);
            end




            if isstruct(ctrlIn)
                test=fieldnames(ctrlIn);
                truth={'start';'end';'valid'};
                if isequal(test,truth)
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'RSEncoder','startIn');
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'RSEncoder','endIn');
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'RSEncoder','validIn');
                else
                    coder.internal.error('whdl:RSCode:InvalidCtrlBusType');
                end
            else
                coder.internal.error('whdl:RSCode:InvalidCtrlBusType');
            end
            obj.inPorts=~isempty(dataIn);
        end
        function validatePropertiesImpl(obj)

            validateattributes(obj.CodewordLength,...
            {'numeric'},{'scalar','integer','>=',7,'<=',65535},'RSEncoder','CodewordLength');

            validateattributes(obj.MessageLength,...
            {'numeric'},{'scalar','integer','>=',3,'<=',obj.CodewordLength-2},'RSEncoder','MessageLength');

            validateattributes(obj.CodewordLength-obj.MessageLength,...
            {'numeric'},{'scalar','even','integer','>=',2},'RSEncoder','CodewordLength - MessageLength');

            if~strcmp(obj.PrimitivePolynomialSource,'Auto')
                validateattributes(obj.PrimitivePolynomial,{'numeric'},{'integer'},'RSEncoder','PrimitivePolynomial');
                [row,col]=size(obj.PrimitivePolynomial);
                ind=find(obj.PrimitivePolynomial>1);
                if(row>1&&col>1)
                    coder.internal.error('whdl:RSCode:InvalidPrimPoly');
                end
                len=length(obj.PrimitivePolynomial);
                if len>1
                    if~isempty(ind)
                        coder.internal.error('whdl:RSCode:InvalidBinaryInput');
                    else
                        val1=bin2dec(num2str(obj.PrimitivePolynomial));
                    end
                else
                    val1=obj.PrimitivePolynomial;
                end
                wordlength=ceil(log2(obj.CodewordLength));
                if val1<=2^wordlength-1||val1>=2^(wordlength+1)
                    coder.internal.error('whdl:RSCode:InvalidPrimPolyRange',2^wordlength-1,2^(wordlength+1),obj.CodewordLength);
                end
            end


            if~strcmp(obj.BSource,'Auto')
                validateattributes(obj.B,{'numeric'},{'scalar','integer','>=',0,'<=',obj.CodewordLength},'RSEncoder','B');
            end
            if obj.PuncturePatternSource
                validateattributes(obj.PuncturePattern,{'numeric'},...
                {'vector','integer','>=',0,'<=',1,'numel',obj.CodewordLength-obj.MessageLength},...
                'RSEncoder','PuncturePattern');
                if sum(obj.PuncturePattern)==0
                    coder.internal.error('whdl:RSCode:InvalidPunctureAllZeros');
                end
            end
        end
        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,varargin)








            coder.extrinsic('HDLRSGenPoly');

            if strcmp(obj.PrimitivePolynomialSource,'Auto')
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=coder.internal.const(HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B));
                end
            else
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=coder.internal.const(HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial));
                end
            end

            obj.MultTable=tMultTable;
            obj.PowerTable=tPowerTable;
            obj.Corr=tCorr;
            obj.WordSize=tWordSize;
            obj.resetStates;

            obj.InReg=uint32(0);
            obj.StartReg=false;
            obj.EndReg=false;
            obj.DVReg=false;
            obj.PrevReg=uint32(0);
            obj.nextFrame=true;
            obj.nextFrameCounter=uint32(0);
            obj.counterLoad=false;
            obj.InpacketNxt=false;
            obj.samplecount=uint32(0);
            obj.samplecountload=false;
            if obj.PuncturePatternSource
                obj.dataOutDelay=cast(0,'like',varargin{1});
                obj.startOutDelay=false;
                obj.endOutDelay=false;
                obj.validOutDelay=false;
            end
        end
        function icon=getIconImpl(obj)
            if isempty(obj.inPorts)
                icon=sprintf('RS Encoder\nLatency = --');
            else
                if~isempty(obj.CodewordLength)&&~isempty(obj.MessageLength)&&~isempty(obj.PrimitivePolynomial)&&~isempty(obj.B)
                    icon=sprintf('RS Encoder\nLatency = %d',getLatency(obj));
                else
                    icon=sprintf('RS Encoder');
                end
            end
        end

        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='nextFrame';
        end

        function num=getNumInputsImpl(obj)%#ok
            num=2;
        end

        function num=getNumOutputsImpl(obj)%#ok
            num=3;
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'PrimitivePolynomial'
                if strcmp(obj.PrimitivePolynomialSource,'Auto')
                    flag=true;
                end
            case 'B'
                if strcmp(obj.BSource,'Auto')
                    flag=true;
                end
            case 'PuncturePattern'
                if~obj.PuncturePatternSource
                    flag=true;
                end
            end
        end
    end


    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end