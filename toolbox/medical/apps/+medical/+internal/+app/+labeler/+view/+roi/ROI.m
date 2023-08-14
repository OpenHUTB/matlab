classdef ROI<images.internal.app.segmenter.volume.display.ROI




    events
LevelTraceOutlineRefreshed
    end

    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=private,Transient)

        LevelTrace medical.internal.app.labeler.view.LevelTracing

    end

    methods

        function self=ROI()
            self@images.internal.app.segmenter.volume.display.ROI();
        end


        function startLevelTrace(self,val,color)

            deselectAll(self);

            self.LevelTrace=medical.internal.app.labeler.view.LevelTracing;
            self.LevelTrace.Parent=self.AxesHandle;
            self.LevelTrace.Image=mat2gray(im2gray(self.ImageData));
            self.LevelTrace.Color=color;
            self.LevelTrace.Tolerance=0.05;
            self.LevelTrace.UserData=val;

            addlistener(self.LevelTrace,'MaskReady',@(src,evt)levelTraceReady(self));
            addlistener(self.LevelTrace,'OutlineRefreshed',@(src,evt)self.notify('LevelTraceOutlineRefreshed'));

            beginDrawing(self.LevelTrace);

        end


        function clearLevelTrace(self)
            if isvalid(self.LevelTrace)
                self.LevelTrace.clear()
            end
        end


        function stopLevelTrace(self)
            delete(self.LevelTrace);
        end


        function setLevelTraceThreshold(self,threshold)
            if isvalid(self.LevelTrace)
                self.LevelTrace.Tolerance=threshold;
            end
        end


        function updateSlice(self,img,slice)

            self.Slice=slice;
            self.ImageData=img;

            if isvalid(self.LevelTrace)
                self.LevelTrace.Image=mat2gray(im2gray(img));
            end

        end

    end

    methods(Access=protected)


        function levelTraceReady(self)

            mask=applyBackward(self.Rotate,self.LevelTrace.Mask);

            if any(mask,"all")

                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(mask)),logical.empty,uint8.empty));

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                self.LevelTrace.UserData,...
                logical.empty,...
                0));

            end

        end

    end


end
