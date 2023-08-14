classdef Key<handle&matlab.mixin.SetGet




    events

KeyPressed
KeyReleased

ScrollWheelSpun

SliceMousePressed

    end


    properties(Transient)

        Enabled(1,1)logical=true;

    end


    properties(SetAccess=private,Hidden,Transient)

        ShiftPressed(1,1)logical=false;

        CtrlPressed(1,1)logical=false;

        AltPressed(1,1)logical=false;

        CtrlAPressed(1,1)logical=false;

    end


    properties(Access=private,Hidden,Transient)

        SliceKeyPressListener event.listener
        SliceKeyReleaseListener event.listener
        SliceScrollWheelListener event.listener
        SliceMousePressListener event.listener

        VolumeKeyPressListener event.listener
        VolumeKeyReleaseListener event.listener
        VolumeScrollWheelListener event.listener

        LabelKeyPressListener event.listener
        LabelKeyReleaseListener event.listener
        LabelScrollWheelListener event.listener

        DataBrowserKeyPressListener event.listener
        DataBrowserKeyReleaseListener event.listener
        DataBrowserScrollWheelListener event.listener

        WasKeyAlreadyPressed(1,1)logical=false;

    end


    methods




        function self=Key(transverseFig,coronalFig,sagittalFig,volumeFigure,labelBrowserFigure,dataBrowserFigure)

            sliceFigures=[transverseFig,coronalFig,sagittalFig];

            transverseFig.KeyPressFcn=@(~,~)deal();
            coronalFig.KeyPressFcn=@(~,~)deal();
            sagittalFig.KeyPressFcn=@(~,~)deal();

            self.SliceKeyPressListener=event.listener(sliceFigures,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.SliceKeyReleaseListener=event.listener(sliceFigures,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.SliceScrollWheelListener=event.listener(sliceFigures,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));
            self.SliceMousePressListener=event.listener(sliceFigures,'WindowMousePress',@(src,evt)sliceMousePressed(self,evt));

            volumeFigure.KeyPressFcn=@(~,~)deal();
            self.VolumeKeyPressListener=event.listener(volumeFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.VolumeKeyReleaseListener=event.listener(volumeFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.VolumeScrollWheelListener=event.listener(volumeFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

            labelBrowserFigure.KeyPressFcn=@(~,~)deal();
            self.LabelKeyPressListener=event.listener(labelBrowserFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.LabelKeyReleaseListener=event.listener(labelBrowserFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.LabelScrollWheelListener=event.listener(labelBrowserFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

            dataBrowserFigure.KeyPressFcn=@(~,~)deal();
            self.DataBrowserKeyPressListener=event.listener(dataBrowserFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.DataBrowserKeyReleaseListener=event.listener(dataBrowserFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.DataBrowserScrollWheelListener=event.listener(dataBrowserFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

        end

    end


    methods(Access=private)


        function keyPressed(self,evt)

            self.updateModifiers(evt);

            if~self.Enabled||self.WasKeyAlreadyPressed
                return;
            end

            if self.CtrlPressed


                switch evt.Key
                case 'a'
                    key='ctrla';
                    self.CtrlAPressed=true;
                case 'c'
                    key='ctrlc';
                case 's'
                    key='ctrls';
                case 'v'
                    key='ctrlv';
                case 'x'
                    key='ctrlx';
                case 'y'
                    key='ctrly';
                case 'z'
                    key='ctrlz';
                case 'equal'
                    key='ctrl+';
                case 'hyphen'
                    key='ctrl-';
                otherwise
                    return;

                end

            elseif self.ShiftPressed

                if self.AltPressed


                    switch evt.Key
                    case 'downarrow'
                        key='blockdown';
                    case 'leftarrow'
                        key='blockleft';
                    case 'rightarrow'
                        key='blockright';
                    case 'uparrow'
                        key='blockup';
                    otherwise
                        return;

                    end

                else


                    switch evt.Key
                    case 'downarrow'
                        key='pandown';
                    case 'leftarrow'
                        key='panleft';
                    case 'rightarrow'
                        key='panright';
                    case 'uparrow'
                        key='panup';
                    case 'shift'
                        key='windowLevelOn';
                    otherwise
                        return;

                    end

                end

            else


                switch evt.Key
                case 'downarrow'
                    key='down';
                case 'leftarrow'
                    key='left';
                case 'rightarrow'
                    key='right';
                case 'uparrow'
                    key='up';
                case 'delete'
                    key='delete';
                case 'return'
                    key='return';
                case 'escape'
                    key='escape';
                otherwise
                    return;

                end

            end

            self.WasKeyAlreadyPressed=true;

            evt=images.internal.app.segmenter.volume.events.KeyPressedEventData(key);
            self.notify('KeyPressed',evt);

        end


        function keyReleased(self,evt)

            self.updateModifiers(evt);
            self.WasKeyAlreadyPressed=false;

            switch evt.Key
            case 'shift'
                key='windowLevelOff';
            otherwise
                return
            end

            evt=images.internal.app.segmenter.volume.events.KeyPressedEventData(key);
            self.notify('KeyReleased',evt);

        end


        function scrollWheel(self,evt)

            if~self.Enabled
                return;
            end

            evt=images.internal.app.segmenter.volume.events.ScrollWheelSpunEventData(evt.VerticalScrollCount);
            self.notify('ScrollWheelSpun',evt);

        end


        function sliceMousePressed(self,evt)

            evt=images.internal.app.segmenter.volume.events.WindowClickedEventData(...
            images.roi.internal.getClickType(evt.Source));
            self.notify('SliceMousePressed',evt);

        end


        function updateModifiers(self,evt)

            self.CtrlPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'control'));
            self.ShiftPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'shift'));
            self.AltPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'alt'));
            self.CtrlAPressed=false;

        end

    end


end