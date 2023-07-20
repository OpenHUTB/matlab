classdef(StrictDefaults)PixelsToFrame<visionhdl.internal.FrameOfPixelsToFrame














































































%#codegen


    methods
        function obj=PixelsToFrame(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
            resetStates(obj);
        end

    end
    methods(Access=protected)


        function validateInputsImpl(obj,pixel,control)
            if isempty(coder.target)||~eml_ambiguous_types
                D1=size(pixel,1);

                if obj.NumPixels==1
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumComponents]},'PixelsToFrame','DataIn');
                else
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumPixels]},'PixelsToFrame','DataIn');
                end


                validatecontrolsignals(control(1));


            else
                D1=size(pixel,1);
                if obj.NumPixels==1
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumComponents]},'PixelsToFrame','DataIn');
                else
                    validateattributes(pixel,{'numeric','logical','embedded.fi'},{'size',[D1,obj.NumPixels]},'PixelsToFrame','DataIn');
                end

                validatecontrolsignals(control(1));


            end
        end

        function[matrix,validOut]=singlePixelStep(obj,pixel,ctrl)

            obj.FrameValid=false;
            for jj=1:numel(ctrl)
                Curr_hStartIn=ctrl(jj).hStart;
                Curr_hEndIn=ctrl(jj).hEnd;
                Curr_vStartIn=ctrl(jj).vStart;
                Curr_vEndIn=ctrl(jj).vEnd;
                Curr_validIn=ctrl(jj).valid;
                if Curr_validIn
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

            obj.FrameValid=false;
            for jj=1:numel(ctrl)
                Curr_hStartIn=ctrl(jj).hStart;
                Curr_hEndIn=ctrl(jj).hEnd;
                Curr_vStartIn=ctrl(jj).vStart;
                Curr_vEndIn=ctrl(jj).vEnd;
                Curr_validIn=ctrl(jj).valid;
                if Curr_validIn
                    if(obj.VCount>=1)&&(obj.VCount<=obj.pActiveVideoLines)&&...
                        (obj.HCount>=1)&&(obj.HCount<=obj.pActivePixelsPerLine)
                        if(obj.ActiveFrame==1)
                            obj.FrameStore_1(obj.VCount,(((obj.HCount-1)*obj.NumPixels)+1:(obj.HCount*obj.NumPixels)))=pixel(jj,:);
                        else
                            obj.FrameStore_2(obj.VCount,(((obj.HCount-1)*obj.NumPixels)+1:(obj.HCount*obj.NumPixels)))=pixel(jj,:);
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
                matrix=cast(zeros(obj.pActiveVideoLines,obj.pActivePixelsPerLine*obj.NumPixels),'like',pixel(1,1));
            end

        end
    end

    methods(Hidden,Static)

        function flag=isAllowedInSystemBlock(~)
            flag=false;
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl(platformName)
            simMode=["Code generation","Interpreted execution"];
            if strcmp(platformName,'MATLAB')
                simMode="Code generation";
            end
        end
    end
end
