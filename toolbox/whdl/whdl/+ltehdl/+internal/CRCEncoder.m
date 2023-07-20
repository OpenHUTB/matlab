classdef(StrictDefaults)CRCEncoder<matlab.System


































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)









        CRCType='CRC16';
    end

    properties(Constant,Hidden)


        CRCTypeSet=matlab.system.StringSet({'CRC8','CRC16','CRC24A','CRC24B'});
    end

    properties(Nontunable)









        FinalXORValue=0;
    end

    properties(Access=private)
        ctrlOutstart;
        ctrlOutend;
        ctrlOutvalid;
        dataOut;
    end

    properties(Access=private)
        cHDLCRCGenerator;
    end

    properties(Nontunable,Access=private)
        DirectMethod(1,1)logical=false;
        ReflectInput(1,1)logical=false;
        ReflectCRCChecksum(1,1)logical=false;

        Poly_Opt;
        InitialState=0;

        datalen=16;
        isIntIn=false;
        dataclass='uint8';
        isUInt=true;
        crc_len=16;
        depth=1;
        clenflag=false;
    end

    methods
        function obj=CRCEncoder(varargin)
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
            obj.crc_len=length(getPoly(obj))-1;
        end

        function set.FinalXORValue(obj,val)
            validateInitValue(obj,val);
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


        function setupImpl(obj,dataIn,~)

            obj.Poly_Opt=getPoly(obj);

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
                tlen=length(obj.Poly_Opt);
                if tlen>=2&&tlen>=obj.datalen
                    obj.crc_len=length(obj.Poly_Opt(2:end));
                    obj.clenflag=false;
                else
                    obj.clenflag=true;
                end
            end

            obj.depth=round(obj.crc_len/obj.datalen);
            obj.ctrlOutstart=false(1,1);
            obj.ctrlOutend=false(1,1);
            obj.ctrlOutvalid=false(1,1);

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


            p=coder.const(feval('int2bit',(obj.FinalXORValue),(obj.crc_len)).');
            obj.cHDLCRCGenerator=commhdl.internal.CRCGenerator(...
            'Polynomial',obj.Poly_Opt,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',p);
        end

        function resetImpl(obj)
            reset(obj.cHDLCRCGenerator);
            obj.ctrlOutstart(:)=false;
            obj.ctrlOutend(:)=false;
            obj.ctrlOutvalid(:)=false;
            obj.dataOut(:)=0;
        end

        function validateInputsImpl(obj,dataIn,ctrlIn)
            isScalarIn=isscalar(dataIn);
            obj.isIntIn=isScalarIn&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');

            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            name='Input message';
            if isempty(coder.target)||~eml_ambiguous_types
                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if obj.isIntIn
                    validateattributes(dataIn,{'uint8','uint16','uint32','uint64','embedded.fi','single'},{'scalar','integer'},'CRCEncoder',name);
                else
                    if isa(dataIn,'double')
                        validateattributes(dataIn,{'double'},...
                        {'vector','binary','column'},'CRCEncoder',name);
                    else
                        validateattributes(dataIn,{'logical','double','single','embedded.fi'},{'vector','binary','column'},'CRCEncoder',name);
                    end
                end

                if~obj.isIntIn&&dsphdlshared.hdlgetwordsizefromdata(dataIn)>1
                    validateattributes(dataIn,{'embedded.fi'},{'scalar','binary','column'},'CRCEncoder',name);
                end
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                    coder.internal.errorIf(isScalarIn&&~obj.isUInt&&issigned(dataIn),...
                    'comm:HDLCRC:UnsignedIntFixptExpected');
                    if~obj.isUInt
                        coder.internal.errorIf(dataIn.FractionLength~=0,...
                        'comm:HDLCRC:UnsignedIntFixptExpected');
                    end
                end

                coder.internal.errorIf(obj.clenflag||mod(obj.crc_len,obj.datalen)~=0,...
                'comm:HDLCRC:InvPolyDataWidth');
                coder.internal.errorIf(obj.ReflectInput&&mod(obj.datalen,8)~=0||obj.datalen<1,...
                'comm:HDLCRC:InvDataWidth');

                validateattributes(ctrlIn.start,{'logical'},{'scalar'},'CRCEncoder','startIn');
                validateattributes(ctrlIn.end,{'logical'},{'scalar'},'CRCEncoder','endIn');
                validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'CRCEncoder','validIn');
            end
        end


        function num=getNumInputsImpl(~)
            num=2;
        end


        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)
            icon=sprintf('LTE CRC Encoder');
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


        function varargout=outputImpl(obj,varargin)
            ctrlbus.start=obj.ctrlOutstart;
            ctrlbus.end=obj.ctrlOutend;
            ctrlbus.valid=obj.ctrlOutvalid;

            varargout{1}=obj.dataOut;
            varargout{2}=ctrlbus;
        end

        function updateImpl(obj,m,ctrlIn)
            [obj.dataOut,ctrlOutstruct]=step(...
            obj.cHDLCRCGenerator,...
            m,ctrlIn);
            obj.ctrlOutstart=ctrlOutstruct.start;
            obj.ctrlOutend=ctrlOutstruct.end;
            obj.ctrlOutvalid=ctrlOutstruct.valid;
        end


        function validateInitValue(obj,val)
            obj.validateVectorInputs(obj,val,'FinalXORValue');








        end


        function y=getPoly(obj)
            if strcmp(obj.CRCType,'CRC8')
                y=[1,1,0,0,1,1,0,1,1];
            elseif strcmp(obj.CRCType,'CRC16')
                y=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC24A')
                y=[1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
            else
                y=[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
            end
        end
    end

    methods(Static,Access=private)

        function validateVectorInputs(obj,x,name)






            validateattributes(x,{'double'},{'scalar','integer','nonnegative','<',2.^obj.crc_len},'CRCEncoder',name);
        end
    end

    methods(Static,Access=protected)

        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end


        function header=getHeaderImpl
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','LTE CRC Encoder',...
            'Text','Generate CRC code bits and append to input data.');
        end
    end

end
