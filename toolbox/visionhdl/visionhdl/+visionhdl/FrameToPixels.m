classdef(StrictDefaults)FrameToPixels<visionhdl.internal.FrameToFrameOfPixels
















































































%#codegen

    methods
        function obj=FrameToPixels(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
        end

    end

    methods(Access=protected)

        function validateInputsImpl(obj,~)

            if isempty(coder.target)||~eml_ambiguous_types

                if obj.NumPixels>1&&obj.NumComponents>1
                    coder.internal.error('visionhdl:FrameToPixels:MultiPixelsComponentNum');
                end
            end

        end

        function[PixelOut,CtrlOut]=stepImpl(obj,frame)




            if coder.target('MATLAB')


                Frame_t=permute(frame,[2,1,3]);

                if obj.NumPixels>1

                    Frame_t1=zeros(obj.pActivePixelsPerLine,obj.pActiveVideoLines,obj.NumPixels,'like',frame);
                    for ii=1:obj.NumPixels
                        Frame_t1(:,:,ii)=Frame_t(ii:obj.NumPixels:end,:,:);
                    end
                    SecDimOut=obj.NumPixels;
                else
                    Frame_t1=Frame_t;
                    SecDimOut=obj.NumComponents;
                end


                PixelOut_t=cast(zeros(obj.pTotalPixelsPerLine,obj.pTotalVideoLines,SecDimOut),'like',frame);
                PixelOut_t(obj.pBackPorch+1:obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1,:)=...
                Frame_t1;
                PixelOut=reshape(PixelOut_t,[],SecDimOut);


                CtrlOut_t=repmat(pixelcontrolstruct(0,0,0,0,0),obj.pTotalPixelsPerLine,obj.pTotalVideoLines);
                [CtrlOut_t(obj.pBackPorch+1,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1).hStart]=deal(true);
                [CtrlOut_t(obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1).hEnd]=deal(true);
                [CtrlOut_t(obj.pBackPorch+1,obj.pStartingActiveLine).vStart]=deal(true);
                [CtrlOut_t(obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine+obj.pActiveVideoLines-1).vEnd]=deal(true);
                [CtrlOut_t(obj.pBackPorch+1:obj.pBackPorch+obj.pActivePixelsPerLine,obj.pStartingActiveLine:obj.pStartingActiveLine+obj.pActiveVideoLines-1).valid]=deal(true);
                CtrlOut=CtrlOut_t(:);
            else
                iter=obj.pTotalVideoLines*obj.pTotalPixelsPerLine;
                PixelOut=cast(zeros(iter,obj.NumComponents),'like',frame);
                CtrlOut=repmat(struct('hStart',false,'hEnd',false,'vStart',false,'vEnd',false,'valid',false),iter,1);
                obj.LineCount=obj.pStartingActiveLine;
                obj.PixelCount=obj.pBackPorch;

                for ii=((obj.pStartingActiveLine-1)*obj.pTotalPixelsPerLine)+obj.pBackPorch+1:((obj.pStartingActiveLine+obj.pActiveVideoLines-1)*obj.pTotalPixelsPerLine)-(obj.pFrontPorch)
                    if(obj.LineCount>=obj.pStartingActiveLine)&&...
                        (obj.LineCount<=obj.pEndingActiveLine)

                        if(obj.PixelCount>=obj.pBackPorch)&&...
                            (obj.PixelCount<(obj.pBackPorch+obj.pActivePixelsPerLine))

                            if obj.PixelCount==obj.pBackPorch
                                CtrlOut(ii).hStart=true;
                                if obj.LineCount==obj.pStartingActiveLine
                                    CtrlOut(ii).vStart=true;
                                end
                            end
                            if obj.PixelCount==(obj.pBackPorch+obj.pActivePixelsPerLine-1)
                                CtrlOut(ii).hEnd=true;
                                if obj.LineCount==obj.pEndingActiveLine
                                    CtrlOut(ii).vEnd=true;
                                end
                            end
                            CtrlOut(ii).valid=true;

                            PixelOut(ii,:)=frame(obj.LineCount-obj.pStartingActiveLine+1,...
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
        end
    end

    methods(Hidden,Static)

        function flag=isAllowedInSystemBlock(~)
            flag=false;
        end
    end
end
