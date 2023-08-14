classdef MouseBehaviour<handle




    properties
        MB_DoubleClickPress=0
        MB_RightMousePress=0
        MB_LeftMousePress=0
        MB_DragMotion=0
MB_ParentFig
MB_Listeners
        MB_leftClick=0;
MB_leftButtonDownEvt
MB_leftButtonUpEvt
MB_rightButtonDownEvt
MB_rightButtonUpEvt
MB_MotionEvt
    end
    methods
        function initializeMouseBehaviour(self)
            self.MB_ParentFig=getFigure(self);
            MB_addListeners(self)
        end

        function set.MB_DragMotion(self,val)
            self.MB_DragMotion=val;
        end

        function MB_addListeners(self)
            self.MB_Listeners.MousePress=addlistener(self.MB_ParentFig,'WindowMousePress',...
            @(src,evt)self.notifyClickDrag(src,evt));
            self.MB_Listeners.MouseRelease=addlistener(self.MB_ParentFig,'WindowMouseRelease',...
            @(src,evt)self.notifyClickDrag(src,evt));
            self.MB_Listeners.DragMotion=addlistener(self.MB_ParentFig,'WindowMouseMotion',...
            @(src,evt)self.notifyClickDrag(src,evt));
        end
        function notifyClickDrag(self,src,evt)
            if~isvalid(self)
                return;
            end

            switch evt.EventName
            case 'WindowMousePress'
                if strcmpi(self.MB_ParentFig.SelectionType,'normal')
                    self.MB_LeftMousePress=1;
                    self.MB_leftButtonDownEvt=evt;
                elseif strcmpi(self.MB_ParentFig.SelectionType,'alt')
                    self.MB_RightMousePress=1;
                    self.MB_rightButtonDownEvt=evt;
                elseif strcmpi(self.MB_ParentFig.SelectionType,'open')
                    self.MB_DoubleClickPress=1;
                end
            case 'WindowMouseRelease'
                if strcmpi(self.MB_ParentFig.SelectionType,'normal')
                    self.MB_leftButtonUpEvt=evt;
                    if self.MB_DragMotion
                        self.MB_LeftMousePress=0;
                        self.MB_DragMotion=0;
                        self.notify('DragEnded',self.MB_leftButtonUpEvt)
                        self.dragEnded(self.MB_leftButtonDownEvt,self.MB_leftButtonUpEvt);
                    else
                        self.MB_LeftMousePress=0;
                        self.notify('LeftClick',self.MB_leftButtonUpEvt)
                        self.leftClick(self.MB_leftButtonUpEvt);
                    end


                elseif strcmpi(self.MB_ParentFig.SelectionType,'alt')
                    self.MB_rightButtonUpEvt=evt;
                    self.MB_RightMousePress=0;
                    self.MB_DragMotion=0;

                    self.rightClick(self.MB_rightButtonUpEvt);
                elseif strcmpi(self.MB_ParentFig.SelectionType,'open')
                    self.MB_leftButtonUpEvt=evt;
                    self.MB_DoubleClickPress=0;
                    self.MB_DragMotion=0;

                    self.doubleClick(self.MB_leftButtonUpEvt);
                end
            case 'WindowMouseMotion'
                if any(isnan(evt.IntersectionPoint))
                    return;
                end
                self.MB_MotionEvt=evt;
                if self.MB_LeftMousePress
                    if~self.MB_DragMotion
                        self.notify('DragStarted',self.MB_MotionEvt)
                        self.MB_DragMotion=1;
                        self.dragStarted(self.MB_leftButtonDownEvt,self.MB_MotionEvt);
                    else
                        self.notify('Drag',self.MB_MotionEvt)
                        self.drag(self.MB_leftButtonDownEvt,self.MB_MotionEvt);
                    end

                else
                    self.notify('Hover',self.MB_MotionEvt);
                    self.hover(self.MB_MotionEvt);
                end
            end
            function hover(self,evt)
            end
            function rightClick(self,evt)
            end

            function leftClick(self,evt)
            end

            function doubleClick(self,evt)
            end

            function dragStarted(self,evt1,evt2)
            end

            function dragEnded(self,evt1,evt2)
            end

            function drag(self,evt1,evt2)

            end
        end
    end
    events
DoubleClick
LeftClick
RightClick
DragStarted
DragEnded
Drag
Hover
    end
end
