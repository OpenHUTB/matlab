classdef(StrictDefaults)GammaCorrector<matlab.System















































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        Correction='Gamma';



        Gamma=2.2;




        LinearSegment(1,1)logical=true;





        BreakPoint=0.018;
    end

    properties(Constant,Hidden)
        CorrectionSet=matlab.system.StringSet({'Gamma','De-gamma'});
    end

    properties(Nontunable,Access=private)
        Sls;
        Fs;
        Co;
        wl;
        fl;
        si;
        BreakPoint_LUT;
        CoreHandler;
    end

    properties(DiscreteState)


        Table;
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
        function obj=GammaCorrector(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},...
            'Correction','Gamma');
        end

        function set.Gamma(obj,val)
            validateattributes(val,{'double','single'},...
            {'scalar','>=',1},'GammaCorrector','Gamma');
            obj.Gamma=val;
        end

        function set.BreakPoint(obj,val)
            validateattributes(val,{'double','single'},...
            {'scalar','>',0,'<',1},'GammaCorrector','Break Point');
            obj.BreakPoint=val;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.GammaCorrector',...
            'ShowSourceLink',false,...
            'Title','Gamma');
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function icon=getIconImpl(obj)
            if strcmp(obj.Correction,'Gamma')
                icon=sprintf('Gamma');
            else
                icon=sprintf('De-gamma');
            end
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
            dt1=propagatedInputDataType(obj,1);
            dt2=pixelcontrolbustype;
        end

        function[sz1,sz2]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);
        end

        function[sz,dt,cp]=getDiscreteStateSpecificationImpl(obj,~)
            dt=propagatedInputDataType(obj,1);
            cp=propagatedInputComplexity(obj,1);
            if isa(dt,'embedded.numerictype')
                sz=[1,2^(dt.WordLength)];
            elseif strcmp(dt,'int8')||strcmp(dt,'uint8')
                sz=[1,256];
            elseif strcmp(dt,'int16')||strcmp(dt,'uint16')
                sz=[1,65536];
            elseif strcmp(dt,'double')||strcmp(dt,'single')
                sz=propagatedInputSize(obj,1);
            else
                assert(false,'This branch should never be hit!');
            end
        end

        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'single','double','int8','int16','uint8','uint16','embedded.fi'},...
                {'real','nonnan','finite'},'GammaCorrector','pixel input');
                if isfi(pixelIn)

                    coder.internal.errorIf((pixelIn.WordLength>16),'visionhdl:GammaCorrector:WordLength');
                end

                validatecontrolsignals(ctrlIn);


                if~(ismember((size(pixelIn,1)),[1,2,4,8]))
                    coder.internal.error('visionhdl:GammaCorrector:InputDimensions');
                end

                if~ismember(size(pixelIn,2),1)
                    coder.internal.error('visionhdl:GammaCorrector:UnsupportedComps');
                end
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.CoreHandler=obj.CoreHandler;
                s.Sls=obj.Sls;
                s.Fs=obj.Fs;
                s.Co=obj.Co;
                s.wl=obj.wl;
                s.fl=obj.fl;
                s.si=obj.si;
                s.OutputDelay1=obj.OutputDelay1;
                s.OutputDelay2=obj.OutputDelay2;
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


        function flag=isInactivePropertyImpl(obj,prop)
            flag=strcmp(prop,'BreakPoint')&&...
            (obj.LinearSegment==false);
        end

        function setDiscreteStateImpl(obj,ds)
            obj.Table=ds.Table;
        end

        function resetImpl(obj)
            obj.OutputDelay1(:,:)=0;
            obj.OutputDelay2(:,:)=0;
            obj.hstartdelay(:,:)=false;
            obj.henddelay(:,:)=false;
            obj.vstartdelay(:,:)=false;
            obj.venddelay(:,:)=false;
            obj.validdelay(:,:)=false;
            obj.Table=obj.Table;
        end

        function setupImpl(obj,dataIn,~)
            obj.OutputDelay1=cast(zeros(size(dataIn,1),1),'like',dataIn);
            obj.OutputDelay2=cast(zeros(size(dataIn,1),1),'like',dataIn);

            if obj.LinearSegment==false
                obj.BreakPoint=0.018;


                obj.BreakPoint_LUT=0;

                obj.Sls=0;
                obj.Fs=1;
                obj.Co=0;
            else
                aa=obj.BreakPoint^((1/obj.Gamma)-1);
                obj.Sls=1/(obj.Gamma/aa-obj.Gamma*obj.BreakPoint+obj.BreakPoint);
                obj.Fs=obj.Gamma*obj.Sls/aa;
                obj.Co=obj.Fs*obj.BreakPoint^(1/obj.Gamma)-obj.Sls*obj.BreakPoint;
                obj.BreakPoint_LUT=obj.BreakPoint;
            end

            if~isfloat(dataIn)
                obj.CoreHandler=@FiLUT;

                if isa(dataIn,'int8')
                    obj.wl=8;obj.fl=0;obj.si=true;
                elseif isa(dataIn,'uint8')
                    obj.wl=8;obj.fl=0;obj.si=false;
                elseif isa(dataIn,'int16')
                    obj.wl=16;obj.fl=0;obj.si=true;
                elseif isa(dataIn,'uint16')
                    obj.wl=16;obj.fl=0;obj.si=false;
                else
                    obj.wl=get(dataIn,'WordLength');
                    obj.fl=get(dataIn,'FractionLength');
                    obj.si=strcmp(get(dataIn,'Signedness'),'Signed');
                end

                grid=linspace(0,1,2^obj.wl);
                temp=zeros(1,length(grid));

                if strcmp(obj.Correction,'Gamma')
                    if(obj.BreakPoint_LUT==0)
                        low=0;
                    else
                        low=1;
                        high=length(grid);
                        while(low+1)~=high
                            middle=floor((low+high)/2);
                            if grid(middle)>obj.BreakPoint_LUT
                                high=middle;
                            else
                                low=middle;
                            end
                        end
                    end
                    BP_IX=low;
                    temp(1:BP_IX)=grid(1:BP_IX)*obj.Sls;
                    temp(BP_IX+1:end)=obj.Fs*grid(BP_IX+1:end).^(1/obj.Gamma)-obj.Co;
                else
                    if(obj.BreakPoint_LUT==0)
                        low=0;
                    else
                        low=1;
                        high=length(grid);
                        while(low+1)~=high
                            middle=floor((low+high)/2);
                            if grid(middle)>obj.BreakPoint_LUT*obj.Sls
                                high=middle;
                            else
                                low=middle;
                            end
                        end
                    end
                    BP_IX=low;
                    temp(1:BP_IX)=grid(1:BP_IX)/obj.Sls;
                    temp(BP_IX+1:end)=((grid(BP_IX+1:end)+obj.Co)/obj.Fs).^obj.Gamma;
                end

                temp=temp*(2^(obj.wl-obj.fl)-2^(-obj.fl));
                if obj.si

                    temp=temp-2^(obj.wl-obj.fl-1);


                    ii=2^(obj.wl-1);
                    for k=1:ii
                        a=temp(k);
                        temp(k)=temp(k+ii);
                        temp(k+ii)=a;
                    end
                end












                if isinteger(dataIn)
                    temp=nearest(temp);
                end

                temp=fi(temp,obj.si,obj.wl,obj.fl,...
                'RoundingMethod','Round');

                obj.Table=cast(temp,'like',dataIn);
            else
                obj.Table=cast(zeros(size(dataIn,1),1),'like',dataIn);
                if strcmp(obj.Correction,'Gamma')
                    obj.CoreHandler=@FloatGamma;
                else
                    obj.CoreHandler=@FloatDegamma;
                end
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

            if obj.validdelay(1)
                obj.OutputDelay2=obj.OutputDelay1;
            else
                obj.OutputDelay2=cast(zeros(size(dataIn,1),1),'like',dataIn);
            end

            obj.OutputDelay1(:,:)=obj.CoreHandler(obj,dataIn);

            obj.hstartdelay=[CtrlIn.hStart,obj.hstartdelay(1:end-1)];
            obj.henddelay=[CtrlIn.hEnd,obj.henddelay(1:end-1)];
            obj.vstartdelay=[CtrlIn.vStart,obj.vstartdelay(1:end-1)];
            obj.venddelay=[CtrlIn.vEnd,obj.venddelay(1:end-1)];
            obj.validdelay=[CtrlIn.valid,obj.validdelay(1:end-1)];
        end

        function dataOut=FloatGamma(obj,dataIn)

            dataOut=cast(zeros(size(dataIn,1),1),'like',dataIn);
            for ii=1:size(dataIn,1)
                if dataIn(ii)<obj.BreakPoint_LUT
                    dataOut(ii)=obj.Sls*dataIn(ii);
                else
                    dataOut(ii)=obj.Fs*dataIn(ii)^(1/obj.Gamma)-obj.Co;
                end
            end
        end

        function dataOut=FloatDegamma(obj,dataIn)

            dataOut=cast(zeros(size(dataIn,1),1),'like',dataIn);
            for ii=1:size(dataIn,1)
                if dataIn(ii)<obj.BreakPoint_LUT*obj.Sls
                    dataOut(ii)=dataIn(ii)/obj.Sls;
                else
                    dataOut(ii)=((dataIn(ii)+obj.Co)/obj.Fs)^obj.Gamma;
                end
            end
        end

        function dataOut=FiLUT(obj,dataIn)
            addr=reinterpretcast(dataIn,numerictype(false,obj.wl,0))+...
            fi(1,false,obj.wl,0);
            dataOut=obj.Table(addr);
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
