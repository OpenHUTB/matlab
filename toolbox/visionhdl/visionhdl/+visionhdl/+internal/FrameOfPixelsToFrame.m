classdef(Hidden,StrictDefaults)FrameOfPixelsToFrame<matlab.System



%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        NumComponents=1;



        NumPixels=1;


        VideoFormat='1080p';
    end

    properties(Nontunable)




        ActivePixelsPerLine=32;





        ActiveVideoLines=18;





        TotalPixelsPerLine=42;
    end

    properties(Constant,Hidden)
        VideoFormatSet=visionhdl.internal.CommonSets.getSet('VideoFormats');
    end

    properties(Nontunable,Access=protected)
        pActivePixelsPerLine;
        pActiveVideoLines;
    end

    properties(Access=protected)
        InFrame;
        InLine;
        VCount;
        HCount;
        ActiveFrame;
        FrameStore_1;
        FrameStore_2;
        FrameValid;
        pStepHandle;
    end

    methods
        function obj=FrameOfPixelsToFrame(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
            resetStates(obj);
        end
    end

    methods

        function set.NumComponents(obj,val)
            validateattributes(val,{'numeric'},...
            {'integer','scalar','>',0},'PixelsToFrame','NumComponents');
            coder.internal.errorIf(~(val==1||val==2||val==3||val==4),...
            'visionhdl:PixelsToFrame:InvalidComponentNum',val);
            obj.NumComponents=val;
        end

        function set.NumPixels(obj,numPixels)
            validateattributes(numPixels,{'numeric'},{'integer','scalar'},'PixelsToFrame','NumPixels');
            coder.internal.errorIf(~(numPixels==1||numPixels==2||numPixels==4||numPixels==8),'visionhdl:PixelsToFrame:InvalidNumPixels',numPixels);
            obj.NumPixels=numPixels;
        end

        function set.ActivePixelsPerLine(obj,APPL)
            validateattributes(APPL,{'numeric'},{'integer','scalar','>',0},'PixelsToFrame','ActivePixelsPerLine');
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
            validateattributes(AVL,{'numeric'},{'integer','scalar','>',0},'PixelsToFrame','ActiveVideoLines');
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
            validateattributes(TPPL,{'numeric'},{'integer','scalar','>',0},'PixelsToFrame','TotalPixelsPerLine');
            obj.TotalPixelsPerLine=TPPL;
        end

        function TPPL=get.TotalPixelsPerLine(obj)
            if strcmpi(obj.VideoFormat,'Custom')
                TPPL=obj.TotalPixelsPerLine;
            else
                [~,~,TPPL,~,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);
            end
        end

    end


    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('visionhdl.internal.FrameOfPixelsToFrame',...
            'ShowSourceLink',false,...
            'Title','Frame Of Pixels To Frame');
        end
    end

    methods(Access=protected)
        function[matrix,validOut]=stepImpl(obj,pixel,control)
            [matrix,validOut]=obj.pStepHandle(obj,pixel,control);


        end



        function startVideoFrame(obj,~)
            coder.inline('always');
            obj.HCount=1;
            obj.VCount=1;
        end

        function endVideoFrame(obj,dataIn)
            coder.inline('always');
            obj.HCount=1;
            obj.VCount=1;
            obj.FrameValid=true;
            updateFrameStore(obj,dataIn);
        end

        function startFirstVideoLine(~,~)
            coder.inline('always');
        end

        function startVideoLine(~,~)
            coder.inline('always');
        end

        function endVideoLine(obj,~)
            coder.inline('always');
            obj.VCount=obj.VCount+1;
            obj.HCount=1;
        end

        function endLastVideoLine(obj,~)
            coder.inline('always');
            obj.HCount=1;
            obj.VCount=1;
        end

        function processPixel(obj,~)
            coder.inline('always');
            obj.HCount=obj.HCount+1;
        end

        function updateFrameStore(obj,dataIn)

            coder.inline('always');
            obj.ActiveFrame=obj.DisplayFrame;
            if(obj.ActiveFrame==1)
                obj.FrameStore_1(:,:,:)=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels,obj.NumComponents),'like',dataIn);
            else
                obj.FrameStore_2(:,:,:)=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels,obj.NumComponents),'like',dataIn);
            end
        end

        function resetStates(obj)
            obj.InFrame=false;
            obj.InLine=false;
            obj.VCount=1;
            obj.HCount=1;
            obj.ActiveFrame=1;
            obj.FrameValid=false;
        end

        function setupImpl(obj,dataIn,varargin)
            resetStates(obj);

            if strcmpi(obj.VideoFormat,'custom')

                coder.internal.errorIf(obj.ActivePixelsPerLine>obj.TotalPixelsPerLine,'visionhdl:PixelsToFrame:InvalidPixelsPerLine',obj.TotalPixelsPerLine,obj.ActivePixelsPerLine);

                if obj.NumPixels==1
                    obj.pActivePixelsPerLine=obj.ActivePixelsPerLine;
                    obj.pActiveVideoLines=obj.ActiveVideoLines;
                else
                    obj.pActivePixelsPerLine=obj.ActivePixelsPerLine/obj.NumPixels;
                    obj.pActiveVideoLines=obj.ActiveVideoLines;
                end

                if obj.NumPixels>1
                    coder.internal.errorIf(...
                    obj.ActivePixelsPerLine<32,...
                    'visionhdl:PixelsToFrame:MultiPixelsMin');
                end

                if obj.NumPixels==1
                    validateattributes(obj.pActiveVideoLines,...
                    {'numeric'},{'scalar','integer','>=',1,'<',65536},'PixelsToFrame','ActiveVideoLines');
                    validateattributes(obj.pActivePixelsPerLine,...
                    {'numeric'},{'scalar','integer','>=',1,'<',65536},'PixelsToFrame','ActivePixelsPerLine');
                end

                coder.internal.errorIf(...
                ~((mod(obj.TotalPixelsPerLine,obj.NumPixels))==0),...
                'visionhdl:PixelsToFrame:MultiPixelsFormat');

                coder.internal.errorIf(...
                ~((mod(obj.ActivePixelsPerLine,obj.NumPixels))==0),...
                'visionhdl:PixelsToFrame:MultiPixelsFormat');

            else
                [APL,AVL,TPL,~,~,~,FP,BP]=...
                visionhdl.internal.CommonSets.getVideoFormatParameters(obj.VideoFormat);


                if obj.NumPixels==1
                    obj.pActivePixelsPerLine=APL;
                    obj.pActiveVideoLines=AVL;
                else
                    obj.pActivePixelsPerLine=double(round(APL/obj.NumPixels));
                    obj.pActiveVideoLines=AVL;
                end

                if obj.NumPixels>1
                    coder.internal.errorIf(...
                    APL<32,...
                    'visionhdl:PixelsToFrame:MultiPixelsMin');
                end

                coder.internal.errorIf(...
                any(mod([APL,TPL,FP,BP],obj.NumPixels)),...
                'visionhdl:PixelsToFrame:MultiPixelsFormat');

            end

            if obj.NumPixels==1
                obj.FrameStore_1=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine,obj.NumComponents),'like',dataIn);
                obj.FrameStore_2=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine,obj.NumComponents),'like',dataIn);
                obj.pStepHandle=@singlePixelStep;
            else
                obj.FrameStore_1=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels,obj.NumComponents),'like',dataIn);
                obj.FrameStore_2=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels,obj.NumComponents),'like',dataIn);
                obj.pStepHandle=@multiPixelStep;
            end

        end
    end

    methods(Access=protected)




        function num=getNumInputsImpl(~)
            num=2;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='matrix';
            varargout{2}='validOut';
        end

        function validateInputsImpl(obj,pixel,control)
            if isempty(coder.target)||~eml_ambiguous_types
                D1=size(pixel,1);

                if obj.NumPixels==1&&obj.NumComponents>1
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumComponents]},'PixelsToFrame','DataIn');
                end

                validateattributes(control,{'logical'},{'size',[D1,5]},'','CtrlIn');
            else
                D1=size(pixel,1);
                if obj.NumPixels==1&&obj.NumComponents>1
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumComponents]},'PixelsToFrame','DataIn');
                end
                validateattributes(control,{'double','logical'},{'size',[D1,5]},'PixelsToFrame','CtrlIn');
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if(strcmpi(prop,'ActivePixelsPerLine')||...
                strcmpi(prop,'ActiveVideoLines')||strcmpi(prop,'TotalPixelsPerLine'))&&...
                ~strcmpi(obj.VideoFormat,'custom')
                flag=true;
            end
        end

        function value=DisplayFrame(obj)
            coder.inline('always');
            value=3-obj.ActiveFrame;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.InFrame=obj.InFrame;
                s.InLine=obj.InLine;
                s.VCount=obj.VCount;
                s.HCount=obj.HCount;
                s.ActiveFrame=obj.ActiveFrame;
                s.FrameStore_1=obj.FrameStore_1;
                s.FrameStore_2=obj.FrameStore_2;
                s.FrameValid=obj.FrameValid;
                s.pStepHandle=obj.pStepHandle;
                s.pActivePixelsPerLine=obj.pActivePixelsPerLine;
                s.pActiveVideoLines=obj.pActiveVideoLines;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end


    methods(Access=protected)



        function[matrix,validOut]=singlePixelStep(obj,pixel,ctrl)

            validIn=ctrl(:,5);
            obj.FrameValid=false;
            for jj=1:numel(validIn)
                Curr_hStartIn=ctrl(jj,1);
                Curr_hEndIn=ctrl(jj,2);
                Curr_vStartIn=ctrl(jj,3);
                Curr_vEndIn=ctrl(jj,4);
                if validIn(jj)
                    if(obj.VCount>=1)&&(obj.VCount<=obj.pActiveVideoLines)&&...
                        (obj.HCount>=1)&&(obj.HCount<=obj.pActivePixelsPerLine)
                        if(obj.ActiveFrame==1)
                            obj.FrameStore_1(obj.VCount,obj.HCount,:)=pixel(jj,:);
                        else
                            obj.FrameStore_2(obj.VCount,obj.HCount,:)=pixel(jj,:);
                        end
                    else
                        coder.internal.warning('visionhdl:PixelsToFrame:OutOfBounds');
                    end

                    if Curr_vStartIn
                        obj.InFrame=true;
                        startVideoFrame(obj,pixel)
                        if Curr_hStartIn
                            obj.InLine=true;
                            startFirstVideoLine(obj,pixel);
                        else
                            coder.internal.warning('visionhdl:PixelsToFrame:vstarthstart');
                        end
                    end

                    if obj.InFrame&&Curr_vEndIn
                        endVideoFrame(obj,pixel);
                        obj.InFrame=false;
                        if Curr_hEndIn
                            obj.InLine=false;
                        else
                            coder.internal.warning('visionhdl:PixelsToFrame:vendhend');
                        end
                    elseif obj.InFrame&&obj.InLine&&Curr_hEndIn
                        obj.InLine=false;
                        endVideoLine(obj,pixel);
                    elseif obj.InFrame&&Curr_hStartIn
                        obj.InLine=true;
                        startVideoLine(obj,pixel);
                    elseif obj.InFrame&&~obj.InLine&&Curr_hEndIn
                        obj.InLine=false;
                        coder.internal.warning('visionhdl:PixelsToFrame:extrahend');
                    elseif~obj.InFrame&&(Curr_hStartIn||Curr_hEndIn)
                        coder.internal.warning('visionhdl:PixelsToFrame:lineoutsideframe');
                    end
                    if obj.InFrame&&obj.InLine
                        processPixel(obj,pixel);
                    end
                end
            end
            validOut=obj.FrameValid;

            if validOut
                if obj.DisplayFrame==1
                    matrix=obj.FrameStore_1;
                else
                    matrix=obj.FrameStore_2;
                end
            else
                matrix=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine,obj.NumComponents),'like',pixel(1,1));
            end

        end



        function[matrix,validOut]=multiPixelStep(obj,pixel,ctrl)

            validIn=ctrl(:,5);
            obj.FrameValid=false;
            for jj=1:numel(validIn)
                Curr_hStartIn=ctrl(jj,1);
                Curr_hEndIn=ctrl(jj,2);
                Curr_vStartIn=ctrl(jj,3);
                Curr_vEndIn=ctrl(jj,4);
                if validIn(jj)
                    if(obj.VCount>=1)&&(obj.VCount<=obj.pActiveVideoLines)&&...
                        (obj.HCount>=1)&&(obj.HCount<=obj.pActivePixelsPerLine)
                        if(obj.ActiveFrame==1)
                            obj.FrameStore_1(obj.VCount,(((obj.HCount-1)*obj.NumPixels)+1:(obj.HCount*obj.NumPixels)),:)=pixel(jj,:,:);
                        else
                            obj.FrameStore_2(obj.VCount,(((obj.HCount-1)*obj.NumPixels)+1:(obj.HCount*obj.NumPixels)),:)=pixel(jj,:,:);
                        end
                    else
                        coder.internal.warning('visionhdl:PixelsToFrame:OutOfBounds');
                    end

                    if Curr_vStartIn
                        obj.InFrame=true;
                        startVideoFrame(obj,pixel)
                        if Curr_hStartIn
                            obj.InLine=true;
                            startFirstVideoLine(obj,pixel);
                        else
                            coder.internal.warning('visionhdl:PixelsToFrame:vstarthstart');
                        end
                    end

                    if obj.InFrame&&Curr_vEndIn
                        endVideoFrame(obj,pixel);
                        obj.InFrame=false;
                        if Curr_hEndIn
                            obj.InLine=false;
                        else
                            coder.internal.warning('visionhdl:PixelsToFrame:vendhend');
                        end
                    elseif obj.InFrame&&obj.InLine&&Curr_hEndIn
                        obj.InLine=false;
                        endVideoLine(obj,pixel);
                    elseif obj.InFrame&&Curr_hStartIn
                        obj.InLine=true;
                        startVideoLine(obj,pixel);
                    elseif obj.InFrame&&~obj.InLine&&Curr_hEndIn
                        obj.InLine=false;
                        coder.internal.warning('visionhdl:PixelsToFrame:extrahend');
                    elseif~obj.InFrame&&(Curr_hStartIn||Curr_hEndIn)
                        coder.internal.warning('visionhdl:PixelsToFrame:lineoutsideframe');
                    end
                    if obj.InFrame&&obj.InLine
                        processPixel(obj,pixel);
                    end
                end
            end
            validOut=obj.FrameValid;

            if validOut
                if obj.DisplayFrame==1
                    matrix=obj.FrameStore_1;
                else
                    matrix=obj.FrameStore_2;
                end
            else
                matrix=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels,obj.NumComponents),'like',pixel(1,1));
            end

        end






    end



end
