classdef DechirpDialog<handle

    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
    end
    properties(Dependent)
ProcessType
    end
    properties
ProcessTypeLabel
ProcessTypeEdit
Title
AddButton
DeleteButton
    end
    methods
        function self=DechirpDialog(parent)
            if nargin==0
                parent=figure;
            end
            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
        end
    end
    methods
        function val=get.ProcessType(self)
            val=self.ProcessTypeEdit.String;
        end
        function set.ProcessType(self,val)
            self.ProcessTypeEdit.String=val;
        end
    end
    methods(Access=private)
        function createUIControls(self)

            if~self.Parent.View.Toolstrip.IsAppContainer
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','line',...
                'HighlightColor',[.5,.5,.5],...
                'AutoResizeChildren','off',...
                'Visible','on');
            else
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','line',...
                'AutoResizeChildren','off',...
                'Visible','on');
            end
            self.ProcessTypeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:ProcessTypeLabel')),...
            'HorizontalAlignment','right');
            self.ProcessTypeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',getString(message('phased:apps:waveformapp:Dechirp')),...
            'Tag','ProcessType',...
            'HorizontalAlignment','left');
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.ProcessTypeEdit))
        end

        function layoutUIControls(self)
            hspacing=0;
            vspacing=1;

            self.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            self.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[0,1,0]);
            if isunix
                w1=140;
            else
                w1=130;
            end
            w2=75;
            rowParam=1;
            height=24;
            self.Parent.addText(self.Layout,self.ProcessTypeLabel,rowParam,1,w1,height)
            self.Parent.addText(self.Layout,self.ProcessTypeEdit,rowParam,2:3,w2,height)
            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
        end
    end
end
