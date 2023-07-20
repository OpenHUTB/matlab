classdef Parameters<handle



    properties
View
Layout
WaveformCharacteristics
        ElementDialog=[]
        LinearDialog=[]
        RectangularDialog=[]
        SteppedDialog=[]
        PhaseCodedDialog=[]
        FMCWDialog=[]
        WaveformChanged=0;
        NumSamplesLimit=10000
        NumSamplesLimit3D=1024
        PRFPRIIndex=0
        MatchedFilterDialog=[]
        StretchProcessorDialog=[]
        DechirpDialog=[]
        ProcessDialog=[]
        ProcessTypeChanged=0;
ApplyButton
ApplyPanel
    end

    properties(Dependent)
ElementType
ProcessType
    end

    methods
        function self=Parameters(view)
            if nargin==0
                view=figure;
            end
            self.View=view;
            self.ElementDialog=phased.apps.internal.WaveformViewer.RectangularDialog(self);
            self.ProcessDialog=phased.apps.internal.WaveformViewer.MatchedFilterDialog(self);
            self.ApplyButton=phased.apps.internal.WaveformViewer.ApplyButtonDialog(self);
            self.RectangularDialog=self.ElementDialog;
            self.WaveformCharacteristics=phased.apps.internal.WaveformViewer.WaveformCharacteristics(self);
            self.Layout=...
            matlabshared.application.layout.ScrollableGridBagLayout(...
            self.View.ParametersFig,...
            'VerticalGap',8,...
            'HorizontalGap',6,...
            'VerticalWeights',[0,0,0,1],...
            'HorizontalWeights',1);
            dummypanel=uipanel(...
            'Parent',self.View.ParametersFig,...
            'Title','',...
            'BorderType','line',...
            'Visible','off');
            add(self.Layout,self.ApplyButton.Panel,4,1,...
            'MinimumWidth',self.ApplyButton.Width,...
            'Fill','Horizontal',...
            'Anchor','North')
            add(self.Layout,self.ProcessDialog.Panel,3,1,...
            'MinimumWidth',self.ProcessDialog.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',self.ProcessDialog.Height,...
            'Anchor','North')
            add(self.Layout,self.ElementDialog.Panel,2,1,...
            'MinimumWidth',self.ElementDialog.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',self.ElementDialog.Height,...
            'Anchor','North')
            add(self.Layout,self.View.SampleRatePanel,1,1,...
            'MinimumWidth',self.ElementDialog.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',40,...
            'Anchor','North')
            add(self.Layout,dummypanel,1,2,...
            'Fill','Horizontal',...
            'Anchor','North')
            remove(self.Layout,1,2)
        end
        function set.ElementType(self,str)
            switch str
            case ''
                if~isempty(self.ElementDialog)
                    self.ElementDialog.Panel.Visible='off';
                    remove(self.Layout,2,1)
                    self.ElementDialog=[];
                end
                return
            case 'phased.apps.internal.WaveformViewer.LinearFMWaveform'
                if isempty(self.LinearDialog)
                    self.LinearDialog=...
                    phased.apps.internal.WaveformViewer.LinearFMDialog(self);
                end
                self.ElementDialog=self.LinearDialog;
            case 'phased.apps.internal.WaveformViewer.RectangularWaveform'
                if isempty(self.RectangularDialog)
                    self.RectangularDialog=...
                    phased.apps.internal.WaveformViewer.RectangularDialog(self);
                end
                self.ElementDialog=self.RectangularDialog;
            case 'phased.apps.internal.WaveformViewer.SteppedFMWaveform'
                if isempty(self.SteppedDialog)
                    self.SteppedDialog=...
                    phased.apps.internal.WaveformViewer.SteppedDialog(self);
                end
                self.ElementDialog=self.SteppedDialog;
            case 'phased.apps.internal.WaveformViewer.PhaseCodedWaveform'
                if isempty(self.PhaseCodedDialog)
                    self.PhaseCodedDialog=...
                    phased.apps.internal.WaveformViewer.PhaseCodedDialog(self);
                end
                self.ElementDialog=self.PhaseCodedDialog;

            case 'phased.apps.internal.WaveformViewer.FMCWWaveform'
                if isempty(self.FMCWDialog)
                    self.FMCWDialog=...
                    phased.apps.internal.WaveformViewer.FMCWDialog(self);
                end
                self.ElementDialog=self.FMCWDialog;
            end
            dummypanel=uipanel(...
            'Parent',self.View.ParametersFig,...
            'Title','',...
            'BorderType','line',...
            'Visible','off');
            add(self.Layout,self.ElementDialog.Panel,2,1,...
            'MinimumWidth',self.ElementDialog.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',self.ElementDialog.Height,...
            'Anchor','North')
            self.ElementDialog.Panel.Visible='on';
            add(self.Layout,dummypanel,1,2,...
            'Fill','Horizontal',...
            'Anchor','North')
            remove(self.Layout,1,2);
        end
        function str=get.ElementType(self)
            if isempty(self.ElementDialog)
                str='';
            else
                str=self.ElementDialog.Title.String;
            end
        end
        function set.ProcessType(self,str)
            switch str
            case ''
                if~isempty(self.ProcessDialog)
                    self.ProcessDialog.Panel.Visible='off';
                    remove(self.Layout,3,1)
                    self.ProcessDialog=[];
                end
                return
            case 'phased.apps.internal.WaveformViewer.MatchedFilter'
                if isempty(self.MatchedFilterDialog)
                    self.MatchedFilterDialog=...
                    phased.apps.internal.WaveformViewer.MatchedFilterDialog(self);
                end
                self.ProcessDialog=self.MatchedFilterDialog;
            case 'phased.apps.internal.WaveformViewer.StretchProcessor'
                if isempty(self.StretchProcessorDialog)
                    self.StretchProcessorDialog=...
                    phased.apps.internal.WaveformViewer.StretchProcessorDialog(self);
                end
                self.ProcessDialog=self.StretchProcessorDialog;
            case 'phased.apps.internal.WaveformViewer.Dechirp'
                if isempty(self.DechirpDialog)
                    self.DechirpDialog=...
                    phased.apps.internal.WaveformViewer.DechirpDialog(self);
                end
                self.ProcessDialog=self.DechirpDialog;
                self.ProcessDialog.Height=24;
            end
            dummypanel=uipanel(...
            'Parent',self.View.ParametersFig,...
            'Title','',...
            'BorderType','line',...
            'Visible','off');
            add(self.Layout,self.ProcessDialog.Panel,3,1,...
            'MinimumWidth',self.ProcessDialog.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',self.ProcessDialog.Height,...
            'Anchor','North')
            self.ProcessDialog.Panel.Visible='on';
            add(self.Layout,dummypanel,1,2,...
            'Fill','Horizontal',...
            'Anchor','North')
            remove(self.Layout,1,2);
        end
        function str=get.ProcessType(self)
            if isempty(self.ProcessDialog)
                str='';
            else
                str=self.ProcessDialog.ProcessType.String;
            end
        end
    end
    methods(Static)
        function addTitle(layout,uic,row,col,h,hspacing,vspacing)
            add(layout,uic,row,col,...
            'LeftInset',-hspacing,...
            'RightInset',-hspacing,...
            'TopInset',-vspacing,...
            'MinimumHeight',h,...
            'MaximumHeight',h,...
            'Fill','Horizontal')
        end
        function addText(layout,uic,row,col,w,h)
            textInset=5;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'MinimumHeight',h-textInset,...
            'TopInset',textInset)
        end
        function addEdit(layout,uic,row,col,w,h)
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'Fill','Horizontal',...
            'MinimumHeight',h)
        end
        function remove(layout,row,col)
            remove(layout,row,col)
        end
        function addPopup(layout,uic,row,col,w,h)
            popupInset=0;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'Fill','Horizontal',...
            'MinimumHeight',h-popupInset,...
            'TopInset',popupInset)
        end
        function addButton(layout,uic,row,col,w,h)
            popupInset=-2;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'MinimumHeight',h-popupInset,...
            'TopInset',popupInset)
        end
    end

    methods
        function elementParameterInvalid(self,data)
            self.ElementDialog.(data.Name)=data.Value;
        end
        function compressParameterInvalid(self,data)
            self.ProcessDialog.(data.Name)=data.Value;
        end

    end
    events
SystemParameterView
SystemParameterChanged
ElementParameterChanged
ElementParameterView
MultiSelectElementParameterView
MultiSelectCompressParameterView
SystemCompressionView
CompressParameterView
CompressParameterChanged
    end
end
