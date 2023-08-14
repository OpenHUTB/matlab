classdef(StrictDefaults)ChromaResampler<matlab.System


















































































%#codegen
%#ok<*EMCLS>


    properties(Nontunable)



        Resampling='4:4:4 to 4:2:2';











        AntialiasingFilterSource='Auto';






        HorizontalFilterCoefficients=[0.2,0.6,0.2];










        InterpolationFilter='Linear';




        RoundingMethod='Floor';




        OverflowAction='Wrap';





        CustomCoefficientsDataType=numerictype(1,16,15);
    end

    properties(Constant,Hidden)
        ResamplingSet=matlab.system.StringSet({...
        '4:4:4 to 4:2:2',...
        '4:2:2 to 4:4:4'});

        AntialiasingFilterSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property',...
        'None'});

        InterpolationFilterSet=matlab.system.StringSet({...
        'Linear',...
        'Pixel replication'});

        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...

        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        CustomCoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);
    end

    properties(Nontunable,Access=private)
        Coefficients;
        CoeffCastFlip;
        PadL;
        pFimath;
        OpMode;
        LinearOffset;
    end

    properties(Access=private)
        CbMean;
        CrMean;
        CbPre;
        CbPre1;
        CrPre;
        CrPre1;
        counter;
        counter1;
        Stage1DelayYIn;
        Stage1DelayCtr;
        Stage1ChromaOCI;
        Stage2DelayTri;
        Stage2DelayCtr;
        CounterVal;
        TreeSumOutputFi;
        TreeSumOutputCbDT;
        TreeSumOutputCrDT;
        FSM_State;
    end

    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl
            className=mfilename('class');
            mainGroup=matlab.system.display.SectionGroup(className);
            dataTypesGroup=matlab.system.display.internal.DataTypesGroup(className);
            dataTypesGroup.PropertyList{3}=...
            matlab.system.display.internal.DataTypeProperty('CustomCoefficientsDataType',...
            'Prefix','Coeff',...
            'Description','Filter coefficients');

            groups=[mainGroup,dataTypesGroup];
        end
    end

    methods
        function obj=ChromaResampler(varargin)
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

        function set.HorizontalFilterCoefficients(obj,val)
            validateattributes(val,{'numeric'},{'real','vector'},'ChromaResampler','HorizontalFilterCoefficients');
            validateattributes(numel(val),{'numeric'},{'scalar','integer','>=',1,'<=',29},'ChromaResampler','the length of the coefficients');
            coder.internal.errorIf((mod(numel(val),2)==0),'visionhdl:ChromaResampler:CoefficientDimensions');

            obj.HorizontalFilterCoefficients=(val(:)).';

        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('visionhdl.ChromaResampler',...
            'ShowSourceLink',false,...
            'Title','Chroma Resampler');
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
            icon=sprintf('Chroma Resampler');
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
            sz1=[1,3];


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


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'AntialiasingFilterSource'
                flag=strcmp(obj.Resampling,'4:2:2 to 4:4:4');
            case 'HorizontalFilterCoefficients'
                flag=strcmp(obj.Resampling,'4:2:2 to 4:4:4')||...
                (strcmp(obj.Resampling,'4:4:4 to 4:2:2')&&~(strcmp(obj.AntialiasingFilterSource,'Property')));
            case 'InterpolationFilter'
                flag=strcmp(obj.Resampling,'4:4:4 to 4:2:2');
            case 'CustomCoefficientsDataType'
                flag=strcmp(obj.Resampling,'4:2:2 to 4:4:4')||...
                (strcmp(obj.Resampling,'4:4:4 to 4:2:2')&&strcmp(obj.AntialiasingFilterSource,'None'));
            case 'RoundingMethod'
                flag=(strcmp(obj.Resampling,'4:2:2 to 4:4:4')&&strcmp(obj.InterpolationFilter,'Pixel replication'))||...
                (strcmp(obj.Resampling,'4:4:4 to 4:2:2')&&strcmp(obj.AntialiasingFilterSource,'None'));
            case 'OverflowAction'
                flag=strcmp(obj.Resampling,'4:2:2 to 4:4:4')||...
                (strcmp(obj.Resampling,'4:4:4 to 4:2:2')&&strcmp(obj.AntialiasingFilterSource,'None'));
            end
        end


        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'single','double','uint8','uint16','embedded.fi'},...
                {'real','nonnan','finite'},'ChromaResampler','pixel input');
                if isfi(pixelIn)

                    coder.internal.errorIf(issigned(pixelIn),'visionhdl:ChromaResampler:SignedType');

                    WL=pixelIn.WordLength;
                    coder.internal.errorIf(((WL<8)||(WL>16)),'visionhdl:ChromaResampler:WordLength');

                    coder.internal.errorIf((pixelIn.FractionLength~=0),'visionhdl:ChromaResampler:NoFraction');
                end

                if~ismember(size(pixelIn,1),[1])%#ok<NBRAK2> 
                    coder.internal.error('visionhdl:ChromaResampler:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[3])%#ok<NBRAK2>
                    coder.internal.error('visionhdl:ChromaResampler:InputDimensions');
                end

                validatecontrolsignals(ctrlIn);
            end

        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.OpMode=obj.OpMode;
                s.Coefficients=obj.Coefficients;
                s.CoeffCastFlip=obj.CoeffCastFlip;
                s.PadL=obj.PadL;
                s.pFimath=obj.pFimath;
                s.LinearOffset=obj.LinearOffset;
                s.CbMean=obj.CbMean;
                s.CrMean=obj.CrMean;
                s.CbPre=obj.CbPre;
                s.CrPre=obj.CrPre;
                s.counter=obj.counter;
                s.CbPre1=obj.CbPre1;
                s.CrPre1=obj.CrPre1;
                s.counter1=obj.counter1;
                s.Stage1DelayYIn=obj.Stage1DelayYIn;
                s.Stage1DelayCtr=obj.Stage1DelayCtr;
                s.Stage1ChromaOCI=obj.Stage1ChromaOCI;
                s.Stage2DelayTri=obj.Stage2DelayTri;
                s.Stage2DelayCtr=obj.Stage2DelayCtr;
                s.CounterVal=obj.CounterVal;
                s.TreeSumOutputFi=obj.TreeSumOutputFi;
                s.TreeSumOutputCbDT=obj.TreeSumOutputCbDT;
                s.TreeSumOutputCrDT=obj.TreeSumOutputCrDT;
                s.FSM_State=obj.FSM_State;
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


        function setupImpl(obj,pixelIn,~)
            YIn=pixelIn(1);
            coder.extrinsic('visionhdl.ChromaResampler.firkernellatency');
            coder.extrinsic('visionhdl.ChromaResampler.EnumOperationMode');
            obj.pFimath=fimath('RoundingMethod',obj.RoundingMethod,...
            'OverflowAction',obj.OverflowAction);

            obj.OpMode=coder.internal.const(...
            visionhdl.ChromaResampler.EnumOperationMode(...
            obj.Resampling,...
            obj.AntialiasingFilterSource,...
            obj.InterpolationFilter));








            if obj.OpMode==1
                if strcmp(obj.AntialiasingFilterSource,'Auto')

                    obj.Coefficients=[0.00251767046967...
                    ,0.00490688948250...
                    ,-0.00285843115822...
                    ,-0.00890518732801...
                    ,0.00395561699943...
                    ,0.01685803908729...
                    ,-0.00534284868508...
                    ,-0.02947105950561...
                    ,0.00652585779416...
                    ,0.05132323586029...
                    ,-0.00752159904442...
                    ,-0.09829944333989...
                    ,0.00816272666677...
                    ,0.31564088548256...
                    ,0.49161039145657...
                    ,0.31564088548256...
                    ,0.00816272666677...
                    ,-0.09829944333989...
                    ,-0.00752159904442...
                    ,0.05132323586029...
                    ,0.00652585779416...
                    ,-0.02947105950561...
                    ,-0.00534284868508...
                    ,0.01685803908729...
                    ,0.00395561699943...
                    ,-0.00890518732801...
                    ,-0.00285843115822...
                    ,0.00490688948250...
                    ,0.00251767046967];
                else
                    obj.Coefficients=obj.HorizontalFilterCoefficients;
                end
                obj.PadL=(numel(obj.Coefficients)-1)/2;







                if isfloat(YIn)

                    obj.CoeffCastFlip=cast(fliplr(obj.Coefficients),'like',YIn);
                else
















                    obj.CoeffCastFlip=fi(fliplr(obj.Coefficients),obj.CustomCoefficientsDataType,obj.pFimath);

                end




                if isfi(YIn)
                    obj.Stage1ChromaOCI=fi(zeros(2,numel(obj.CoeffCastFlip)),...
                    issigned(YIn),...
                    YIn.WordLength,...
                    YIn.FractionLength,...
                    obj.pFimath);
                else
                    obj.Stage1ChromaOCI=cast(zeros(2,numel(obj.CoeffCastFlip)),'like',YIn);
                end


                if isfloat(YIn)
                    obj.TreeSumOutputFi=cast(0,'like',YIn);
                    obj.TreeSumOutputCbDT=cast(0,'like',YIn);
                    obj.TreeSumOutputCrDT=cast(0,'like',YIn);
                else
                    RowCB=obj.Stage1ChromaOCI(1,:);
                    TreeSumOutputDT=sum(RowCB(:).*obj.CoeffCastFlip(:),1,'native');
                    obj.TreeSumOutputFi=fi(0,issigned(TreeSumOutputDT),...
                    TreeSumOutputDT.WordLength,...
                    TreeSumOutputDT.FractionLength,...
                    obj.pFimath);

                    if isa(YIn,'uint8')
                        obj.TreeSumOutputCbDT=fi(0,0,8,0,obj.pFimath);
                    elseif isa(YIn,'uint16')
                        obj.TreeSumOutputCbDT=fi(0,0,16,0,obj.pFimath);
                    else
                        obj.TreeSumOutputCbDT=fi(0,issigned(YIn),...
                        YIn.WordLength,...
                        YIn.FractionLength,...
                        obj.pFimath);
                    end
                    obj.TreeSumOutputCrDT=obj.TreeSumOutputCbDT;
                end
            else
                obj.Coefficients=0;
                obj.CoeffCastFlip=0;
                obj.PadL=0;
                obj.Stage1ChromaOCI=0;
                obj.TreeSumOutputFi=0;
                obj.TreeSumOutputCbDT=0;
                obj.TreeSumOutputCrDT=0;
            end

            if obj.OpMode==2




                if isa(YIn,'uint8')
                    obj.CbPre=fi(0,0,8,0,obj.pFimath);
                elseif isa(YIn,'uint16')
                    obj.CbPre=fi(0,0,16,0,obj.pFimath);
                elseif isfi(YIn)
                    obj.CbPre=fi(0,issigned(YIn),...
                    YIn.WordLength,...
                    YIn.FractionLength,...
                    obj.pFimath);
                else
                    obj.CbPre=cast(0,'like',YIn);
                end
                obj.CrPre=obj.CbPre;
            else
                obj.CbPre=cast(0,'like',YIn);
                obj.CrPre=cast(0,'like',YIn);
            end




            if((obj.OpMode==2)&&...
                isfi(obj.CbPre)&&...
                (strcmp(obj.RoundingMethod,'Ceiling')||...
                strcmp(obj.RoundingMethod,'Round')||...
                strcmp(obj.RoundingMethod,'Nearest'))...
                )
                obj.LinearOffset=cast(1,'like',obj.CbPre);
            else
                obj.LinearOffset=cast(0,'like',obj.CbPre);
            end

            obj.CbMean=cast(0,'like',YIn);
            obj.CrMean=cast(0,'like',YIn);

            obj.CbPre1=cast(0,'like',YIn);
            obj.CrPre1=cast(0,'like',YIn);

            obj.counter=true;
            obj.counter1=true;





            switch obj.OpMode
            case 0
                Stage1_Delay=0;
                Stage2_Delay=3;
            case 1
                Stage1_Delay=obj.PadL+1;
                Stage2_Delay=coder.internal.const(...
                visionhdl.ChromaResampler.firkernellatency(...
                class(YIn),...
                obj.Coefficients,...
                obj.CustomCoefficientsDataType,...
                obj.pFimath));

                Stage2_Delay=Stage2_Delay+3;
            case 2
                Stage1_Delay=2;
                Stage2_Delay=3;
            end

            obj.Stage1DelayYIn=cast(zeros(1,Stage1_Delay),'like',YIn);
            if strcmp(obj.Resampling,'4:4:4 to 4:2:2')&&...
                ~strcmp(obj.AntialiasingFilterSource,'None')
                obj.Stage1DelayCtr=false(4,Stage1_Delay);
            else
                obj.Stage1DelayCtr=false(5,Stage1_Delay);
            end
            obj.Stage2DelayTri=cast(zeros(3,Stage2_Delay),'like',YIn);
            obj.Stage2DelayCtr=false(5,Stage2_Delay);

            obj.CounterVal=0;
            obj.FSM_State=0;
        end


        function[pixelOut,CtrlOut]=outputImpl(obj,~,~)

            pixelOut=obj.Stage2DelayTri(:,end).';
            CtrlOut.hStart=obj.Stage2DelayCtr(1,end);
            CtrlOut.hEnd=obj.Stage2DelayCtr(2,end);
            CtrlOut.vStart=obj.Stage2DelayCtr(3,end);
            CtrlOut.vEnd=obj.Stage2DelayCtr(4,end);
            CtrlOut.valid=obj.Stage2DelayCtr(5,end);
        end


        function updateImpl(obj,pixelIn,CtrlIn)


            YIn=pixelIn(1);
            CbIn=pixelIn(2);
            CrIn=pixelIn(3);





            CtrlInCol=[CtrlIn.hStart;CtrlIn.hEnd;CtrlIn.vStart;CtrlIn.vEnd;CtrlIn.valid];
            switch obj.OpMode
            case 0
                [TriOut,CtrOut]=PixelFormatter(obj,YIn,CbIn,CrIn,CtrlInCol);
            case 1
                [TriTem,CtrTem]=DownsamplerWFilter(obj,YIn,CbIn,CrIn,CtrlInCol);
                [TriOut,CtrOut]=PixelFormatter(obj,TriTem(1),TriTem(2),TriTem(3),CtrTem);
            case 2
                [TriTem,CtrTem]=PixelFormatter(obj,YIn,CbIn,CrIn,CtrlInCol);
                [TriOut,CtrOut]=LinearUpsampler(obj,TriTem(1),TriTem(2),TriTem(3),CtrTem);
            end

            if~CtrOut(5)
                TriOut=cast(zeros(3,1),'like',YIn);
                CtrOut=false(5,1);
            end

            obj.Stage2DelayTri(:,:)=[TriOut,obj.Stage2DelayTri(:,1:end-1)];
            obj.Stage2DelayCtr=[CtrOut,obj.Stage2DelayCtr(:,1:end-1)];
        end


        function resetImpl(obj)

            obj.CbMean(:)=0;
            obj.CrMean(:)=0;
            obj.CbPre(:)=0;
            obj.CbPre1(:)=0;
            obj.CrPre(:)=0;
            obj.CrPre1(:)=0;
            obj.counter(:)=true;
            obj.counter1(:)=true;
            obj.Stage1DelayYIn(:)=0;
            obj.Stage1DelayCtr(:)=false;
            obj.Stage1ChromaOCI(:)=0;
            obj.Stage2DelayTri(:)=0;
            obj.Stage2DelayCtr(:)=false;
            obj.CounterVal(:)=0;
            obj.TreeSumOutputFi(:)=0;
            obj.TreeSumOutputCbDT(:)=0;
            obj.TreeSumOutputCrDT(:)=0;
            obj.FSM_State(:)=0;
        end


        function[Tri,Ctr]=DownsamplerWFilter(obj,YIn,CbIn,CrIn,CtrVecIn)
            if isfi(YIn)
                CbInTemp=fi(CbIn,obj.pFimath);
                CrInTemp=fi(CrIn,obj.pFimath);
            else
                CbInTemp=CbIn;
                CrInTemp=CrIn;
            end

            if obj.PadL==0
                obj.Stage1DelayCtr=CtrVecIn(1:4);
                obj.Stage1DelayYIn=YIn;
                obj.Stage1ChromaOCI=[CbInTemp;CrInTemp];
                validOut=CtrVecIn(5);
            else
                if CtrVecIn(5)||(obj.FSM_State==2)
                    obj.Stage1DelayCtr=[CtrVecIn(1:4),obj.Stage1DelayCtr(:,1:end-1)];
                    obj.Stage1DelayYIn=[YIn,obj.Stage1DelayYIn(1:end-1)];
                    obj.Stage1ChromaOCI=[[CbInTemp;CrInTemp],obj.Stage1ChromaOCI(:,1:end-1)];
                end

                validOut=false;
                switch(obj.FSM_State)
                case 0
                    if obj.Stage1DelayCtr(1,end)
                        obj.Stage1ChromaOCI(:,end-obj.PadL+1:end)=...
                        fliplr(obj.Stage1ChromaOCI(:,end-2*obj.PadL+1:end-obj.PadL));
                        obj.FSM_State=1;
                        validOut=true;
                    end
                case 1
                    validOut=CtrVecIn(5);
                    if CtrVecIn(5)&&CtrVecIn(2)
                        obj.FSM_State=2;
                        obj.CounterVal=1;
                    end
                case 2
                    validOut=true;
                    obj.Stage1ChromaOCI(:,1)=obj.Stage1ChromaOCI(:,2*obj.CounterVal);
                    if obj.CounterVal==obj.PadL
                        obj.FSM_State=0;
                    end
                    obj.CounterVal=obj.CounterVal+1;
                end

                if CtrVecIn(1)&&CtrVecIn(5)
                    obj.FSM_State=0;
                end
            end

            weighted=obj.Stage1ChromaOCI(1,:).*obj.CoeffCastFlip;
            obj.TreeSumOutputFi(:)=sum(weighted(:),1,'native');
            obj.TreeSumOutputCbDT(:)=obj.TreeSumOutputFi;
            CbOut1=cast(obj.TreeSumOutputCbDT,'like',YIn);

            weighted=obj.Stage1ChromaOCI(2,:).*obj.CoeffCastFlip;
            obj.TreeSumOutputFi(:)=sum(weighted(:),1,'native');
            obj.TreeSumOutputCrDT(:)=obj.TreeSumOutputFi;
            CrOut1=cast(obj.TreeSumOutputCrDT,'like',YIn);

            Tri=[obj.Stage1DelayYIn(end);CbOut1;CrOut1];
            Ctr=[obj.Stage1DelayCtr(:,end);validOut];
        end


        function[Tri,Ctr]=PixelFormatter(obj,YIn,CbIn,CrIn,CtrVecIn)









            if CtrVecIn(1)&&CtrVecIn(5)

                obj.counter1=true;
            end

            if CtrVecIn(5)
                if obj.counter1
                    CbOut1=CbIn;
                    CrOut1=CrIn;
                    obj.CbPre1=CbIn;
                    obj.CrPre1=CrIn;
                else
                    CbOut1=obj.CbPre1;
                    CrOut1=obj.CrPre1;
                end
                obj.counter1=~obj.counter1;
            else
                CbOut1=CbIn;
                CrOut1=CrIn;
            end

            Tri=[YIn;CbOut1;CrOut1];
            Ctr=CtrVecIn;
        end


        function[Tri,Ctr]=LinearUpsampler(obj,YIn,CbIn,CrIn,CtrVecIn)
            CbInTemp=cast(CbIn,'like',obj.CbPre);
            CrInTemp=cast(CrIn,'like',obj.CrPre);

            if CtrVecIn(1)
                obj.counter=true;
            end

            CbOut1=cast(0,'like',YIn);
            CrOut1=cast(0,'like',YIn);
            if obj.Stage1DelayCtr(5,end)
                if obj.counter
                    CbOut1=cast(obj.CbPre,'like',YIn);
                    CrOut1=cast(obj.CrPre,'like',YIn);
                else
                    if(CtrVecIn(5)&&~obj.Stage1DelayCtr(5,end-1))
                        if isa(YIn,'double')||isa(YIn,'single')
                            obj.CbMean(:)=(obj.CbPre+CbInTemp)/2;
                            obj.CrMean(:)=(obj.CrPre+CrInTemp)/2;
                        else
                            obj.CbMean(:)=bitshift((obj.CbPre+CbInTemp+obj.LinearOffset),-1);
                            obj.CrMean(:)=bitshift((obj.CrPre+CrInTemp+obj.LinearOffset),-1);

















                        end
                    end
                    CbOut1=obj.CbMean;
                    CrOut1=obj.CrMean;
                end
                obj.counter=~obj.counter;
            end

            if CtrVecIn(5)
                if isa(YIn,'double')||isa(YIn,'single')
                    obj.CbMean(:)=(obj.CbPre+CbInTemp)/2;
                    obj.CrMean(:)=(obj.CrPre+CrInTemp)/2;
                else
                    obj.CbMean(:)=bitshift((obj.CbPre+CbInTemp+obj.LinearOffset),-1);
                    obj.CrMean(:)=bitshift((obj.CrPre+CrInTemp+obj.LinearOffset),-1);
                end

                obj.CbPre(:)=CbIn;
                obj.CrPre(:)=CrIn;
            end

            Tri=[obj.Stage1DelayYIn(end);CbOut1;CrOut1];
            Ctr=obj.Stage1DelayCtr(:,end);

            obj.Stage1DelayYIn=[YIn,obj.Stage1DelayYIn(1:end-1)];
            obj.Stage1DelayCtr=[CtrVecIn,obj.Stage1DelayCtr(:,1:end-1)];
        end
    end

    methods(Static,Hidden)
        function OpMode=EnumOperationMode(InArg1,InArg2,InArg3)




            if strcmp(InArg1,'4:4:4 to 4:2:2')
                if strcmp(InArg2,'None')
                    OpMode=0;
                else
                    OpMode=1;
                end
            else
                if strcmp(InArg3,'Linear')
                    OpMode=2;
                else
                    OpMode=0;
                end
            end
        end


        function firKernelDelay=firkernellatency(dataInDT,coeffs,CcoeffsDT,myFimath)


            if strcmp(dataInDT,'single')
                JLCoeffCastFlip=cast(fliplr(coeffs),'like',single(0));
            elseif strcmp(dataInDT,'double')
                JLCoeffCastFlip=cast(fliplr(coeffs),'like',double(0));
            else

















                JLCoeffCastFlip=fi(fliplr(coeffs),CcoeffsDT,myFimath);

            end


            nonZeroCoeffIndex=(JLCoeffCastFlip~=0);
            nonZeroCoeffs=JLCoeffCastFlip(nonZeroCoeffIndex);


            hdlDataLatency=1;
            firKernelDelay=hdlDataLatency;

            if isempty(nonZeroCoeffs)

                return;
            end



            multPreDelay=2;
            multPostDelay=2;


            sizeNonZeroCoeffs=size(nonZeroCoeffs);


            if all(sizeNonZeroCoeffs==1)

                firKernelDelay=multPreDelay+multPostDelay+firKernelDelay;
                return;
            end




            coeffsUniqueAbsNonZero=unique(abs(double(nonZeroCoeffs)));
            coeffsUniqueAbsNonZero=cast(coeffsUniqueAbsNonZero,'like',nonZeroCoeffs);



            coeffsNum=numel(coeffsUniqueAbsNonZero);
            if~(numel(coeffsUniqueAbsNonZero)==numel(nonZeroCoeffs))

                preAddLatency=zeros(1,coeffsNum);
                for ii=1:coeffsNum
                    coeffVal=coeffsUniqueAbsNonZero(ii);

                    coeffValSymIndex=(nonZeroCoeffs==coeffVal);
                    coeffValAntiSymIndex=(nonZeroCoeffs==(-1*coeffVal));
                    numSymRepetitions=sum(sum(coeffValSymIndex));
                    numAntiSymRepetitions=sum(sum(coeffValAntiSymIndex));
                    numRepetitions=numSymRepetitions+numAntiSymRepetitions;
                    if numRepetitions==1
                        continue;
                    else
                        preAddLatency(ii)=ceil(log2(numRepetitions))+1;
                    end
                end


                totalPreAddLatency=max(preAddLatency);
            else

                totalPreAddLatency=0;
            end


            firKernelDelay=firKernelDelay+totalPreAddLatency;


            multLatency=multPreDelay+multPostDelay;


            firKernelDelay=firKernelDelay+multLatency;



            if coeffsNum==1
                addLatency=0;
            else

                addLatency=ceil(log2(coeffsNum))+1;
            end


            firKernelDelay=firKernelDelay+addLatency;


            dtclatency=1;


            firKernelDelay=firKernelDelay+dtclatency;
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
