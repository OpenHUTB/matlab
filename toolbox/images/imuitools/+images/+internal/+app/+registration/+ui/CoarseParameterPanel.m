classdef CoarseParameterPanel<images.internal.app.registration.ui.ParameterPanel





    properties(GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.ui.DocumentArea})
hBlurSlider
hNormalize
hApplyBlur
hAlignCenters
    end

    properties(Access=private)
hNormalizeLabel
hApplyBlurLabel
hAlignCentersLabel
    end

    properties
        Normalize=false;
        ApplyBlur=false;
        AlignCenters='geometric';
    end

    methods

        function self=CoarseParameterPanel(hParent)

            import images.internal.app.registration.ui.*;

            self.PanelHeight=92;

            self.setupParameterPanel(hParent,getMessageString('preprocessing'),'preprocessing')

            self.setupCoarseComponents();

        end

        function setupCoarseComponents(self)

            import images.internal.app.registration.ui.*;

            pos=get(self.BodyPanel,'Position');
            border=2;
            height=20;

            newpos=[10,pos(4)-height-border,height,height];
            labelpos=[10+height+border,pos(4)-height-border,pos(3)-(2*height)-border-10,height-3];


            self.hNormalize=uicheckbox(...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Tag','NormalizeCheck',...
            'Text','',...
            'Tooltip',getMessageString('normalizeTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.normalizeCallback(hobj,evt));

            self.hNormalizeLabel=uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('normalize'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(2*height)-(2*border);
            labelpos=[10+height+border,newpos(2),pos(3)-(2*height)-border-10,height-3];


            self.hApplyBlur=uicheckbox(...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Tag','ApplyBlurCheck',...
            'Text','',...
            'Tooltip',getMessageString('applyBlurTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.applyBlurCallback(hobj,evt));

            self.hApplyBlurLabel=uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('applyBlur'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(2.5*height)-(3*border);
            newpos(3)=8*height;

            self.hBlurSlider=uislider('Parent',self.BodyPanel,...
            'Value',0.5,...
            'Position',[newpos(1:3),3],...
            'Visible','on',...
            'Limits',[0,1],...
            'MajorTicks',[],...
            'MinorTicks',[],...
            'ValueChangedFcn',@(~,~)updateSettings(self));

            newpos=[10,pos(4)-(4*height)-(3*border),5*height,height];
            labelpos=[10+(5*height)+border,pos(4)-(4*height)-(3*border),pos(3)-(5*height)-border-10,height-3];


            self.hAlignCenters=uidropdown(...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Items',{'Geometric','Center of Mass'},...
            'ItemsData',[1,2],...
            'Value',1,...
            'Tag','AlignCenters',...
            'Tooltip',getMessageString('alignCentersTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.alignCentersCallback(hobj,evt),...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            self.hAlignCentersLabel=uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('alignCenters'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

        end

        function normalizeCallback(self,~,evt)
            self.Normalize=evt.Source.Value;
            self.updateSettings();
        end

        function applyBlurCallback(self,~,evt)
            self.ApplyBlur=evt.Source.Value;
            self.updateSettings();
        end

        function alignCentersCallback(self,~,evt)
            self.AlignCenters=evt.Source.Items{evt.Source.Value};
            self.updateSettings();
        end

    end

    methods

        function set.Normalize(self,TF)
            set(self.hNormalize,'Value',TF);%#ok<MCSUP>
            self.Normalize=TF;
        end

        function set.ApplyBlur(self,TF)
            set(self.hApplyBlur,'Value',TF);%#ok<MCSUP>
            self.hBlurSlider.Enable=TF;%#ok<MCSUP>
            self.ApplyBlur=TF;
        end

        function set.AlignCenters(self,inputString)
            idx=find(strcmpi({'Geometric','Center of Mass'},inputString));
            set(self.hAlignCenters,'Value',idx);%#ok<MCSUP>
            self.AlignCenters=lower(inputString);
        end

    end

end
