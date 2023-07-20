classdef(Hidden,StrictDefaults)FrameToFrameOfPixels<matlab.System



%#codegen

    properties(Nontunable)



        NumComponents=1;



        NumPixels=1;


        VideoFormat='1080p';
    end

    properties(Nontunable)




        ActivePixelsPerLine=32;





        ActiveVideoLines=18;





        TotalPixelsPerLine=42;





        TotalVideoLines=28;




        StartingActiveLine=6;





        FrontPorch=5;
    end

    properties(Nontunable,Access=protected)
        pTotalVideoLines;
        pActiveVideoLines;
        pTotalPixelsPerLine;
        pActivePixelsPerLine;
        pStartingActiveLine;
        pEndingActiveLine;
        pFrontPorch;
        pBackPorch;
        pStepHandle;
    end

    properties(Access=protected)
        LineCount;
        PixelCount;
    end

    properties(Constant,Hidden)
        VideoFormatSet=visionhdl.internal.CommonSets.getSet('VideoFormats');
    end


    methods
        function obj=FrameToFrameOfPixels(varargin)
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

    methods
        function set.NumComponents(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','NumComponents');
            coder.internal.errorIf(~(val==1||val==3||val==4),...
            'visionhdl:FrameToPixels:InvalidComponentNum',val);
            obj.NumComponents=val;
        end

        function set.NumPixels(obj,numPixels)
            validateattributes(numPixels,{'numeric'},{'integer','scalar'},'FrameToPixels','NumPixels');
            coder.internal.errorIf(~(numPixels==1||numPixels==2||numPixels==4||numPixels==8),'visionhdl:FrameToPixels:InvalidNumPixels',numPixels);
            obj.NumPixels=numPixels;
        end

        function set.VideoFormat(obj,videoFormat)
            obj.VideoFormat=videoFormat;
        end

        function set.ActivePixelsPerLine(obj,APPL)
            validateattributes(APPL,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','ActivePixelsPerLine');
            obj.ActivePixelsPerLine=APPL;
        end

        function APPL=get.ActivePixelsPerLine(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                APPL=obj.ActivePixelsPerLine;
            else
                [APPL,~,~,~,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

        function set.ActiveVideoLines(obj,AVL)
            validateattributes(AVL,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','ActiveVideoLines');
            obj.ActiveVideoLines=AVL;
        end

        function AVL=get.ActiveVideoLines(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                AVL=obj.ActiveVideoLines;
            else
                [~,AVL,~,~,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

        function set.TotalPixelsPerLine(obj,TPPL)
            validateattributes(TPPL,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','TotalPixelsPerLine');
            obj.TotalPixelsPerLine=TPPL;
        end

        function TPPL=get.TotalPixelsPerLine(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                TPPL=obj.TotalPixelsPerLine;
            else
                [~,~,TPPL,~,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

        function set.TotalVideoLines(obj,TVL)
            validateattributes(TVL,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','TotalVideoLines');
            obj.TotalVideoLines=TVL;
        end

        function TVL=get.TotalVideoLines(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                TVL=obj.TotalVideoLines;
            else
                [~,~,~,TVL,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

        function set.StartingActiveLine(obj,SAL)
            validateattributes(SAL,{'numeric'},{'integer','scalar','>',0},'FrameToPixels','StartingActiveLine');
            obj.StartingActiveLine=SAL;
        end

        function SAL=get.StartingActiveLine(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                SAL=obj.StartingActiveLine;
            else
                [~,~,~,~,SAL,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

        function set.FrontPorch(obj,FP)
            validateattributes(FP,{'numeric'},{'integer','scalar','>=',0},'FrameToPixels','FrontPorch');
            obj.FrontPorch=FP;
        end

        function FP=get.FrontPorch(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                FP=obj.FrontPorch;
            else
                [~,~,~,~,~,~,FP,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('visionhdl.internal.FrameToFrameOfPixels',...
            'ShowSourceLink',false,...
            'Title','Frame To Frame Of Pixels');
        end
    end

    methods(Access=protected)
        function[dataOut,ctrlOut]=stepImpl(obj,matrix)


            Frame_t=permute(matrix,[2,1,3,4]);


            if obj.NumPixels>1&&obj.NumComponents==1

                Frame_t1=zeros(obj.pActivePixelsPerLine,obj.pActiveVideoLines,obj.NumPixels,'like',matrix);
                for ii=1:obj.NumPixels
                    Frame_t1(:,:,ii)=Frame_t(ii:obj.NumPixels:end,:,:);
                end
                SecDimOut=obj.NumPixels;
                ThirdDimOut=1;
            elseif obj.NumPixels>1&&obj.NumComponents>1
                Frame_t1=zeros(obj.pActivePixelsPerLine,obj.pActiveVideoLines,obj.NumPixels,obj.NumComponents,'like',matrix);
                for ii=1:obj.NumPixels
                    Frame_t1(:,:,ii,:)=Frame_t(ii:obj.NumPixels:end,:,:);
                end
                SecDimOut=obj.NumPixels;
                ThirdDimOut=obj.NumComponents;
            else
                Frame_t1=Frame_t;
                SecDimOut=obj.NumComponents;
                ThirdDimOut=1;
            end


            PixelOut_t=cast(zeros(obj.pTotalPixelsPerLine,obj.pTotalVideoLines,SecDimOut,ThirdDimOut),'like',matrix);
            PixelOut_t(obj.pBackPorch+1:obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1,:,:)=...
            Frame_t1;
            dataOut=reshape(PixelOut_t,[],SecDimOut,ThirdDimOut);


            CtrlOut_t=false(obj.pTotalPixelsPerLine,obj.pTotalVideoLines,5);
            CtrlOut_t(obj.pBackPorch+1,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1,1)=true;
            CtrlOut_t(obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1,2)=true;
            CtrlOut_t(obj.pBackPorch+1,obj.pStartingActiveLine,3)=true;
            CtrlOut_t(obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine+obj.pActiveVideoLines-1,4)=true;
            CtrlOut_t(obj.pBackPorch+1:obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1,5)=true;
            ctrlOut=reshape(CtrlOut_t,[],5);
        end

        function resetStates(obj)
            obj.LineCount=1;
            obj.PixelCount=0;
        end


        function setupImpl(obj,varargin)
            resetStates(obj);

            if strcmpi(obj.VideoFormat,'custom')

                validateattributes(obj.ActivePixelsPerLine,{'numeric'},{'<=',obj.TotalPixelsPerLine},'FrameToPixels','ActivePixelsPerLine');
                validateattributes(obj.ActiveVideoLines,{'numeric'},{'<=',obj.TotalVideoLines},'FrameToPixels','ActiveVideoLines');
                validateattributes(obj.StartingActiveLine,{'numeric'},{'<=',obj.TotalVideoLines-obj.ActiveVideoLines+1},'FrameToPixels','StartingActiveLine');
                validateattributes(obj.FrontPorch,{'numeric'},{'<=',obj.TotalPixelsPerLine-1},'FrameToPixels','FrontPorch');

                if obj.NumPixels==1
                    obj.pActivePixelsPerLine=obj.ActivePixelsPerLine;
                    obj.pActiveVideoLines=obj.ActiveVideoLines;
                    obj.pTotalPixelsPerLine=obj.TotalPixelsPerLine;
                    obj.pTotalVideoLines=obj.TotalVideoLines;
                    obj.pStartingActiveLine=obj.StartingActiveLine;
                    obj.pEndingActiveLine=obj.StartingActiveLine+obj.ActiveVideoLines-1;
                    obj.pFrontPorch=obj.FrontPorch;
                    obj.pBackPorch=(obj.TotalPixelsPerLine-obj.ActivePixelsPerLine-obj.FrontPorch);


                elseif obj.NumPixels==2||obj.NumPixels==4||obj.NumPixels==8||obj.NumPixels==16
                    obj.pActivePixelsPerLine=obj.ActivePixelsPerLine/obj.NumPixels;
                    obj.pActiveVideoLines=obj.ActiveVideoLines;
                    obj.pTotalPixelsPerLine=double(round(obj.TotalPixelsPerLine/obj.NumPixels));
                    obj.pTotalVideoLines=obj.TotalVideoLines;
                    obj.pStartingActiveLine=obj.StartingActiveLine;
                    obj.pEndingActiveLine=obj.StartingActiveLine+obj.ActiveVideoLines-1;
                    obj.pFrontPorch=double(round(obj.FrontPorch/obj.NumPixels));
                    obj.pBackPorch=(obj.pTotalPixelsPerLine-obj.pActivePixelsPerLine-obj.pFrontPorch);
                end
            else
                if obj.NumPixels==1
                    [obj.pActivePixelsPerLine,obj.pActiveVideoLines,...
                    obj.pTotalPixelsPerLine,obj.pTotalVideoLines,...
                    obj.pStartingActiveLine,obj.pEndingActiveLine,...
                    obj.pFrontPorch,obj.pBackPorch]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);

                elseif obj.NumPixels==2||obj.NumPixels==4||obj.NumPixels==8||obj.NumPixels==16

                    [APL,AVL,...
                    TPL,TVL,...
                    SAL,EAL,...
                    FP,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);

                    obj.pActivePixelsPerLine=APL/obj.NumPixels;
                    obj.pActiveVideoLines=AVL;
                    obj.pTotalPixelsPerLine=double(round(TPL/obj.NumPixels));
                    obj.pTotalVideoLines=TVL;
                    obj.pStartingActiveLine=SAL;
                    obj.pFrontPorch=double(round(FP/obj.NumPixels));
                    obj.pBackPorch=(obj.pTotalPixelsPerLine-obj.pActivePixelsPerLine-obj.pFrontPorch);
                    obj.pEndingActiveLine=EAL;
                end

            end


            assert(isfloat(obj.pActivePixelsPerLine));
            assert(isfloat(obj.pActiveVideoLines));
            assert(isfloat(obj.pTotalPixelsPerLine));
            assert(isfloat(obj.pTotalVideoLines));
            assert(isfloat(obj.pStartingActiveLine));
            assert(isfloat(obj.pEndingActiveLine));
            assert(isfloat(obj.pFrontPorch));
            assert(isfloat(obj.pBackPorch));

            assert(isscalar(obj.pActivePixelsPerLine));
            assert(isscalar(obj.pActiveVideoLines));
            assert(isscalar(obj.pTotalPixelsPerLine));
            assert(isscalar(obj.pTotalVideoLines));
            assert(isscalar(obj.pStartingActiveLine));
            assert(isscalar(obj.pEndingActiveLine));
            assert(isscalar(obj.pFrontPorch));
            assert(isscalar(obj.pBackPorch));





            mh=obj.pActiveVideoLines;
            mw=obj.pActivePixelsPerLine*obj.NumPixels;

            validateattributes(varargin{1},{'numeric','embedded.fi','logical'},...
            {'size',[mh,mw,obj.NumComponents]},'FrameToPixels','matrix input');

            validateattributes(obj.pTotalVideoLines,...
            {'numeric'},{'scalar','integer',...
            '>=',1,'<',65536},'FrameToPixels','TotalVideoLines');
            if obj.NumPixels==1
                validateattributes(obj.pTotalPixelsPerLine,...
                {'numeric'},{'scalar','integer',...
                '>=',1,'<',65536},'FrameToPixels','TotalPixelsPerLine');


                validateattributes(obj.pActiveVideoLines,...
                {'numeric'},{'scalar','integer',...
                '>=',1,'<=',obj.pTotalVideoLines},'FrameToPixels','ActiveVideoLines');
                validateattributes(obj.pActivePixelsPerLine,...
                {'numeric'},{'scalar','integer',...
                '>=',1,'<=',obj.pTotalPixelsPerLine},'FrameToPixels','ActivePixelsPerLine');

                validateattributes(obj.pFrontPorch,...
                {'numeric'},{'scalar','integer',...
                '>=',0,'<',obj.pTotalPixelsPerLine},'FrameToPixels','FrontPorch');


                validateattributes(obj.pBackPorch,...
                {'numeric'},{'scalar','integer',...
                '>=',0,'<',obj.pTotalPixelsPerLine},'FrameToPixels','BackPorch');
            end


            coder.internal.errorIf(...
            ~((obj.pStartingActiveLine<=obj.pEndingActiveLine)&&(obj.pEndingActiveLine<=obj.pTotalVideoLines)),...
            'visionhdl:FrameToPixels:WrongEAL');


            coder.internal.errorIf(...
            obj.pActiveVideoLines~=(obj.pEndingActiveLine-obj.pStartingActiveLine+1),...
            'visionhdl:FrameToPixels:Eq1Violation');


            if obj.NumPixels==1
                coder.internal.errorIf(...
                obj.pTotalPixelsPerLine~=(obj.pActivePixelsPerLine+obj.pFrontPorch+(obj.pBackPorch)),...
                'visionhdl:FrameToPixels:Eq2Violation');
            elseif obj.NumPixels==2||obj.NumPixels==4||obj.NumPixels==8||obj.NumPixels==16

                if strcmpi(obj.VideoFormat,'custom')

                    coder.internal.errorIf(...
                    obj.ActivePixelsPerLine<32,...
                    'visionhdl:FrameToPixels:MultiPixelsMin');

                    coder.internal.errorIf(...
                    obj.pTotalPixelsPerLine~=(obj.pActivePixelsPerLine+obj.pFrontPorch+(obj.pBackPorch)),...
                    'visionhdl:FrameToPixels:Eq2Violation');

                    coder.internal.errorIf(...
                    ~((mod(obj.TotalPixelsPerLine,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                    coder.internal.errorIf(...
                    ~((mod(obj.ActivePixelsPerLine,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');


                    coder.internal.errorIf(...
                    ~((mod(obj.FrontPorch,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                    coder.internal.errorIf(...
                    ~((mod(obj.TotalPixelsPerLine-obj.ActivePixelsPerLine-obj.FrontPorch,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');
                else
                    coder.internal.errorIf(...
                    obj.pTotalPixelsPerLine~=(obj.pActivePixelsPerLine+obj.pFrontPorch+(obj.pBackPorch)),...
                    'visionhdl:FrameToPixels:Eq2Violation');

                    coder.internal.errorIf(...
                    ~((mod(TPL,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                    coder.internal.errorIf(...
                    ~((mod(APL,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                    coder.internal.errorIf(...
                    ~((mod(FP,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                    coder.internal.errorIf(...
                    ~((mod(TPL-APL-FP,obj.NumPixels))==0),...
                    'visionhdl:FrameToPixels:MultiPixelsFormat');

                end

            end

            if obj.NumPixels==1
                obj.pStepHandle=@singlePixelStep;
            elseif obj.NumPixels==2||obj.NumPixels==4||obj.NumPixels==8||obj.NumPixels==16
                obj.pStepHandle=@multiPixelStep;
            end

        end
    end


    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='matrix';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;

            switch prop

            case 'ActivePixelsPerLine'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end
            case 'ActiveVideoLines'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end
            case 'TotalPixelsPerLine'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end
            case 'TotalVideoLines'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end
            case 'StartingActiveLine'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end
            case 'FrontPorch'
                if~strcmpi(obj.VideoFormat,'custom')
                    flag=true;
                end

            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pTotalVideoLines=obj.pTotalVideoLines;
                s.pActiveVideoLines=obj.pActiveVideoLines;
                s.pTotalPixelsPerLine=obj.pTotalPixelsPerLine;
                s.pActivePixelsPerLine=obj.pActivePixelsPerLine;
                s.pStartingActiveLine=obj.pStartingActiveLine;
                s.pEndingActiveLine=obj.pEndingActiveLine;
                s.pFrontPorch=obj.pFrontPorch;
                s.pBackPorch=obj.pBackPorch;
                s.pStepHandle=obj.pStepHandle;
                s.LineCount=obj.LineCount;
                s.PixelCount=obj.PixelCount;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end


    methods(Access=private)


        function[dataOut,ctrlOut]=singlePixelStep(obj,frame)
            iter=obj.pTotalVideoLines*(obj.pTotalPixelsPerLine);


            dataOut=cast(zeros(iter,obj.NumComponents),'like',frame);
            ctrlOut=false(iter,5);

            for ii=1:iter
                if(obj.LineCount>=obj.pStartingActiveLine)&&...
                    (obj.LineCount<=obj.pEndingActiveLine)

                    if(obj.PixelCount>=obj.pBackPorch)&&...
                        (obj.PixelCount<(obj.pBackPorch+obj.pActivePixelsPerLine))

                        if obj.PixelCount==obj.pBackPorch
                            ctrlOut(ii,1)=true;
                            if obj.LineCount==obj.pStartingActiveLine
                                ctrlOut(ii,3)=true;
                            end
                        end
                        if obj.PixelCount==(obj.pBackPorch+obj.pActivePixelsPerLine-1)
                            ctrlOut(ii,2)=true;
                            if obj.LineCount==obj.pEndingActiveLine
                                ctrlOut(ii,4)=true;
                            end
                        end
                        ctrlOut(ii,5)=true;
                        dataOut(ii,:)=frame(obj.LineCount-obj.pStartingActiveLine+1,...
                        obj.PixelCount-obj.pBackPorch+1,:);
                    end
                end

                obj.PixelCount=obj.PixelCount+1;
                if obj.PixelCount==obj.pTotalPixelsPerLine
                    obj.PixelCount=0;
                    if obj.LineCount==obj.pTotalVideoLines
                        obj.LineCount=1;
                    else
                        obj.LineCount=obj.LineCount+1;
                    end
                end
            end
        end



        function[dataOut,ctrlOut]=multiPixelStep(obj,frame)
            iter=obj.pTotalVideoLines*(obj.pTotalPixelsPerLine);


            dataOut=cast(zeros(iter,obj.NumPixels),'like',frame(1));
            ctrlOut=false(iter,5);

            for ii=1:iter
                if(obj.LineCount>=obj.pStartingActiveLine)&&...
                    (obj.LineCount<=obj.pEndingActiveLine)

                    if(obj.PixelCount>=obj.pBackPorch)&&...
                        (obj.PixelCount<(obj.pBackPorch+obj.pActivePixelsPerLine))

                        if obj.PixelCount==obj.pBackPorch
                            ctrlOut(ii,1)=true;
                            if obj.LineCount==obj.pStartingActiveLine
                                ctrlOut(ii,3)=true;
                            end
                        end
                        if obj.PixelCount==(obj.pBackPorch+obj.pActivePixelsPerLine-1)
                            ctrlOut(ii,2)=true;
                            if obj.LineCount==obj.pEndingActiveLine
                                ctrlOut(ii,4)=true;
                            end
                        end
                        ctrlOut(ii,5)=true;
                        if((obj.PixelCount-obj.pBackPorch+1))==1
                            dataOut(ii,1:obj.NumPixels)=frame(obj.LineCount-obj.pStartingActiveLine+1,...
                            1:obj.NumPixels,:);
                        else
                            dataOut(ii,1:obj.NumPixels)=frame(obj.LineCount-obj.pStartingActiveLine+1,...
                            (((obj.PixelCount-obj.pBackPorch)*obj.NumPixels)+1:((obj.PixelCount-obj.pBackPorch)*obj.NumPixels)+obj.NumPixels),:);
                        end
                    end
                end

                obj.PixelCount=obj.PixelCount+1;
                if obj.PixelCount==obj.pTotalPixelsPerLine
                    obj.PixelCount=0;
                    if obj.LineCount==obj.pTotalVideoLines
                        obj.LineCount=1;
                    else
                        obj.LineCount=obj.LineCount+1;
                    end
                end
            end
        end

    end


end
