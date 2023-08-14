classdef Pointer<handle




    events

SetDrawingToolPointer

UpdateDatatip

UpdateOverviewDatatip

UpdateThumbnail

    end


    properties

        Enabled(1,1)logical=true;

    end


    properties(SetAccess=private,Hidden,Transient)


        ActivePanel char

    end


    properties(Access=private,Hidden,Transient)

        SliceListener event.listener
        VolumeListener event.listener
        LabelListener event.listener
        OverviewListener event.listener

        DatatipVisible(1,1)logical=false;
        OverviewDatatipVisible(1,1)logical=false;
        ThumbnailVisible(1,1)logical=false;

    end


    methods




        function self=Pointer(sliceFigure,volumeFigure,labelFigure,overviewFigure)

            self.SliceListener=event.listener(sliceFigure,'WindowMouseMotion',@(src,evt)managePointer(self,src,evt));
            self.VolumeListener=event.listener(volumeFigure,'WindowMouseMotion',@(src,evt)managePointer(self,src,evt));
            self.LabelListener=event.listener(labelFigure,'WindowMouseMotion',@(src,evt)managePointer(self,src,evt));
            self.OverviewListener=event.listener(overviewFigure,'WindowMouseMotion',@(src,evt)managePointer(self,src,evt));
            set(sliceFigure,'WindowButtonMotionFcn',@(~,~)deal());

        end




        function wait(self)

            self.Enabled=false;

        end




        function resume(self)

            self.Enabled=true;

        end




        function setDrawingToolPointer(~,fig,mode)

            switch mode

            case{'Freehand','AssistedFreehand','Polygon'}
                ptr='crosshair';

            case{'PaintBrush','Eraser'}
                ptr='dot';

            case{'FillRegion','FloodFill'}
                ptr='paintcan';

            case{'Select','None'}
                ptr='arrow';

            otherwise

            end

            images.roi.setBackgroundPointer(fig,ptr);

        end

    end


    methods(Access=private)


        function managePointer(self,src,evt)

            if~self.Enabled
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end


            hpanel=ancestor(evt.HitObject,'uipanel','toplevel');

            if isempty(hpanel)
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end

            if strcmp(hpanel.Tag,'DirtyVolumePanel')

                if~self.DatatipVisible
                    self.DatatipVisible=true;
                    notify(self,'UpdateDatatip',images.internal.app.segmenter.volume.events.UpdateDatatipEventData(true));
                end

            elseif self.DatatipVisible

                self.DatatipVisible=false;
                notify(self,'UpdateDatatip',images.internal.app.segmenter.volume.events.UpdateDatatipEventData(false));

            end

            if strcmp(hpanel.Tag,'DirtyOverviewPanel')

                if~self.OverviewDatatipVisible
                    self.OverviewDatatipVisible=true;
                    notify(self,'UpdateOverviewDatatip',images.internal.app.segmenter.volume.events.UpdateDatatipEventData(true));
                end

            elseif self.OverviewDatatipVisible

                self.OverviewDatatipVisible=false;
                notify(self,'UpdateOverviewDatatip',images.internal.app.segmenter.volume.events.UpdateDatatipEventData(false));

            end

            if strcmp(hpanel.Tag,'SummaryPanel')

                if isa(evt.HitObject,'matlab.graphics.axis.Axes')

                    idx=round(evt.HitObject.CurrentPoint(1,1));
                    self.ThumbnailVisible=true;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(true,idx));

                elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')

                    idx=round(evt.HitObject.Parent.CurrentPoint(1,1));
                    self.ThumbnailVisible=true;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(true,idx));

                else

                    self.ThumbnailVisible=false;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(false,[]));

                end

            elseif self.ThumbnailVisible

                self.ThumbnailVisible=false;
                notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(false,[]));

            end

            switch hpanel.Tag

            case{'VolumePanel','OverviewPanel'}
                manageVolumePointer(self,src,evt);

            case{'DirtyVolumePanel','DirtyOverviewPanel'}
                manageDirtyVolumePointer(self,src,evt);

            case 'SlicePanel'
                manageSlicePointer(self,src,evt);

            case 'EntryPanel'
                manageEntryPointer(self,src,evt);

            case 'ScrollBarPanel'
                manageScrollBarPointer(self,src,evt);

            case 'HeaderPanel'
                manageHeaderPointer(self,src,evt);

            case 'SliderPanel'
                manageSliderPointer(self,src,evt);

            case 'SummaryPanel'
                manageSummaryPointer(self,src,evt);

            otherwise
                return;

            end

            self.ActivePanel=hpanel.Tag;

        end


        function manageVolumePointer(~,src,~)
            images.roi.setBackgroundPointer(src,'rotate');
        end


        function manageDirtyVolumePointer(~,src,~)
            images.roi.setBackgroundPointer(src,'push');
        end


        function manageSlicePointer(self,src,evt)

            if wasClickOnAxesToolbar(self,evt)
                images.roi.setBackgroundPointer(src,'arrow');
            elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')
                if isprop(evt.HitObject,'InteractionMode')
                    switch evt.HitObject.InteractionMode
                    case ''
                        notify(self,'SetDrawingToolPointer');
                    case 'pan'
                        images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('pan_both'),[16,16]);
                    case 'zoomin'
                        images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomin_unconstrained'),[16,16]);
                    case 'zoomout'
                        images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomout_both'),[16,16]);
                    end
                else
                    images.roi.setBackgroundPointer(src,'arrow');
                end
            elseif isa(evt.HitObject,'matlab.graphics.axis.Axes')
                images.roi.setBackgroundPointer(src,'arrow');
            elseif isa(evt.HitObject,'matlab.ui.container.Panel')
                images.roi.setBackgroundPointer(src,'arrow');
            end

        end


        function manageEntryPointer(~,src,evt)

            if isa(evt.HitObject,'matlab.graphics.primitive.Image')||...
                isa(evt.HitObject,'matlab.ui.control.Image')
                images.roi.setBackgroundPointer(src,'push');
            else
                images.roi.setBackgroundPointer(src,'arrow');
            end

        end


        function manageScrollBarPointer(~,src,~)
            images.roi.setBackgroundPointer(src,'arrow');
        end


        function manageSliderPointer(~,src,~)
            images.roi.setBackgroundPointer(src,'arrow');
        end


        function manageSummaryPointer(~,src,evt)

            if isa(evt.HitObject,'matlab.graphics.primitive.Image')
                images.roi.setBackgroundPointer(src,'push');
            else
                images.roi.setBackgroundPointer(src,'arrow');
            end

        end


        function manageHeaderPointer(~,src,~)
            images.roi.setBackgroundPointer(src,'arrow');
        end


        function TF=wasClickOnAxesToolbar(~,evt)



            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end


        function TF=isModeManagerActive(~,src)
            hManager=uigetmodemanager(src);
            hMode=hManager.CurrentMode;
            TF=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);
        end

    end


end