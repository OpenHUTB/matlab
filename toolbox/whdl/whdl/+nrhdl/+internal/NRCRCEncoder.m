classdef(StrictDefaults)NRCRCEncoder<matlab.System





%#codegen
%#ok<*EMCLS>

    properties(Nontunable)











        CRCType='CRC16';
    end

    properties(Constant,Hidden)


        CRCTypeSet=matlab.system.StringSet({'CRC6','CRC11','CRC16','CRC24A','CRC24B','CRC24C'});
    end

    properties(Nontunable)

        EnableCRCMaskPort(1,1)logical=false;
    end

    properties(Access=private)
        ctrlOut;
        dataOut;
        crcMask;
        count;
        countIdx;
        enbCount;
        enbMask;
    end

    properties(Access=private)
        commHDLCRCGenerator;
    end

    properties(Nontunable,Access=private)
        DirectMethod(1,1)logical=false;
        ReflectInput(1,1)logical=false;
        ReflectCRCChecksum(1,1)logical=false;

        Poly_Opt;
        InitialState=0;
        CRCMask=0;
        crc_len;
        latency;
        maskLen;
        isScalar;
        isParallel;
        datalen;
        isIntIn;
        dataclass;
        isUInt;
        depth;
        inDisp;
    end

    methods
        function obj=NRCRCEncoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'CRCType');
        end

        function set.CRCType(obj,val)
            obj.CRCType=val;
        end

    end

    methods(Access=public)
        function latency=getLatency(obj)
            latency=obj.crc_len/obj.datalen+3;
        end
    end

    methods(Access=protected)

        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function setupImpl(obj,dataIn)

            obj.Poly_Opt=getPoly(obj);
            obj.crc_len=length(obj.Poly_Opt)-1;

            isScalarIn=isscalar(dataIn);
            obj.isIntIn=isScalarIn&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');
            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            if isempty(coder.target)||~eml_ambiguous_types
                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                end
            end

            obj.depth=round(obj.crc_len/obj.datalen);
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);

            if isscalar(dataIn)
                if~isempty(strfind(class(dataIn),'uint'))||~isa(dataIn,'embedded.fi')%#ok
                    obj.dataOut=cast(false(1,1),class(dataIn));
                else
                    obj.dataOut=fi(false(1,1),dataIn.numerictype);
                end
            else
                if~isa(dataIn,'embedded.fi')
                    obj.dataOut=cast(false(obj.datalen,1),class(dataIn));
                else
                    obj.dataOut=fi(false(obj.datalen,1),dataIn.numerictype);
                end
            end

            obj.crcMask=fi(0,0,24,0);
            obj.latency=obj.crc_len/obj.datalen+3;
            obj.maskLen=obj.crc_len/obj.datalen;

            obj.count=fi(0,0,log2(obj.latency)+1,0);
            obj.countIdx=fi(0,0,log2(obj.depth)+1,0);
            obj.enbCount=false;
            obj.enbMask=false;
            if obj.datalen==1
                obj.isParallel=false;
            else
                obj.isParallel=true;
            end
            obj.isScalar=isscalar(dataIn);


            p=coder.const(feval('int2bit',(obj.CRCMask),(obj.crc_len)).');
            obj.commHDLCRCGenerator=commhdl.internal.CRCGenerator(...
            'Polynomial',obj.Poly_Opt,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',p);

        end

        function resetImpl(obj)
            reset(obj.commHDLCRCGenerator);
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.dataOut(:)=0;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
        end

        function updateImpl(obj,varargin)
            data=varargin{1};
            ctrl=varargin{2};

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)

                finxorval=varargin{3};

                if ctrl.start&&ctrl.valid
                    obj.crcMask(:)=finxorval;
                    obj.count(:)=0;
                    obj.countIdx(:)=0;
                    obj.enbCount(:)=false;
                    obj.enbMask(:)=false;
                end

                maskBits=maskCalculation(obj,obj.crcMask);

                if(ctrl.end&&ctrl.valid)
                    obj.enbCount(:)=true;
                end

                if obj.count(:)==obj.latency
                    obj.enbCount(:)=false;
                    obj.enbMask(:)=true;
                else
                    if obj.enbCount
                        obj.count(:)=obj.count+1;
                    end
                end

            end

            [obj.dataOut,obj.ctrlOut]=step(obj.commHDLCRCGenerator,data,ctrl);

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                if obj.datalen~=1
                    mask=maskBits(:,double(obj.countIdx)+1);
                else
                    mask=maskBits(double(obj.countIdx)+1)>0;
                end

                if obj.enbMask
                    if obj.isScalar&&obj.datalen~=1
                        obj.dataOut(:)=bitxor(obj.dataOut,cast(mask,'like',obj.dataOut));
                    else
                        obj.dataOut(:)=xor(obj.dataOut,mask);
                    end
                end

                if obj.countIdx(:)==obj.maskLen-1
                    obj.enbMask(:)=false;
                else
                    if obj.enbMask
                        obj.countIdx(:)=obj.countIdx+1;
                    end
                end
            end

            if~obj.ctrlOut.valid
                obj.dataOut(:)=0;
            end

        end

        function maskBits=maskCalculation(obj,crcMask)
            maskbits=comm.internal.utilities.de2biBase2LeftMSB(double(crcMask),obj.crc_len)';
            y=(obj.crc_len)/obj.datalen;
            maskBits=zeros(1,y);
            x=[];
            if obj.datalen~=1
                if obj.isScalar
                    x=fi(reshape(maskbits,obj.datalen,y),0,1,0);
                    for i=1:size(x,2)
                        maskBits(i)=bitconcat(x(:,i));
                    end
                else
                    maskBits=reshape(maskbits,obj.datalen,y);
                end
            else
                maskBits=maskbits;
            end

        end

        function validateInputsImpl(obj,varargin)
            dataIn=varargin{1};
            ctrlIn=varargin{2};

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                crcmask=varargin{3};
                validateattributes(crcmask,{'embedded.fi'},{'scalar','integer'},'NRCRCEncoder','CRCMask');
                if isa(crcmask,'embedded.fi')
                    if(issigned(crcmask))
                        coder.internal.error('whdl:NRCRCEncoder:InvalidSignedType');
                    end
                end
                coder.internal.errorIf(crcmask.WordLength~=24,...
                'whdl:NRCRCEncoder:InvMaskFixptExpected',tostringInternalSlName(crcmask.numerictype));

                coder.internal.errorIf(crcmask.FractionLength~=0,...
                'whdl:NRCRCEncoder:InvMaskFixptExpected',tostringInternalSlName(crcmask.numerictype));
            end

            obj.Poly_Opt=getPoly(obj);
            obj.crc_len=length(obj.Poly_Opt)-1;
            isScalarIn=isscalar(dataIn);
            obj.isIntIn=isScalarIn&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');

            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            if isempty(coder.target)||~eml_ambiguous_types
                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if isa(dataIn,'embedded.fi')
                    if(issigned(dataIn))
                        coder.internal.error('whdl:NRCRCEncoder:InvalidSignedType');
                    end
                end
                if obj.isIntIn
                    validateattributes(dataIn,{'uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer'},'NRCRCEncoder','data');
                else
                    validateattributes(dataIn,{'logical','double','single','embedded.fi'},{'vector','binary','column'},'NRCRCEncoder','data');
                end

                if~obj.isIntIn&&dsphdlshared.hdlgetwordsizefromdata(dataIn)>1
                    validateattributes(dataIn,{'embedded.fi'},{'scalar','binary','column'},'NRCRCEncoder','data');
                end
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                    if~obj.isUInt
                        coder.internal.errorIf(dataIn.FractionLength~=0,...
                        'whdl:NRCRCEncoder:InvFixptExpected');
                    end
                end


                coder.internal.errorIf(mod(obj.crc_len,obj.datalen)~=0,...
                'whdl:NRCRCEncoder:InvDataWidth');


                if~isstruct(ctrlIn)
                    coder.internal.error('whdl:NRCRCEncoder:InvalidSampleCtrlBus');
                end

                ctrlNames=fieldnames(ctrlIn);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:NRCRCEncoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'NRCRCEncoder','start');
                else
                    coder.internal.error('whdl:NRCRCEncoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'NRCRCEncoder','end');
                else
                    coder.internal.error('whdl:NRCRCEncoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'NRCRCEncoder','valid');
                else
                    coder.internal.error('whdl:NRCRCEncoder:InvalidSampleCtrlBus');
                end

                obj.inDisp=~isempty(dataIn);
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.commHDLCRCGenerator=matlab.System.saveObject(obj.commHDLCRCGenerator);
                s.ctrlOut=obj.ctrlOut;
                s.dataOut=obj.dataOut;
                s.crcMask=obj.crcMask;
                s.count=obj.count;
                s.countIdx=obj.countIdx;
                s.enbCount=obj.enbCount;
                s.enbMask=obj.enbMask;

            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.commHDLCRCGenerator=matlab.System.loadObject(s.commHDLCRCGenerator);
                s=rmfield(s,'commHDLCRCGenerator');
            end
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function num=getNumInputsImpl(obj)
            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                num=3;
            else
                num=2;
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function icon=getIconImpl(obj)
            if isempty(obj.inDisp)
                icon='NR CRC Encoder\nLatency = --';
            else
                icon=['NR CRC Encoder\nLatency = ',num2str(getLatency(obj))];
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                varargout{3}='CRCMask';
            end
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

        function y=getPoly(obj)
            if strcmp(obj.CRCType,'CRC6')
                y=[1,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC11')
                y=[1,1,1,0,0,0,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC16')
                y=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC24A')
                y=[1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
            elseif strcmp(obj.CRCType,'CRC24B')
                y=[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
            else
                y=[1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch~(strcmp(obj.CRCType,'CRC24C'))
            case 1
                props={'EnableCRCMaskPort'};
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Access=protected)

        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end

        function header=getHeaderImpl
            header=matlab.system.display.Header('nrhdl.internal.NRCRCEncoder',...
            'ShowSourceLink',false,...
            'Title','NR CRC Encoder',...
            'Text','Generate CRC code bits and append to input data.');
        end
    end

end
