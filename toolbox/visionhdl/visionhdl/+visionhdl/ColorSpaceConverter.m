classdef(StrictDefaults)ColorSpaceConverter<matlab.System












































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        Conversion='RGB to YCbCr';





        ConversionStandard='Rec. 601 (SDTV)';





        ScanningStandard='1250/50/2:1';
    end

    properties(Constant,Hidden)
        ConversionSet=matlab.system.StringSet({'RGB to YCbCr',...
        'YCbCr to RGB',...
        'RGB to intensity'});
        ConversionStandardSet=matlab.system.StringSet({'Rec. 601 (SDTV)',...
        'Rec. 709 (HDTV)'});
        ScanningStandardSet=matlab.system.StringSet({'1125/60/2:1',...
        '1250/50/2:1'});
    end

    properties(Nontunable,Access=private)
        transform;
        LumaSup;
        ChroSup;
        offset;
        d_or_s;
    end

    properties(Access=private)
        OutputCast;
        datadelay;
        hstartdelay;
        henddelay;
        vstartdelay;
        venddelay;
        validdelay;
        TreeSumOutput;
    end

    methods
        function obj=ColorSpaceConverter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'Conversion');
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('visionhdl.ColorSpaceConverter',...
            'ShowSourceLink',false,...
            'Title','Color Space Converter');
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
            if strcmp(obj.Conversion,'RGB to intensity')
                icon=sprintf('RGB to\nintensity');
            elseif strcmp(obj.Conversion,'RGB to YCbCr')
                icon=sprintf('RGB to\nYCbCr');
            else
                icon=sprintf('YCbCr to\nRGB');
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
            if strcmp(obj.Conversion,'RGB to intensity')
                sz1(2)=1;
            end
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

        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'single','double','uint8','uint16','embedded.fi'},...
                {'real','nonnan','finite'},'ColorSpaceConverter','pixel input');
                if isfi(pixelIn)

                    coder.internal.errorIf(issigned(pixelIn),'visionhdl:ColorSpaceConverter:SignedType');

                    WL=pixelIn.WordLength;
                    coder.internal.errorIf(((WL<8)||(WL>16)),'visionhdl:ColorSpaceConverter:WordLength');

                    coder.internal.errorIf((pixelIn.FractionLength~=0),'visionhdl:ColorSpaceConverter:NoFraction');
                end

                if~(ismember((size(pixelIn,1)),[1,2,4,8]))
                    coder.internal.error('visionhdl:ColorSpaceConverter:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[3])%#ok<NBRAK2>
                    coder.internal.error('visionhdl:ColorSpaceConverter:UnsupportedComps');
                end

                validatecontrolsignals(ctrlIn);
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.transform=obj.transform;
                s.LumaSup=obj.LumaSup;
                s.ChroSup=obj.ChroSup;
                s.offset=obj.offset;
                s.OutputCast=obj.OutputCast;
                s.datadelay=obj.datadelay;
                s.hstartdelay=obj.hstartdelay;
                s.henddelay=obj.henddelay;
                s.vstartdelay=obj.vstartdelay;
                s.venddelay=obj.venddelay;
                s.validdelay=obj.validdelay;
                s.d_or_s=obj.d_or_s;
                s.TreeSumOutput=obj.TreeSumOutput;
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
            flag=false;
            switch prop
            case 'ConversionStandard'
                flag=strcmp(obj.Conversion,'RGB to intensity');
            case 'ScanningStandard'
                if strcmp(obj.Conversion,'RGB to intensity')
                    flag=true;
                else
                    if strcmp(obj.ConversionStandard,'Rec. 601 (SDTV)')
                        flag=true;
                    end
                end
            otherwise
            end
        end

        function resetImpl(obj)

            obj.OutputCast(:,:)=0;
            obj.datadelay(:,:)=0;
            obj.hstartdelay(:,:)=false;
            obj.henddelay(:,:)=false;
            obj.vstartdelay(:,:)=false;
            obj.venddelay(:,:)=false;
            obj.validdelay(:,:)=false;
            obj.TreeSumOutput(:,:)=0;
        end

        function setupImpl(obj,pixelIn,~)
            dataIn1=pixelIn(1);
            S=visionhdl.ColorSpaceConverter.getWeightOffset(...
            obj.Conversion,...
            obj.ConversionStandard,...
            obj.ScanningStandard,...
            class(dataIn1));

            obj.transform=S.transformA;
            tempOffset=S.offsetb;
            tempLuma=S.MinMaxLuma;
            tempChroma=S.MinMaxChroma;


            if isa(dataIn1,'uint8')
                obj.offset=tempOffset;
                obj.LumaSup=cast(tempLuma,'like',dataIn1);
                obj.ChroSup=cast(tempChroma,'like',dataIn1);

                if strcmp(obj.Conversion,'RGB to intensity')
                    obj.TreeSumOutput=fi(zeros(1,size(pixelIn,1)),0,8,0,'RoundingMethod','nearest');
                else
                    obj.TreeSumOutput=fi(zeros(3,size(pixelIn,1)),0,8,0,'RoundingMethod','nearest');
                end
            elseif isa(dataIn1,'uint16')
                tempOffset=fi(2^8,0,9,0)*tempOffset;
                tempLuma=2^8*tempLuma;
                tempChroma=2^8*tempChroma;


                obj.offset=tempOffset;
                obj.LumaSup=cast(tempLuma,'like',dataIn1);
                obj.ChroSup=cast(tempChroma,'like',dataIn1);

                if strcmp(obj.Conversion,'RGB to intensity')
                    obj.TreeSumOutput=fi(zeros(1,size(pixelIn,1)),0,16,0,'RoundingMethod','nearest');
                else
                    obj.TreeSumOutput=fi(zeros(3,size(pixelIn,1)),0,16,0,'RoundingMethod','nearest');
                end
            elseif isfi(dataIn1)
                tempOffset=fi(2^(dataIn1.WordLength-8),0,dataIn1.WordLength-7,0)*tempOffset;
                tempLuma=2^(dataIn1.WordLength-8)*tempLuma;
                tempChroma=2^(dataIn1.WordLength-8)*tempChroma;

                obj.offset=tempOffset;
                obj.LumaSup=cast(tempLuma,'like',dataIn1);
                obj.ChroSup=cast(tempChroma,'like',dataIn1);

                if strcmp(obj.Conversion,'RGB to intensity')
                    obj.TreeSumOutput=fi(zeros(1,size(pixelIn,1)),0,dataIn1.WordLength,0,'RoundingMethod','nearest');
                else
                    obj.TreeSumOutput=fi(zeros(3,size(pixelIn,1)),0,dataIn1.WordLength,0,'RoundingMethod','nearest');
                end
            else
                obj.offset=tempOffset;
                obj.LumaSup=cast(tempLuma,'like',dataIn1);
                obj.ChroSup=cast(tempChroma,'like',dataIn1);

                if strcmp(obj.Conversion,'RGB to intensity')
                    obj.TreeSumOutput=cast(zeros(1,size(pixelIn,1)),'like',dataIn1);
                else
                    obj.TreeSumOutput=cast(zeros(3,size(pixelIn,1)),'like',dataIn1);
                end
            end

            if strcmp(obj.Conversion,'YCbCr to RGB')
                NumberOfDelay=10;
            else
                NumberOfDelay=9;
            end

            if strcmp(obj.Conversion,'RGB to intensity')

                obj.OutputCast=cast(zeros(1,size(pixelIn,1)),'like',dataIn1);
                obj.datadelay=cast(zeros(size(pixelIn,1),NumberOfDelay),'like',dataIn1);
            else
                obj.OutputCast=cast(zeros(3,size(pixelIn,1)),'like',dataIn1);
                obj.datadelay=cast(zeros(3*size(pixelIn,1),NumberOfDelay),'like',dataIn1);

            end
            obj.hstartdelay=false(1,NumberOfDelay);
            obj.henddelay=false(1,NumberOfDelay);
            obj.vstartdelay=false(1,NumberOfDelay);
            obj.venddelay=false(1,NumberOfDelay);
            obj.validdelay=false(1,NumberOfDelay);

            obj.d_or_s=isfloat(dataIn1);
        end



        function[pixelOut,CtrlOut]=outputImpl(obj,pixelIn,~)

            if strcmp(obj.Conversion,'RGB to intensity')
                pixelOut=(obj.datadelay(:,end));
            else
                pixelOut=reshape(obj.datadelay(:,end),[3,size(pixelIn,1)])';
            end

            CtrlOut.hStart=obj.hstartdelay(end);
            CtrlOut.hEnd=obj.henddelay(end);
            CtrlOut.vStart=obj.vstartdelay(end);
            CtrlOut.vEnd=obj.venddelay(end);
            CtrlOut.valid=obj.validdelay(end);
        end

        function updateImpl(obj,pixelIn,CtrlIn)

            data1=pixelIn(:,1);
            data2=pixelIn(:,2);
            data3=pixelIn(:,3);

            if CtrlIn.valid
                if strcmp(obj.Conversion,'YCbCr to RGB')&&(~obj.d_or_s)


                    data1=min(obj.LumaSup(2),max(obj.LumaSup(1),data1));
                    data2=min(obj.ChroSup(2),max(obj.ChroSup(1),data2));
                    data3=min(obj.ChroSup(2),max(obj.ChroSup(1),data3));
                end

                obj.TreeSumOutput(:,:)=repmat(obj.offset,1,size(pixelIn,1))+...
                obj.transform*[data1';data2';data3'];

                if(~strcmp(obj.Conversion,'RGB to YCbCr'))&&obj.d_or_s
                    obj.TreeSumOutput=max(0,min(1,obj.TreeSumOutput));
                end
                obj.OutputCast(:,:)=obj.TreeSumOutput;
            else
                obj.OutputCast(:,:)=0;
            end

            obj.datadelay=[obj.OutputCast(:),obj.datadelay(:,1:end-1)];
            obj.hstartdelay=[CtrlIn.hStart,obj.hstartdelay(1:end-1)];
            obj.henddelay=[CtrlIn.hEnd,obj.henddelay(1:end-1)];
            obj.vstartdelay=[CtrlIn.vStart,obj.vstartdelay(1:end-1)];
            obj.venddelay=[CtrlIn.vEnd,obj.venddelay(1:end-1)];
            obj.validdelay=[CtrlIn.valid,obj.validdelay(1:end-1)];
        end
    end

    methods(Static,Hidden)
        function S=getWeightOffset(ConvT,CS,SS,dataInDT)
            if(nargin<4)



                dataInDT='fi';
            end

            switch ConvT
            case 'RGB to YCbCr'
                if(strcmp(CS,'Rec. 709 (HDTV)')&&...
                    strcmp(SS,'1125/60/2:1'))
                    AA=[46.5594,156.6288,15.8118;...
                    -25.6642,-86.3358,112.0000;...
                    112.0000,-101.7303,-10.2697]/255;
                else
                    AA=[65.481,128.553,24.966;...
                    -0.299*0.5*224/0.886,-0.587*0.5*224/0.886,112.0;...
                    112.0,-0.587*0.5*224/0.701,-0.114*0.5*224/0.701]/255;
                end
                if(strcmp(dataInDT,'double')||strcmp(dataInDT,'single'))
                    A=AA;
                    b=([16,128,128]./255).';
                else

                    A=fi(AA,1,17,16,'RoundingMethod','Nearest');
                    b=fi([16;128;128],0,8,0);
                end
            case 'YCbCr to RGB'
                if(strcmp(CS,'Rec. 709 (HDTV)')&&...
                    strcmp(SS,'1125/60/2:1'))
                    AA=[1.16438356164384,0.00000000000000,1.79274107142857;...
                    1.16438356164384,-0.21324861427373,-0.53290932855944;...
                    1.16438356164384,2.11240178571429,0.00000000000000];
                else
                    AA=[1.16438356164384,0.00000000000000,1.59602678571429;...
                    1.16438356164384,-0.39176229009491,-0.81296764723777;...
                    1.16438356164384,2.01723214285714,0.00000000000000];
                end
                if(strcmp(dataInDT,'double')||strcmp(dataInDT,'single'))
                    A=AA;
                    b=-AA*[16;128;128]./255;
                else

                    A=fi(AA,1,17,14,'RoundingMethod','Nearest');
                    b=-A*fi([16;128;128],1,9,0);


                end
            otherwise
                if(strcmp(dataInDT,'double')||strcmp(dataInDT,'single'))
                    A=[0.299,0.587,0.114];
                    b=0;
                else
                    A=fi([0.299,0.587,0.114],0,16,16);
                    b=fi(0,0,1,0);
                end
            end
            S.transformA=A;
            S.offsetb=b;

            S.MinMaxLuma=[16,235];
            S.MinMaxChroma=[16,240];
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
