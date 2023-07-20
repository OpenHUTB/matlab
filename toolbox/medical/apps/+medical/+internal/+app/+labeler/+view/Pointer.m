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
        LabelBrowserListener event.listener
        DataBrowserListener event.listener

        DatatipVisible(1,1)logical=false;
        OverviewDatatipVisible(1,1)logical=false;
        ThumbnailVisible(1,1)logical=false;

SlicesLinkedPointerProps

WindowLevelPointer

    end


    methods




        function self=Pointer(transverseFig,coronalFig,sagittalFig,volumeFigure,labelBrowserFigure,dataBrowserFigure)

            sliceFigures=[transverseFig,coronalFig,sagittalFig];
            self.SlicesLinkedPointerProps=linkprop(sliceFigures,...
            {'Pointer','PointerShapeCData','PointerShapeHotSpot'});

            self.SliceListener=event.listener(sliceFigures,'WindowMouseMotion',@(src,evt)manageSlicePointer(self,src,evt));
            self.VolumeListener=event.listener(volumeFigure,'WindowMouseMotion',@(src,evt)manageVolumePointer(self,src,evt));
            self.LabelBrowserListener=event.listener(labelBrowserFigure,'WindowMouseMotion',@(src,evt)manageLabelBrowserPointer(self,src,evt));
            self.DataBrowserListener=event.listener(dataBrowserFigure,'WindowMouseMotion',@(src,evt)manageDataBrowserPointer(self,src,evt));
            set(sliceFigures,'WindowButtonMotionFcn',@(~,~)deal());


            iconRoot=ipticondir;
            cdata=makeToolbarIconFromPNG(fullfile(iconRoot,'cursor_contrast.png'));
            self.WindowLevelPointer=cdata(:,:,1)+1;

        end




        function wait(self)

            self.Enabled=false;

        end




        function resume(self)

            self.Enabled=true;

        end




        function setPointer(self,fig,mode)

            switch mode

            case{'Freehand','AssistedFreehand','Polygon'}
                ptr='crosshair';
                images.roi.setBackgroundPointer(fig,ptr);

            case{'PaintBrush','Eraser'}
                ptr='dot';
                images.roi.setBackgroundPointer(fig,ptr);

            case{'FillRegion','FloodFill'}
                ptr='paintcan';
                images.roi.setBackgroundPointer(fig,ptr);

            case 'Select'
                ptr='arrow';
                images.roi.setBackgroundPointer(fig,ptr);

            case 'None'
                ptr='restricted';
                images.roi.setBackgroundPointer(fig,ptr);

            case 'WindowLevel'
                images.roi.setBackgroundPointer(fig,'custom',self.WindowLevelPointer,[16,16]);

            case 'LevelTracing'
                ptr='arrow';
                images.roi.setBackgroundPointer(fig,ptr);

            otherwise

            end



        end

    end


    methods(Access=private)


        function manageSlicePointer(self,src,evt)

            if~self.Enabled
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end


            hpanel=ancestor(evt.HitObject,'uipanel','toplevel');

            if isempty(hpanel)
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end

            if strcmp(hpanel.Tag,'SummaryPanel')

                if isa(evt.HitObject,'matlab.graphics.axis.Axes')

                    idx=floor(evt.HitObject.CurrentPoint(1,1));
                    idx=max(1,idx);
                    self.ThumbnailVisible=true;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(true,idx));

                elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')

                    idx=floor(evt.HitObject.Parent.CurrentPoint(1,1));
                    idx=max(1,idx);
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

            case{'TransverseSlicePanel','SagittalSlicePanel','CoronalSlicePanel'}

                self.ActivePanel=hpanel.Tag;

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

            case 'SliderPanel'
                self.ActivePanel=hpanel.Tag;
                images.roi.setBackgroundPointer(src,'arrow');

            case{'TransverseSummary','SagittalSummary','CoronalSummary'}
                self.ActivePanel=hpanel.Tag;

                if isa(evt.HitObject,'matlab.graphics.axis.Axes')

                    images.roi.setBackgroundPointer(src,'arrow');

                    idx=floor(evt.HitObject.CurrentPoint(1,1));
                    idx=max(1,idx);
                    self.ThumbnailVisible=true;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(true,idx));

                elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')

                    images.roi.setBackgroundPointer(src,'push');

                    idx=floor(evt.HitObject.Parent.CurrentPoint(1,1));
                    idx=max(1,idx);
                    self.ThumbnailVisible=true;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(true,idx));

                else

                    images.roi.setBackgroundPointer(src,'arrow');

                    self.ThumbnailVisible=false;
                    notify(self,'UpdateThumbnail',images.internal.app.segmenter.volume.events.UpdateThumbnailEventData(false,[]));

                end

            otherwise
                return;

            end


        end


        function manageVolumePointer(self,src,evt)

            if~self.Enabled
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end


            hpanel=ancestor(evt.HitObject,'uipanel','toplevel');

            if isempty(hpanel)
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end

            switch hpanel.Tag

            case 'VolumePanel'
                images.roi.setBackgroundPointer(src,'rotate');

            case 'DirtyVolumePanel'
                images.roi.setBackgroundPointer(src,'push');

            otherwise
                return;

            end

            self.ActivePanel=hpanel.Tag;

        end


        function manageLabelBrowserPointer(self,src,evt)

            if~self.Enabled
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end


            hpanel=ancestor(evt.HitObject,'uipanel','toplevel');

            if isempty(hpanel)
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end

            switch hpanel.Tag

            case 'EntryPanel'
                if isa(evt.HitObject,'matlab.graphics.primitive.Image')||...
                    isa(evt.HitObject,'matlab.ui.control.Image')
                    images.roi.setBackgroundPointer(src,'push');
                else
                    images.roi.setBackgroundPointer(src,'arrow');
                end

            case 'ScrollBarPanel'
                images.roi.setBackgroundPointer(src,'arrow');

            case 'HeaderPanel'
                images.roi.setBackgroundPointer(src,'arrow');

            otherwise
                return;

            end

            self.ActivePanel=hpanel.Tag;

        end


        function manageDataBrowserPointer(self,src,evt)

            if~self.Enabled
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end


            hpanel=ancestor(evt.HitObject,'uipanel','toplevel');

            if isempty(hpanel)
                images.roi.setBackgroundPointer(src,'arrow');
                return;
            end

            switch hpanel.Tag

            case 'EntryPanel'
                if isa(evt.HitObject,'matlab.graphics.primitive.Image')||...
                    isa(evt.HitObject,'matlab.ui.control.Image')
                    images.roi.setBackgroundPointer(src,'push');
                else
                    images.roi.setBackgroundPointer(src,'arrow');
                end

            case 'ScrollBarPanel'
                images.roi.setBackgroundPointer(src,'arrow');

            otherwise
                return;

            end

            self.ActivePanel=hpanel.Tag;

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

function icon=makeToolbarIconFromPNG(filename)






    [icon,map,alpha]=imread(filename);




    if(ndims(icon)==3)

        idx=0;
        if~isempty(alpha)
            mask=alpha==idx;
        else
            mask=icon==idx;
        end

    else


        for i=1:size(map,1)
            if all(map(i,:)==[0,1,1])
                idx=i;
                break;
            end
        end

        mask=icon==(idx-1);
        icon=ind2rgb(icon,map);

    end


    icon=im2double(icon);

    for p=1:3

        tmp=icon(:,:,p);
        tmp(mask)=NaN;
        icon(:,:,p)=tmp;

    end
end
