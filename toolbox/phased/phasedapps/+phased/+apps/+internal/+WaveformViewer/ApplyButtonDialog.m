classdef ApplyButtonDialog<handle



    properties
Parent
Layout
Panel
ApplyButton
        Width=0
        Height=0
Listeners
    end
    methods
        function self=ApplyButtonDialog(parent)

            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
        end
    end
    methods(Access=private)
        function createUIControls(self)

            if~self.Parent.View.Toolstrip.IsAppContainer
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','none',...
                'HighlightColor',[.5,.5,.5],...
                'AutoResizeChildren','off',...
                'Visible','on');
            else
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','none',...
                'AutoResizeChildren','off',...
                'Visible','on');
            end
            Icon=load(fullfile(matlabroot,'toolbox','phased','phasedapps',...
            '+phased','+apps','+internal','+WaveformViewer','ApplyIcon.mat'));

            self.ApplyButton=uicontrol(...
            'Parent',self.Panel,...
            'Style','pushbutton',...
            'Units','char',...
            'FontUnits','normalized',...
            'FontWeight','bold',...
            'FontSize',.80,...
            'CData',Icon.confirm16,...
            'Tag','ApplyButton',...
            'TooltipString',getString(message('phased:apps:waveformapp:Apply')),...
            'Enable','off',...
            'Callback',@(h,e)applyCallback(self));
        end
        function layoutUIControls(self)
            hspacing=0;
            vspacing=1;

            self.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            self.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[0,1,0]);
            w2=75;
            row=1;
            height=24;
            self.Parent.addButton(self.Layout,self.ApplyButton,row,3,w2-35,height-5)
            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
        end
        function applyCallback(self)
            self.Parent.View.Canvas.AutoSelect=false;
            if numel(self.Parent.View.Canvas.WaveformList.getSelectedRows())>1
                idx=self.Parent.View.Canvas.WaveformList.getSelectedRows();
                self.Parent.notify('ElementParameterChanged',phased.apps.internal.WaveformViewer.ElementParameterChangedEventData(idx))
            else
                idx=self.Parent.View.Canvas.SelectIdx;
                value=self.Parent.ElementDialog.Waveform;
                k=numel(self.Parent.View.Canvas.WaveformList.Data);
                if~self.Parent.View.Toolstrip.IsAppContainer
                    if k~=0
                        self.Parent.View.Canvas.WaveformList.Data{idx,2}=self.Parent.ElementDialog.Waveform;
                        if(strcmp(self.Parent.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM'))))
                            self.Parent.View.Canvas.WaveformList.Data{idx,3}=self.Parent.ProcessDialog.ProcessTypeEdit.String{self.Parent.ProcessDialog.ProcessTypeEdit.Value};
                        else
                            self.Parent.View.Canvas.WaveformList.Data{idx,3}=self.Parent.ProcessDialog.ProcessTypeEdit.String;
                        end
                        self.Parent.View.Canvas.WaveformList.updateUI();
                        self.Parent.View.Canvas.WaveformList.setRowSelection(idx);
                    end
                else
                    waveformName=self.Parent.View.Canvas.WaveformList.Table.Data{idx,1};
                    if k~=0
                        waveform=self.Parent.ElementDialog.Waveform;
                        waveform=strrep(waveform,' ','');
                        if(strcmp(self.Parent.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM'))))
                            rangeProcessing=self.Parent.ProcessDialog.ProcessTypeEdit.String{self.Parent.ProcessDialog.ProcessTypeEdit.Value};
                        else
                            rangeProcessing=self.Parent.ProcessDialog.ProcessTypeEdit.String;
                        end
                        rangeProcessing=strrep(rangeProcessing,' ','');
                        data={waveformName,waveform,rangeProcessing};

                        self.Parent.View.Canvas.WaveformList.Data(idx,:)=data;

                        self.Parent.View.Canvas.WaveformList.updateUI();
                        self.Parent.View.Canvas.WaveformList.qeSelect(idx);
                    end
                end
                if self.Parent.View.Parameters.WaveformChanged==1
                    name=self.Parent.View.Canvas.WaveformList.Data{idx,1};
                    SR=str2num(self.Parent.View.SampleRateEdit.String);%#ok<*ST2NM>
                    self.Parent.notify('SystemParameterChanged',phased.apps.internal.WaveformViewer.SystemParameterChangedEventData(idx,value,name,SR))
                end
                self.Parent.View.Parameters.WaveformChanged=0;
                self.Parent.notify('ElementParameterChanged',phased.apps.internal.WaveformViewer.ElementParameterChangedEventData(idx))
            end
            self.Parent.notify('CompressParameterChanged',phased.apps.internal.WaveformViewer.CompressParameterChangedEventData(idx))
            self.Parent.View.Canvas.AutoSelect=true;

            titleUpdate(self.Parent.View);
        end
    end
end