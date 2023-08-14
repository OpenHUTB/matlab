classdef(StrictDefaults)DemosaicInterpolator<visionhdl.internal.abstractLineMemoryKernel




























































































































%#codegen


    properties(Nontunable)



        Algorithm='Gradient-corrected linear';




        SensorAlignment='RGGB';





        LineBufferSize=2048;

    end

    properties(Nontunable)

    end






    properties(Access=private)

        pPOCI;
        pControlDBShiftRegister;
        pControlDBKernelOperation;
        pControlDataWrite;
        pProcessDelay;
        pEndOfLine;
        pSELR;
        pSELG;
        pSELB;
pPassThrough
        pOutputR;
        pOutputG;
        pOutputB;
        pInputInteger;
        processfHandle;
        processOutfHandle;
        updatePOCIHandle;
calcSinglePixelGradient
pMulPixBuffer

        pSELRD;
        pSELGD;
        pSELBD;
pBayerState
        pInterpGOut;
        pInterpRB1Out;
        pInterpRB2Out;
        pInterpRB3Out;
        pInterpGOutD;
        pInterpRB1OutD;
        pInterpRB2OutD;
        pInterpRB3OutD;
        pOutputScaling;







        pKernel1;
        pKernel2;
        pKernel3;
        pKernel4;
        pKernel1D;
        pKernel2D;
        pKernel3D;
        pKernel4D;


    end

    properties(Access=private,Nontunable)
        pInterpG=[0,0,-1,0,0;0,0,2,0,0;-1,2,4,2,-1;0,0,2,0,0;0,0,-1,0,0];
        pInterpRB1=[0,0,0.5,0,0;0,-1,0,-1,0;-1,4,5,4,-1;0,-1,0,-1,0;0,0,0.5,0,0];
        pInterpRB2=[0,0,-1,0,0;0,-1,4,-1,0;0.5,0,5,0,0.5;0,-1,4,-1,0;0,0,-1,0,0];
        pInterpRB3=[0,0,-1.5,0,0;0,2,0,2,0;-1.5,0,6,0,-1.5;0,2,0,2,0;0,0,-1.5,0,0];

        pSELRL1P1;
        pSELRL1P2;
        pSELRL2P1;
        pSELRL2P2;
        pSELGL1P1;
        pSELGL1P2;
        pSELGL2P1;
        pSELGL2P2;
        pSELBL1P1;
        pSELBL1P2;
        pSELBL2P1;
        pSELBL2P2;

        pNumberOfPixels;
        pSELRL1;
        pSELRL2;
        pSELGL1;
        pSELGL2;
        pSELBL1;
        pSELBL2;

    end

    properties(DiscreteState)
    end

    properties(Hidden,Transient)
        AlgorithmSet=matlab.system.StringSet({...
        'Gradient-corrected linear',...
        'Bilinear'});

        SensorAlignmentSet=matlab.system.StringSet({...
        'GBRG',...
        'GRBG',...
        'BGGR',...
        'RGGB'});
    end


    methods

        function obj=DemosaicInterpolator(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.DemosaicInterpolator',...
            'ShowSourceLink',false,...
            'Title','Demosaic Interpolator');
        end

        function groups=getPropertyGroupsImpl

            groups=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'Algorithm','SensorAlignment','LineBufferSize'});
        end

    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
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
            dataSize=propagatedInputSize(obj,1);
            sz1=[dataSize(1),3];
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

        function setupImpl(obj,dataIn,ctrlIn)
            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(ctrlIn);

            obj.pNumberOfPixels=size(dataIn,1);


            if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                obj.KernelMemoryKernelHeight=5;
                obj.KernelMemoryKernelWidth=5;
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Symmetric';
            elseif strcmpi(obj.Algorithm,'Bilinear')
                obj.KernelMemoryKernelHeight=3;
                obj.KernelMemoryKernelWidth=3;
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Symmetric';
            else
                obj.KernelMemoryKernelHeight=3;
                obj.KernelMemoryKernelWidth=3;
                obj.KernelMemoryMaxLineSize=obj.LineBufferSize;
                obj.KernelMemoryPaddingMethod='Symmetric';
            end
            obj.KernelMemoryBiasUp=true;
            setupKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);


            if isa(dataIn,'double')
                if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                    obj.setupGradientFloat('double');
                else
                    obj.setupBilinearFloat('double');
                end
            elseif isa(dataIn,'single')
                if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                    obj.setupGradientFloat('single');
                else
                    obj.setupBilinearFloat('single');
                end
            end

            if isempty(coder.target)||~eml_ambiguous_types
                if isa(dataIn,'embedded.fi')

                    if strcmpi(dataIn.Signedness,'Signed')
                        dataSign=true;
                    else
                        dataSign=false;
                    end

                    if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                        obj.setupGradientFixed(dataIn.WordLength,dataIn.FractionLength,dataSign);
                    else
                        obj.setupBilinearFixed(dataIn.WordLength,dataIn.FractionLength,dataSign);
                    end
                elseif isinteger(dataIn)
                    if isa(dataIn,'uint8')
                        WL=8;FL=0;signed=false;
                        obj.pInputInteger=true;
                    elseif(isa(dataIn,'uint16'))
                        WL=16;FL=0;signed=false;
                        obj.pInputInteger=true;
                    elseif(isa(dataIn,'uint32'))
                        WL=32;FL=0;signed=false;
                        obj.pInputInteger=true;
                    elseif(isa(dataIn,'uint64'))
                        WL=64;FL=0;signed=false;
                        obj.pInputInteger=true;
                    end

                    if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                        obj.setupGradientInteger(WL,FL,signed);
                    else
                        obj.setupBilinearInteger(WL,FL,signed);
                    end
                end
            end

            if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                if(obj.pNumberOfPixels==1)
                    obj.processfHandle=@calcSinglePixelGradientCorrected;
                    obj.updatePOCIHandle=@updateSinglePixelPOCI;
                else
                    obj.processfHandle=@calcMultiPixelGradientCorrected;
                    obj.updatePOCIHandle=@updateGradientMultiPixelPOCI;
                end
                obj.processOutfHandle=@calcGradientCorrectedOut;
            elseif strcmpi(obj.Algorithm,'Bilinear')
                obj.processfHandle=@calcBilinear;
                obj.processOutfHandle=@calcBilinearOut;
                if(obj.pNumberOfPixels==1)
                    obj.updatePOCIHandle=@updateSinglePixelPOCI;
                else
                    obj.updatePOCIHandle=@updateBilinearMultiPixelPOCI;
                end
            end


            setupFSMConstant(obj);

        end

        function[dataOut,ctrlOut]=outputImpl(obj,dataIn,ctrlIn)

            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(ctrlIn);

            [R,G,B,hStartOut,hEndOut,vStartOut,vEndOut,validOut]=...
            obj.processOutfHandle(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);

            dataOut=[R,G,B];

            ctrlOut=pixelcontrolstruct(hStartOut,hEndOut,vStartOut,vEndOut,validOut);
        end

        function updateImpl(obj,dataIn,ctrlIn)

            [hStartIn,hEndIn,vStartIn,vEndIn,validIn]=pixelcontrolsignals(ctrlIn);

            obj.processfHandle(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);
        end

        function resetImpl(obj)

            obj.pPOCI(:,:)=0;
            obj.pControlDBShiftRegister(:,:)=false;
            obj.pControlDBKernelOperation(:,:)=false;
            obj.pControlDataWrite(:,:)=false;
            obj.pSELR(:)=0;
            obj.pSELG(:)=0;
            obj.pSELB(:)=0;
            obj.pOutputR(:)=0;
            obj.pOutputG(:)=0;
            obj.pOutputB(:)=0;
            obj.pBayerState(:)=0;


            if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                obj.pSELRD(:)=0;
                obj.pSELGD(:)=0;
                obj.pSELBD(:)=0;
                obj.pInterpGOut(:)=0;
                obj.pInterpRB1Out(:)=0;
                obj.pInterpRB2Out(:)=0;
                obj.pInterpRB3Out(:)=0;
                obj.pInterpGOutD(:)=0;
                obj.pInterpRB1OutD(:)=0;
                obj.pInterpRB2OutD(:)=0;
                obj.pInterpRB3OutD(:)=0;
            else
                obj.pKernel1(:)=0;
                obj.pKernel2(:)=0;
                obj.pKernel3(:)=0;
                obj.pKernel4(:)=0;
                obj.pKernel1D(:)=0;
                obj.pKernel2D(:)=0;
                obj.pKernel3D(:)=0;
                obj.pKernel4D(:)=0;
            end
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            s=saveObjectKernelMemory(obj,s);

            if obj.isLocked
                s.pPOCI=obj.pPOCI;

                s.pSELR=obj.pSELR;
                s.pSELG=obj.pSELG;
                s.pSELB=obj.pSELB;
                s.pOutputR=obj.pOutputR;
                s.pOutputG=obj.pOutputG;
                s.pOutputB=obj.pOutputB;
                s.pInputInteger=obj.pInputInteger;
                s.processfHandle=obj.processfHandle;
                s.processOutfHandle=obj.processOutfHandle;
                s.pProcessDelay=obj.pProcessDelay;
                s.pEndOfLine=obj.pEndOfLine;
                s.pPassThrough=obj.pPassThrough;
                s.pControlDBShiftRegister=obj.pControlDBShiftRegister;
                s.pControlDBKernelOperation=obj.pControlDBKernelOperation;
                s.pControlDataWrite=obj.pControlDataWrite;
                s.pSELRD=obj.pSELRD;
                s.pSELGD=obj.pSELGD;
                s.pSELBD=obj.pSELBD;
                s.pBayerState=obj.pBayerState;
                s.pInterpGOut=obj.pInterpGOut;
                s.pInterpRB1Out=obj.pInterpRB1Out;
                s.pInterpRB2Out=obj.pInterpRB2Out;
                s.pInterpRB3Out=obj.pInterpRB3Out;
                s.pInterpGOutD=obj.pInterpGOutD;
                s.pInterpRB1OutD=obj.pInterpRB1OutD;
                s.pInterpRB2OutD=obj.pInterpRB2OutD;
                s.pInterpRB3OutD=obj.pInterpRB3OutD;
                s.pOutputScaling=obj.pOutputScaling;
                s.pKernel1=obj.pKernel1;
                s.pKernel2=obj.pKernel2;
                s.pKernel3=obj.pKernel3;
                s.pKernel4=obj.pKernel4;
                s.pKernel1D=obj.pKernel1D;
                s.pKernel2D=obj.pKernel2D;
                s.pKernel3D=obj.pKernel3D;
                s.pKernel4D=obj.pKernel4D;

                s.pInterpG=obj.pInterpG;
                s.pInterpRB1=obj.pInterpRB1;
                s.pInterpRB2=obj.pInterpRB2;
                s.pInterpRB3=obj.pInterpRB3;
                s.pSELRL1P1=obj.pSELRL1P1;
                s.pSELRL1P2=obj.pSELRL1P2;
                s.pSELRL2P1=obj.pSELRL2P1;
                s.pSELRL2P2=obj.pSELRL2P2;
                s.pSELGL1P1=obj.pSELGL1P1;
                s.pSELGL1P2=obj.pSELGL1P2;
                s.pSELGL2P1=obj.pSELGL2P1;
                s.pSELGL2P2=obj.pSELGL2P2;
                s.pSELBL1P1=obj.pSELBL1P1;
                s.pSELBL1P2=obj.pSELBL1P2;
                s.pSELBL2P1=obj.pSELBL2P1;
                s.pSELBL2P2=obj.pSELBL2P2;

                s.pNumberOfPixels=obj.pNumberOfPixels;
                s.pMulPixBuffer=obj.pMulPixBuffer;
                s.pSELRL1=obj.pSELRL1;
                s.pSELRL2=obj.pSELRL2;
                s.pSELGL1=obj.pSELGL1;
                s.pSELGL2=obj.pSELGL2;
                s.pSELBL1=obj.pSELBL1;
                s.pSELBL2=obj.pSELBL2;

            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectKernelMemory(obj,s);
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function icon=getIconImpl(~)
            icon=sprintf('Demosaic Interpolator');
        end


        function validateInputsImpl(~,dataIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types

                dataDim=size(dataIn);

                if numel(dataDim)>2
                    coder.internal.error('visionhdl:DemosaicInterpolator:InputDimensions');
                elseif dataDim(1)>1
                    if ismember(dataDim(1),[2,4,8])&&dataDim(2)==1
                        validateattributes(dataIn,{'single','double','embedded.fi','uint8','uint16','uint32','uint64'},{'real'},'DemosaicInterpolator','pixelIn');
                    else
                        coder.internal.error('visionhdl:DemosaicInterpolator:InputDimensions');
                    end
                else
                    if dataDim(2)>1
                        coder.internal.error('visionhdl:DemosaicInterpolator:InputDimensions');
                    else
                        validateattributes(dataIn,{'single','double','embedded.fi','uint8','uint16','uint32','uint64'},{'real','scalar'},'DemosaicInterpolator','pixelIn');
                    end
                end

                validatecontrolsignals(ctrlIn);

                if isfi(dataIn)
                    coder.internal.errorIf(strcmpi(dataIn.Signedness,'Signed'),...
                    'visionhdl:DemosaicInterpolator:signedType');
                end
            end
        end

        function validatePropertiesImpl(obj)

            validateattributes(obj.LineBufferSize,{'numeric'},{'real','integer','nonzero','positive','scalar'},'DemosaicInterpolator','LineBufferSize');
        end

        function z=getDiscreteStateImpl(obj)%#ok<MANU>


            z=struct([]);
        end

    end

    methods(Access=private)

        function[R,G,B,hStartOut,hEndOut,vStartOut,vEndOut,validOut]=...
            calcGradientCorrectedOut(obj,~,~,~,~,~,~)
            R=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputR);
            G=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputG);
            B=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputB);

            hStartOut=obj.pControlDBKernelOperation(1,end-1);
            hEndOut=obj.pControlDBKernelOperation(2,end);
            vStartOut=obj.pControlDBKernelOperation(3,end-1);
            vEndOut=obj.pControlDBKernelOperation(4,end);
            validOut=obj.pControlDBKernelOperation(5,end-1);

            if validOut
                if obj.pNumberOfPixels==1
                    R(:)=obj.pOutputR(1,2,:);G(:)=obj.pOutputG(1,2,:);B(:)=obj.pOutputB(1,2,:);
                else
                    R(:)=obj.pOutputR(1,3,:);G(:)=obj.pOutputG(1,3,:);B(:)=obj.pOutputB(1,3,:);
                end
            end
        end


        function calcSinglePixelGradientCorrected(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn)

            [data,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);

            obj.pControlDBKernelOperation(:,2:end)=obj.pControlDBKernelOperation(:,1:end-1);

            obj.pControlDBKernelOperation(1,1)=obj.pControlDataWrite(1,1);
            obj.pControlDBKernelOperation(2,1)=obj.pControlDBShiftRegister(2,end);
            obj.pControlDBKernelOperation(3,1)=obj.pControlDataWrite(3,1);
            obj.pControlDBKernelOperation(4,1)=obj.pControlDBShiftRegister(4,end);
            obj.pControlDBKernelOperation(5,1)=obj.pControlDataWrite(5,1)||obj.pEndOfLine(2);

            obj.pControlDataWrite(1,1)=obj.pControlDBShiftRegister(1,end)&&obj.pProcessDelay;
            obj.pControlDataWrite(5,1)=obj.pControlDBShiftRegister(5,end)&&obj.pProcessDelay||hEnd||obj.pEndOfLine(1);
            obj.pControlDataWrite(3,1)=obj.pControlDBShiftRegister(3,end)&&obj.pProcessDelay;


            dataWriteController(obj,obj.pControlDataWrite(1,1),obj.pControlDataWrite(2,2),...
            obj.pControlDataWrite(3,1),obj.pControlDataWrite(4,2),obj.pControlDataWrite(5,1));

            if obj.pControlDataWrite(2,1)
                obj.pControlDBKernelOperation(:,:)=0;
                obj.pControlDBShiftRegister(:,:)=0;
            end

            if obj.pControlDataWrite(2,2)
                obj.pControlDBKernelOperation(:,:)=0;
                obj.pControlDBShiftRegister(:,:)=0;
                obj.pControlDataWrite(:,:)=0;
            end

            obj.pControlDataWrite(4,2)=obj.pControlDataWrite(4,1);
            obj.pControlDataWrite(2,2)=obj.pControlDataWrite(2,1);

            obj.pControlDataWrite(4,1)=obj.pControlDBKernelOperation(4,end);
            obj.pControlDataWrite(2,1)=obj.pControlDBKernelOperation(2,end);
            obj.pProcessDelay=processData||obj.pEndOfLine(1);
            obj.pEndOfLine(2)=obj.pEndOfLine(1);

            if hEnd
                obj.pEndOfLine(1)=true;
            elseif obj.pControlDBKernelOperation(2,end)
                obj.pEndOfLine(1)=false;
            end

            if processData

                obj.pControlDBShiftRegister(1,2:end)=obj.pControlDBShiftRegister(1,1:end-1);
                obj.pControlDBShiftRegister(3,2:end)=obj.pControlDBShiftRegister(3,1:end-1);
                obj.pControlDBShiftRegister(5,2:end)=obj.pControlDBShiftRegister(5,1:end-1);

                obj.pControlDBShiftRegister(1,1)=hStart;
                obj.pControlDBShiftRegister(3,1)=vStart;
                obj.pControlDBShiftRegister(5,1)=valid;

                if hEnd
                    obj.pControlDBShiftRegister(5,:)=0;
                end
            end

            obj.pControlDBShiftRegister(2,2:end)=obj.pControlDBShiftRegister(2,1:end-1);
            obj.pControlDBShiftRegister(4,2:end)=obj.pControlDBShiftRegister(4,1:end-1);

            obj.pControlDBShiftRegister(2,1)=hEnd;
            obj.pControlDBShiftRegister(4,1)=vEnd;

            obj.pOutputR(1,3,:)=obj.pOutputR(1,2,:);
            obj.pOutputG(1,3,:)=obj.pOutputG(1,2,:);
            obj.pOutputB(1,3,:)=obj.pOutputB(1,2,:);
            obj.pOutputR(1,2,:)=obj.pOutputR(1,1,:);
            obj.pOutputG(1,2,:)=obj.pOutputG(1,1,:);
            obj.pOutputB(1,2,:)=obj.pOutputB(1,1,:);


            for ii=1:obj.pNumberOfPixels

                switch obj.pSELRD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputR(1,1,ii)=obj.pInterpRB1OutD(ii);
                case 1
                    obj.pOutputR(1,1,ii)=obj.pInterpRB2OutD(ii);
                case 2
                    obj.pOutputR(1,1,ii)=obj.pInterpRB3OutD(ii);
                case 3
                    obj.pOutputR(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                switch obj.pSELGD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputG(1,1,ii)=obj.pInterpGOutD(ii);
                case 1
                    obj.pOutputG(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                switch obj.pSELBD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputB(1,1,ii)=obj.pInterpRB1OutD(ii);
                case 1
                    obj.pOutputB(1,1,ii)=obj.pInterpRB2OutD(ii);
                case 2
                    obj.pOutputB(1,1,ii)=obj.pInterpRB3OutD(ii);
                case 3
                    obj.pOutputB(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                obj.pInterpRB1OutD(ii)=obj.pInterpRB1Out(ii)*obj.pOutputScaling;
                obj.pInterpRB2OutD(ii)=obj.pInterpRB2Out(ii)*obj.pOutputScaling;
                obj.pInterpRB3OutD(ii)=obj.pInterpRB3Out(ii)*obj.pOutputScaling;
                obj.pInterpGOutD(ii)=obj.pInterpGOut(ii)*obj.pOutputScaling;


                obj.pInterpGOut(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpG,1,5*5));
                obj.pInterpRB1Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB1,1,5*5));
                obj.pInterpRB2Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB2,1,5*5));
                obj.pInterpRB3Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB3,1,5*5));
            end


            obj.pSELRD(1,2:end,:)=obj.pSELRD(1,1:end-1,:);
            obj.pSELGD(1,2:end,:)=obj.pSELGD(1,1:end-1,:);
            obj.pSELBD(1,2:end,:)=obj.pSELBD(1,1:end-1,:);

            obj.pSELRD(1,1,:)=obj.pSELR;
            obj.pSELGD(1,1,:)=obj.pSELG;
            obj.pSELBD(1,1,:)=obj.pSELB;

            if processData
                obj.updatePOCIHandle(obj,data);
            end
            obj.pPassThrough(:,2:end,:)=obj.pPassThrough(:,1:(end-1),:);
            obj.pPassThrough(1,1,:)=obj.pPOCI(3,3,:);

        end


        function calcMultiPixelGradientCorrected(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn)

            [data,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);

            obj.pControlDBKernelOperation(:,2:end)=obj.pControlDBKernelOperation(:,1:end-1);

            obj.pControlDBKernelOperation(1,1)=obj.pControlDataWrite(1,1);
            obj.pControlDBKernelOperation(2,1)=obj.pControlDBShiftRegister(2,end);
            obj.pControlDBKernelOperation(3,1)=obj.pControlDataWrite(3,1);
            obj.pControlDBKernelOperation(4,1)=obj.pControlDBShiftRegister(4,end);
            obj.pControlDBKernelOperation(5,1)=obj.pControlDataWrite(5,1)||obj.pEndOfLine(2);


            obj.pControlDataWrite(1,1)=obj.pControlDBShiftRegister(1,end)&&obj.pProcessDelay;
            obj.pControlDataWrite(5,1)=obj.pControlDBShiftRegister(5,end)&&obj.pProcessDelay||hEnd||obj.pEndOfLine(1);
            obj.pControlDataWrite(3,1)=obj.pControlDBShiftRegister(3,end)&&obj.pProcessDelay;


            dataWriteController(obj,obj.pControlDataWrite(1,1),obj.pControlDataWrite(2,2),...
            obj.pControlDataWrite(3,1),obj.pControlDataWrite(4,2),obj.pControlDataWrite(5,1));

            if obj.pControlDataWrite(2,1)
                obj.pControlDBKernelOperation(:,:)=0;
                obj.pControlDBShiftRegister(:,:)=0;
            end

            if obj.pControlDataWrite(2,2)
                obj.pControlDBKernelOperation(:,:)=0;
                obj.pControlDBShiftRegister(:,:)=0;
                obj.pControlDataWrite(:,:)=0;
            end

            obj.pControlDataWrite(4,2)=obj.pControlDataWrite(4,1);
            obj.pControlDataWrite(2,2)=obj.pControlDataWrite(2,1);

            obj.pControlDataWrite(4,1)=obj.pControlDBKernelOperation(4,end);
            obj.pControlDataWrite(2,1)=obj.pControlDBKernelOperation(2,end);
            obj.pProcessDelay=processData||obj.pEndOfLine(1);
            obj.pEndOfLine(2)=obj.pEndOfLine(1);

            if hEnd
                obj.pEndOfLine(1)=true;
            elseif obj.pControlDBKernelOperation(2,end)
                obj.pEndOfLine(1)=false;
            end

            if processData

                obj.pControlDBShiftRegister(1,2:end)=obj.pControlDBShiftRegister(1,1:end-1);
                obj.pControlDBShiftRegister(3,2:end)=obj.pControlDBShiftRegister(3,1:end-1);
                obj.pControlDBShiftRegister(5,2:end)=obj.pControlDBShiftRegister(5,1:end-1);

                obj.pControlDBShiftRegister(1,1)=hStart;
                obj.pControlDBShiftRegister(3,1)=vStart;
                obj.pControlDBShiftRegister(5,1)=valid;

                if hEnd
                    obj.pControlDBShiftRegister(5,:)=0;
                end
            end

            obj.pControlDBShiftRegister(2,2:end)=obj.pControlDBShiftRegister(2,1:end-1);
            obj.pControlDBShiftRegister(4,2:end)=obj.pControlDBShiftRegister(4,1:end-1);

            obj.pControlDBShiftRegister(2,1)=hEnd;
            obj.pControlDBShiftRegister(4,1)=vEnd;

            obj.pOutputR(1,3,:)=obj.pOutputR(1,2,:);
            obj.pOutputG(1,3,:)=obj.pOutputG(1,2,:);
            obj.pOutputB(1,3,:)=obj.pOutputB(1,2,:);
            obj.pOutputR(1,2,:)=obj.pOutputR(1,1,:);
            obj.pOutputG(1,2,:)=obj.pOutputG(1,1,:);
            obj.pOutputB(1,2,:)=obj.pOutputB(1,1,:);


            obj.pSELRD(1,2:end,:)=obj.pSELRD(1,1:end-1,:);
            obj.pSELGD(1,2:end,:)=obj.pSELGD(1,1:end-1,:);
            obj.pSELBD(1,2:end,:)=obj.pSELBD(1,1:end-1,:);

            obj.pSELRD(1,1,:)=obj.pSELR;
            obj.pSELGD(1,1,:)=obj.pSELG;
            obj.pSELBD(1,1,:)=obj.pSELB;


            for ii=1:obj.pNumberOfPixels

                switch obj.pSELRD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputR(1,1,ii)=obj.pInterpRB1OutD(ii);
                case 1
                    obj.pOutputR(1,1,ii)=obj.pInterpRB2OutD(ii);
                case 2
                    obj.pOutputR(1,1,ii)=obj.pInterpRB3OutD(ii);
                case 3
                    obj.pOutputR(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                switch obj.pSELGD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputG(1,1,ii)=obj.pInterpGOutD(ii);
                case 1
                    obj.pOutputG(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                switch obj.pSELBD(1,1,min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputB(1,1,ii)=obj.pInterpRB1OutD(ii);
                case 1
                    obj.pOutputB(1,1,ii)=obj.pInterpRB2OutD(ii);
                case 2
                    obj.pOutputB(1,1,ii)=obj.pInterpRB3OutD(ii);
                case 3
                    obj.pOutputB(1,1,ii)=obj.pPassThrough(1,end,ii);
                end


                obj.pInterpRB1OutD(ii)=obj.pInterpRB1Out(ii)*obj.pOutputScaling;
                obj.pInterpRB2OutD(ii)=obj.pInterpRB2Out(ii)*obj.pOutputScaling;
                obj.pInterpRB3OutD(ii)=obj.pInterpRB3Out(ii)*obj.pOutputScaling;
                obj.pInterpGOutD(ii)=obj.pInterpGOut(ii)*obj.pOutputScaling;


                obj.pInterpGOut(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpG,1,5*5));
                obj.pInterpRB1Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB1,1,5*5));
                obj.pInterpRB2Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB2,1,5*5));
                obj.pInterpRB3Out(ii)=sum(reshape(obj.pPOCI(:,:,ii).*obj.pInterpRB3,1,5*5));
            end

            if processData
                obj.updatePOCIHandle(obj,data);
            end
            obj.pPassThrough(:,2:end,:)=obj.pPassThrough(:,1:(end-1),:);
            obj.pPassThrough(1,1,:)=obj.pPOCI(3,3,:);

        end



        function[R,G,B,hStartOut,hEndOut,vStartOut,vEndOut,validOut]=...
            calcBilinearOut(obj,~,~,~,~,~,~)

            R=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputR);
            G=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputG);
            B=cast(zeros(obj.pNumberOfPixels,1),'like',obj.pOutputB);

            hStartOut=obj.pControlDBKernelOperation(1,1);
            hEndOut=obj.pControlDBKernelOperation(2,1);
            vStartOut=obj.pControlDBKernelOperation(3,1);
            vEndOut=obj.pControlDBKernelOperation(4,1);
            validOut=obj.pControlDBKernelOperation(5,1)||hEndOut;
            if validOut
                R(:)=obj.pOutputR';G(:)=obj.pOutputG';B(:)=obj.pOutputB';
            end

        end


        function calcBilinear(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn)


            [data,hStart,hEnd,vStart,vEnd,valid,processData]=...
            stepKernelMemory(obj,dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn);


            dataWriteController(obj,obj.pControlDataWrite(1,1),obj.pControlDataWrite(2,2),...
            obj.pControlDataWrite(3,1),obj.pControlDataWrite(4,2),obj.pControlDataWrite(5,1));

            if processData
                obj.updatePOCIHandle(obj,data);
            end

            obj.pControlDBKernelOperation(1,1)=obj.pControlDBShiftRegister(1,end)&&obj.pProcessDelay;
            obj.pControlDBKernelOperation(2,1)=obj.pControlDBShiftRegister(2,end);
            obj.pControlDBKernelOperation(3,1)=obj.pControlDBShiftRegister(3,end)&&obj.pProcessDelay;
            obj.pControlDBKernelOperation(4,1)=obj.pControlDBShiftRegister(4,end);
            obj.pControlDBKernelOperation(5,1)=obj.pControlDBShiftRegister(5,end)&&obj.pProcessDelay;


            for ii=1:obj.pNumberOfPixels
                obj.pKernel1(ii)=((obj.pPOCI(3,2,ii)+obj.pPOCI(2,3,ii)+obj.pPOCI(2,1,ii)+obj.pPOCI(1,2,ii))/4);
                obj.pKernel2(ii)=((obj.pPOCI(3,3,ii)+obj.pPOCI(3,1,ii)+obj.pPOCI(1,3,ii)+obj.pPOCI(1,1,ii))/4);
                obj.pKernel3(ii)=((obj.pPOCI(3,2,ii)+obj.pPOCI(1,2,ii))/2);
                obj.pKernel4(ii)=((obj.pPOCI(2,3,ii)+obj.pPOCI(2,1,ii))/2);



                switch obj.pSELR(min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputR(ii)=obj.pKernel1D(ii);
                case 1
                    obj.pOutputR(ii)=obj.pKernel2D(ii);
                case 2
                    obj.pOutputR(ii)=obj.pKernel3D(ii);
                case 3
                    obj.pOutputR(ii)=obj.pKernel4D(ii);
                case 4
                    obj.pOutputR(ii)=obj.pPassThrough(ii);
                end


                switch obj.pSELG(min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputG(ii)=obj.pKernel1D(ii);
                case 1
                    obj.pOutputG(ii)=obj.pKernel2D(ii);
                case 2
                    obj.pOutputG(ii)=obj.pKernel3D(ii);
                case 3
                    obj.pOutputG(ii)=obj.pKernel4D(ii);
                case 4
                    obj.pOutputG(ii)=obj.pPassThrough(ii);
                end


                switch obj.pSELB(min((2-mod(ii,2)),obj.pNumberOfPixels))
                case 0
                    obj.pOutputB(ii)=obj.pKernel1D(ii);
                case 1
                    obj.pOutputB(ii)=obj.pKernel2D(ii);
                case 2
                    obj.pOutputB(ii)=obj.pKernel3D(ii);
                case 3
                    obj.pOutputB(ii)=obj.pKernel4D(ii);
                case 4
                    obj.pOutputB(ii)=obj.pPassThrough(ii);
                end
            end



            obj.pControlDataWrite(:,2:end)=obj.pControlDataWrite(:,1:end-1);

            obj.pControlDataWrite(1,1)=hStart;
            obj.pControlDataWrite(2,1)=hEnd;
            obj.pControlDataWrite(3,1)=vStart;
            obj.pControlDataWrite(4,1)=vEnd;
            obj.pControlDataWrite(5,1)=valid;

            if processData


                obj.pControlDBShiftRegister(1,2:end)=obj.pControlDBShiftRegister(1,1:end-1);
                obj.pControlDBShiftRegister(3,2:end)=obj.pControlDBShiftRegister(3,1:end-1);
                obj.pControlDBShiftRegister(5,2:end)=obj.pControlDBShiftRegister(5,1:end-1);


                obj.pControlDBShiftRegister(1,1)=hStart;
                obj.pControlDBShiftRegister(3,1)=vStart;
                obj.pControlDBShiftRegister(5,1)=valid;

                if hEnd
                    obj.pControlDBShiftRegister(5,1)=false;

                end

            end

            obj.pControlDBShiftRegister(2,2:end)=obj.pControlDBShiftRegister(2,1:end-1);
            obj.pControlDBShiftRegister(4,2:end)=obj.pControlDBShiftRegister(4,1:end-1);

            obj.pControlDBShiftRegister(2,1)=hEnd;
            obj.pControlDBShiftRegister(4,1)=vEnd;


            obj.pKernel1D(:)=obj.pKernel1;
            obj.pKernel2D(:)=obj.pKernel2;
            obj.pKernel3D(:)=obj.pKernel3;
            obj.pKernel4D(:)=obj.pKernel4;

            obj.pPassThrough(:)=obj.pPOCI(2,2,:);
            obj.pProcessDelay=processData;
        end


        function updateSinglePixelPOCI(obj,data)

            obj.pPOCI(:,2:end)=obj.pPOCI(:,1:end-1);


            obj.pPOCI(:,1)=data;
        end


        function updateBilinearMultiPixelPOCI(obj,data)

            obj.pMulPixBuffer(:,1:(2*obj.pNumberOfPixels))=obj.pMulPixBuffer(:,(obj.pNumberOfPixels+1):end);


            obj.pMulPixBuffer(:,(2*obj.pNumberOfPixels+1):end)=data;


            for ii=1:obj.pNumberOfPixels
                obj.pPOCI(:,:,ii)=obj.pMulPixBuffer(:,(obj.pNumberOfPixels+(ii-1)):(obj.pNumberOfPixels+(ii+1)));
            end
        end


        function updateGradientMultiPixelPOCI(obj,data)

            obj.pMulPixBuffer(:,1:(2*obj.pNumberOfPixels))=obj.pMulPixBuffer(:,(obj.pNumberOfPixels+1):end);


            obj.pMulPixBuffer(:,(2*obj.pNumberOfPixels+1):end)=data;


            for ii=1:obj.pNumberOfPixels
                obj.pPOCI(:,:,ii)=obj.pMulPixBuffer(:,(obj.pNumberOfPixels+(ii-2)):(obj.pNumberOfPixels+(ii+2)));
            end
        end


        function setupGradientFloat(obj,type)

            if strcmpi(type,'single')
                obj.pPOCI=single(zeros(5,5,obj.pNumberOfPixels));
                if obj.pNumberOfPixels>1
                    obj.pMulPixBuffer=single(zeros(5,(3*obj.pNumberOfPixels)));
                end
                obj.pControlDBShiftRegister=false(5,3);
                obj.pControlDBKernelOperation=false(5,4);
                obj.pControlDataWrite=false(5,2);
                obj.pEndOfLine=false(5,2);
                obj.pProcessDelay=false;
                obj.pSELR=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELG=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELB=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELRD=single(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pSELGD=single(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pSELBD=single(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pPassThrough=single(zeros(1,3,obj.pNumberOfPixels));
                obj.pBayerState=single(0);
                obj.pInterpGOut=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB1Out=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB2Out=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB3Out=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpGOutD=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB1OutD=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB2OutD=single(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB3OutD=single(zeros(1,obj.pNumberOfPixels));
                obj.pOutputScaling=single(1/8);
                obj.pOutputR=single(zeros(1,3,obj.pNumberOfPixels));
                obj.pOutputG=single(zeros(1,3,obj.pNumberOfPixels));
                obj.pOutputB=single(zeros(1,3,obj.pNumberOfPixels));
            elseif strcmpi(type,'double')
                obj.pPOCI=double(zeros(5,5,obj.pNumberOfPixels));
                if obj.pNumberOfPixels>1
                    obj.pMulPixBuffer=double(zeros(5,(3*obj.pNumberOfPixels)));
                end
                obj.pControlDBShiftRegister=false(5,3);
                obj.pControlDBKernelOperation=false(5,4);
                obj.pControlDataWrite=false(5,2);
                obj.pEndOfLine=false(5,2);
                obj.pProcessDelay=false;
                obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELRD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pSELGD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pSELBD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
                obj.pPassThrough=double(zeros(1,3,obj.pNumberOfPixels));
                obj.pBayerState=double(0);
                obj.pInterpGOut=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB1Out=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB2Out=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB3Out=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpGOutD=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB1OutD=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB2OutD=double(zeros(1,obj.pNumberOfPixels));
                obj.pInterpRB3OutD=double(zeros(1,obj.pNumberOfPixels));
                obj.pOutputScaling=double(1/8);
                obj.pOutputR=double(zeros(1,3,obj.pNumberOfPixels));
                obj.pOutputG=double(zeros(1,3,obj.pNumberOfPixels));
                obj.pOutputB=double(zeros(1,3,obj.pNumberOfPixels));

            end

        end

        function setupGradientFixed(obj,WL,FL,signed)
            obj.pPOCI=double(zeros(5,5,obj.pNumberOfPixels));
            if obj.pNumberOfPixels>1
                obj.pMulPixBuffer=double(zeros(5,(3*obj.pNumberOfPixels)));
            end
            obj.pControlDBShiftRegister=false(5,3);
            obj.pControlDBKernelOperation=false(5,4);
            obj.pControlDataWrite=false(5,2);
            obj.pEndOfLine=false(5,2);
            obj.pProcessDelay=false;
            obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELRD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pSELGD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pSELBD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pPassThrough=double(zeros(1,3,obj.pNumberOfPixels));
            obj.pBayerState=double(0);
            obj.pInterpGOut=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB1Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB2Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB3Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pOutputScaling=double(1/8);
            if signed
                obj.pOutputR=(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpGOutD=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB1OutD=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB2OutD=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB3OutD=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            else
                obj.pOutputR=(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpGOutD=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB1OutD=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB2OutD=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB3OutD=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            end

        end

        function setupGradientInteger(obj,WL,FL,signed)
            obj.pPOCI=double(zeros(5,5,obj.pNumberOfPixels));
            if obj.pNumberOfPixels>1
                obj.pMulPixBuffer=double(zeros(5,(3*obj.pNumberOfPixels)));
            end
            obj.pControlDBShiftRegister=false(5,3);
            obj.pControlDBKernelOperation=false(5,4);
            obj.pControlDataWrite=false(5,2);
            obj.pEndOfLine=false(5,2);
            obj.pProcessDelay=false;
            obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELRD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pSELGD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pSELBD=double(zeros(1,3,min(obj.pNumberOfPixels,2)));
            obj.pPassThrough=double(zeros(1,3,obj.pNumberOfPixels));
            obj.pBayerState=double(0);
            obj.pInterpGOut=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB1Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB2Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pInterpRB3Out=double(zeros(1,obj.pNumberOfPixels));
            obj.pOutputScaling=double(1/8);
            if signed
                obj.pOutputR=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpGOutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB1OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB2OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB3OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            else
                obj.pOutputR=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=storedInteger(fi(zeros(1,3,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpGOutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB1OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB2OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pInterpRB3OutD=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            end

        end


        function setupBilinearFloat(obj,type)

            if strcmpi(type,'single')
                obj.pPOCI=single(zeros(3,3,obj.pNumberOfPixels));
                if obj.pNumberOfPixels>1
                    obj.pMulPixBuffer=single(zeros(3,(3*obj.pNumberOfPixels)));
                end
                obj.pControlDBShiftRegister=false(5,2);
                obj.pControlDBKernelOperation=false(5,1);
                obj.pControlDataWrite=false(5,2);
                obj.pEndOfLine=false(5,2);
                obj.pPassThrough=single(zeros(1,obj.pNumberOfPixels));
                obj.pProcessDelay=false;
                obj.pSELR=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELG=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELB=single(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pBayerState=single(0);
                obj.pOutputR=single(zeros(1,obj.pNumberOfPixels));
                obj.pOutputG=single(zeros(1,obj.pNumberOfPixels));
                obj.pOutputB=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel1=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel2=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel3=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel4=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel1D=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel2D=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel3D=single(zeros(1,obj.pNumberOfPixels));
                obj.pKernel4D=single(zeros(1,obj.pNumberOfPixels));
            elseif strcmpi(type,'double')
                obj.pPOCI=double(zeros(3,3,obj.pNumberOfPixels));
                if obj.pNumberOfPixels>1
                    obj.pMulPixBuffer=double(zeros(3,(3*obj.pNumberOfPixels)));
                end
                obj.pControlDBShiftRegister=false(5,2);
                obj.pControlDBKernelOperation=false(5,1);
                obj.pControlDataWrite=false(5,2);
                obj.pEndOfLine=false(5,2);
                obj.pPassThrough=double(zeros(1,obj.pNumberOfPixels));
                obj.pProcessDelay=false;
                obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
                obj.pBayerState=double(0);
                obj.pOutputR=double(zeros(1,obj.pNumberOfPixels));
                obj.pOutputG=double(zeros(1,obj.pNumberOfPixels));
                obj.pOutputB=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel1=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel2=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel3=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel4=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel1D=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel2D=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel3D=double(zeros(1,obj.pNumberOfPixels));
                obj.pKernel4D=double(zeros(1,obj.pNumberOfPixels));
            end

        end

        function setupBilinearFixed(obj,WL,FL,signed)
            obj.pPOCI=double(zeros(3,3,obj.pNumberOfPixels));
            if obj.pNumberOfPixels>1
                obj.pMulPixBuffer=double(zeros(3,(3*obj.pNumberOfPixels)));
            end
            obj.pControlDBShiftRegister=false(5,2);
            obj.pControlDBKernelOperation=false(5,1);
            obj.pControlDataWrite=false(5,2);
            obj.pEndOfLine=false(5,2);
            obj.pPassThrough=double(zeros(1,obj.pNumberOfPixels));
            obj.pProcessDelay=false;
            obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pBayerState=double(0);
            if signed
                obj.pOutputR=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel1D=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel2D=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel3D=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel4D=(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            else
                obj.pOutputR=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel1D=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel2D=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel3D=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel4D=(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            end
            obj.pKernel1=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel2=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel3=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel4=double(zeros(1,obj.pNumberOfPixels));
        end

        function setupBilinearInteger(obj,WL,FL,signed)
            obj.pPOCI=double(zeros(3,3,obj.pNumberOfPixels));
            if obj.pNumberOfPixels>1
                obj.pMulPixBuffer=double(zeros(3,(3*obj.pNumberOfPixels)));
            end
            obj.pControlDBShiftRegister=false(5,2);
            obj.pControlDBKernelOperation=false(5,1);
            obj.pControlDataWrite=false(5,2);
            obj.pEndOfLine=false(5,2);
            obj.pPassThrough=double(zeros(1,obj.pNumberOfPixels));
            obj.pProcessDelay=false;
            obj.pSELR=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELG=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pSELB=double(zeros(1,min(obj.pNumberOfPixels,2)));
            obj.pBayerState=double(0);
            if signed
                obj.pOutputR=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel1D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel2D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel3D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel4D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),1,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            else
                obj.pOutputR=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputG=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pOutputB=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel1D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel2D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel3D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
                obj.pKernel4D=storedInteger(fi(zeros(1,obj.pNumberOfPixels),0,WL,FL,'RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision'));
            end
            obj.pKernel1=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel2=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel3=double(zeros(1,obj.pNumberOfPixels));
            obj.pKernel4=double(zeros(1,obj.pNumberOfPixels));
        end




        function setupFSMConstant(obj)

            if strcmpi(obj.Algorithm,'Gradient-corrected linear')
                if obj.pNumberOfPixels==1
                    switch(obj.SensorAlignment)
                    case('GBRG')
                        obj.pSELRL1P1=1;
                        obj.pSELGL1P1=1;
                        obj.pSELBL1P1=0;
                        obj.pSELRL1P2=2;
                        obj.pSELGL1P2=0;
                        obj.pSELBL1P2=3;
                        obj.pSELRL2P1=3;
                        obj.pSELGL2P1=0;
                        obj.pSELBL2P1=2;
                        obj.pSELRL2P2=0;
                        obj.pSELGL2P2=1;
                        obj.pSELBL2P2=1;

                    case('GRBG')
                        obj.pSELRL1P1=0;
                        obj.pSELGL1P1=1;
                        obj.pSELBL1P1=1;
                        obj.pSELRL1P2=3;
                        obj.pSELGL1P2=0;
                        obj.pSELBL1P2=2;
                        obj.pSELRL2P1=2;
                        obj.pSELGL2P1=0;
                        obj.pSELBL2P1=3;
                        obj.pSELRL2P2=1;
                        obj.pSELGL2P2=1;
                        obj.pSELBL2P2=0;

                    case('BGGR')
                        obj.pSELRL1P1=2;
                        obj.pSELGL1P1=0;
                        obj.pSELBL1P1=3;
                        obj.pSELRL1P2=1;
                        obj.pSELGL1P2=1;
                        obj.pSELBL1P2=0;
                        obj.pSELRL2P1=0;
                        obj.pSELGL2P1=1;
                        obj.pSELBL2P1=1;
                        obj.pSELRL2P2=3;
                        obj.pSELGL2P2=0;
                        obj.pSELBL2P2=2;


                    case('RGGB')
                        obj.pSELRL1P1=3;
                        obj.pSELGL1P1=0;
                        obj.pSELBL1P1=2;
                        obj.pSELRL1P2=0;
                        obj.pSELGL1P2=1;
                        obj.pSELBL1P2=1;
                        obj.pSELRL2P1=1;
                        obj.pSELGL2P1=1;
                        obj.pSELBL2P1=0;
                        obj.pSELRL2P2=2;
                        obj.pSELGL2P2=0;
                        obj.pSELBL2P2=3;

                    end

                else
                    switch(obj.SensorAlignment)
                    case('GBRG')
                        obj.pSELRL1=[1,2];
                        obj.pSELGL1=[1,0];
                        obj.pSELBL1=[0,3];
                        obj.pSELRL2=[3,0];
                        obj.pSELGL2=[0,1];
                        obj.pSELBL2=[2,1];

                    case('GRBG')
                        obj.pSELRL1=[0,3];
                        obj.pSELGL1=[1,0];
                        obj.pSELBL1=[1,2];
                        obj.pSELRL2=[2,1];
                        obj.pSELGL2=[0,1];
                        obj.pSELBL2=[3,0];

                    case('BGGR')
                        obj.pSELRL1=[2,1];
                        obj.pSELGL1=[0,1];
                        obj.pSELBL1=[3,0];
                        obj.pSELRL2=[0,3];
                        obj.pSELGL2=[1,0];
                        obj.pSELBL2=[1,2];

                    case('RGGB')
                        obj.pSELRL1=[3,0];
                        obj.pSELGL1=[0,1];
                        obj.pSELBL1=[2,1];
                        obj.pSELRL2=[1,2];
                        obj.pSELGL2=[1,0];
                        obj.pSELBL2=[0,3];

                    end
                end

            else
                if obj.pNumberOfPixels==1
                    switch(obj.SensorAlignment)
                    case('GBRG')
                        obj.pSELRL1P1=2;
                        obj.pSELGL1P1=4;
                        obj.pSELBL1P1=3;
                        obj.pSELRL1P2=1;
                        obj.pSELGL1P2=0;
                        obj.pSELBL1P2=4;
                        obj.pSELRL2P1=4;
                        obj.pSELGL2P1=0;
                        obj.pSELBL2P1=1;
                        obj.pSELRL2P2=3;
                        obj.pSELGL2P2=4;
                        obj.pSELBL2P2=2;


                    case('GRBG')
                        obj.pSELRL1P1=3;
                        obj.pSELGL1P1=4;
                        obj.pSELBL1P1=2;
                        obj.pSELRL1P2=4;
                        obj.pSELGL1P2=0;
                        obj.pSELBL1P2=1;
                        obj.pSELRL2P1=1;
                        obj.pSELGL2P1=0;
                        obj.pSELBL2P1=4;
                        obj.pSELRL2P2=2;
                        obj.pSELGL2P2=4;
                        obj.pSELBL2P2=3;

                    case('BGGR')
                        obj.pSELRL1P1=1;
                        obj.pSELGL1P1=0;
                        obj.pSELBL1P1=4;
                        obj.pSELRL1P2=2;
                        obj.pSELGL1P2=4;
                        obj.pSELBL1P2=3;
                        obj.pSELRL2P1=3;
                        obj.pSELGL2P1=4;
                        obj.pSELBL2P1=2;
                        obj.pSELRL2P2=4;
                        obj.pSELGL2P2=0;
                        obj.pSELBL2P2=1;

                    case('RGGB')
                        obj.pSELRL1P1=4;
                        obj.pSELGL1P1=0;
                        obj.pSELBL1P1=1;
                        obj.pSELRL1P2=3;
                        obj.pSELGL1P2=4;
                        obj.pSELBL1P2=2;
                        obj.pSELRL2P1=2;
                        obj.pSELGL2P1=4;
                        obj.pSELBL2P1=3;
                        obj.pSELRL2P2=1;
                        obj.pSELGL2P2=0;
                        obj.pSELBL2P2=4;

                    end

                else
                    switch(obj.SensorAlignment)
                    case('GBRG')
                        obj.pSELRL1=[2,1];
                        obj.pSELGL1=[4,0];
                        obj.pSELBL1=[3,4];
                        obj.pSELRL2=[4,3];
                        obj.pSELGL2=[0,4];
                        obj.pSELBL2=[1,2];

                    case('GRBG')
                        obj.pSELRL1=[3,4];
                        obj.pSELGL1=[4,0];
                        obj.pSELBL1=[2,1];
                        obj.pSELRL2=[1,2];
                        obj.pSELGL2=[0,4];
                        obj.pSELBL2=[4,3];

                    case('BGGR')
                        obj.pSELRL1=[1,2];
                        obj.pSELGL1=[0,4];
                        obj.pSELBL1=[4,3];
                        obj.pSELRL2=[3,4];
                        obj.pSELGL2=[4,0];
                        obj.pSELBL2=[2,1];

                    case('RGGB')
                        obj.pSELRL1=[4,3];
                        obj.pSELGL1=[0,4];
                        obj.pSELBL1=[1,2];
                        obj.pSELRL2=[2,1];
                        obj.pSELGL2=[4,0];
                        obj.pSELBL2=[3,4];

                    end
                end
            end

        end




        function dataWriteController(obj,hStart,hEnd,vStart,vEnd,valid)

            switch obj.pBayerState

            case 0
                obj.pSELR(:)=0;
                obj.pSELG(:)=0;
                obj.pSELB(:)=0;


                if vStart||hStart
                    obj.pBayerState(:)=1;
                else
                    obj.pBayerState(:)=0;
                end

            case 1
                if obj.pNumberOfPixels==1
                    obj.pSELR(:)=obj.pSELRL1P1;
                    obj.pSELG(:)=obj.pSELGL1P1;
                    obj.pSELB(:)=obj.pSELBL1P1;
                else
                    obj.pSELR(:)=obj.pSELRL1;
                    obj.pSELG(:)=obj.pSELGL1;
                    obj.pSELB(:)=obj.pSELBL1;
                end


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hEnd
                    obj.pBayerState(:)=5;
                elseif valid
                    obj.pBayerState(:)=2;
                else
                    obj.pBayerState(:)=1;
                end

            case 2
                if obj.pNumberOfPixels==1
                    obj.pSELR(:)=obj.pSELRL1P2;
                    obj.pSELG(:)=obj.pSELGL1P2;
                    obj.pSELB(:)=obj.pSELBL1P2;
                else
                    obj.pSELR(:)=obj.pSELRL1;
                    obj.pSELG(:)=obj.pSELGL1;
                    obj.pSELB(:)=obj.pSELBL1;
                end


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hEnd
                    obj.pBayerState(:)=5;
                elseif valid
                    obj.pBayerState(:)=1;
                else
                    obj.pBayerState(:)=2;
                end

            case 3
                if obj.pNumberOfPixels==1
                    obj.pSELR(:)=obj.pSELRL2P1;
                    obj.pSELG(:)=obj.pSELGL2P1;
                    obj.pSELB(:)=obj.pSELBL2P1;
                else
                    obj.pSELR(:)=obj.pSELRL2;
                    obj.pSELG(:)=obj.pSELGL2;
                    obj.pSELB(:)=obj.pSELBL2;
                end


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hEnd
                    obj.pBayerState(:)=6;
                elseif valid
                    obj.pBayerState(:)=4;
                else
                    obj.pBayerState(:)=3;
                end

            case 4
                if obj.pNumberOfPixels==1
                    obj.pSELR(:)=obj.pSELRL2P2;
                    obj.pSELG(:)=obj.pSELGL2P2;
                    obj.pSELB(:)=obj.pSELBL2P2;
                else
                    obj.pSELR(:)=obj.pSELRL2;
                    obj.pSELG(:)=obj.pSELGL2;
                    obj.pSELB(:)=obj.pSELBL2;
                end


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hEnd
                    obj.pBayerState(:)=6;
                elseif valid
                    obj.pBayerState(:)=3;
                else
                    obj.pBayerState(:)=4;
                end


            case 5
                obj.pSELR(:)=0;
                obj.pSELG(:)=0;
                obj.pSELB(:)=0;


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hStart
                    obj.pBayerState(:)=3;
                else
                    obj.pBayerState(:)=5;
                end


            case 6
                obj.pSELR(:)=0;
                obj.pSELG(:)=0;
                obj.pSELB(:)=0;


                if vEnd
                    obj.pBayerState(:)=0;
                elseif hStart
                    obj.pBayerState(:)=1;
                else
                    obj.pBayerState(:)=6;
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
