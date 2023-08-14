classdef Key<handle&matlab.mixin.SetGet





    properties(Access=private)

AppHandle

    end

    properties(SetAccess=private,Hidden,Transient)

        CtrlPressed(1,1)logical=false;

    end


    methods




        function self=Key(AppHandle,labelFigure)

            self.AppHandle=AppHandle;
            labelFigure.KeyPressFcn=@(~,~)deal();
            labelFigure.WindowKeyPressFcn=@(src,evt)keyPressed(self,evt);
            labelFigure.WindowKeyReleaseFcn=@(src,evt)keyReleased(self,evt);
            labelFigure.WindowScrollWheelFcn=@(src,evt)scrollWheel(self,evt);

        end

    end


    methods(Access=private)


        function keyPressed(self,evt)
            self.CtrlPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'control'));

            if~self.CtrlPressed
                switch evt.Key
                case 'downarrow'
                    down(self.AppHandle.SubarrayLabels);
                case 'uparrow'
                    up(self.AppHandle.SubarrayLabels);
                case 'delete'
                    deleteobj=self.AppHandle.SubarrayLabels.Entries(self.AppHandle.SubarrayLabels.Current);
                    if isequal(deleteobj.DeleteBtnUI.Enable,'on')
                        removeLabel(self.AppHandle.SubarrayLabels,deleteobj.Name)
                    end
                otherwise
                    return;
                end
            else

                switch evt.Key
                case 'y'
                    elementRedo(self.AppHandle.SubarrayLabels);
                case 'z'
                    elementUndo(self.AppHandle.SubarrayLabels);
                otherwise
                    return;
                end
            end
        end


        function keyReleased(self,evt)
            self.CtrlPressed=~isempty(evt.Modifier)&&any(strcmp(evt.Modifier,'control'));

        end


        function scrollWheel(self,evt)
            scroll(self.AppHandle.SubarrayLabels,evt.VerticalScrollCount);
        end

    end

end