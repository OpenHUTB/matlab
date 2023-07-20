classdef(StrictDefaults)CRCGenerator<matlab.System











































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)








        Polynomial=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];









        InitialState=0;








        DirectMethod(1,1)logical=false;





        ReflectInput(1,1)logical=false;





        ReflectCRCChecksum(1,1)logical=false;

    end

    properties(DiscreteState)
    end

    properties(Nontunable)









        FinalXORValue=0;
    end

    properties(Access=private)
        padZero;
        processMsg;
        processCRC;
        FSMCurrState;
        FSMNextState;
        counter1;
        counter2;
        counter2_delay;
        counter3;
        counter3_delay;
        crcoutreg;
        inMessage;
        dataOut_delay;
        validOut_delay;
        endOut_delay;
        startOut_delay;
        Cnt3_enb;
        outputCRC;
        count_ntype;
        count_ntype1;
        validIn_delay;
        F;
        initVector;
        reg;
        mReg;
        xorValue;
        dm;

        regClr;
        startIn_delay;
        endIn_delay;
        dataIn_delay;
        validIn_conf;

    end

    properties(Nontunable,Access=private)
        depthObj=1;
        crclen=16;
        datalen=16;
        isUInt=true;
        dataclass='uint8';
        isIntIn=false;
    end


    methods
        function obj=CRCGenerator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'Polynomial');
        end

        function set.Polynomial(obj,val)









            obj.validateVectorInputs(val,'strPolynomial');

            if ischar(val)
                obj.Polynomial=commstr2poly(val,'descending');
            elseif any(val~=1&val~=0)
                PolyTemp=commblkCheckPolynomial(val);
                n=size(dec2bin(PolyTemp),2);
                p=coder.const(reshape(feval('int2bit',PolyTemp,(n)),n,[])');
                obj.Polynomial=[1,p];
            elseif length(find((val==1|val==0)))==length(val)
                obj.Polynomial=val;
            else
                error('Input of Polynomial can either be string or row vector with binary / non-binary integer');
            end

            obj.crclen=length(obj.Polynomial)-1;

        end

        function set.InitialState(obj,val)

            validateInitValue(obj,val,1);
            obj.InitialState=val;

        end

        function set.FinalXORValue(obj,val)

            validateInitValue(obj,val,2);
            obj.FinalXORValue=val;
        end

    end


    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function setDiscreteStateImpl(obj,ds)


            fnameList=fieldnames(ds);
            for fnameIdx=1:numel(fnameList)
                fname=fnameList{fnameIdx};
                obj.(fname)=ds.(fname);
            end
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
        end


        function obj=loadObjectImpl(obj,ds,~)

            loadObjectImpl@matlab.System(obj,ds);

            obj.derivePrivPropSettings;
        end


        function derivePrivPropSettings(obj)



            sz_mReg=size(obj.mReg);
            if~isempty(sz_mReg)
                obj.depthObj=sz_mReg(1);
                obj.datalen=sz_mReg(2);
                obj.crclen=sz_mReg(1)*sz_mReg(2);
            end
        end


        function setupImpl(obj,dataIn,ctrlIn)


            name='Input message';
            isScalarIn=isscalar(dataIn);
            obj.isIntIn=isScalarIn&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');
            if obj.isIntIn
                validateattributes(dataIn,{'uint8','uint16','uint32','uint64','embedded.fi','single'},{'scalar','integer'},'CRCGenerator',name);
            else
                if isa(dataIn,'double')
                    validateattributes(dataIn,{'double'},...
                    {'vector','binary','column'},'CRCGenerator',name);
                else
                    validateattributes(dataIn,{'logical','double','single','embedded.fi'},{'vector','binary','column'},'CRCGenerator',name);
                end
            end
            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            if isempty(coder.target)||~eml_ambiguous_types
                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if obj.isIntIn
                    coder.internal.errorIf(isScalarIn&&~obj.isUInt&&issigned(dataIn),...
                    'comm:HDLCRC:UnsignedIntFixptExpected');
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                    if~obj.isUInt
                        coder.internal.errorIf(dataIn.FractionLength~=0,...
                        'comm:HDLCRC:UnsignedIntFixptExpected');
                    end
                end
                tlen=length(obj.Polynomial);
                if tlen>=2&&tlen>=obj.datalen
                    obj.crclen=length(obj.Polynomial(2:end));
                    clenflag=false;
                else
                    clenflag=true;
                end

                coder.internal.errorIf(clenflag||mod(obj.crclen,obj.datalen)~=0,...
                'comm:HDLCRC:InvPolyDataWidth');
                coder.internal.errorIf(obj.ReflectInput&&mod(obj.datalen,8)~=0||obj.datalen<1,...
                'comm:HDLCRC:InvDataWidth');
            end

            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(ctrlIn.start,{'logical'},{'scalar'},'CRCGenerator','startIn');
                validateattributes(ctrlIn.end,{'logical'},{'scalar'},'CRCGenerator','endIn');
                validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'CRCGenerator','validIn');
            end



            clen=obj.crclen;
            obj.depthObj=round(clen/obj.datalen);

            obj.mReg=false(obj.depthObj,obj.datalen);
            obj.dm=false(1,obj.datalen);

            obj.xorValue=validateInitValue(obj,obj.FinalXORValue,2);
            obj.initVector=validateInitValue(obj,obj.InitialState,3);
            obj.reg=obj.initVector;
            obj.crcoutreg=false(1,clen);

            obj.F=false(clen,clen);
            I=eye(clen,clen);[~,c]=size(obj.Polynomial);
            if(c==1)
                p=obj.Polynomial(2:end)';
            else
                p=obj.Polynomial(2:end);
            end
            tF=logical([p',I(:,1:clen-1)]);
            for i=1:obj.datalen-1
                c=obj.GF2multiply(tF,p');
                tF=[c,tF(:,1:clen-1)];
            end
            obj.F=full(tF);
            if clen/obj.datalen==1
                obj.count_ntype=numerictype(0,1,0);
            else
                obj.count_ntype=numerictype(0,ceil(log2(clen/obj.datalen)),0);
            end
            obj.count_ntype1=numerictype(0,ceil(log2(clen/obj.datalen))+1,0);
            obj.FSMNextState=fi(0,0,2,0);
            obj.FSMCurrState=fi(0,0,2,0);
            if~isa(dataIn,'embedded.fi')
                obj.dataOut_delay=cast(zeros(obj.datalen,1),class(dataIn));
            else
                obj.dataOut_delay=fi(false(obj.datalen,1),dataIn.numerictype);
            end
            obj.counter1=fi(0,'numerictype',obj.count_ntype1);
            obj.counter2=fi(0,'numerictype',obj.count_ntype);
            obj.counter2_delay=fi(0,'numerictype',obj.count_ntype);
            obj.counter3=fi(0,'numerictype',obj.count_ntype);
            obj.counter3_delay=fi(0,'numerictype',obj.count_ntype);
            obj.inMessage=false;
            obj.validOut_delay=false;
            obj.endOut_delay=false(1,obj.depthObj+1);
            obj.startOut_delay=false(1,obj.depthObj+2);
            obj.Cnt3_enb=false;
            obj.outputCRC=false;
            obj.processMsg=false;
            obj.padZero=false;
            obj.processCRC=false;
            obj.validIn_delay=false;
            obj.startIn_delay=false;
            obj.endIn_delay=false;

            obj.regClr=false;
            obj.dataIn_delay=false(obj.datalen,1);
            obj.validIn_conf=false(1,obj.depthObj+1);


        end


        function[dataOut,ctrlOut]=...
            stepImpl(obj,dataIn,ctrlIn)


            startIn=ctrlIn.start;
            validIn=ctrlIn.valid;
            endIn=ctrlIn.end;


            [validOutTemp,endOutTemp,validLowFlag]=...
            CRCCtrlFSM(obj,obj.startIn_delay,obj.validIn_delay,obj.endIn_delay,validIn,startIn);
            obj.validIn_conf(2:end)=obj.validIn_conf(1:end-1);
            obj.validIn_conf(1)=validLowFlag;


            validOut=obj.validOut_delay;
            obj.validOut_delay=validOutTemp&obj.validIn_conf(end);
            endOut=obj.endOut_delay(1);
            obj.endOut_delay(1:end-1)=obj.endOut_delay(2:end);
            obj.endOut_delay(end)=endOutTemp;
            startOut=obj.startOut_delay(1);
            obj.startOut_delay(1:end-1)=obj.startOut_delay(2:end);
            obj.startOut_delay(end)=startIn;
            ctrlOut.start=startOut&&validOut;
            ctrlOut.end=endOut;
            ctrlOut.valid=validOut;


            dataOut=DataSigCal(obj,dataIn);


            obj.startIn_delay=startIn;
            obj.validIn_delay=validIn;
            obj.endIn_delay=endIn;

        end


        function resetImpl(obj)
            obj.padZero(:)=0;
            obj.processMsg(:)=0;
            obj.processCRC(:)=0;
            obj.FSMCurrState(:)=0;
            obj.FSMNextState(:)=0;
            obj.counter1(:)=0;
            obj.counter2(:)=0;
            obj.counter2_delay(:)=0;
            obj.counter3(:)=0;
            obj.counter3_delay(:)=0;
            obj.crcoutreg(:)=0;
            obj.inMessage(:)=0;
            obj.dataOut_delay(:)=0;
            obj.validOut_delay(:)=0;
            obj.endOut_delay(:)=0;
            obj.startOut_delay(:)=0;
            obj.Cnt3_enb(:)=0;
            obj.outputCRC(:)=0;


            obj.validIn_delay(:)=0;

            obj.initVector=validateInitValue(obj,obj.InitialState,3);
            obj.reg(:)=0;
            obj.mReg(:)=0;
            obj.xorValue=validateInitValue(obj,obj.FinalXORValue,2);
            obj.dm(:)=0;

            obj.regClr(:)=0;
            obj.startIn_delay(:)=0;
            obj.endIn_delay(:)=0;
            obj.dataIn_delay(:)=0;
            obj.validIn_conf(:)=0;
        end


        function[validOutTemp,endOutTemp,validLowFlag]=...
            CRCCtrlFSM(obj,startIn,validIn,endIn,validIn_pre,startIn_pre)

            if obj.depthObj==1
                depth_minus=fi(obj.depthObj-1,'numerictype',numerictype(0,1,0));
            else
                depth_minus=fi(obj.depthObj-1,'numerictype',obj.count_ntype);
            end
            obj.FSMCurrState=obj.FSMNextState;
            obj.counter2_delay=obj.counter2;
            obj.counter3_delay=obj.counter3;


            switch obj.FSMCurrState
            case fi(0,0,2,0)
                obj.regClr=false;
                obj.processMsg=false;
                obj.padZero=false;
                endOutTemp=false;
                validLowFlag=true;
                if obj.Cnt3_enb
                    validOutTemp=true;
                    obj.outputCRC=true;
                    if obj.counter3==depth_minus
                        obj.Cnt3_enb=false;
                        obj.counter3=fi(0,'numerictype',obj.count_ntype);
                    else
                        obj.counter3=fi(obj.counter3+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                    end
                else
                    validOutTemp=false;
                    obj.outputCRC=false;
                end
                if validIn&&startIn
                    obj.processMsg=true;
                end

                if validIn_pre&&startIn_pre
                    obj.regClr=true;
                    obj.FSMNextState=fi(1,0,2,0);
                    obj.counter1=fi(0,'numerictype',obj.count_ntype1);
                    obj.counter2=fi(0,'numerictype',obj.count_ntype);
                else
                    obj.FSMNextState=fi(0,0,2,0);
                end

            case fi(1,0,2,0)
                obj.regClr=false;
                obj.processMsg=true;
                endOutTemp=false;
                obj.padZero=false;
                obj.counter2=fi(0,'numerictype',obj.count_ntype);
                validLowFlag=true;
                if validIn==false
                    validLowFlag=false;
                end
                if validIn_pre&&startIn_pre
                    obj.regClr=true;
                    obj.FSMNextState=fi(1,0,2,0);
                    obj.counter1=fi(0,'numerictype',obj.count_ntype1);
                    if obj.Cnt3_enb
                        validOutTemp=true;
                        obj.outputCRC=true;
                        if obj.counter3==depth_minus
                            obj.Cnt3_enb=false;
                            obj.counter3=fi(0,'numerictype',obj.count_ntype);
                        else
                            obj.counter3=fi(obj.counter3+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                        end
                    else
                        validOutTemp=false;
                        obj.outputCRC=false;
                    end
                else
                    if obj.Cnt3_enb
                        validOutTemp=true;
                        obj.outputCRC=true;
                    else
                        if obj.counter1==obj.depthObj
                            validOutTemp=true;
                        else
                            validOutTemp=false;
                        end
                        obj.outputCRC=false;
                    end
                    if obj.Cnt3_enb
                        if obj.counter3==depth_minus
                            obj.Cnt3_enb=false;
                            obj.counter3=fi(0,'numerictype',obj.count_ntype);
                        else
                            obj.counter3=fi(obj.counter3+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                        end
                    end
                    if obj.counter1<obj.depthObj
                        obj.counter1=fi(obj.counter1+fi(1,'numerictype',obj.count_ntype1),'numerictype',obj.count_ntype1);
                    end

                    if validIn&&endIn
                        obj.FSMNextState=fi(2,0,2,0);
                    else
                        obj.FSMNextState=fi(1,0,2,0);
                    end
                end

            case fi(2,0,2,0)
                obj.processMsg=false;
                obj.padZero=true;
                obj.regClr=false;
                validLowFlag=true;
                if validIn&&startIn
                    obj.processMsg=true;
                end
                if validIn_pre&&startIn_pre
                    obj.regClr=true;
                    obj.FSMNextState=fi(1,0,2,0);
                    obj.counter1=fi(0,'numerictype',obj.count_ntype1);
                    if obj.counter2==depth_minus
                        validOutTemp=true;
                        endOutTemp=true;
                        obj.Cnt3_enb=true;
                        obj.outputCRC=false;

                        obj.counter2=fi(0,'numerictype',obj.count_ntype);
                        obj.counter3=fi(0,'numerictype',obj.count_ntype);

                    else
                        endOutTemp=false;
                        if obj.Cnt3_enb
                            validOutTemp=true;
                            obj.outputCRC=true;
                            if obj.counter3==depth_minus
                                obj.Cnt3_enb=false;
                                obj.counter3=fi(0,'numerictype',obj.count_ntype);
                            end
                            obj.counter3=fi(obj.counter3+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                        else

                            obj.outputCRC=false;
                            validOutTemp=false;
                            obj.counter2=fi(0,'numerictype',obj.count_ntype);
                            obj.counter3=fi(0,'numerictype',obj.count_ntype);
                        end
                    end
                else
                    if obj.counter1==obj.depthObj
                        validOutTemp=true;
                    else
                        if obj.counter2==depth_minus||obj.Cnt3_enb
                            validOutTemp=true;
                        else
                            obj.counter1=fi(obj.counter1+fi(1,'numerictype',obj.count_ntype1),'numerictype',obj.count_ntype1);
                            validOutTemp=false;
                        end
                    end

                    if obj.Cnt3_enb
                        obj.outputCRC=true;
                        if obj.counter3==depth_minus
                            obj.Cnt3_enb=false;
                            obj.counter3=fi(0,'numerictype',obj.count_ntype);
                        end
                        obj.counter3=fi(obj.counter3+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                    else
                        obj.outputCRC=false;
                    end

                    if obj.counter2==depth_minus
                        obj.FSMNextState=fi(0,0,2,0);
                        endOutTemp=true;
                        obj.Cnt3_enb=true;
                        obj.counter3=fi(0,'numerictype',obj.count_ntype);
                        obj.counter2=fi(0,'numerictype',obj.count_ntype);
                    else
                        obj.FSMNextState=fi(2,0,2,0);
                        endOutTemp=false;
                        obj.counter2=fi(obj.counter2+fi(1,'numerictype',obj.count_ntype),'numerictype',obj.count_ntype);
                    end
                end

            otherwise
                obj.FSMNextState=fi(0,0,2,0);
                validOutTemp=false;
                endOutTemp=false;
                obj.outputCRC=false;
                obj.processMsg=false;
                obj.padZero=false;
                obj.regClr=false;
                validLowFlag=true;
            end
        end


        function dataOut=DataSigCal(obj,dataIn)
            clen=obj.crclen;
            dlen=obj.datalen;
            if obj.isIntIn
                yv=0;
                for i=1:obj.datalen
                    yv=yv+double(obj.dataOut_delay(i))*2^(obj.datalen-i);
                end
                if obj.isUInt
                    dataOut=cast(yv,obj.dataclass);
                else
                    dataOut=fi(yv,dataIn.numerictype);
                end

            else
                dataOut=obj.dataOut_delay;
            end
            if obj.outputCRC
                k=double(obj.counter3_delay);
                ty1=obj.crcoutreg(obj.crclen-k*obj.datalen:-1:obj.crclen+1-(k+1)*obj.datalen);
                ty=ty1(1:dlen);
            else
                if obj.validOut_delay
                    ty=obj.mReg(1,:);
                else
                    ty=false(1,dlen);
                end
            end
            obj.dataOut_delay(:)=ty';
            if obj.padZero
                tm=false(1,dlen);
            else
                tm=obj.dm;
            end

            if clen==dlen
                obj.mReg(1,:)=tm;
            else
                obj.mReg(1:end-1,:)=obj.mReg(2:end,:);
                obj.mReg(end,:)=tm;
            end
            computeCRC(obj);
            if(obj.counter2_delay==obj.depthObj-1)&&(obj.FSMCurrState==fi(2,0,2,0))
                obj.crcoutreg=obj.reg;
                obj.reg=obj.initVector;
            else
                if obj.regClr
                    obj.reg=obj.initVector;
                end
            end
            if 1
                if obj.isIntIn
                    if obj.isUInt
                        tmpVal=logical((dec2bin(dataIn,obj.datalen)-48));
                        obj.dm=tmpVal(1:obj.datalen);
                    else
                        for i=coder.unroll(1:obj.datalen)
                            obj.dm(obj.datalen-i+1)=logical(bitsliceget(dataIn,i,i));
                        end
                    end
                else
                    tmpm=logical(dataIn');
                    obj.dm=tmpm(1:obj.datalen);
                end

            end
        end


        function computeCRC(obj)
            clen=obj.crclen;
            dlen=obj.datalen;
            d=false(1,clen);
            if~obj.padZero&&(obj.validIn_delay&&obj.processMsg)
                messagein=obj.dm;
                if(obj.ReflectInput)
                    for k=1:dlen/8
                        newmessage_byte=messagein(1+(k-1)*8:8*k);
                        messagein(1+(k-1)*8:8*k)=fliplr(newmessage_byte);
                    end
                end
                d(clen-dlen+1:clen)=messagein;
            end

            if(obj.validIn_delay&&obj.processMsg)||obj.padZero

                a=false(1,obj.crclen);
                for j=1:clen
                    t1=and(obj.F(j,1),obj.reg(clen));
                    for k=2:clen
                        t2=and(obj.F(j,k),obj.reg(clen-k+1));
                        t1=xor(t1,t2);
                    end
                    a(clen-j+1)=xor(t1,d(j));
                end

                obj.reg=a;
            end

            if(obj.counter2_delay==obj.depthObj-1)&&(obj.FSMCurrState==fi(2,0,2,0))

                if(obj.ReflectCRCChecksum)
                    obj.reg=logical(fliplr(obj.reg));
                end
                obj.reg=xor(obj.reg,obj.xorValue);
            end
        end


        function y=validateInitValue(obj,val,flag)
            if(flag==1)||(flag==3)
                para='InitialState';
            else
                para='FinalXORValue';
            end

            obj.validateVectorInputs(val,para);
            coder.internal.errorIf(length(val)~=obj.crclen&&length(val)~=1,...
            'comm:HDLCRC:NotSameLength');
            if length(val)==1
                y=logical(val*true(1,obj.crclen));
            else
                y=logical(reshape(val(end:-1:1),1,length(val)));
            end

            coder.extrinsic('crcConvInits');

            if(flag==3)&&(obj.DirectMethod)
                if isempty(coder.target)
                    convy=crcConvInits(y,obj.Polynomial(2:end));
                else
                    convy=coder.internal.const(crcConvInits(y,obj.Polynomial(2:end)));
                end
                y=logical(reshape(convy(end:-1:1),1,length(convy)));
            end
        end


        function num=getNumInputsImpl(~)
            num=2;
        end


        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon='CommCRCGenerator';
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
        end


        function varargout=getOutputSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,2);
        end


        function varargout=isOutputComplexImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=propagatedInputComplexity(obj,2);
        end


        function varargout=getOutputDataTypeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}=samplecontrolbustype;
        end


        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,2);
        end
    end


    methods(Static,Access=private)
        function validateVectorInputs(x,name)
            if isa(x,'double')

                validateattributes(x,{'double'},{'vector'},'CRCGenerator',name);
            else
                validateattributes(x,{'logical','double','char'},{'vector'},'CRCGenerator',name);

            end
        end

        function y=GF2multiply(A,B)

            [rowA,colA]=size(A);
            colB=size(B,2);
            y=false(rowA,colB);
            for j=1:colB
                for i=1:rowA
                    t=false;
                    for k=1:colA
                        t=xor(t,and(A(i,k),B(k,j)));
                    end
                    y(i,j)=t;
                end
            end
        end
    end


    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=true;
        end
    end
end
