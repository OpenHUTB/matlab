classdef MonomodalParameterPanel<images.internal.app.registration.ui.ParameterPanel





    properties(GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.ui.DocumentArea})
hTransformType
hGradMagTol
hMinStepLength
hMaxStepLength
hMaxIterations
hRelaxFactor
hPyramidLevels
        TformList={'Similarity','Affine','Rigid','Translation'};
    end

    properties
        Tform='similarity';
        GradMagTol=1e-4;
        MinStepLength=1e-5;
        MaxStepLength=0.0625;
        MaxIterations=100;
        RelaxFactor=0.5;
        PyramidLevels=3;
HelpPanel
    end

    methods

        function self=MonomodalParameterPanel(hParent)

            import images.internal.app.registration.ui.*;

            self.PanelHeight=168;

            self.setupParameterPanel(hParent,getMessageString('intensityParameters'),'intensityParameters')

            self.setupMonomodalComponents();

        end

        function setupMonomodalComponents(self)

            import images.internal.app.registration.ui.*;

            pos=get(self.BodyPanel,'Position');
            border=2;
            height=20;

            newpos=[10,pos(4)-height,5*height,height];
            labelpos=[10+(5*height)+border,pos(4)-height,pos(3)-(5*height)-border-10,height-3];

            self.hTransformType=uidropdown(...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Items',self.TformList,...
            'ItemsData',1:numel(self.TformList),...
            'Value',1,...
            'Tag','MonoTransformType',...
            'Tooltip',getMessageString('tformTypeTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.tformCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('tformType'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(2*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(2*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hGradMagTol=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.GradMagTol,...
            'Tag','GradMagTol',...
            'Tooltip',getMessageString('gradMagTolTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.gradMagTolCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('gradMagTol'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(3*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(3*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hMinStepLength=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.MinStepLength,...
            'Tag','MinStepLength',...
            'Tooltip',getMessageString('minStepLengthTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.minStepCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('minStepLength'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(4*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(4*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hMaxStepLength=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.MaxStepLength,...
            'Tag','MaxStepLength',...
            'Tooltip',getMessageString('maxStepLengthTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.maxStepCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('maxStepLength'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(5*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(5*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hMaxIterations=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.MaxIterations,...
            'Tag','MonoMaxIterations',...
            'RoundFractionalValues','on',...
            'Tooltip',getMessageString('maxIterTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.maxIterCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('maxIter'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(6*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(6*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hRelaxFactor=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.RelaxFactor,...
            'Tag','RelaxFactor',...
            'Tooltip',getMessageString('relaxFactorTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.relaxFactorCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('relaxFactor'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos=[10,pos(4)-(7*(height+border)),3*height,height];
            labelpos=[10+(3*height)+border,pos(4)-(7*(height+border)),pos(3)-(3*height)-border-10,height-3];

            self.hPyramidLevels=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.PyramidLevels,...
            'Tag','MonoPyramidLevels',...
            'RoundFractionalValues','on',...
            'Tooltip',getMessageString('pyramidLevelsTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.pyramidCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('pyramidLevels'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            bodyPos=get(self.BodyPanel,'Position');
            pos=[bodyPos(3)-18,3,16,16];

            helpImage=uiimage('Parent',self.BodyPanel,...
            'Position',pos,...
            'ScaleMethod','fill',...
            'ImageSource',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Help_16.png'));

            addlistener(helpImage,'ImageClicked',@(~,~)helpCallback());

        end

        function tformCallback(self,~,evt)
            self.Tform=evt.Source.Items{evt.Source.Value};
            self.updateSettings();
        end

        function gradMagTolCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.GradMagTol=inputVal;
                self.updateSettings();
            else
                self.hGradMagTol.Value=evt.PreviousValue;
            end
        end

        function minStepCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.MinStepLength=inputVal;
                self.updateSettings();
            else
                self.hMinStepLength.Value=evt.PreviousValue;
            end
        end

        function maxStepCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.MaxStepLength=inputVal;
                self.updateSettings();
            else
                self.hMaxStepLength.Value=evt.PreviousValue;
            end
        end

        function maxIterCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.MaxIterations=inputVal;
                self.updateSettings();
            else
                self.hMaxIterations.Value=evt.PreviousValue;
            end
        end

        function relaxFactorCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0&&inputVal<1
                self.RelaxFactor=inputVal;
                self.updateSettings();
            else
                self.hRelaxFactor.Value=evt.PreviousValue;
            end
        end

        function pyramidCallback(self,~,evt)
            inputVal=evt.Source.Value;
            if self.validateSettings(inputVal)&&inputVal>0
                self.PyramidLevels=inputVal;
                self.updateSettings();
            else
                self.hPyramidLevels.Value=evt.PreviousValue;
            end
        end

    end

    methods

        function set.Tform(self,inputString)
            idx=find(strcmpi(self.TformList,inputString));%#ok<MCSUP>
            set(self.hTransformType,'Value',idx);%#ok<MCSUP>
            self.Tform=lower(inputString);
        end

        function set.GradMagTol(self,inputVal)
            set(self.hGradMagTol,'Value',inputVal);%#ok<MCSUP>
            self.GradMagTol=inputVal;
        end

        function set.MinStepLength(self,inputVal)
            set(self.hMinStepLength,'Value',inputVal);%#ok<MCSUP>
            self.MinStepLength=inputVal;
        end

        function set.MaxStepLength(self,inputVal)
            set(self.hMaxStepLength,'Value',inputVal);%#ok<MCSUP>
            self.MaxStepLength=inputVal;
        end

        function set.MaxIterations(self,inputVal)
            set(self.hMaxIterations,'Value',inputVal);%#ok<MCSUP>
            self.MaxIterations=inputVal;
        end

        function set.RelaxFactor(self,inputVal)
            set(self.hRelaxFactor,'Value',inputVal);%#ok<MCSUP>
            self.RelaxFactor=inputVal;
        end

        function set.PyramidLevels(self,inputVal)
            set(self.hPyramidLevels,'Value',inputVal);%#ok<MCSUP>
            self.PyramidLevels=inputVal;
        end

    end

end

function helpCallback()
    doc registration.optimizer.RegularStepGradientDescent;
end
