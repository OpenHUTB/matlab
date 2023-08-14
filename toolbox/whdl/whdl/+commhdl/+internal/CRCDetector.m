classdef(StrictDefaults)CRCDetector<matlab.System





























































































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

    properties(Access=private)

        cHDLCRCGenerator;
        startReg;
        dataReg;
        endReg;
        flipflop;

        startOutReg;
        startOutff;
        endOutff;
        validOutff;
        dataOutff;
        startInReg;
        validInReg;
        endInReg;
        datadelayReg;
        ctrldelayReg;
        endInReg2;
        delayCRCReg;
        dataInReg;
        crcReg;
        dataOutReg;
        crcInReg;
        crcBaseReg;
        OneDelay;
        err;

    end


    properties(Nontunable,Access=private)
        crclen=16;
        datalen=16;
        depth=1;
        isIntIn=false;
        isUInt=false;
        isScalarIn=true;
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('commhdl.internal.CRCDetector',...
            'ShowSourceLink',false,...
            'Title','General CRC Syndrome Detector HDL Optimized');
        end
    end

    methods
        function obj=CRCDetector(varargin)
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
            obj.validateVectorInputs(val,'Polynomial');

            if ischar(val)
                obj.Polynomial=commstr2poly(val,'descending');
            elseif any(val~=1&val~=0)
                PolyTemp=commblkCheckPolynomial(val);
                n=size(dec2bin(PolyTemp),2);
                p=coder.const(reshape(feval('int2bit',PolyTemp,(n)),n,[])');
                obj.Polynomial=[1,p];


            else
                validateattributes(val,{'double','logical'},{'vector','binary'},'CRCDetector','Polynomial');
                obj.Polynomial=val;

            end
            obj.crclen=length(obj.Polynomial)-1;%#ok<*MCSUP>


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

        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function varargout=outputImpl(obj,varargin)


            IPctrlOut.start=obj.startOutff(1);
            IPctrlOut.end=obj.endOutff(1);
            IPctrlOut.valid=obj.validOutff(1);
            yOut=obj.dataOutff(:,1);







            varargout{1}=yOut;
            varargout{2}=IPctrlOut;

            varargout{3}=obj.err;
        end

        function updateImpl(obj,m,ctrlIn)

            [dataOutPipe,ctrlOutPipe]=PipelineInput(obj,m,ctrlIn);

            ctrlInCRCGen.start=CtrlDelayEnRstCell(obj,ctrlOutPipe.start,ctrlOutPipe.valid,false);
            ctrlInCRCGen.end=ctrlOutPipe.end;
            ctrlInCRCGen.valid=ctrlOutPipe.valid;

            dataInShifted=LockDataIn(obj,dataOutPipe,ctrlOutPipe,false);

            [dataOutCRCGen,ctrlOutCRCGen]=step(...
            obj.cHDLCRCGenerator,...
            dataInShifted,...
            ctrlInCRCGen);

            endInDelayed=DelayEndIn(obj,ctrlOutPipe.end,false)||ctrlOutPipe.valid;

            dummyctrl.start=false;
            dummyctrl.end=false;
            dummyctrl.valid=endInDelayed;

            crcInput=LockCRCIn(obj,dataOutPipe,dummyctrl,false);


            crcInputDelayed=DelayCRCplus2(obj,crcInput,false);


            startOutTemp=LockstartOut(obj,ctrlOutCRCGen.start,ctrlOutCRCGen.valid,false);
            validOutTemp=SetResetFF(obj,startOutTemp,ctrlOutCRCGen.end,ctrlOutCRCGen.valid,ctrlOutCRCGen.start);

            dataOutTemp=LockdataOut(obj,dataOutCRCGen,ctrlOutCRCGen.valid,validOutTemp,false);


            enMask=obj.OneDelay(1)||ctrlOutCRCGen.end||ctrlOutCRCGen.valid;



            obj.OneDelay(1:end-1)=obj.OneDelay(2:end);
            obj.OneDelay(end)=ctrlOutCRCGen.end&&validOutTemp;


            maskTemp=maskGenerator(obj,dataOutCRCGen,crcInputDelayed,enMask,ctrlOutPipe.start);

            if(obj.datalen==1)||~obj.isScalarIn

                zz=zeros(obj.datalen,obj.depth);
            else

                zz=zeros(1,obj.depth);
            end
            if obj.endOutff(2)


                errBool=any(any((maskTemp~=zz)));






            else

                errBool=false;
            end

            obj.err=errBool;








            obj.dataOutff(:,1:end-1)=obj.dataOutff(:,2:end);
            obj.dataOutff(:,end)=dataOutTemp;

            obj.startOutff(1:end-1)=obj.startOutff(2:end);
            obj.startOutff(end)=startOutTemp;

            obj.endOutff(1:end-1)=obj.endOutff(2:end);
            obj.endOutff(end)=ctrlOutCRCGen.end&&validOutTemp;

            obj.validOutff(1:end-1)=obj.validOutff(2:end);
            obj.validOutff(end)=validOutTemp;

        end

        function varargout=isInputDirectFeedthroughImpl(~,~,~)


            varargout={false,false};
        end


        function maskOut=maskGenerator(obj,crcBase,crcIn,enable,reset)


            maskOut=bitxor(double(obj.crcBaseReg),double(obj.crcInReg));
            if reset
                obj.crcBaseReg(:,:)=false;
                obj.crcInReg(:,:)=false;
            elseif enable
                obj.crcBaseReg(:,1:end-1)=obj.crcBaseReg(:,2:end);
                obj.crcInReg(:,1:end-1)=obj.crcInReg(:,2:end);

                obj.crcBaseReg(:,end)=crcBase;
                obj.crcInReg(:,end)=crcIn;
            end
        end

        function dataOut=LockDataIn(obj,dataIn,ctrlIn,reset)

            if ctrlIn.valid
                dataOut=obj.dataReg(:,1);
            else
                if isscalar(dataIn)
                    if~isa(dataIn,'embedded.fi')
                        dataOut=cast(0,class(dataIn));
                    else
                        dataOut=fi(0,dataIn.numerictype);
                    end
                else
                    if~isa(dataIn,'embedded.fi')
                        dataOut=cast(zeros(obj.datalen,1),class(dataIn));
                    else
                        dataOut=fi(zeros(obj.datalen,1),dataIn.numerictype);
                    end
                end
            end
            if reset
                obj.dataReg(:,:)=false;
            elseif ctrlIn.valid
                obj.dataReg(:,1:end-1)=obj.dataReg(:,2:end);
                obj.dataReg(:,end)=dataIn;
            end

        end

        function crcOut=LockCRCIn(obj,dataIn,ctrlIn,reset)

            if ctrlIn.valid
                crcOut=obj.crcReg(:,1);
            else
                if isscalar(dataIn)
                    if~isa(dataIn,'embedded.fi')
                        crcOut=cast(0,class(dataIn));
                    else
                        crcOut=fi(0,dataIn.numerictype);
                    end
                else
                    if~isa(dataIn,'embedded.fi')
                        crcOut=cast(zeros(obj.datalen,1),class(dataIn));
                    else
                        crcOut=fi(zeros(obj.datalen,1),dataIn.numerictype);
                    end
                end
            end
            if reset
                obj.crcReg(:,:)=false;
            elseif ctrlIn.valid
                obj.crcReg(:,1:end-1)=obj.crcReg(:,2:end);
                obj.crcReg(:,end)=dataIn;
            end
        end

        function startOut=LockstartOut(obj,dataIn,enable,reset)
            startOut=obj.startOutReg(1)&&enable;

            if reset
                obj.startOutReg(:,:)=false;
            elseif enable
                obj.startOutReg(1:end-1)=obj.startOutReg(2:end);
                obj.startOutReg(end)=dataIn;
            end
        end

        function dataOut=LockdataOut(obj,dataIn,enable,gateData,reset)

            if enable&&gateData
                dataOut=obj.dataOutReg(:,1);
            else
                if isscalar(dataIn)
                    if~isa(dataIn,'embedded.fi')
                        dataOut=cast(0,class(dataIn));
                    else
                        dataOut=fi(0,dataIn.numerictype);
                    end
                else
                    if~isa(dataIn,'embedded.fi')
                        dataOut=cast(zeros(obj.datalen,1),class(dataIn));
                    else
                        dataOut=fi(zeros(obj.datalen,1),dataIn.numerictype);
                    end
                end
            end
            if reset
                obj.dataOutReg(:,:)=false;
            elseif enable
                obj.dataOutReg(:,1:end-1)=obj.dataOutReg(:,2:end);
                obj.dataOutReg(:,end)=dataIn;
            end
        end

        function Q=SetResetFF(obj,start,reset,valid,resetGlobal)



            Q=valid&&(start||(not(obj.endReg(1))&&obj.flipflop(1))&&not(resetGlobal));
            if resetGlobal
                obj.flipflop=false;
                obj.endReg=false;
            else
                obj.endReg(1:end-1)=obj.endReg(2:end);
                obj.flipflop(1:end-1)=obj.flipflop(2:end);


                obj.flipflop(end)=start||(not(obj.endReg(1))&&obj.flipflop(1));
                obj.endReg(end)=reset;
            end

        end

        function y=CtrlDelayEnRstCell(obj,data,enable,reset)

            y=obj.ctrldelayReg(1)&&enable;

            if reset
                obj.ctrldelayReg(:,:)=false;
            elseif enable
                obj.ctrldelayReg(1:end-1)=obj.ctrldelayReg(2:end);
                obj.ctrldelayReg(end)=data;
            end

        end

        function endOut=DelayEndIn(obj,data,reset)
            endOut=any(obj.endInReg2)||data;
            if reset
                obj.endInReg2(:,:)=false;
            else
                obj.endInReg2(1:end-1)=obj.endInReg2(2:end);
                obj.endInReg2(end)=data;
            end
        end

        function y=DelayCRCplus2(obj,data,reset)
            y=obj.delayCRCReg(:,1);
            if reset
                obj.delayCRCReg(:,:)=false;
            else
                obj.delayCRCReg(:,1:end-1)=obj.delayCRCReg(:,2:end);
                obj.delayCRCReg(:,end)=data;
            end
        end

        function[dataOut,ctrlOut]=PipelineInput(obj,data,ctrl)

            dataOut=obj.dataInReg(:,1);
            ctrlOut.start=obj.startInReg(1);
            ctrlOut.end=obj.endInReg(1);
            ctrlOut.valid=obj.validInReg(1);

            obj.dataInReg(:,1:end-1)=obj.dataInReg(:,2:end);
            obj.dataInReg(:,end)=data;

            obj.startInReg(1:end-1)=obj.startInReg(2:end);
            obj.startInReg(end)=ctrl.start;

            obj.endInReg(1:end-1)=obj.endInReg(2:end);
            obj.endInReg(end)=ctrl.end;

            obj.validInReg(1:end-1)=obj.validInReg(2:end);
            obj.validInReg(end)=ctrl.valid;
        end

        function setupImpl(obj,m,ctrlIn)

            startIn=ctrlIn.start;
            endIn=ctrlIn.end;
            validIn=ctrlIn.valid;
            name='Input message';

            if isempty(coder.target)||~eml_ambiguous_types


                obj.isScalarIn=isscalar(m);
                if obj.isScalarIn
                    validateattributes(m,{'uint8','uint16','uint32','uint64','embedded.fi','double','single','logical','boolean'},{'scalar','integer'},'CRCDetector',name);
                else
                    validateattributes(m,{'embedded.fi','double','single','logical','boolean'},{'vector','column','binary'},'CRCDetector',name);
                end
                dataclass=class(m);
                if(isscalar(m)&&isa(m,'embedded.fi'))||~isempty(strfind(dataclass,'uint'))%#ok
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(m));
                else
                    obj.datalen=coder.const(length(m));
                end

                obj.isUInt=~isempty(strfind(dataclass,'uint'))||~isa(m,'embedded.fi');%#ok

                if isa(m,'embedded.fi')
                    coder.internal.errorIf(m.FractionLength~=0||issigned(m),...
                    'comm:HDLCRC:UnsignedIntFixptExpected');
                end

                obj.err=false;

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

                validateattributes(startIn,{'logical'},{'scalar'},'CRCDetector','startIn');
                validateattributes(endIn,{'logical'},{'scalar'},'CRCDetector','endIn');
                validateattributes(validIn,{'logical'},{'scalar'},'CRCDetector','validIn');

            end

            obj.depth=round(obj.crclen/obj.datalen);

            obj.endReg=false(1,1);
            obj.flipflop=false(1,1);
            obj.startOutff=false(2,1);
            obj.endOutff=false(2,1);
            obj.validOutff=false(2,1);

            obj.startInReg=false(1,1);
            obj.validInReg=false(1,1);
            obj.endInReg=false(1,1);

            obj.OneDelay=false(1,1);
            if obj.isScalarIn
                if obj.isUInt
                    obj.datadelayReg=cast(false(1,obj.depth),dataclass);
                    obj.dataInReg=cast(false(1,1),dataclass);
                    obj.delayCRCReg=cast(false(1,obj.depth+2),dataclass);
                    obj.dataReg=cast(false(1,obj.depth),dataclass);
                    obj.crcReg=cast(false(1,obj.depth),dataclass);
                    obj.dataOutReg=cast(false(1,obj.depth),dataclass);
                    obj.crcInReg=cast(false(1,obj.depth),dataclass);
                    obj.crcBaseReg=cast(false(1,obj.depth),dataclass);
                    obj.dataOutff=cast(false(1,2),dataclass);
                    obj.startOutReg=false(obj.depth,1);
                    obj.ctrldelayReg=false(obj.depth,1);
                    obj.endInReg2=false(obj.depth,1);
                else
                    obj.datadelayReg=fi(false(1,obj.depth),m.numerictype);
                    obj.dataInReg=fi(false(1,1),m.numerictype);
                    obj.delayCRCReg=fi(false(1,obj.depth+2),m.numerictype);
                    obj.dataReg=fi(false(1,obj.depth),m.numerictype);
                    obj.crcReg=fi(false(1,obj.depth),m.numerictype);
                    obj.dataOutReg=fi(false(1,obj.depth),m.numerictype);
                    obj.crcInReg=fi(false(1,obj.depth),m.numerictype);
                    obj.crcBaseReg=fi(false(1,obj.depth),m.numerictype);
                    obj.dataOutff=fi(false(1,2),m.numerictype);
                    obj.startOutReg=false(obj.depth,1);
                    obj.ctrldelayReg=false(obj.depth,1);
                    obj.endInReg2=false(obj.depth,1);
                end
            else
                if~isa(m,'embedded.fi')
                    obj.datadelayReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.dataInReg=cast(false(obj.datalen,1),dataclass);
                    obj.delayCRCReg=cast(false(obj.datalen,obj.depth+2),dataclass);
                    obj.dataReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.crcReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.dataOutReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.crcInReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.crcBaseReg=cast(false(obj.datalen,obj.depth),dataclass);
                    obj.dataOutff=cast(false(obj.datalen,2),dataclass);
                    obj.startOutReg=false(obj.depth,1);
                    obj.ctrldelayReg=false(obj.depth,1);
                    obj.endInReg2=false(obj.depth,1);
                else
                    obj.datadelayReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.dataInReg=fi(false(obj.datalen,1),m.numerictype);
                    obj.delayCRCReg=fi(false(obj.datalen,obj.depth+2),m.numerictype);
                    obj.dataReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.crcReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.dataOutReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.crcInReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.crcBaseReg=fi(false(obj.datalen,obj.depth),m.numerictype);
                    obj.dataOutff=fi(false(obj.datalen,2),m.numerictype);
                    obj.startOutReg=false(obj.depth,1);
                    obj.ctrldelayReg=false(obj.depth,1);
                    obj.endInReg2=false(obj.depth,1);
                end
            end


            obj.cHDLCRCGenerator=commhdl.internal.CRCGenerator(...
            'Polynomial',obj.Polynomial,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',obj.FinalXORValue);
        end

        function resetImpl(obj)
            reset(obj.cHDLCRCGenerator);
            obj.dataReg(:)=0;
            obj.endReg(:)=0;
            obj.flipflop(:)=0;

            obj.startOutReg(:)=0;
            obj.startOutff(:)=0;
            obj.endOutff(:)=0;
            obj.validOutff(:)=0;
            obj.dataOutff(:)=0;
            obj.startInReg(:)=0;
            obj.validInReg(:)=0;
            obj.endInReg(:)=0;
            obj.datadelayReg(:)=0;
            obj.ctrldelayReg(:)=0;
            obj.endInReg2(:)=0;
            obj.delayCRCReg(:)=0;
            obj.dataInReg(:)=0;
            obj.crcReg(:)=0;
            obj.dataOutReg(:)=0;
            obj.crcInReg(:)=0;
            obj.crcBaseReg(:)=0;
            obj.OneDelay(:)=0;
            obj.err(:)=0;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.cHDLCRCGenerator=matlab.System.saveObject(obj.cHDLCRCGenerator);
                s.startOutReg=obj.startOutReg;
                s.dataReg=obj.dataReg;
                s.endReg=obj.endReg;
                s.flipflop=obj.flipflop;
                s.startOutff=obj.startOutff;
                s.endOutff=obj.endOutff;
                s.validOutff=obj.validOutff;
                s.dataOutff=obj.dataOutff;

                s.datadelayReg=obj.datadelayReg;
                s.startInReg=obj.startInReg;
                s.validInReg=obj.validInReg;
                s.endInReg=obj.endInReg;

                s.ctrldelayReg=obj.ctrldelayReg;
                s.endInReg2=obj.endInReg2;
                s.delayCRCReg=obj.delayCRCReg;
                s.dataInReg=obj.dataInReg;
                s.crcReg=obj.crcReg;
                s.dataOutReg=obj.dataOutReg;
                s.crcInReg=obj.crcInReg;
                s.crcBaseReg=obj.crcBaseReg;
                s.OneDelay=obj.OneDelay;
                s.err=obj.err;
            end
        end


        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.cHDLCRCGenerator=matlab.System.loadObject(s.cHDLCRCGenerator);
                s=rmfield(s,'cHDLCRCGenerator');
            end
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end


        function num=getNumInputsImpl(~)
            num=2;
        end


        function num=getNumOutputsImpl(~)
            num=3;
        end


        function icon=getIconImpl(~)
            icon=sprintf('CommCRCDetector');
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
            varargout{3}='err';
        end


        function varargout=getOutputSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,2);
            varargout{3}=1;
        end


        function varargout=isOutputComplexImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=propagatedInputComplexity(obj,2);
            varargout{3}=false;
        end


        function varargout=getOutputDataTypeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}=samplecontrolbustype;
            varargout{3}='logical';
        end


        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,2);
            varargout{3}=true;
        end


        function validateInitValue(obj,val,flag)
            if(flag==1)
                para='InitialState';
            else
                para='FinalXORValue';
            end
            obj.validateVectorInputs(val,para);
            coder.internal.errorIf(length(val)~=obj.crclen&&length(val)~=1,...
            'comm:HDLCRC:NotSameLength');
        end
    end

    methods(Static,Access=private)
        function validateVectorInputs(x,name)
            if isa(x,'double')
                validateattributes(x,{'double'},{'vector','binary'},'CRCDetector',name);
            else
                validateattributes(x,{'logical','double','char'},{'vector'},'CRCDetector',name);
            end
        end
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end

end
