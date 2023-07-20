classdef(StrictDefaults)LookupTable<matlab.System




































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)




        Table=uint8(0:1:255);
    end

    properties(Nontunable,Access=private)
        wl;
    end

    properties(Access=private)
        OutputDelay1;
        OutputDelay2;
        hstartdelay;
        henddelay;
        vstartdelay;
        venddelay;
        validdelay;
    end

    methods
        function obj=LookupTable(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'Table');
        end

        function set.Table(obj,val)
            validateattributes(val,{'logical','numeric','embedded.fi'},...
            {'vector','real'},'LookupTable','TableData');


            obj.Table=val;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.LookupTable',...
            'ShowSourceLink',false,...
            'Title','Lookup Table');
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function icon=getIconImpl(~)
            icon=sprintf('Lookup Table');
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end

        function[sz1,sz2]=getOutputSizeImpl(obj)
            sz1=propagatedInputSize(obj,1);
            sz2=propagatedInputSize(obj,2);
        end

        function[cp1,cp2]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,2);
        end

        function[dt1,dt2]=getOutputDataTypeImpl(obj)
            if isa(obj.Table,'embedded.fi')
                dt1=obj.Table.numerictype;
            else
                dt1=class(obj.Table);
            end
            dt2=pixelcontrolbustype;
        end

        function[sz1,sz2]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
        end

        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'uint8','uint16','embedded.fi','logical'},...
                {'real','nonnan','finite','vector'},'LookupTable','pixel input');
                if isfi(pixelIn)

                    coder.internal.errorIf(issigned(pixelIn),'visionhdl:LookupTable:SignedType');

                    coder.internal.errorIf((pixelIn.WordLength>16),'visionhdl:LookupTable:WordLength');
                end

                if~ismember(size(pixelIn,1),[1,4,8])
                    coder.internal.error('visionhdl:LookupTable:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1,3])
                    coder.internal.error('visionhdl:LookupTable:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.wl=obj.wl;
                s.OutputDelay1=obj.OutputDelay1;
                s.OutputDelay2=obj.OutputDelay2;
                s.Table=obj.Table;
                s.hstartdelay=obj.hstartdelay;
                s.henddelay=obj.henddelay;
                s.vstartdelay=obj.vstartdelay;
                s.venddelay=obj.venddelay;
                s.validdelay=obj.validdelay;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function resetImpl(obj)
            obj.OutputDelay1(:)=0;
            obj.OutputDelay2(:)=0;
            obj.hstartdelay(:,:)=false;
            obj.henddelay(:,:)=false;
            obj.vstartdelay(:,:)=false;
            obj.venddelay(:,:)=false;
            obj.validdelay(:,:)=false;
        end

        function setupImpl(obj,dataIn,~)
            if~isfloat(dataIn)
                [obj.OutputDelay1,obj.OutputDelay2]=deal(cast(zeros(size(dataIn)),'like',obj.Table));
                if isa(dataIn,'logical')
                    obj.wl=1;
                elseif isa(dataIn,'uint8')
                    obj.wl=8;
                elseif isa(dataIn,'uint16')
                    obj.wl=16;
                else
                    obj.wl=get(dataIn,'WordLength');
                end

                if isempty(coder.target)||~eml_ambiguous_types
                    coder.internal.errorIf(2^obj.wl~=length(obj.Table),...
                    'visionhdl:LookupTable:LengthMismatch',length(obj.Table),2^obj.wl,obj.wl);
                end
            else
                obj.OutputDelay1=cast(zeros(size(dataIn)),'like',dataIn);
                obj.OutputDelay2=cast(zeros(size(dataIn)),'like',dataIn);
                obj.wl=16;
            end

            obj.hstartdelay=false(1,2);
            obj.henddelay=false(1,2);
            obj.vstartdelay=false(1,2);
            obj.venddelay=false(1,2);
            obj.validdelay=false(1,2);
        end

        function[dataOut,CtrlOut]=outputImpl(obj,~,~)

            dataOut=obj.OutputDelay2;
            CtrlOut.hStart=obj.hstartdelay(2);
            CtrlOut.hEnd=obj.henddelay(2);
            CtrlOut.vStart=obj.vstartdelay(2);
            CtrlOut.vEnd=obj.venddelay(2);
            CtrlOut.valid=obj.validdelay(2);
        end

        function updateImpl(obj,dataIn,CtrlIn)

            if~isfloat(dataIn)
                if islogical(dataIn)
                    addr=dataIn+1;
                else
                    addr=reinterpretcast(dataIn,numerictype(false,coder.const(obj.wl),0))+...
                    fi(1,false,coder.const(obj.wl),0);
                end
                temp=obj.Table(addr);
            else
                temp=dataIn;
            end
            if obj.validdelay(1)
                obj.OutputDelay2=obj.OutputDelay1;
            else
                obj.OutputDelay2=cast(zeros(size(dataIn)),'like',obj.OutputDelay2);
            end

            obj.OutputDelay1(:)=temp;

            obj.hstartdelay=[CtrlIn.hStart,obj.hstartdelay(1)];
            obj.henddelay=[CtrlIn.hEnd,obj.henddelay(1)];
            obj.vstartdelay=[CtrlIn.vStart,obj.vstartdelay(1)];
            obj.venddelay=[CtrlIn.vEnd,obj.venddelay(1)];
            obj.validdelay=[CtrlIn.valid,obj.validdelay(1)];
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
