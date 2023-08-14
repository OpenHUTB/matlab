classdef(StrictDefaults)HDLCRCGenerator<matlab.System
























































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)






        Polynomial=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];









        InitialState=0;








        DirectMethod(1,1)logical=false;




        ReflectInput(1,1)logical=false;





        ReflectCRCChecksum(1,1)logical=false;











        FinalXORValue=0;
    end

    properties(DiscreteState)

        processMsg;
        padZero;

        tStartOut;
        tEndOut;

        startOutReg;
        endOutReg;
        validOutReg;
        yOutReg;
        F;
        reg;
        crcoutreg;
        mReg;
        dm;
        xorValue;
        initVector;
        validIn_delay;
        endIn_delay;
        startOutbuffer;
        validInReg;
        sysenb;
        processCRC;
        outputCRC;
        counter1;
        counter2;
    end


    properties(Nontunable,Access=private)
        crclen=16;
        datalen;
        depth=1;
        isUInt=true;
        dataclass='uint8';
        isIntIn=false;
        inDisp;
    end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

    methods
        function obj=HDLCRCGenerator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','Communication_Toolbox'))
                    error(message('comm:HDLCRC:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Communication_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'Polynomial');
        end

        function set.Polynomial(obj,val)
            obj.validateVectorInputs(val,'Polynomial');
            val=reshape(val,[1,length(val)]);
            obj.Polynomial=val;
            obj.crclen=length(val)-1;%#ok<*MCSUP>

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

    methods(Access=public)
        function latency=getLatency(obj)
            latency=obj.crclen/obj.datalen+2;
        end
    end

    methods(Access=protected)


        function resetImpl(obj)



            obj.processMsg=false;
            obj.padZero=false;
            obj.tStartOut=false;
            obj.tEndOut=false;

            obj.startOutReg=false;
            obj.endOutReg=false;
            obj.validOutReg=false;
            if~isempty(obj.yOutReg)

                if isa(obj.yOutReg,'double')
                    obj.yOutReg(:)=0;
                else
                    obj.yOutReg(:)=false;
                end
            end


            obj.mReg=false(obj.depth,obj.datalen);
            obj.dm=false(1,obj.datalen);
            obj.xorValue=validateInitValue(obj,obj.FinalXORValue,2);
            obj.initVector=validateInitValue(obj,obj.InitialState,3);
            obj.reg=obj.initVector;
            obj.validIn_delay=false;
            obj.endIn_delay=false;
            obj.startOutbuffer=false(1,obj.depth);
            obj.validInReg=false(1,obj.depth);
            obj.sysenb=false;
            obj.processCRC=false;
            obj.outputCRC=false;
            obj.counter1=0;
            obj.counter2=0;
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function setDiscreteStateImpl(obj,ds)


            fnameList=fieldnames(ds);

...
...
...
...
...
...
...
...
...
...

            for fnameIdx=1:numel(fnameList)
                fname=fnameList{fnameIdx};
                obj.(fname)=ds.(fname);
            end






        end

        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


...
...
...
...
...
        end

        function obj=loadObjectImpl(obj,ds,~)


...
...
...
...
...
...
...
...

            loadObjectImpl@matlab.System(obj,ds);

            obj.derivePrivPropSettings;
        end

        function derivePrivPropSettings(obj)




            sz_mReg=size(obj.mReg);
            if~isempty(sz_mReg)
                obj.depth=sz_mReg(1);
                obj.datalen=sz_mReg(2);
                obj.crclen=sz_mReg(1)*sz_mReg(2);
            end
        end

    end

    methods(Access=protected)

        function[y,startOut,endOut,validOut]=outputImpl(obj,m,startIn,endIn,validIn)%#ok<INUSD>

            startOut=obj.startOutReg;
            endOut=obj.endOutReg;
            validOut=obj.validOutReg;
            if obj.isIntIn
                yv=0;
                for i=1:obj.datalen
                    yv=yv+obj.yOutReg(i)*2^(obj.datalen-i);
                end
                if obj.isUInt
                    y=cast(yv,obj.dataclass);
                else
                    y=fi(yv,m.numerictype);
                end

            else
                y=obj.yOutReg;
            end

        end

        function updateImpl(obj,m,startIn,endIn,validIn)

            clen=obj.crclen;
            dlen=obj.datalen;


            obj.startOutReg=obj.startOutbuffer(1);
            if obj.sysenb
                if(obj.depth>1)
                    obj.startOutbuffer(1:end-1)=obj.startOutbuffer(2:end);
                end
                obj.startOutbuffer(end)=obj.tStartOut;
            end


            if obj.tStartOut
                obj.tStartOut=false;
            end

            obj.endOutReg=obj.tEndOut;





            if obj.outputCRC
                k=obj.counter2;
                ty1=obj.crcoutreg(clen-k*dlen:-1:clen+1-(k+1)*dlen);
                ty=ty1(1:dlen);
                obj.validOutReg=obj.outputCRC;
            else

                obj.validOutReg=obj.validInReg(1);
                if obj.validOutReg

                    ty=obj.mReg(1,:);
                else
                    ty=false(1,dlen);
                end
            end

            obj.yOutReg(:)=ty';

            if obj.processCRC
                obj.counter1=obj.counter1+1;
            end

            if obj.outputCRC
                obj.counter2=obj.counter2+1;
            end



            if obj.sysenb
                if obj.processCRC
                    tm=false(1,dlen);
                    tv=false;
                else
                    tm=obj.dm;
                    tv=obj.validIn_delay;
                end


                if clen==dlen
                    obj.mReg(1,:)=tm;
                    obj.validInReg(1)=tv;
                else
                    obj.mReg(1:end-1,:)=obj.mReg(2:end,:);
                    obj.mReg(end,:)=tm;

                    obj.validInReg(1:end-1)=obj.validInReg(2:end);
                    obj.validInReg(end)=tv;
                end


                computeCRC(obj);

            end

            if obj.endIn_delay&&obj.sysenb
                obj.processCRC=true;
                obj.padZero=true;
                obj.processMsg=false;
            end

            obj.endIn_delay=logical(endIn)&&validIn;


            if obj.tEndOut

                obj.counter2=0;
                obj.outputCRC=false;
                obj.tEndOut=false;

            end

            if obj.counter1==obj.depth

                obj.padZero=false;
                obj.processCRC=false;
                obj.outputCRC=true;
                obj.sysenb=false;
                obj.counter1=0;
                obj.crcoutreg=obj.reg;
                obj.reg=obj.initVector;
            end


            if obj.counter2==obj.depth-1&&obj.outputCRC
                obj.tEndOut=true;

            end


            if startIn&&validIn&&~obj.sysenb
                obj.processMsg=true;
                obj.tStartOut=true;
                obj.sysenb=true;

            end

            if obj.processMsg


                if obj.isIntIn
                    if obj.isUInt
                        tmpVal=logical((dec2bin(m,obj.datalen)-48));
                        obj.dm=tmpVal(1:obj.datalen);

                    else
                        for i=coder.unroll(1:obj.datalen)
                            obj.dm(obj.datalen-i+1)=logical(bitsliceget(m,i,i));
                        end

                    end
                else
                    tmpm=logical(m');
                    obj.dm=tmpm(1:obj.datalen);
                end
                obj.validIn_delay=logical(validIn);
            end


        end













        function setupImpl(obj,m,startIn,endIn,validIn)




            name='Input message';
            isScalarIn=isscalar(m);
            obj.isIntIn=isScalarIn&&~isa(m,'double')&&~isa(m,'logical');
            if obj.isIntIn
                validateattributes(m,{'uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer'},'',name);
            else
                if isa(m,'double')
                    validateattributes(m,{'double'},...
                    {'vector','binary','column'},'',name);
                else
                    validateattributes(m,{'logical','double'},{'vector','binary','column'},'',name);
                end
            end



            if~obj.isIntIn
                obj.datalen=coder.const(length(m));
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                obj.dataclass=class(m);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));

                if obj.isIntIn
                    coder.internal.errorIf(isScalarIn&&~obj.isUInt&&issigned(m),...
                    'comm:HDLCRC:UnsignedIntFixptExpected');



                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(m));

                    if~obj.isUInt
                        coder.internal.errorIf(m.FractionLength~=0,...
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





            if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                validateattributes(startIn,{'logical'},{'scalar'},'','startIn');
                validateattributes(endIn,{'logical'},{'scalar'},'','endIn');
                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');


            end




            clen=obj.crclen;


            obj.depth=round(clen/obj.datalen);

            obj.mReg=false(obj.depth,obj.datalen);
            obj.dm=false(1,obj.datalen);

            obj.startOutbuffer=false(1,obj.depth);
            obj.validInReg=false(1,obj.depth);

            if isa(m,'double')
                obj.yOutReg=zeros(obj.datalen,1);
            else
                obj.yOutReg=false(obj.datalen,1);
            end


            obj.xorValue=validateInitValue(obj,obj.FinalXORValue,2);
            obj.initVector=validateInitValue(obj,obj.InitialState,3);

            obj.reg=obj.initVector;
            obj.crcoutreg=false(1,clen);%#ok

            obj.F=false(clen,clen);%#ok
            I=eye(clen,clen);


            p=obj.Polynomial(2:end);

            tF=logical([p',I(:,1:clen-1)]);

            for i=1:obj.datalen-1
                c=obj.GF2multiply(tF,p');
                tF=[c,tF(:,1:clen-1)];
            end
            obj.F=full(tF);

        end
        function validateInputsImpl(obj,m,~,~,~)
            isScalarIn=isscalar(m);
            obj.isIntIn=isScalarIn&&~isa(m,'double')&&~isa(m,'logical');
            if~obj.isIntIn
                obj.datalen=coder.const(length(m));
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(m));
                end
                obj.inDisp=~isempty(m);
            end
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function num=getNumInputsImpl(~)
            num=4;
        end

        function num=getNumOutputsImpl(~)
            num=4;
        end


        function icon=getIconImpl(obj)
            if isempty(obj.inDisp)
                icon='General CRC\nGenerator\nHDL Optimized\nLatency = --';
            else
                icon=['General CRC\nGenerator\nHDL Optimized\nLatency = ',num2str(getLatency(obj))];
            end
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='dataIn';
            varargout{2}='startIn';
            varargout{3}='endIn';
            varargout{4}='validIn';
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='dataOut';
            varargout{2}='startOut';
            varargout{3}='endOut';
            varargout{4}='validOut';
        end


        function computeCRC(obj)

            clen=obj.crclen;
            dlen=obj.datalen;


            d=false(1,clen);

            if~obj.padZero&&obj.validIn_delay

                messagein=obj.dm;
                if(obj.ReflectInput)

                    for k=1:dlen/8
                        newmessage_byte=messagein(1+(k-1)*8:8*k);
                        messagein(1+(k-1)*8:8*k)=fliplr(newmessage_byte);
                    end
                end

                d(clen-dlen+1:clen)=messagein;
            end

            if obj.validIn_delay||obj.padZero

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

            if obj.counter1==obj.depth
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
            val=reshape(val,[1,length(val)]);
            coder.internal.errorIf(length(val)~=obj.crclen&&length(val)~=1,...
            'comm:HDLCRC:NotSameLength');

            if length(val)==1

                y=logical(val*true(1,obj.crclen));
            else
                if((flag==3)&&(obj.DirectMethod))
                    y=logical(val);
                else
                    y=logical(reshape(val(end:-1:1),1,length(val)));
                end
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

    end


    methods(Static,Access=private)


        function validateVectorInputs(x,name)

            if isa(x,'double')
                validateattributes(x,{'double'},...
                {'vector','binary'},'',name);
            else
                validateattributes(x,{'logical','double'},{'vector','binary'},'',name);
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


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

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