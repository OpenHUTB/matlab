classdef Canvas<handle

    properties(Hidden)
View
Figure
Layout
WaveformList
        AutoSelect=true
        RectNum=0;
        LinearNum=0;
        StepNum=0;
        PCNum=0;
        FMCWNum=0;
    end
    properties(Hidden)
        SelectIdx=[]
        InsertIdx=1
    end

    methods
        function self=Canvas(parent)
            self.View=parent;
            self.Figure=self.View.ParametersFig;
            createCanvas(self);
        end
        function selectElement(self,Wave)


            self.AutoSelect=false;
            self.View.Parameters.ElementType=class(Wave);
            dlg=self.View.Parameters.ElementDialog;
            WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Wave));
            switch WaveformType
            case 'LinearFMWaveform'
                dlg.Waveform=getString(message('phased:apps:waveformapp:LinearFM'));
                dlg.NumPulses=Wave.NumPulses;
                dlg.PRF=Wave.PRF;
                dlg.FrequencyOffset=Wave.FrequencyOffset;
                dlg.PropagationSpeed=Wave.PropagationSpeed;
                dlg.PulseWidth=Wave.PulseWidth;
                dlg.SweepBandwidth=Wave.SweepBandwidth;
                dlg.SweepDirection=Wave.SweepDirection;
                dlg.SweepInterval=Wave.SweepInterval;
                dlg.Envelope=Wave.Envelope;
            case 'RectangularWaveform'
                dlg.Waveform=getString(message('phased:apps:waveformapp:Rectangular'));
                dlg.NumPulses=Wave.NumPulses;
                dlg.PRF=Wave.PRF;
                dlg.FrequencyOffset=Wave.FrequencyOffset;
                dlg.PropagationSpeed=Wave.PropagationSpeed;
                dlg.PulseWidth=Wave.PulseWidth;
            case 'SteppedFMWaveform'
                dlg.Waveform=getString(message('phased:apps:waveformapp:SteppedFM'));
                dlg.NumPulses=Wave.NumPulses;
                dlg.PRF=Wave.PRF;
                dlg.FrequencyOffset=Wave.FrequencyOffset;
                dlg.PropagationSpeed=Wave.PropagationSpeed;
                dlg.PulseWidth=Wave.PulseWidth;
                dlg.FrequencyStep=Wave.FrequencyStep;
                dlg.NumSteps=Wave.NumSteps;
            case 'PhaseCodedWaveform'
                dlg.Waveform=getString(message('phased:apps:waveformapp:PhaseCoded'));
                dlg.NumPulses=Wave.NumPulses;
                dlg.PRF=Wave.PRF;
                dlg.FrequencyOffset=Wave.FrequencyOffset;
                dlg.PropagationSpeed=Wave.PropagationSpeed;
                dlg.Code=Wave.Code;
                dlg.ChipWidth=Wave.ChipWidth;
                dlg.NumChips=Wave.NumChips;
                dlg.SequenceIndex=Wave.SequenceIndex;

                if~strcmp(dlg.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))&&numel(self.View.Parameters.ElementDialog.Layout.Grid)/3==9
                    remove(self.View.Parameters.ElementDialog.Layout,9,1);
                    remove(self.View.Parameters.ElementDialog.Layout,9,2);
                    self.View.Parameters.ElementDialog.SequenceIndexLabel.Visible='off';
                    self.View.Parameters.ElementDialog.SequenceIndexEdit.Visible='off';
                elseif strcmp(dlg.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                    self.View.Parameters.ElementDialog.SequenceIndexLabel.Visible='on';
                    self.View.Parameters.ElementDialog.SequenceIndexEdit.Visible='on';
                    self.View.Parameters.addText(self.View.Parameters.ElementDialog.Layout,self.View.Parameters.ElementDialog.SequenceIndexLabel,9,1,123,24)
                    self.View.Parameters.addEdit(self.View.Parameters.ElementDialog.Layout,self.View.Parameters.ElementDialog.SequenceIndexEdit,9,2,80,24)

                end
            case 'FMCWWaveform'
                dlg.Waveform=getString(message('phased:apps:waveformapp:FMCW'));
                dlg.NumSweeps=Wave.NumSweeps;
                dlg.SweepTime=Wave.SweepTime;
                dlg.SweepBandwidth=Wave.SweepBandwidth;
                dlg.SweepDirection=Wave.SweepDirection;
                dlg.SweepInterval=Wave.SweepInterval;
                dlg.PropagationSpeed=Wave.PropagationSpeed;
            end
            self.View.SampleRateEdit.String=num2str(Wave.SampleRate);
            self.AutoSelect=true;
        end
        function selectProcess(self,Process)


            self.AutoSelect=false;
            self.View.Parameters.ProcessType=class(Process);
            dlg=self.View.Parameters.ProcessDialog;
            ProcessType=phased.apps.internal.WaveformViewer.getWaveformString(class(Process));
            if(strcmp(self.View.Parameters.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM'))))
                dlg.ProcessTypeEdit.Style='popupmenu';
                dlg.ProcessTypeEdit.String={getString(message('phased:apps:waveformapp:MatchedFilter')),getString(message('phased:apps:waveformapp:StretchProcessor'))};
                if strcmp(ProcessType,'MatchedFilter')
                    dlg.ProcessTypeEdit.Value=1;
                else
                    dlg.ProcessTypeEdit.Value=2;
                end
            else
                dlg.ProcessTypeEdit.Style='text';
            end
            switch ProcessType
            case 'MatchedFilter'
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=true;
                if(strcmp(self.View.Parameters.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM'))))
                    dlg.ProcessTypeEdit.Value=1;
                    dlg.ProcessTypeEdit.String{dlg.ProcessTypeEdit.Value}=getString(message('phased:apps:waveformapp:MatchedFilter'));
                else
                    dlg.ProcessTypeEdit.String=getString(message('phased:apps:waveformapp:MatchedFilter'));
                end
                dlg.SpectrumWindow=Process.SpectrumWindow;
                hspacing=1;
                vspacing=2;
                dlg.Layout=...
                matlabshared.application.layout.GridBagLayout(...
                dlg.Panel,...
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
                if strcmp(dlg.Parent.ElementDialog.Waveform,'Linear FM')
                    dlg.Parent.addText(dlg.Layout,dlg.ProcessTypeLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.ProcessTypeEdit,rowParam,2:3,w2,height)
                else
                    dlg.Parent.addText(dlg.Layout,dlg.ProcessTypeLabel,rowParam,1,w1,height)
                    dlg.Parent.addText(dlg.Layout,dlg.ProcessTypeEdit,rowParam,2:3,w2+40,height)
                end
                switch Process.SpectrumWindow
                case 'Taylor'

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumWindowLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.SpectrumWindowEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumRangeLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SpectrumRangeEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SideLobeAttenuationLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SideLobeAttenuationEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.NbarLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.NbarEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='on';
                    dlg.SideLobeAttenuationEdit.Visible='on';
                    dlg.SideLobeAttenuation=Process.SideLobeAttenuation;
                    dlg.NbarLabel.Visible='on';
                    dlg.NbarEdit.Visible='on';
                    dlg.Nbar=Process.Nbar;
                    dlg.SpectrumRangeLabel.Visible='on';
                    dlg.SpectrumRangeEdit.Visible='on';
                    dlg.SpectrumRange=Process.SpectrumRange;
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                case 'Chebyshev'

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumWindowLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.SpectrumWindowEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumRangeLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SpectrumRangeEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SideLobeAttenuationLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='on';
                    dlg.SideLobeAttenuationEdit.Visible='on';
                    dlg.SideLobeAttenuation=Process.SideLobeAttenuation;
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.SpectrumRangeLabel.Visible='on';
                    dlg.SpectrumRangeEdit.Visible='on';
                    dlg.SpectrumRange=Process.SpectrumRange;
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                case 'Kaiser'

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumWindowLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.SpectrumWindowEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumRangeLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SpectrumRangeEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.BetaLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.BetaEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='off';
                    dlg.SideLobeAttenuationEdit.Visible='off';
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.SpectrumRangeLabel.Visible='on';
                    dlg.SpectrumRangeEdit.Visible='on';
                    dlg.SpectrumRange=Process.SpectrumRange;
                    dlg.BetaLabel.Visible='on';
                    dlg.BetaEdit.Visible='on';
                    dlg.Beta=Process.Beta;
                case 'None'

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumWindowLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.SpectrumWindowEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='off';
                    dlg.SideLobeAttenuationEdit.Visible='off';
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.SpectrumRangeLabel.Visible='off';
                    dlg.SpectrumRangeEdit.Visible='off';
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                otherwise

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumWindowLabel,rowParam,1,w1,height)
                    dlg.Parent.addPopup(dlg.Layout,dlg.SpectrumWindowEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SpectrumRangeLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SpectrumRangeEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='off';
                    dlg.SideLobeAttenuationEdit.Visible='off';
                    dlg.SpectrumRangeEdit.Visible='on';
                    dlg.SpectrumRangeLabel.Visible='on';
                    dlg.SpectrumRange=Process.SpectrumRange;
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                end
                [~,~,w,height]=getMinimumSize(dlg.Layout);
                dlg.Width=sum(w)+dlg.Layout.HorizontalGap*(numel(w)+1);
                dlg.Height=max(height(2:end))*numel(height(2:end))+...
                dlg.Layout.VerticalGap*(numel(height(2:end))+10);
                add(dlg.Parent.Layout,dlg.Panel,3,1,...
                'MinimumWidth',dlg.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',dlg.Height,...
                'Anchor','North');
            case 'StretchProcessor'
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
                dlg.ProcessTypeEdit.Value=2;
                dlg.ProcessTypeEdit.String{dlg.ProcessTypeEdit.Value}=getString(message('phased:apps:waveformapp:StretchProcessor'));
                dlg.ReferenceRange=Process.ReferenceRange;
                dlg.RangeSpan=Process.RangeSpan;
                dlg.RangeWindow=Process.RangeWindow;
                dlg.RangeFFTLength=Process.RangeFFTLength;
                hspacing=0;
                vspacing=1;

                dlg.Layout=...
                matlabshared.application.layout.GridBagLayout(...
                dlg.Panel,...
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
                dlg.Parent.addText(dlg.Layout,dlg.ProcessTypeLabel,rowParam,1,w1,height)
                dlg.Parent.addPopup(dlg.Layout,dlg.ProcessTypeEdit,rowParam,2:3,w2,height)
                rowParam=rowParam+1;
                dlg.Parent.addText(dlg.Layout,dlg.ReferenceRangeLabel,rowParam,1,w1,height)
                dlg.Parent.addEdit(dlg.Layout,dlg.ReferenceRangeEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                dlg.Parent.addText(dlg.Layout,dlg.RangeSpanLabel,rowParam,1,w1,height)
                dlg.Parent.addEdit(dlg.Layout,dlg.RangeSpanEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                dlg.Parent.addText(dlg.Layout,dlg.RangeFFTLengthLabel,rowParam,1,w1,height)
                dlg.Parent.addEdit(dlg.Layout,dlg.RangeFFTLengthEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                dlg.Parent.addText(dlg.Layout,dlg.RangeWindowLabel,rowParam,1,w1,height)
                dlg.Parent.addEdit(dlg.Layout,dlg.RangeWindowEdit,rowParam,2:3,w2,height)
                switch Process.RangeWindow
                case 'Taylor'
                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SideLobeAttenuationLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SideLobeAttenuationEdit,rowParam,2:3,w2,height)

                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.NbarLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.NbarEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='on';
                    dlg.SideLobeAttenuationEdit.Visible='on';
                    dlg.SideLobeAttenuation=Process.SideLobeAttenuation;
                    dlg.NbarLabel.Visible='on';
                    dlg.NbarEdit.Visible='on';
                    dlg.Nbar=Process.Nbar;
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                case 'Chebyshev'
                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.SideLobeAttenuationLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='on';
                    dlg.SideLobeAttenuationEdit.Visible='on';
                    dlg.SideLobeAttenuation=Process.SideLobeAttenuation;
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                case 'Kaiser'
                    rowParam=rowParam+1;
                    dlg.Parent.addText(dlg.Layout,dlg.BetaLabel,rowParam,1,w1,height)
                    dlg.Parent.addEdit(dlg.Layout,dlg.BetaEdit,rowParam,2:3,w2,height)
                    dlg.SideLobeAttenuationLabel.Visible='off';
                    dlg.SideLobeAttenuationEdit.Visible='off';
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.BetaLabel.Visible='on';
                    dlg.BetaEdit.Visible='on';
                    dlg.Beta=Process.Beta;
                otherwise
                    dlg.SideLobeAttenuationLabel.Visible='off';
                    dlg.SideLobeAttenuationEdit.Visible='off';
                    dlg.NbarLabel.Visible='off';
                    dlg.NbarEdit.Visible='off';
                    dlg.BetaLabel.Visible='off';
                    dlg.BetaEdit.Visible='off';
                end
                [~,~,w,height]=getMinimumSize(dlg.Layout);
                dlg.Width=sum(w)+dlg.Layout.HorizontalGap*(numel(w)+1);
                dlg.Height=max(height(2:end))*numel(height(2:end))+...
                dlg.Layout.VerticalGap*(numel(height(2:end))+10);
                add(dlg.Parent.Layout,dlg.Panel,3,1,...
                'MinimumWidth',dlg.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',dlg.Height,...
                'Anchor','North');
            case 'Dechirp'
                dlg.ProcessTypeEdit.String=getString(message('phased:apps:waveformapp:Dechirp'));
            end
            self.AutoSelect=true;
        end
        function createCanvas(self)

            if self.View.Toolstrip.IsAppContainer
                self.WaveformList=phased.apps.internal.WaveformViewer.WaveformBrowserJT(self,'wavBrowser',getString(message('phased:apps:waveformapp:Library')));
                addToAppContainer(self.WaveformList,self.View.Toolstrip.AppContainer);

                addlistener(self.WaveformList,...
                'SelectionChanged',...
                @(src,evt)self.postScenarioClick(src,evt));
            else
                self.WaveformList=phased.apps.internal.WaveformViewer.WaveformBrowser(self,'wavBrowser','wavBrowser');

                addlistener(self.WaveformList,...
                'DataBrowserSelectionChanged',...
                @(src,evt)self.postScenarioClick(src,evt));
            end

            addlistener(self.WaveformList,...
            'renameWaveform',...
            @(src,evt)self.cbNewname(src,evt));

            addlistener(self.WaveformList,...
            'deleteWaveform',...
            @(src,evt)self.cbDelete(src,evt));

            addlistener(self.WaveformList,...
            'duplicateWaveform',...
            @(src,evt)self.cbDuplicate(src,evt));

        end
        function postScenarioClick(self,src,~)


            if~self.AutoSelect||isempty(src.Data)||~isvalid(self.View)
                selectionButtonsEnable(self);
                return
            end
            if~isvalid(self.View.Toolstrip.AddWavBtn)
                return
            end
            if isempty(self.SelectIdx)
                return
            else


                rowIndex=src.getSelectedRows();

                if isempty(rowIndex)
                    k=self.SelectIdx;
                    if self.View.Toolstrip.IsAppContainer
                        selectRow(self.WaveformList,k(1));
                    else
                        self.WaveformList.setRowSelection(k(1));
                    end
                    return
                end

                if numel(rowIndex)==1
                    self.SelectIdx=rowIndex;
                    selectionButtonsEnable(self);
                    self.notify('ItemSelected',...
                    phased.apps.internal.WaveformViewer.ElementSelectedEventData(self.SelectIdx));
                    selectionButtonsEnable(self);

                    self.View.addplotAction();
                else
                    if self.View.Parameters.WaveformChanged==1
                        self.notify('ElementSelected',...
                        phased.apps.internal.WaveformViewer.ElementSelectedEventData(self.SelectIdx));
                    end
                    indices=rowIndex;
                    k=numel(indices);
                    index=-1;
                    if k==0
                        return;
                    else
                        for i=1:k
                            if indices(i)==self.SelectIdx
                                index=self.SelectIdx;
                                break
                            end
                        end



                        if index~=self.SelectIdx
                            self.SelectIdx=indices(1);
                            self.notify('ElementSelected',...
                            phased.apps.internal.WaveformViewer.ElementSelectedEventData(self.SelectIdx));
                        end
                        multiSelectButtonsDisable(self,indices);
                        self.notify('MultiselectDisable',...
                        phased.apps.internal.WaveformViewer.MultiSelectedEventData(self.View));
                        setAppStatus(self.View,true);
                        self.View.addplotAction();
                        setAppStatus(self.View,false);
                    end

                    figure(self.View.Parameters.Layout.Panel);
                end
            end
        end

        function cbNewname(self,src,evt)

            waveformName=evt.scenNewName;
            waveformName=matlab.lang.makeValidName(waveformName);
            src.Data{evt.scenIndex}='';
            waveformName=matlab.lang.makeUniqueStrings(waveformName,self.WaveformList.Data(:,1));
            src.Data{evt.scenIndex}=waveformName;
            src.updateUI();
            self.notify('UpdateName',...
            phased.apps.internal.WaveformViewer.UpdateNameEventData(evt.scenIndex,waveformName));
            titleUpdate(self.View);
            self.View.setAppStatus(true);
            self.View.characteristicsAction();
            self.View.setAppStatus(false);
        end
        function cbDelete(self,~,~)

            deleteAction(self.View);
        end
        function cbDuplicate(self,~,~)

            duplicateAction(self.View);
        end

        function selectionButtonsEnable(self)

            if numel(self.WaveformList.getSelectedRows())>1
                return
            end
            self.View.Toolstrip.AddWavBtn.Enabled=true;
            haveSimulink=builtin('license','test','SIMULINK');
            if haveSimulink
                self.View.Toolstrip.SimulinkBtn.Enabled=true;
                self.View.Toolstrip.WaveformSimulinkPopup.Enabled=true;
                if self.View.Toolstrip.isWaveformLibraryEnabled
                    self.View.Toolstrip.LibrarySimulinkPopup.Enabled=true;
                end
            end
            if isempty(self.View.Parameters.ElementDialog)
                return;
            end
            self.View.Parameters.ElementDialog.WaveformEdit.Enable='on';
            self.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
            Wav=self.View.Parameters.ElementDialog.Waveform;
            if(strcmp(Wav,getString(message('phased:apps:waveformapp:LinearFM'))))
                if self.View.Parameters.ProcessDialog.ProcessTypeEdit.Value==0
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Style='popupmenu';
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.String={getString(message('phased:apps:waveformapp:MatchedFilter')),getString(message('phased:apps:waveformapp:StretchProcessor'))};
                end
                Comp=self.View.Parameters.ProcessDialog.ProcessTypeEdit.String{self.View.Parameters.ProcessDialog.ProcessTypeEdit.Value};
            elseif(strcmp(Wav,getString(message('phased:apps:waveformapp:FMCW'))))
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Style='text';
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.String=getString(message('phased:apps:waveformapp:Dechirp'));
                Comp=self.View.Parameters.ProcessDialog.ProcessTypeEdit.String;
            else
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Style='text';
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.String=getString(message('phased:apps:waveformapp:MatchedFilter'));
                Comp=self.View.Parameters.ProcessDialog.ProcessTypeEdit.String;
            end
            self.View.Toolstrip.ExportBtn.Enabled=true;
            self.View.Toolstrip.WaveformWorkspacePopup.Enabled=true;
            self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            self.View.Toolstrip.WaveformFilePopup.Enabled=true;
            self.View.Toolstrip.WaveformReportPopup.Enabled=true;
            if self.View.Toolstrip.isWaveformLibraryEnabled
                self.View.Toolstrip.LibraryWorkspacePopup.Enabled=true;
                self.View.Toolstrip.LibraryScriptPopup.Enabled=true;
                self.View.Toolstrip.LibraryFilePopup.Enabled=true;
                self.View.Toolstrip.LibrarySimulinkPopup.Enabled=true;
            end
            switch Wav
            case getString(message('phased:apps:waveformapp:Rectangular'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='on';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
            case getString(message('phased:apps:waveformapp:LinearFM'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='on';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='on';
                self.View.Parameters.ElementDialog.EnvelopeEdit.Enable='on';
            case getString(message('phased:apps:waveformapp:SteppedFM'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='on';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                self.View.Parameters.ElementDialog.FrequencyStepEdit.Enable='on';
                self.View.Parameters.ElementDialog.NumStepsEdit.Enable='on';
            case getString(message('phased:apps:waveformapp:PhaseCoded'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='on';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                self.View.Parameters.ElementDialog.CodeEdit.Enable='on';
                self.View.Parameters.ElementDialog.ChipWidthEdit.Enable='on';
                self.View.Parameters.ElementDialog.NumChipsEdit.Enable='on';
                if strcmp(self.View.Parameters.ElementDialog.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                    self.View.Parameters.ElementDialog.SequenceIndexEdit.Enable='on';
                end
            case getString(message('phased:apps:waveformapp:FMCW'))
                self.View.Parameters.ElementDialog.NumSweepsEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepTimeEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='on';
                self.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='on';
                if self.View.Toolstrip.isWaveformLibraryEnabled
                    self.View.Toolstrip.LibrarySimulinkPopup.Enabled=false;
                    self.View.Toolstrip.LibraryWorkspacePopup.Enabled=false;
                    self.View.Toolstrip.LibraryScriptPopup.Enabled=false;
                    self.View.Toolstrip.LibraryFilePopup.Enabled=false;
                end
            end
            switch Comp
            case getString(message('phased:apps:waveformapp:MatchedFilter'))
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=true;
                if strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.NbarEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                elseif strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                elseif strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.BetaEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                elseif strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:None')))
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                else
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                end
            case getString(message('phased:apps:waveformapp:StretchProcessor'))
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=true;
                self.View.Parameters.ProcessDialog.RangeSpanEdit.Enable='on';
                self.View.Parameters.ProcessDialog.ReferenceRangeEdit.Enable='on';
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                self.View.Parameters.ProcessDialog.RangeWindowEdit.Enable='on';
                self.View.Parameters.ProcessDialog.RangeFFTLengthEdit.Enable='on';
                if strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                    self.View.Parameters.ProcessDialog.NbarEdit.Enable='on';
                elseif strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                elseif strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                    self.View.Parameters.ProcessDialog.BetaEdit.Enable='on';
                end
            case getString(message('phased:apps:waveformapp:Dechirp'))
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='on';
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
                if self.View.Toolstrip.isWaveformLibraryEnabled
                    self.View.Toolstrip.LibraryWorkspacePopup.Enabled=false;
                    self.View.Toolstrip.LibraryScriptPopup.Enabled=false;
                    self.View.Toolstrip.LibraryFilePopup.Enabled=false;
                end
            end
            self.View.Toolstrip.PspectrumBtn.Enabled=true;
            self.View.Toolstrip.SpectrogramBtn.Enabled=true;
            self.View.Toolstrip.AmbFnContourBtn.Enabled=true;
            self.View.Toolstrip.AmbFnSurfaceBtn.Enabled=true;
            if any(ismember(findall(0,'type','figure'),self.View.PSpectrumFig))
                self.View.PSpectrum.TopAxes.Visible='on';
                self.View.PSpectrum.Panel.Title='';
            end
            if any(ismember(findall(0,'type','figure'),self.View.SpectrogramFig))
                self.View.Spectrogram.TopAxes.Visible='on';
                self.View.Spectrogram.Panel.Title='';
                self.View.Spectrogram.hThresholdedt.Visible='on';
                self.View.Spectrogram.hThresholdtxt.Visible='on';
                self.View.Spectrogram.hThresholdunit.Visible='on';
                self.View.Spectrogram.hReassignededt.Visible='on';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionContourFig))
                self.View.AmbiguityFunctionContour.TopAxes.Visible='on';
                self.View.AmbiguityFunctionContour.Panel.Title='';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionSurfaceFig))
                self.View.AmbiguityFunctionSurface.TopAxes.Visible='on';
                self.View.AmbiguityFunctionSurface.Panel.Title='';
            end
        end
        function multiSelectButtonsDisable(self,indices)


            self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
            self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
            self.View.Toolstrip.AddWavBtn.Enabled=false;
            self.View.Toolstrip.WaveformWorkspacePopup.Enabled=false;
            self.View.Toolstrip.WaveformScriptPopup.Enabled=false;
            self.View.Toolstrip.WaveformFilePopup.Enabled=false;
            self.View.Toolstrip.WaveformReportPopup.Enabled=false;
            self.View.Toolstrip.WaveformSimulinkPopup.Enabled=false;
            if self.View.Toolstrip.isWaveformLibraryEnabled
                self.View.Toolstrip.LibrarySimulinkPopup.Enabled=true;
                self.View.Toolstrip.LibraryWorkspacePopup.Enabled=true;
                self.View.Toolstrip.LibraryScriptPopup.Enabled=true;
                self.View.Toolstrip.LibraryFilePopup.Enabled=true;
            end
            self.View.Parameters.ElementDialog.WaveformEdit.Enable='off';
            self.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
            Wave=self.View.Parameters.ElementDialog;
            if strcmp(Wave.Waveform,getString(message('phased:apps:waveformapp:LinearFM')))
                ProcessType=self.View.Parameters.ProcessDialog.ProcessTypeEdit.String{self.View.Parameters.ProcessDialog.ProcessTypeEdit.Value};
            else
                ProcessType=self.View.Parameters.ProcessDialog.ProcessTypeEdit.String;
            end
            switch Wave.Waveform
            case getString(message('phased:apps:waveformapp:Rectangular'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='off';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
            case getString(message('phased:apps:waveformapp:LinearFM'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='off';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='off';
                self.View.Parameters.ElementDialog.EnvelopeEdit.Enable='off';
            case getString(message('phased:apps:waveformapp:SteppedFM'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='off';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                self.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                self.View.Parameters.ElementDialog.FrequencyStepEdit.Enable='off';
                self.View.Parameters.ElementDialog.NumStepsEdit.Enable='off';
            case getString(message('phased:apps:waveformapp:PhaseCoded'))
                self.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                self.View.Parameters.ElementDialog.PRFLabel.Enable='off';
                self.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                self.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                self.View.Parameters.ElementDialog.CodeEdit.Enable='off';
                self.View.Parameters.ElementDialog.ChipWidthEdit.Enable='off';
                self.View.Parameters.ElementDialog.NumChipsEdit.Enable='off';
                if strcmp(self.View.Parameters.ElementDialog.Code,'Zadoff-Chu')
                    self.View.Parameters.ElementDialog.SequenceIndexEdit.Enable='off';
                end
            case getString(message('phased:apps:waveformapp:FMCW'))
                self.View.Parameters.ElementDialog.NumSweepsEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepTimeEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='off';
                self.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='off';
            end
            switch ProcessType
            case getString(message('phased:apps:waveformapp:MatchedFilter'))
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='off';
                self.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='off';
                if strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                    self.View.Parameters.ProcessDialog.NbarEdit.Enable='off';
                elseif strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                elseif strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,'Kaiser')
                    self.View.Parameters.ProcessDialog.BetaEdit.Enable='off';
                end
                if~strcmp(self.View.Parameters.ProcessDialog.SpectrumWindow,'None')
                    self.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='off';
                end
            case getString(message('phased:apps:waveformapp:StretchProcessor'))
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='off';
                if strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                    self.View.Parameters.ProcessDialog.NbarEdit.Enable='off';
                elseif strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                elseif strcmp(self.View.Parameters.ProcessDialog.RangeWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                    self.View.Parameters.ProcessDialog.BetaEdit.Enable='off';
                end
                self.View.Parameters.ProcessDialog.ReferenceRangeEdit.Enable='off';
                self.View.Parameters.ProcessDialog.RangeSpanEdit.Enable='off';
                self.View.Parameters.ProcessDialog.RangeFFTLengthEdit.Enable='off';
                self.View.Parameters.ProcessDialog.RangeWindowEdit.Enable='off';
            case getString(message('phased:apps:waveformapp:Dechirp'))
                self.View.Parameters.ProcessDialog.ProcessTypeEdit.Enable='off';
            end
            self.View.Toolstrip.PspectrumBtn.Enabled=false;
            self.View.Toolstrip.SpectrogramBtn.Enabled=false;
            self.View.Toolstrip.AmbFnContourBtn.Enabled=false;
            self.View.Toolstrip.AmbFnSurfaceBtn.Enabled=false;
            if any(ismember(findall(0,'type','figure'),self.View.PSpectrumFig))
                plot(self.View.PSpectrum.TopAxes,1,1)
                self.View.PSpectrum.TopAxes.Visible='off';
                self.View.PSpectrum.Panel.Title='Disabled for multiselect';
            end
            if any(ismember(findall(0,'type','figure'),self.View.SpectrogramFig))
                plot(self.View.Spectrogram.TopAxes,1,1)
                self.View.Spectrogram.TopAxes.Visible='off';
                self.View.Spectrogram.Panel.Title='Disabled for multiselect';
                self.View.Spectrogram.hThresholdedt.Visible='off';
                self.View.Spectrogram.hThresholdtxt.Visible='off';
                self.View.Spectrogram.hThresholdunit.Visible='off';
                self.View.Spectrogram.hReassignededt.Visible='off';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionContourFig))
                plot(self.View.AmbiguityFunctionContour.TopAxes,1,1)
                self.View.AmbiguityFunctionContour.TopAxes.Visible='off';
                self.View.AmbiguityFunctionContour.Panel.Title='Disabled for multiselect';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionSurfaceFig))
                plot(self.View.AmbiguityFunctionSurface.TopAxes,1,1)
                self.View.AmbiguityFunctionSurface.TopAxes.Visible='off';
                self.View.AmbiguityFunctionSurface.Panel.Title='Disabled for multiselect';
            end

            matchedfiltercount=0;
            stretchprocessorcount=0;
            for i=1:numel(indices)
                if isa(self.View.AppHandle.Model.ProcessData.Processes{indices(i)},'phased.apps.internal.WaveformViewer.MatchedFilter')
                    matchedfiltercount=matchedfiltercount+1;
                elseif isa(self.View.AppHandle.Model.ProcessData.Processes{indices(i)},'phased.apps.internal.WaveformViewer.StretchProcessor')
                    stretchprocessorcount=stretchprocessorcount+1;
                end
            end
            if matchedfiltercount>0&&matchedfiltercount==numel(indices)
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=true;
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
            elseif stretchprocessorcount>0&&stretchprocessorcount==numel(indices)
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=true;
            else
                self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
                self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
            end
        end
    end

    methods(Hidden)
        function newView(self,data)

            self.WaveformList.Data=[];
            self.WaveformList.updateUI();
            n=numel(data.Elem.Elements);
            if n==0
                return
            end
            self.RectNum=0;
            self.LinearNum=0;
            self.StepNum=0;
            self.PCNum=0;
            self.FMCWNum=0;
            self.View.Parameters.PRFPRIIndex=0;
            if~isempty(data.numWaveforms)
                for index=1:n
                    data.Index=index;
                    waveformName=data.Elem.Elements{index}.Name;
                    elementInserted(self.View,data)
                    self.WaveformList.Data{index}=waveformName;
                    self.WaveformList.updateUI();
                    self.notify('UpdateName',...
                    phased.apps.internal.WaveformViewer.UpdateNameEventData(index,waveformName));
                end
                self.RectNum=data.numWaveforms{1};
                self.LinearNum=data.numWaveforms{2};
                self.StepNum=data.numWaveforms{3};
                self.PCNum=data.numWaveforms{4};
                self.FMCWNum=data.numWaveforms{5};
                self.View.Parameters.PRFPRIIndex=data.PRFPRIIndex;
            else
                for index=1:n
                    data.Index=index;
                    elementInserted(self.View,data)

                end
            end
            self.View.SampleRateEdit.String=data.Elem.Elements{1}.SampleRate;
            setAppStatus(self.View,true);
            self.View.characteristicsAction();
            setAppStatus(self.View,false);
            self.View.addplotAction();
            titleSave(self,data);
        end
        function titleSave(self,data)
            self.View.Toolstrip.ToolGroup.Title=sprintf(strcat(getString(message('phased:apps:waveformapp:title')),'-',data.Name));
        end
    end
    methods(Hidden)
        function deleteElement(self,Wave,Comp,index)

            self.AutoSelect=false;
            self.WaveformList.Data(index,:)=[];
            self.WaveformList.updateUI();
            prevStr=self.WaveformList.Data;
            self.View.Parameters.ElementType='';
            self.View.Parameters.ProcessType='';
            self.InsertIdx=self.InsertIdx-1;
            if numel(prevStr)>0
                self.SelectIdx=max(1,index-1);
                if~self.View.Toolstrip.IsAppContainer
                    self.WaveformList.setRowSelection(self.SelectIdx);
                else
                    selectRow(self.WaveformList,self.SelectIdx)
                end
                selectElement(self,...
                Wave.Elements{self.SelectIdx});
                selectProcess(self,...
                Comp.Processes{self.SelectIdx});
                self.View.Toolstrip.AddWavBtn.Enabled=true;
                setAppStatus(self.View,true);
                self.View.characteristicsAction();
                setAppStatus(self.View,false);
                self.View.addplotAction();
            else
                buttonsDisable(self);
            end
            self.AutoSelect=true;
        end
        function buttonsDisable(self)

            self.View.Toolstrip.DefaultBtn.Enabled=false;
            self.View.Toolstrip.SaveBtn.Enabled=false;
            self.View.Toolstrip.DeleteBtn.Enabled=false;
            self.View.Toolstrip.CopyBtn.Enabled=false;
            self.View.Toolstrip.RealImagBtn.Enabled=false;
            self.View.Toolstrip.MagnitudePhaseBtn.Enabled=false;
            self.View.Toolstrip.SpectrumBtn.Enabled=false;
            self.View.Toolstrip.PspectrumBtn.Enabled=false;
            self.View.Toolstrip.SpectrogramBtn.Enabled=false;
            self.View.Toolstrip.AmbFnContourBtn.Enabled=false;
            self.View.Toolstrip.AmbFnSurfaceBtn.Enabled=false;
            self.View.Toolstrip.AmbFnDelayBtn.Enabled=false;
            self.View.Toolstrip.AmbFnDopplerBtn.Enabled=false;
            self.View.Toolstrip.AutoCorrelationBtn.Enabled=false;
            self.View.Toolstrip.MatchedFilterResponseBtn.Enabled=false;
            self.View.Toolstrip.StretchProcessorResponseBtn.Enabled=false;
            self.View.Toolstrip.ExportBtn.Enabled=false;



            self.View.Parameters.ApplyButton.ApplyButton.Enable='off';
            self.View.Parameters.ApplyButton.ApplyButton.Visible='off';
            self.View.SampleRatePanel.Visible='off';
            haveSimulink=builtin('license','test','SIMULINK');
            drawnow;
            if haveSimulink
                self.View.Toolstrip.SimulinkBtn.Enabled=false;
            end
            self.View.Toolstrip.AddWavBtn.Enabled=true;
            self.View.SampleRateEdit.Enable='off';
            self.View.Parameters.WaveformCharacteristics.characteristicsTable.Visible='off';
            plot(self.View.RealAndImaginary.TopAxes,1,1)
            plot(self.View.RealAndImaginary.BottomAxes,1,1)
            if any(ismember(findall(0,'type','figure'),self.View.MagnitudeAndPhaseFig))
                plot(self.View.MagnitudeAndPhase.TopAxes,1,1)
                plot(self.View.MagnitudeAndPhase.BottomAxes,1,1)
            end
            if any(ismember(findall(0,'type','figure'),self.View.SpectrumFig))
                plot(self.View.Spectrum.TopAxes,1,1)
            end
            if any(ismember(findall(0,'type','figure'),self.View.PSpectrumFig))
                plot(self.View.PSpectrum.TopAxes,1,1)
            end
            if any(ismember(findall(0,'type','figure'),self.View.SpectrogramFig))
                plot(self.View.Spectrogram.TopAxes,1,1)
                self.View.Spectrogram.hThresholdedt.Enable='off';
                self.View.Spectrogram.hReassignededt.Enable='off';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionContourFig))
                plot(self.View.AmbiguityFunctionContour.TopAxes,1,1)
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionSurfaceFig))
                plot(self.View.AmbiguityFunctionSurface.TopAxes,1,1)
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionDelayCutFig))
                plot(self.View.AmbiguityFunctionDelayCut.TopAxes,1,1)
                self.View.AmbiguityFunctionDelayCut.CutValueEdit.Enable='off';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AmbiguityFunctionDopplerCutFig))
                plot(self.View.AmbiguityFunctionDopplerCut.TopAxes,1,1)
                self.View.AmbiguityFunctionDopplerCut.CutValueEdit.Enable='off';
            end
            if any(ismember(findall(0,'type','figure'),self.View.AutoCorrelationFig))
                plot(self.View.AutoCorrelation.TopAxes,1,1)
            end
            if~self.View.Toolstrip.IsAppContainer
                if strcmp(self.View.Toolstrip.ToolGroup.Title(end),'*')
                    self.View.Toolstrip.ToolGroup.Title(end)='';
                end
            else
                if strcmp(self.View.Toolstrip.AppContainer.Title(end),'*')
                    self.View.Toolstrip.AppContainer.Title(end)='';
                end
            end
            self.RectNum=0;
            self.LinearNum=0;
            self.StepNum=0;
            self.PCNum=0;
            self.FMCWNum=0;
        end
        function buttonsEnable(self)

            self.View.Toolstrip.DefaultBtn.Enabled=true;
            self.View.Toolstrip.SaveBtn.Enabled=true;
            self.View.Toolstrip.DeleteBtn.Enabled=true;
            self.View.Toolstrip.CopyBtn.Enabled=true;
            self.View.Toolstrip.RealImagBtn.Enabled=true;
            self.View.Toolstrip.MagnitudePhaseBtn.Enabled=true;
            self.View.Toolstrip.SpectrumBtn.Enabled=true;
            self.View.Toolstrip.PspectrumBtn.Enabled=true;
            self.View.Toolstrip.SpectrogramBtn.Enabled=true;
            self.View.Toolstrip.AmbFnContourBtn.Enabled=true;
            self.View.Toolstrip.AmbFnSurfaceBtn.Enabled=true;
            self.View.Toolstrip.AmbFnDelayBtn.Enabled=true;
            self.View.Toolstrip.AmbFnDopplerBtn.Enabled=true;
            self.View.Toolstrip.AutoCorrelationBtn.Enabled=true;
            self.View.Toolstrip.ExportBtn.Enabled=true;
            haveSimulink=builtin('license','test','SIMULINK');
            if haveSimulink
                self.View.Toolstrip.SimulinkBtn.Enabled=true;
            end
            self.View.SampleRatePanel.Visible='on';
            self.View.SampleRateEdit.Enable='on';
            self.View.Parameters.ApplyButton.ApplyButton.Visible='on';
            self.View.Parameters.WaveformCharacteristics.characteristicsTable.Visible='on';
        end
        function insertAddElementView(self,Wave,Process,index)

            self.SelectIdx=index;
            selectElement(self,Wave)
            selectProcess(self,Process)


            self.View.SampleRatePanel.Visible='on';
            self.View.SampleRateEdit.Enable='on';
            self.View.Parameters.WaveformCharacteristics.characteristicsTable.Visible='on';

            self.AutoSelect=false;
            WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Wave));
            ProcessType=phased.apps.internal.WaveformViewer.getWaveformString(class(Process));
            oldStr=self.WaveformList.Data;
            switch WaveformType
            case 'RectangularWaveform'
                addStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,getString(message('phased:apps:waveformapp:Rectangular')));
            case 'LinearFMWaveform'
                addStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,getString(message('phased:apps:waveformapp:LinearFM')));
            case 'SteppedFMWaveform'
                addStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,getString(message('phased:apps:waveformapp:SteppedFM')));
            case 'PhaseCodedWaveform'
                addStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,getString(message('phased:apps:waveformapp:PhaseCoded')));
            case 'FMCWWaveform'
                addStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,getString(message('phased:apps:waveformapp:FMCW')));

            end
            addStr{1}=matlab.lang.makeValidName(addStr{1});
            if~isempty(self.WaveformList.Data)
                waveNameImport=matlab.lang.makeValidName(addStr{1});
                waveNameUpdate=matlab.lang.makeUniqueStrings(waveNameImport,self.WaveformList.Data(:,1));
                cond=any(strcmp(waveNameImport,self.WaveformList.Data(:,1)));
                if cond
                    if self.View.Toolstrip.IsAppContainer
                        uialert(self.View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:waveformnamecoincide',...
                        waveNameImport,waveNameUpdate)),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Modal',true,'Icon','Warning');
                    else
                        h=warndlg(getString(message('phased:apps:waveformapp:waveformnamecoincide',waveNameImport,waveNameUpdate)),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal');
                        uiwait(h)
                    end
                end
                addStr{1}=waveNameUpdate;
            end
            self.RectNum=self.RectNum+1;
            self.AutoSelect=true;
            if self.View.Toolstrip.IsAppContainer
                addStr={addStr{:,1},addStr{:,2},addStr{:,3}};
                self.WaveformList.Data=addStr;
                newStr=[oldStr;addStr];
                self.WaveformList.Data=newStr;
                if~iscell(self.WaveformList.Data)
                    self.WaveformList.Data={newStr};
                end
                self.WaveformList.updateUI();
                qeSelect(self.WaveformList,self.SelectIdx);
                Wave.Name=addStr{1};
            else
                newStr=[oldStr;addStr];
                self.WaveformList.Data=newStr;
                self.WaveformList.updateUI();
                self.WaveformList.setRowSelection(index);
                Wave.Name=addStr{1};
            end
            prevStr=self.WaveformList.Data;
            if size(prevStr,1)==2
                buttonsEnable(self);
            end
            self.InsertIdx=self.SelectIdx+1;
            if~self.View.Toolstrip.IsAppContainer
                self.View.RealAndImaginary.Panel.Visible='on';
            end
        end
        function insertElement(self,Wave,Process,index)
            if~isempty(self.View.Parameters.ElementDialog)
                self.View.Parameters.ElementType='';
            end
            if~isempty(self.View.Parameters.ProcessDialog)
                self.View.Parameters.ProcessType='';
            end
            insertAddElementView(self,Wave.Elements{index},Process.Processes{index},index);
        end
        function selectedElement(self,data)
            if~isempty(data.Element)
                self.View.Parameters.ElementType='';
            end
            selectElement(self,data.Element)
        end
        function selectedProcess(self,data)
            if~isempty(data.Value)
                self.View.Parameters.ProcessType='';
            end
            selectProcess(self,data.Value)
        end
        function newStr=waveformListUpdate(self,Wave,WaveformType,ProcessType,wavename)
            if~self.View.Toolstrip.IsAppContainer
                if~strcmp(Wave.Name,wavename)
                    if strcmp(ProcessType,'MatchedFilter')
                        newStr={Wave.Name,wavename,getString(message('phased:apps:waveformapp:MatchedFilter'))};
                    elseif strcmp(ProcessType,'StretchProcessor')
                        newStr={Wave.Name,wavename,getString(message('phased:apps:waveformapp:StretchProcessor'))};
                    else
                        newStr={Wave.Name,wavename,getString(message('phased:apps:waveformapp:Dechirp'))};
                    end
                elseif self.RectNum==0
                    newStr={'Waveform',wavename,getString(message('phased:apps:waveformapp:MatchedFilter'))};
                else
                    j=num2str(self.RectNum);
                    newStr=strcat('Waveform',j);
                    if strcmp(ProcessType,'MatchedFilter')
                        newStr={newStr,wavename,getString(message('phased:apps:waveformapp:MatchedFilter'))};
                    elseif strcmp(ProcessType,'StretchProcessor')
                        newStr={newStr,wavename,getString(message('phased:apps:waveformapp:StretchProcessor'))};
                    elseif strcmp(ProcessType,'Dechirp')
                        newStr={newStr,wavename,getString(message('phased:apps:waveformapp:Dechirp'))};
                    end
                end
            else
                if~strcmp(Wave.Name,wavename)
                    newStr={Wave.Name,extractBefore(WaveformType,'Waveform'),ProcessType};
                elseif self.RectNum==0
                    newStr={'Waveform',extractBefore(WaveformType,'Waveform'),ProcessType};
                else
                    j=num2str(self.RectNum);
                    newStr=strcat('Waveform',j);
                    newStr={newStr,extractBefore(WaveformType,'Waveform'),ProcessType};
                end
            end
        end
    end
    events(Hidden)
ElementSelected
ItemSelected
MultiselectDisable
UpdateName
SelectedProcess
    end
end
