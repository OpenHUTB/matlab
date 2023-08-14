classdef PhaseParameterPanel<images.internal.app.registration.ui.ParameterPanel





    properties(GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.ui.DocumentArea})
hTransformType
hWindow
        TformList={'Similarity','Rigid','Translation'};
    end

    properties
        Tform='similarity';
        Window=true;
    end

    methods

        function self=PhaseParameterPanel(hParent)

            import images.internal.app.registration.ui.*;

            self.PanelHeight=46;

            self.setupParameterPanel(hParent,getMessageString('phaseParameters'),'phaseParameters')

            self.setupPhaseComponents();

        end

        function setupPhaseComponents(self)

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
            'Tag','PhaseTransformType',...
            'Tooltip',getMessageString('tformTypeTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.tformCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('tformType'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(3)=height;
            newpos(2)=pos(4)-(2*height)-(2*border);
            labelpos=[10+(4*height)+border,newpos(2),pos(3)-(4*height)-border-10,height-3];

            self.hWindow=uicheckbox(...
            'Parent',self.BodyPanel,...
            'Value',1,...
            'Position',newpos,...
            'Tag','PhaseWindow',...
            'Text','',...
            'Tooltip',getMessageString('windowingTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.windowCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('windowing'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

        end

        function tformCallback(self,~,evt)
            self.Tform=evt.Source.Items{evt.Source.Value};
            self.updateSettings();
        end

        function windowCallback(self,~,evt)
            self.Window=evt.Source.Value;
            self.updateSettings();
        end

    end

    methods

        function set.Tform(self,inputString)
            idx=find(strcmpi(self.TformList,inputString));%#ok<MCSUP>
            set(self.hTransformType,'Value',idx);%#ok<MCSUP>
            self.Tform=lower(inputString);
        end

        function set.Window(self,TF)
            set(self.hWindow,'Value',TF);%#ok<MCSUP>
            self.Window=TF;
        end
    end

end
