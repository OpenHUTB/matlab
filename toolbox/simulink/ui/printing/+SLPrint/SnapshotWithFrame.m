classdef SnapshotWithFrame<SLPrint.Snapshot

    properties
        AddFrame=false;
        FrameFile='sldefaultframe.fig';
        UseSizeSpecifiedByFrameFile=true;
    end

    properties(Hidden)
        FramePadding=[24,24,24,24];
    end

    properties(Access=protected)
        OverlayRootNode;
    end

    properties(Access=private)
        FrameFileInfo;
    end

    methods
        function this=SnapshotWithFrame(varargin)
            this=this@SLPrint.Snapshot(varargin{:});
        end

        function FrameFileInfo=get.FrameFileInfo(this)
            FrameFileInfo=SLPrint.FrameFileInfo(this.FrameFile);
        end

        function set.FramePadding(this,value)
            if(length(value)==1)
                value=repmat(value,1,4);
            end
            if(isnumeric(value)&&(length(value)==4))
                this.FramePadding=value;
            else
                error(message('Simulink:Printing:InvalidFramePadding'));
            end
        end
    end

    methods(Access=protected)
        function render(this)
            this.render@SLPrint.Snapshot();


            portal=this.Portal;
            portal.clearOverlayScene();
            overlayRootNode=MG2.ContainerNode;
            portal.overlayScene.addNode(overlayRootNode);
            this.OverlayRootNode=overlayRootNode;

            if this.AddFrame
                this.drawFrames();
            end
        end

        function targetOutputRect=getTargetOutputRect(this)
            if~this.AddFrame
                targetOutputRect=this.getTargetOutputRect@SLPrint.Snapshot();
                return
            end

            fInfo=this.FrameFileInfo;
            targetSize=this.getUnscaledTargetSize;

            [frameScale,frameOffset]=this.getFrameScaleAndOffset();

            sysOverlayRect=[frameScale,frameScale].*fInfo.SystemRect+[frameOffset,0,0];


            this.Portal.targetOverlayRect=sysOverlayRect;


            padding=this.getOutputPadding();
            targetOutputRect=sysOverlayRect+[...
            padding(1)...
            ,padding(2)...
            ,-padding(1)-padding(3)...
            ,-padding(2)-padding(4)];

            [offset,scale]=this.getOffsetAndScaleToFit(...
            [0,0,targetSize],...
            targetOutputRect);


            offset=offset+(targetOutputRect(3:4)-scale*targetSize)/2;

            trgSize=this.getUnscaledTargetSize();
            targetOutputRect=[offset,scale*trgSize];
        end

        function outputSize=getOutputSize(this)
            if~this.AddFrame
                outputSize=this.getOutputSize@SLPrint.Snapshot();
                return
            end

            fInfo=this.FrameFileInfo;
            paper=fInfo.Paper;
            if this.UseSizeSpecifiedByFrameFile
                outputSize=paper.Size.toPixels(this.Resolution);

            else
                if strcmp(this.SizeMode,'UseScaledSize')
                    paperMargins=paper.Margins.toPixels(this.Resolution);
                    outputSize=this.getFrameScaleAndOffset()+...
                    [paperMargins(1)+paperMargins(3)...
                    ,paperMargins(2)+paperMargins(4)];
                else
                    outputSize=this.SpecifiedSize;
                end
            end
        end

        function padding=getOutputPadding(this)
            if this.AddFrame
                padding=this.FramePadding;
            else
                padding=this.Padding;
            end
        end

        function[frameScale,frameOffset]=getFrameScaleAndOffset(this)
            fInfo=this.FrameFileInfo;
            paper=fInfo.Paper;

            paperMargins=paper.Margins.toPixels(this.Resolution);
            frameOffset=[paperMargins(1),paperMargins(2)];

            if this.UseSizeSpecifiedByFrameFile
                frameScale=fInfo.ConversionScale.toPixels(this.Resolution);
            else
                if strcmp(this.SizeMode,'UseScaledSize')
                    trgSize=this.getUnscaledTargetSize();
                    padding=this.getOutputPadding();
                    framePadSize=[padding(1)+padding(3),padding(2)+padding(4)];
                    sysRectSize=this.Scale*trgSize+framePadSize;
                    frameScale=sysRectSize./fInfo.SystemRect(3:4);


                    outputSize=frameScale+[paperMargins(1)+paperMargins(3)...
                    ,paperMargins(2)+paperMargins(4)];

                    if any(outputSize>this.ScaledMaxSize)
                        nonSysRect=trgSize.*([1,1]-fInfo.SystemRect(3:4))+...
                        [paperMargins(1)+paperMargins(3),paperMargins(2)+paperMargins(4)];

                        [~,scale]=this.getOffsetAndScaleToFit(...
                        [0,0,trgSize],...
                        [0,0,this.ScaledMaxSize-nonSysRect]);

                        sysRectSize=scale*trgSize+framePadSize;
                        frameScale=sysRectSize./fInfo.SystemRect(3:4);
                    end

                else
                    frameScale=this.SpecifiedSize-...
                    [paperMargins(1)+paperMargins(3),paperMargins(2)+paperMargins(4)];
                end
            end
        end

        function drawFrames(this)
            overlayRootNode=this.OverlayRootNode;
            fInfo=this.FrameFileInfo;

            [frameScale,frameOffset]=this.getFrameScaleAndOffset();
            rectScale=[frameScale,frameScale];
            rectOffset=[frameOffset,0,0];


            for i=1:length(fInfo.FrameRects)
                rect=rectScale.*fInfo.FrameRects{i}+rectOffset;
                rectNode=MG2.RectNode(rect);
                rectNode.Parent=overlayRootNode;
            end


            ftInfo=SLPrint.FrameTextInfo();
            ftInfo.System=this.Target;
            tInfo=ftInfo.parseTextInfo(fInfo.TextInfo);

            fontFamily=SLPrint.Utils.GetDefaultFont;
            vAlign='V_CENTER_TEXT';
            tScale=frameScale;
            tOffset=frameOffset;
            for i=1:length(tInfo)
                textNode=MG2.TextNode;
                textNode.InterpretMode=tInfo(i).InterpretMode;
                textNode.Text=tInfo(i).String;
                textNode.HorizontalAlignment=tInfo(i).HorizontalAlignment;
                textNode.VerticalAlignment=vAlign;
                textNode.Font.Family=fontFamily;
                textNode.Font.Weight=tInfo(i).FontWeight;
                textNode.Font.Size=tInfo(i).FontSize;
                textNode.Font.Style=tInfo(i).FontStyle;
                textNode.Position=tScale.*tInfo(i).Position+tOffset;

                textNode.Parent=overlayRootNode;
            end
        end

    end
end
