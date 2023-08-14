classdef NonrigidParameterPanel<images.internal.app.registration.ui.ParameterPanel





    properties(GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.ui.DocumentArea})
hNonrigidToggle
hPyramidLevels
hIterations
hSmoothing
    end

    properties(Access=public)
        NonrigidSelected=false;
        Iterations=100;
        PyramidLevels=3;
        Smoothing=1.0;
    end

    methods

        function self=NonrigidParameterPanel(hParent,checkboxFlag)

            import images.internal.app.registration.ui.*;

            if checkboxFlag
                self.PanelHeight=92;
                self.PanelSelected=false;
                self.setupParameterPanel(hParent,getMessageString('postprocessing'),'postprocessing')
            else
                self.PanelHeight=70;
                self.NonrigidSelected=true;
                self.setupParameterPanel(hParent,getMessageString('nonrigidParameters'),'nonrigidParameters')
            end

            self.setupNonrigidComponents(checkboxFlag);

        end

        function setupNonrigidComponents(self,checkboxFlag)

            import images.internal.app.registration.ui.*;

            pos=get(self.BodyPanel,'Position');
            border=2;
            height=20;
            idx=1;

            newpos=[10,pos(4)-height-border,height,height];
            labelpos=[10+(2*height)+border,pos(4)-height-border,pos(3)-(2*height)-border-10,height-3];
            tags='Only';


            if checkboxFlag
                tags='';
                idx=idx+1;
                self.hNonrigidToggle=uicheckbox(...
                'Parent',self.BodyPanel,...
                'Position',newpos,...
                'Tag',['Nonrigid',tags,'Apply'],...
                'Text','',...
                'Tooltip',getMessageString('applyNonrigidTooltip'),...
                'ValueChangedFcn',@(hobj,evt)self.nonrigidCallback(hobj,evt));

                uilabel('Parent',self.BodyPanel,...
                'Text',getMessageString('applyNonrigid'),...
                'Position',labelpos,...
                'Visible','on',...
                'VerticalAlignment','top',...
                'FontName',self.FontName,...
                'FontSize',self.FontSize);
            end


            newpos(2)=pos(4)-(idx*height)-(idx*border);
            labelpos(2)=newpos(2);
            newpos(3)=2*height;

            self.hIterations=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.Iterations,...
            'Enable','off',...
            'RoundFractionalValues','on',...
            'Tag',['Nonrigid',tags,'Iterations'],...
            'Tooltip',getMessageString('numIterTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.iterationCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('numIter'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);


            idx=idx+1;
            newpos(2)=pos(4)-(idx*height)-(idx*border);
            labelpos(2)=newpos(2);

            self.hPyramidLevels=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.PyramidLevels,...
            'Enable','off',...
            'RoundFractionalValues','on',...
            'Tag',['Nonrigid',tags,'PyramidLevels'],...
            'Tooltip',getMessageString('pyramidLevelsTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.pyramidCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('pyramidLevels'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);


            idx=idx+1;
            newpos(2)=pos(4)-(idx*height)-(idx*border);
            labelpos(2)=newpos(2);

            self.hSmoothing=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.Smoothing,...
            'Enable','off',...
            'Tag',['Nonrigid',tags,'Smoothing'],...
            'Tooltip',getMessageString('smoothingTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.smoothingCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('smoothing'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            if~checkboxFlag
                set(self.hIterations,'Enable','on')
                set(self.hPyramidLevels,'Enable','on')
                set(self.hSmoothing,'Enable','on')
            end


        end

        function nonrigidCallback(self,~,evt)
            self.NonrigidSelected=evt.Value;
            self.updateSettings();
        end

        function iterationCallback(self,~,evt)
            inputVal=evt.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.Iterations=inputVal;
                if self.NonrigidSelected
                    self.updateSettings();
                end
            else
                self.hIterations.Value=evt.PreviousValue;
            end
        end

        function pyramidCallback(self,~,evt)
            inputVal=evt.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.PyramidLevels=inputVal;
                if self.NonrigidSelected
                    self.updateSettings();
                end
            else
                self.hPyramidLevels.Value=evt.PreviousValue;
            end
        end

        function smoothingCallback(self,~,evt)
            inputVal=evt.Value;
            if self.validateSettings(inputVal)&&inputVal>=0.5&&inputVal<=3.0
                self.Smoothing=inputVal;
                if self.NonrigidSelected
                    self.updateSettings();
                end
            else
                self.hSmoothing.Value=evt.PreviousValue;
            end
        end

        function enableNonrigidOptions(self,TF)
            if TF
                status='on';
            else
                status='off';
            end
            set(self.hSmoothing,'Enable',status)
            set(self.hPyramidLevels,'Enable',status)
            set(self.hIterations,'Enable',status)
        end

    end

    methods

        function set.NonrigidSelected(self,inputVal)
            self.enableNonrigidOptions(inputVal)
            set(self.hNonrigidToggle,'Value',inputVal);%#ok<MCSUP>
            self.NonrigidSelected=inputVal;
        end

        function set.Iterations(self,inputVal)
            set(self.hIterations,'Value',inputVal);%#ok<MCSUP>
            self.Iterations=inputVal;
        end

        function set.PyramidLevels(self,inputVal)
            set(self.hPyramidLevels,'Value',inputVal);%#ok<MCSUP>
            self.PyramidLevels=inputVal;
        end

        function set.Smoothing(self,inputVal)
            set(self.hSmoothing,'Value',inputVal);%#ok<MCSUP>
            self.Smoothing=inputVal;
        end

    end

end

