classdef Key<handle&matlab.mixin.SetGet




    events

KeyPressed

ScrollWheelSpun

WindowClicked

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
        SliceClickListener event.listener

        VolumeKeyPressListener event.listener
        VolumeKeyReleaseListener event.listener
        VolumeScrollWheelListener event.listener

        LabelKeyPressListener event.listener
        LabelKeyReleaseListener event.listener
        LabelScrollWheelListener event.listener

        OverviewKeyPressListener event.listener
        OverviewKeyReleaseListener event.listener
        OverviewScrollWheelListener event.listener

        WasKeyAlreadyPressed(1,1)logical=false;

    end


    methods




        function self=Key(sliceFigure,volumeFigure,labelFigure,overviewFigure)

            sliceFigure.KeyPressFcn=@(~,~)deal();

            self.SliceKeyPressListener=event.listener(sliceFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.SliceKeyReleaseListener=event.listener(sliceFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.SliceScrollWheelListener=event.listener(sliceFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));
            self.SliceClickListener=event.listener(sliceFigure,'WindowMousePress',@(src,evt)sliceClicked(self,evt));

            volumeFigure.KeyPressFcn=@(~,~)deal();

            self.VolumeKeyPressListener=event.listener(volumeFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.VolumeKeyReleaseListener=event.listener(volumeFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.VolumeScrollWheelListener=event.listener(volumeFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

            labelFigure.KeyPressFcn=@(~,~)deal();

            self.LabelKeyPressListener=event.listener(labelFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.LabelKeyReleaseListener=event.listener(labelFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.LabelScrollWheelListener=event.listener(labelFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

            overviewFigure.KeyPressFcn=@(~,~)deal();

            self.OverviewKeyPressListener=event.listener(overviewFigure,'WindowKeyPress',@(src,evt)keyPressed(self,evt));
            self.OverviewKeyReleaseListener=event.listener(overviewFigure,'WindowKeyRelease',@(src,evt)keyReleased(self,evt));
            self.OverviewScrollWheelListener=event.listener(overviewFigure,'WindowScrollWheel',@(src,evt)scrollWheel(self,evt));

        end

    end


    methods(Access=private)


        function keyPressed(self,evt)

            updateModifiers(self,evt);

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

            notify(self,'KeyPressed',images.internal.app.segmenter.volume.events.KeyPressedEventData(...
            key));

        end


        function keyReleased(self,evt)

            updateModifiers(self,evt);
            self.WasKeyAlreadyPressed=false;

        end


        function scrollWheel(self,evt)

            if~self.Enabled
                return;
            end

            notify(self,'ScrollWheelSpun',images.internal.app.segmenter.volume.events.ScrollWheelSpunEventData(...
            evt.VerticalScrollCount));

        end


        function sliceClicked(self,evt)

            notify(self,'WindowClicked',images.internal.app.segmenter.volume.events.WindowClickedEventData(...
            images.roi.internal.getClickType(evt.Source)));

        end


        function updateModifiers(self,evt)

            self.CtrlPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'control'));
            self.ShiftPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'shift'));
            self.AltPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'alt'));
            self.CtrlAPressed=false;

        end

    end


end