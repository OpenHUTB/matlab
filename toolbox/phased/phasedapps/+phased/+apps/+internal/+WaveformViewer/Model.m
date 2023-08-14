classdef Model<handle

    properties(Hidden)
Name
StoreData
Storedataref
ProcessDataref
ProcessData
    end
    properties(Constant,Access=private)
        DefaultName=getString(message('phased:apps:waveformapp:DefaultSessionName'));
        DefaultProcessType='MatchedFilter';
    end
    properties(Access=private)
        MatFilePath=''
    end
    methods
        function self=Model()
            self.StoreData=phased.apps.internal.WaveformViewer.StoreData;
            self.Name=self.DefaultName;
            self.ProcessData=phased.apps.internal.WaveformViewer.ProcessData;
            self.Storedataref=phased.apps.internal.WaveformViewer.RectangularWaveform;
            self.ProcessDataref=phased.apps.internal.WaveformViewer.MatchedFilter;
        end
    end
    methods(Hidden)
        function openSession(self,Waveformstruct)

            Library=Waveformstruct.data;
            numWaveforms=Waveformstruct.numWaveforms;
            self.StoreData=Library{1};
            self.ProcessData=Library{2};
            self.notify('NewModel',...
            phased.apps.internal.WaveformViewer.LoadingEventData(self.Name,self.StoreData,self.ProcessData,numWaveforms,'',Waveformstruct.PRFPRIIndex));
        end
        function newActions(self,View)

            if View.Toolstrip.IsAppContainer
                title=View.Toolstrip.AppContainer.Title;
            else
                title=View.Toolstrip.ToolGroup.Title;
            end
            if strcmp(title(end),'*')

                dlg=questdlg(getString(message('phased:apps:waveformapp:SaveSession')),...
                getString(message('phased:apps:waveformapp:title')),...
                getString(message('phased:apps:waveformapp:yes')),getString(message('phased:apps:waveformapp:no')),getString(message('phased:apps:waveformapp:cancel')),getString(message('phased:apps:waveformapp:yes')));
                switch dlg
                case getString(message('phased:apps:waveformapp:yes'))
                    savePopupActions(self,View,getString(message('phased:apps:waveformapp:SaveasLabel')))
                case getString(message('phased:apps:waveformapp:cancel'))
                    return
                end
                if isempty(dlg)
                    return
                end
            end

            self.StoreData.Elements=[];
            self.ProcessData.Processes=[];
            self.MatFilePath='';
            self.StoreData.Elements{1}=phased.apps.internal.WaveformViewer.RectangularWaveform;
            self.ProcessData.Processes{1}=phased.apps.internal.WaveformViewer.MatchedFilter;
            self.Name=self.DefaultName;
            self.notify('NewModel',...
            phased.apps.internal.WaveformViewer.LoadingEventData(self.Name,self.StoreData,self.ProcessData,''));


            if~any(ismember(findall(0,'type','figure'),View.SpectrumFig))
                addplotAction(View,getString(message('phased:apps:waveformapp:spectrum')))
            end
            if any(ismember(findall(0,'type','figure'),View.MagnitudeAndPhaseFig))
                View.closeFigure(View.MagnitudeAndPhaseFig)
            end
            if any(ismember(findall(0,'type','figure'),View.PSpectrumFig))
                View.closeFigure(View.PSpectrumFig)
            end
            if any(ismember(findall(0,'type','figure'),View.SpectrogramFig))
                View.closeFigure(View.SpectrogramFig)
            end
            if any(ismember(findall(0,'type','figure'),View.AmbiguityFunctionContourFig))
                View.closeFigure(View.AmbiguityFunctionContourFig)
            end
            if any(ismember(findall(0,'type','figure'),View.AmbiguityFunctionSurfaceFig))
                View.closeFigure(View.AmbiguityFunctionSurfaceFig)
            end
            if any(ismember(findall(0,'type','figure'),View.AmbiguityFunctionDelayCutFig))
                View.closeFigure(View.AmbiguityFunctionDelayCutFig)
            end
            if any(ismember(findall(0,'type','figure'),View.AmbiguityFunctionDopplerCutFig))
                View.closeFigure(View.AmbiguityFunctionDopplerCutFig)
            end
            if any(ismember(findall(0,'type','figure'),View.AutoCorrelationFig))
                View.closeFigure(View.AutoCorrelationFig)
            end
            if any(ismember(findall(0,'type','figure'),View.MatchedFilterCoefficientsFig))
                View.closeFigure(View.MatchedFilterCoefficientsFig)
            end
            if any(ismember(findall(0,'type','figure'),View.StretchProcessorFig))
                View.closeFigure(View.StretchProcessorFig)
            end
            View.positionFigures();
        end
        function importPopupActions(self,View,str)
            if View.Toolstrip.IsAppContainer
                title=View.Toolstrip.AppContainer.Title;
            else
                title=View.Toolstrip.ToolGroup.Title;
            end
            if endsWith(title,'*')

                dlg=questdlg(getString(message('phased:apps:waveformapp:SaveSession')),...
                getString(message('phased:apps:waveformapp:title')),...
                getString(message('phased:apps:waveformapp:yes')),getString(message('phased:apps:waveformapp:no')),getString(message('phased:apps:waveformapp:cancel')),getString(message('phased:apps:waveformapp:yes')));
                switch dlg
                case getString(message('phased:apps:waveformapp:yes'))
                    savePopupActions(self,View,getString(message('phased:apps:waveformapp:SaveasLabel')))
                case getString(message('phased:apps:waveformapp:cancel'))
                    return
                end
                if isempty(dlg)
                    return
                end
            end

            switch str
            case getString(message('phased:apps:waveformapp:ImportFileLabel'))
                importAction(self,View);
            case getString(message('phased:apps:waveformapp:ImportWorkspaceLabel'))
                [waveformName,importList]=phased.apps.internal.WaveformViewer.ImportWorkspace();
                if isempty(importList)
                    return
                end
                importObject(self,View,importList,waveformName);
            end
            titleUpdate(View);
            self.MatFilePath='';
        end

        function importAction(self,View)

            libraryFiles=getString(message('phased:apps:waveformapp:radWaveMat'));
            allFiles=getString(message('phased:apps:waveformapp:allfiles'));
            selectFileTitle=getString(message('phased:apps:waveformapp:selFile'));
            [matfile,pathname]=uigetfile(...
            {'*.mat',[libraryFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,self.MatFilePath);
            wasCanceled=isequal(matfile,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end
            loadModel(self,View,[pathname,matfile]);
        end
        function openAction(self,View)
            if~View.Toolstrip.IsAppContainer
                title=View.Toolstrip.ToolGroup.Title;
            else
                title=View.Toolstrip.AppContainer.Title;
            end
            if strcmp(title(end),'*')

                dlg=questdlg(getString(message('phased:apps:waveformapp:SaveSession')),...
                getString(message('phased:apps:waveformapp:title')),...
                getString(message('phased:apps:waveformapp:yes')),getString(message('phased:apps:waveformapp:no')),getString(message('phased:apps:waveformapp:cancel')),getString(message('phased:apps:waveformapp:yes')));
                switch dlg
                case getString(message('phased:apps:waveformapp:yes'))
                    savePopupActions(self,View,getString(message('phased:apps:waveformapp:SaveasLabel')))
                case getString(message('phased:apps:waveformapp:cancel'))
                    return
                end
                if isempty(dlg)
                    return
                end
            end
            libraryFiles=getString(message('phased:apps:waveformapp:radWaveMat'));
            allFiles=getString(message('phased:apps:waveformapp:allfiles'));
            selectFileTitle=getString(message('phased:apps:waveformapp:selFile'));
            [matfile,pathname]=uigetfile(...
            {'*.mat',[libraryFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,self.MatFilePath);
            wasCanceled=isequal(matfile,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end

            loadSavedSession(self,View,[pathname,matfile]);
        end
        function loadSavedSession(self,View,matfilepath)

            try
                [~,self.Name,~]=fileparts(matfilepath);
                temp=load(matfilepath,'-mat');
                if self.isValidSavedFile(temp)
                    variables=fieldnames(temp);
                    Waveformstruct=temp.(variables{1});
                    Library=Waveformstruct.data{1};
                    numWaveforms=Waveformstruct.numWaveforms;
                    self.StoreData=Library;
                    self.ProcessData=Waveformstruct.data{2};
                    self.notify('NewModel',...
                    phased.apps.internal.WaveformViewer.LoadingEventData(self.Name,self.StoreData,self.ProcessData,numWaveforms,'',Waveformstruct.PRFPRIIndex));
                    self.MatFilePath=matfilepath;
                else
                    throwError(View,getString(message('phased:apps:waveformapp:InvalidSession')));
                end
            catch
                throwError(View,getString(message('phased:apps:waveformapp:InvalidSession')));
            end
        end
        function loadModel(self,View,matfilepath)



            try
                [~,self.Name,~]=fileparts(matfilepath);


                warnstate(1)=warning('off','MATLAB:license:NoFeature');
                warnstate(2)=warning('off','MATLAB:load:classError');
                warnstate(3)=warning('off','MATLAB:load:cannotInstantiateLoadedVariable');
                temp=load(matfilepath,'-mat');
                [lastWarnMsg,~]=lastwarn;

                warning(warnstate);
                lastwarn('');

                if contains(lastWarnMsg,{'phased.PulseWaveformLibrary','pulseWaveformLibrary'})
                    phased.apps.internal.WaveformViewer.licenseCheck(View.Toolstrip.IsAppContainer,'pulseWaveformLibrary');
                    return;
                elseif contains(lastWarnMsg,{'phased.PulseCompressionLibrary','pulseCompressionLibrary'})
                    phased.apps.internal.WaveformViewer.licenseCheck(View.Toolstrip.IsAppContainer,'pulseCompressionLibrary');
                    return;
                end
                variables=fieldnames(temp);
                for j=1:numel(variables)
                    importData{j}=temp.(variables{j});
                end
                for j=1:numel(importData)
                    if self.isValidLibraryFile(importData{j})
                        try
                            if isa(importData{j},'phased.PulseWaveformLibrary')
                                for i=1:numel(importData{j}.WaveformSpecification)
                                    if isa(importData{j}.WaveformSpecification{i}{1},'function_handle')
                                        throwError(View,getString(message('phased:apps:waveformapp:CustomInput')));
                                        return
                                    end
                                end
                                step(importData{j},1);
                            elseif isa(importData{j},'phased.PulseCompressionLibrary')
                                pwl=phased.PulseWaveformLibrary('SampleRate',importData{j}.SampleRate,...
                                'WaveformSpecification',importData{j}.WaveformSpecification);
                                for i=1:numel(importData{j}.ProcessingSpecification)
                                    if isa(importData{j}.WaveformSpecification{i}{1},'function_handle')
                                        throwError(View,getString(message('phased:apps:waveformapp:CustomInput')));
                                        return
                                    end
                                    wave=pwl(i);
                                    importData{j}(wave,i);
                                end
                            else
                                if(~(isa(importData{j},'phased.MatchedFilter'))&&~(isa(importData{j},'phased.StretchProcessor')))
                                    step(importData{j});
                                end
                            end
                        catch me
                            throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                            return
                        end
                    end
                end
                importObject(self,View,importData,variables')
            catch me
                throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
            end
        end
        function importObject(self,View,importList,waveformName)


            for j=1:numel(importList)
                try

                    if isa(importList{j},'phased.PulseWaveformLibrary')
                        for i=1:numel(importList{j}.WaveformSpecification)
                            if isa(importList{j}.WaveformSpecification{i}{1},'function_handle')
                                throwError(View,getString(message('phased:apps:waveformapp:CustomInput')));
                                return
                            end
                        end
                        step(importList{j},1);
                    elseif isa(importList{j},'phased.PulseCompressionLibrary')

                        pwl=phased.PulseWaveformLibrary('SampleRate',importList{j}.SampleRate,...
                        'WaveformSpecification',importList{j}.WaveformSpecification);
                        for i=1:numel(importList{j}.WaveformSpecification)
                            if isa(importList{j}.ProcessingSpecification{i}{1},'function_handle')
                                throwError(View,getString(message('phased:apps:waveformapp:CustomInput')));
                                return
                            end
                            wave=pwl(i);
                            importList{j}(wave,i);
                        end
                    else

                        if(~(isa(importList{j},'phased.MatchedFilter'))&&~(isa(importList{j},'phased.StretchProcessor')))
                            step(importList{j});
                        end
                    end
                catch me
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    return
                end
            end
            self.StoreData=[];
            self.ProcessData=[];
            waveformimp=[];
            rangeProcessing=[];
            waveformLibrary=[];
            compressionLibrary=[];
            waveName=[];
            rangeProcessName=[];
            waveformLibraryName=[];
            compressionLibraryName=[];
            for i=1:numel(importList)
                if isa(importList{i},'phased.PulseWaveformLibrary')
                    waveformLibrary=horzcat(waveformLibrary,importList(i));%#ok<AGROW>
                    waveformLibraryName=horzcat(waveformLibraryName,waveformName(i));%#ok<AGROW>
                elseif isa(importList{i},'phased.PulseCompressionLibrary')
                    compressionLibrary=horzcat(compressionLibrary,importList(i));%#ok<AGROW>
                    compressionLibraryName=horzcat(compressionLibraryName,waveformName(i));%#ok<AGROW>
                elseif(isa(importList{i},'phased.MatchedFilter')||isa(importList{i},'phased.StretchProcessor'))
                    rangeProcessing=horzcat(rangeProcessing,importList(i));%#ok<AGROW>
                    rangeProcessName=horzcat(rangeProcessName,waveformName(i));%#ok<AGROW>
                else
                    waveformimp=horzcat(waveformimp,importList(i));%#ok<AGROW>
                    waveName=horzcat(waveName,waveformName(i));%#ok<AGROW>
                end
            end

            for i=1:numel(waveformLibrary)
                if isa(waveformLibrary{i},'phased.PulseWaveformLibrary')
                    for j=1:numel(compressionLibrary)
                        wavespeccount=0;
                        for k=1:numel(compressionLibrary{j}.WaveformSpecification)
                            if~(k<=numel(waveformLibrary{i}.WaveformSpecification))
                                break;
                            end
                            if~isempty(waveformLibrary{i})
                                checknumel=isequal(numel(compressionLibrary{j}.WaveformSpecification{k}),numel(waveformLibrary{i}.WaveformSpecification{k}));
                                if~checknumel
                                    break;
                                end
                                if(strcmp(waveformLibrary{i}.WaveformSpecification{k}{1},'Rectangular')&&strcmp(compressionLibrary{j}.WaveformSpecification{k}{1},'Rectangular'))
                                    rectparameters={'PRF','FrequencyOffset','PulseWidth'};
                                    for l=1:numel(rectparameters)
                                        isparamwavLibrary=cellfun(@(x)isequal(x,rectparameters{l}),waveformLibrary{i}.WaveformSpecification{k});
                                        [~,columnWaveform]=find(isparamwavLibrary);
                                        isparamcompLibrary=cellfun(@(x)isequal(x,rectparameters{l}),compressionLibrary{j}.WaveformSpecification{k});
                                        [~,columnCompression]=find(isparamcompLibrary);
                                        if~isempty(columnWaveform)&&~isempty(columnCompression)
                                            paramcheck=isequal(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},compressionLibrary{j}.WaveformSpecification{k}{columnCompression+1});
                                            if~paramcheck
                                                break;
                                            end
                                        else
                                            break;
                                        end
                                    end
                                    wavespeccount=wavespeccount+1;
                                elseif(strcmp(waveformLibrary{i}.WaveformSpecification{k}{1},'LinearFM')&&strcmp(compressionLibrary{j}.WaveformSpecification{k}{1},'LinearFM'))
                                    lfmparameters={'PRF','FrequencyOffset','PulseWidth','SweepBandwidth','SweepInterval','Envelope','SweepDirection'};
                                    for l=1:numel(lfmparameters)
                                        isparamwavLibrary=cellfun(@(x)isequal(x,lfmparameters{l}),waveformLibrary{i}.WaveformSpecification{k});
                                        [~,columnWaveform]=find(isparamwavLibrary);
                                        isparamcompLibrary=cellfun(@(x)isequal(x,lfmparameters{l}),compressionLibrary{j}.WaveformSpecification{k});
                                        [~,columnCompression]=find(isparamcompLibrary);
                                        if~isempty(columnWaveform)&&~isempty(columnCompression)
                                            paramcheck=isequal(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},compressionLibrary{j}.WaveformSpecification{k}{columnCompression+1});
                                            if~paramcheck
                                                break;
                                            end
                                        else
                                            break;
                                        end
                                    end
                                    wavespeccount=wavespeccount+1;
                                elseif strcmp(waveformLibrary{i}.WaveformSpecification{k}{1},'SteppedFM')&&strcmp(compressionLibrary{j}.WaveformSpecification{k}{1},'SteppedFM')
                                    sfmparameters={'PRF','FrequencyOffset','FrequencyStep','NumSteps'};
                                    for l=1:numel(sfmparameters)
                                        isparamwavLibrary=cellfun(@(x)isequal(x,sfmparameters{l}),waveformLibrary{i}.WaveformSpecification{k});
                                        [~,columnWaveform]=find(isparamwavLibrary);
                                        isparamcompLibrary=cellfun(@(x)isequal(x,sfmparameters{l}),compressionLibrary{j}.WaveformSpecification{k});
                                        [~,columnCompression]=find(isparamcompLibrary);
                                        if~isempty(columnWaveform)&&~isempty(columnCompression)
                                            paramcheck=isequal(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},compressionLibrary{j}.WaveformSpecification{k}{columnCompression+1});
                                            if~paramcheck
                                                break;
                                            end
                                        else
                                            break;
                                        end
                                    end
                                    wavespeccount=wavespeccount+1;
                                elseif strcmp(waveformLibrary{i}.WaveformSpecification{k}{1},'PhaseCoded')&&strcmp(compressionLibrary{j}.WaveformSpecification{k}{1},'PhaseCoded')
                                    phasecodedparameters={'PRF','FrequencyOffset','NumChips','Code','ChipWidth'};
                                    for l=1:numel(phasecodedparameters)
                                        isparamwavLibrary=cellfun(@(x)isequal(x,phasecodedparameters{l}),waveformLibrary{i}.WaveformSpecification{k});
                                        [~,columnWaveform]=find(isparamwavLibrary);
                                        isparamcompLibrary=cellfun(@(x)isequal(x,phasecodedparameters{l}),compressionLibrary{j}.WaveformSpecification{k});
                                        [~,columnCompression]=find(isparamcompLibrary);
                                        if~isempty(columnWaveform)&&~isempty(columnCompression)
                                            paramcheck=isequal(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},compressionLibrary{j}.WaveformSpecification{k}{columnCompression+1});
                                            if~paramcheck
                                                break;
                                            end
                                        else
                                            break;
                                        end
                                    end
                                    if strcmp(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},'Zadoff-chu')

                                        isseqidxLibrary=cellfun(@(x)isequal(x,'SequenceIndex'),waveformLibrary{i}.WaveformSpecification{k});
                                        [~,columnWaveform]=find(isseqidxLibrary);
                                        isseqidxLibrary=cellfun(@(x)isequal(x,'SequenceIndex'),compressionLibrary{j}.WaveformSpecification{k});
                                        [~,columnCompression]=find(isseqidxLibrary);
                                        if~isempty(columnWaveform)&&~isempty(columnCompression)
                                            seqidxcheck=isequal(waveformLibrary{i}.WaveformSpecification{k}{columnWaveform+1},compressionLibrary{j}.WaveformSpecification{k}{columnCompression+1});
                                            if~seqidxcheck
                                                break;
                                            end
                                        else
                                            break;
                                        end
                                    end
                                    wavespeccount=wavespeccount+1;
                                end
                            end
                        end
                        if(wavespeccount==numel(waveformLibrary{i}.WaveformSpecification)&&wavespeccount==numel(compressionLibrary{j}.WaveformSpecification))
                            waveformLibrary{i}=[];%#ok<AGROW>
                            waveformLibraryName{i}=[];%#ok<AGROW>
                            break;
                        end
                    end
                end
            end
            if~isempty(waveformLibrary)
                waveformLibrary=waveformLibrary(~cellfun(@isempty,waveformLibrary));
                waveformLibraryName=waveformLibraryName(~cellfun(@isempty,waveformLibraryName));
            end

            importLibraryParametersUpdate(self,View,waveformLibrary,waveformLibraryName);

            importLibraryParametersUpdate(self,View,compressionLibrary,compressionLibraryName);

            for i=1:numel(waveformimp)
                if~isempty(self.StoreData)
                    dataindex=numel(self.StoreData.Elements)+1;
                else
                    dataindex=1;
                end
                if isa(waveformimp{i},'phased.RectangularWaveform')

                    self.StoreData.Elements{dataindex}=phased.apps.internal.WaveformViewer.RectangularWaveform;
                    self.StoreData.Elements{dataindex}.SampleRate=waveformimp{i}.SampleRate;
                    self.StoreData.Elements{dataindex}.PRF=waveformimp{i}.PRF;
                    self.StoreData.Elements{dataindex}.NumPulses=waveformimp{i}.NumPulses;
                    self.StoreData.Elements{dataindex}.Name=waveName{i};
                    if strcmp(waveformimp{i}.DurationSpecification,'Duty cycle')
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.DutyCycle/waveformimp{i}.PRF;
                    else
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.PulseWidth;
                    end
                elseif isa(waveformimp{i},'phased.LinearFMWaveform')

                    self.StoreData.Elements{dataindex}=phased.apps.internal.WaveformViewer.LinearFMWaveform;
                    self.StoreData.Elements{dataindex}.SampleRate=waveformimp{i}.SampleRate;
                    self.StoreData.Elements{dataindex}.PRF=waveformimp{i}.PRF;
                    self.StoreData.Elements{dataindex}.NumPulses=waveformimp{i}.NumPulses;
                    self.StoreData.Elements{dataindex}.Name=waveName{i};
                    if strcmp(waveformimp{i}.DurationSpecification,'Duty cycle')
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.DutyCycle/waveformimp{i}.PRF;
                    else
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.PulseWidth;
                    end
                    self.StoreData.Elements{dataindex}.SweepBandwidth=waveformimp{i}.SweepBandwidth;
                    self.StoreData.Elements{dataindex}.SweepDirection=waveformimp{i}.SweepDirection;
                    self.StoreData.Elements{dataindex}.SweepInterval=waveformimp{i}.SweepInterval;
                    self.StoreData.Elements{dataindex}.Envelope=waveformimp{i}.Envelope;
                elseif isa(waveformimp{i},'phased.SteppedFMWaveform')

                    self.StoreData.Elements{dataindex}=phased.apps.internal.WaveformViewer.SteppedFMWaveform;
                    self.StoreData.Elements{dataindex}.SampleRate=waveformimp{i}.SampleRate;
                    self.StoreData.Elements{dataindex}.PRF=waveformimp{i}.PRF;
                    self.StoreData.Elements{dataindex}.NumPulses=waveformimp{i}.NumPulses;
                    self.StoreData.Elements{dataindex}.Name=waveName{i};
                    if strcmp(waveformimp{i}.DurationSpecification,'Duty cycle')
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.DutyCycle/waveformimp{i}.PRF;
                    else
                        self.StoreData.Elements{dataindex}.PulseWidth=waveformimp{i}.PulseWidth;
                    end
                    self.StoreData.Elements{dataindex}.FrequencyStep=waveformimp{i}.FrequencyStep;
                    self.StoreData.Elements{dataindex}.NumSteps=waveformimp{i}.NumSteps;
                elseif isa(waveformimp{i},'phased.PhaseCodedWaveform')

                    self.StoreData.Elements{dataindex}=phased.apps.internal.WaveformViewer.PhaseCodedWaveform;
                    self.StoreData.Elements{dataindex}.SampleRate=waveformimp{i}.SampleRate;
                    self.StoreData.Elements{dataindex}.PRF=waveformimp{i}.PRF;
                    self.StoreData.Elements{dataindex}.NumPulses=waveformimp{i}.NumPulses;
                    self.StoreData.Elements{dataindex}.ChipWidth=waveformimp{i}.ChipWidth;
                    self.StoreData.Elements{dataindex}.Code=waveformimp{i}.Code;
                    self.StoreData.Elements{dataindex}.NumChips=num2str(waveformimp{i}.NumChips);
                    self.StoreData.Elements{dataindex}.Name=waveName{i};
                    if strcmp(waveformimp{i}.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                        self.StoreData.Elements{dataindex}.SequenceIndex=waveformimp{i}.SequenceIndex;
                    end
                elseif isa(waveformimp{i},'phased.FMCWWaveform')

                    self.StoreData.Elements{dataindex}=phased.apps.internal.WaveformViewer.FMCWWaveform;
                    self.StoreData.Elements{dataindex}.SampleRate=waveformimp{i}.SampleRate;
                    self.StoreData.Elements{dataindex}.SweepTime=waveformimp{i}.SweepTime;
                    self.StoreData.Elements{dataindex}.SweepBandwidth=waveformimp{i}.SweepBandwidth;
                    self.StoreData.Elements{dataindex}.SweepDirection=waveformimp{i}.SweepDirection;
                    self.StoreData.Elements{dataindex}.SweepInterval=waveformimp{i}.SweepInterval;
                    self.StoreData.Elements{dataindex}.NumSweeps=waveformimp{i}.NumSweeps;
                    self.StoreData.Elements{dataindex}.Name=waveName{i};
                    self.ProcessData.Processes{dataindex}=phased.apps.internal.WaveformViewer.Dechirp;
                end
                if~isa(waveformimp{i},'phased.FMCWWaveform')
                    for j=1:numel(rangeProcessing)
                        if isa(rangeProcessing{j},'phased.MatchedFilter')
                            wavCoefficients=getMatchedFilter(waveformimp{i});
                            checknumelcoeff=numel(wavCoefficients(:,1))==numel(rangeProcessing{j}.Coefficients);
                            if checknumelcoeff
                                if rangeProcessing{j}.Coefficients==wavCoefficients(:,1)
                                    self.ProcessData.Processes{dataindex}=phased.apps.internal.WaveformViewer.MatchedFilter;
                                    self.ProcessData.Processes{dataindex}.SpectrumWindow=rangeProcessing{j}.SpectrumWindow;
                                    if strcmp(rangeProcessing{j}.SpectrumWindow,'Taylor')
                                        self.ProcessData.Processes{dataindex}.SpectrumRange=rangeProcessing{j}.SpectrumRange;
                                        self.ProcessData.Processes{dataindex}.SideLobeAttenuation=rangeProcessing{j}.SidelobeAttenuation;
                                        self.ProcessData.Processes{dataindex}.Nbar=rangeProcessing{j}.Nbar;
                                    elseif strcmp(rangeProcessing{j}.SpectrumWindow,'Chebyshev')
                                        self.ProcessData.Processes{dataindex}.SpectrumRange=rangeProcessing{j}.SpectrumRange;
                                        self.ProcessData.Processes{dataindex}.SideLobeAttenuation=rangeProcessing{j}.SidelobeAttenuation;
                                    elseif strcmp(rangeProcessing{j}.SpectrumWindow,'Kaiser')
                                        self.ProcessData.Processes{dataindex}.SpectrumRange=rangeProcessing{j}.SpectrumRange;
                                        self.ProcessData.Processes{dataindex}.Beta=rangeProcessing{j}.Beta;
                                    else
                                        self.ProcessData.Processes{dataindex}.SpectrumRange=rangeProcessing{j}.SpectrumRange;
                                    end
                                    rangeProcessing{j}={};
                                    rangeProcessName{j}={};
                                    break
                                end
                            end
                        elseif isa(rangeProcessing{j},'phased.StretchProcessor')
                            if isa(waveformimp{i},'phased.LinearFMWaveform')
                                checkPRF=(waveformimp{i}.PRF==rangeProcessing{j}.PRF);
                                checkPulseWidth=(waveformimp{i}.PulseWidth==rangeProcessing{j}.PulseWidth);
                                checkSweepInterval=(waveformimp{i}.SweepInterval==rangeProcessing{j}.SweepInterval);
                                if checkPRF||checkPulseWidth||checkSweepInterval
                                    self.ProcessData.Processes{dataindex}=phased.apps.internal.WaveformViewer.StretchProcessor;
                                    self.ProcessData.Processes{dataindex}.ReferenceRange=rangeProcessing{j}.ReferenceRange;
                                    self.ProcessData.Processes{dataindex}.RangeSpan=rangeProcessing{j}.RangeSpan;
                                    rangeProcessing{j}={};
                                    rangeProcessName{j}={};
                                    break
                                end
                            end
                        end
                    end
                    if~isempty(rangeProcessing)
                        if~isempty(rangeProcessing{j})
                            self.ProcessData.Processes{dataindex}=phased.apps.internal.WaveformViewer.MatchedFilter;
                        end
                        rangeProcessing=rangeProcessing(~cellfun(@isempty,rangeProcessing));
                        rangeProcessName=rangeProcessName(~cellfun(@isempty,rangeProcessName));
                    else
                        self.ProcessData.Processes{dataindex}=phased.apps.internal.WaveformViewer.MatchedFilter;
                    end
                end
            end
            cond=~isempty(rangeProcessing);
            if cond
                rangeProcessName=string(rangeProcessName);
                rangeProcessName=join(rangeProcessName,",");
                throwError(View,getString(message('phased:apps:waveformapp:compressionerr',rangeProcessName)));
                return;
            end
            cond=(numel(self.StoreData.Elements)~=numel(self.ProcessData.Processes));
            if cond
                wavecount=numel(self.StoreData.Elements);
                rangeprocesscount=numel(self.ProcessData.Processes);
                for i=rangeprocesscount+1:wavecount
                    self.ProcessData.Processes{i}=phased.apps.internal.WaveformViewer.MatchedFilter;
                end
            end
            self.notify('NewModel',...
            phased.apps.internal.WaveformViewer.LoadingEventData(self.Name,self.StoreData,self.ProcessData,''));
        end
        function importLibraryParametersUpdate(self,View,Library,LibraryName)
            for l=1:numel(Library)

                WaveformSpec=Library{l}.WaveformSpecification;
                k=numel(WaveformSpec);
                for i=1:k
                    if~isempty(self.StoreData)
                        index=numel(self.StoreData.Elements)+1;
                    else
                        index=1;
                    end
                    waveform=WaveformSpec{i}{1};
                    waveform=validatestring(waveform,{'Rectangular','LinearFM','SteppedFM','PhaseCoded'});
                    switch waveform
                    case 'Rectangular'
                        j=numel(Library{l}.WaveformSpecification{i});
                        self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.RectangularWaveform;
                        j=(j-1)/2;
                        for k=1:j
                            parameter=Library{l}.WaveformSpecification{i}{2*k};
                            validStr=validatestring(parameter,{'PRF','PulseWidth','FrequencyOffset','DutyCycle'});
                            id=find(strcmpi(validStr,{'PRF','PulseWidth','FrequencyOffset','DutyCycle'}));
                            switch id
                            case 1
                                self.StoreData.Elements{index}.PRF=WaveformSpec{i}{(2*k)+1};
                            case 2
                                self.StoreData.Elements{index}.PulseWidth=WaveformSpec{i}{(2*k)+1};
                            case 3
                                self.StoreData.Elements{index}.FrequencyOffset=WaveformSpec{i}{(2*k)+1};
                            case 4
                                rectDutyCycle=WaveformSpec{i}{(2*k)+1};
                            end
                        end
                        if exist('rectDutyCycle','var')
                            self.StoreData.Elements{index}.PulseWidth=rectDutyCycle/self.StoreData.Elements{i}.PRF;
                        end
                        self.StoreData.Elements{index}.SampleRate=Library{l}.SampleRate;
                    case 'LinearFM'
                        j=numel(Library{l}.WaveformSpecification{i});
                        self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.LinearFMWaveform;
                        j=(j-1)/2;
                        for k=1:j
                            parameter=Library{l}.WaveformSpecification{i}{2*k};
                            validStr=validatestring(parameter,{'PRF','PulseWidth','SweepBandwidth','SweepDirection','SweepInterval','Envelope','FrequencyOffset','DutyCycle'});
                            id=find(strcmpi(validStr,{'PRF','PulseWidth','SweepBandwidth','SweepDirection','SweepInterval','Envelope','FrequencyOffset','DutyCycle'}));
                            switch id
                            case 1
                                self.StoreData.Elements{index}.PRF=WaveformSpec{i}{(2*k)+1};
                            case 2
                                self.StoreData.Elements{index}.PulseWidth=WaveformSpec{i}{(2*k)+1};
                            case 3
                                self.StoreData.Elements{index}.SweepBandwidth=WaveformSpec{i}{(2*k)+1};
                            case 4
                                self.StoreData.Elements{index}.SweepDirection=WaveformSpec{i}{(2*k)+1};
                            case 5
                                self.StoreData.Elements{index}.SweepInterval=WaveformSpec{i}{(2*k)+1};
                            case 6
                                self.StoreData.Elements{index}.Envelope=WaveformSpec{i}{(2*k)+1};
                            case 7
                                self.StoreData.Elements{index}.FrequencyOffset=WaveformSpec{i}{(2*k)+1};
                            case 8
                                linearDutyCycle=WaveformSpec{i}{(2*k)+1};
                            end
                        end
                        if exist('linearDutyCycle','var')
                            self.StoreData.Elements{index}.PulseWidth=linearDutyCycle/self.StoreData.Elements{i}.PRF;
                        end
                        self.StoreData.Elements{index}.SampleRate=Library{l}.SampleRate;
                    case 'SteppedFM'
                        j=numel(Library{l}.WaveformSpecification{i});
                        self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.SteppedFMWaveform;
                        j=(j-1)/2;
                        for k=1:j
                            parameter=Library{l}.WaveformSpecification{i}{2*k};
                            validStr=validatestring(parameter,{'PRF','PulseWidth','FrequencyStep','NumSteps','FrequencyOffset','DutyCycle'});
                            id=find(strcmpi(validStr,{'PRF','PulseWidth','FrequencyStep','NumSteps','FrequencyOffset','DutyCycle'}));
                            switch id
                            case 1
                                self.StoreData.Elements{index}.PRF=WaveformSpec{i}{(2*k)+1};
                            case 2
                                self.StoreData.Elements{index}.PulseWidth=WaveformSpec{i}{(2*k)+1};
                            case 3
                                self.StoreData.Elements{index}.FrequencyStep=WaveformSpec{i}{(2*k)+1};
                            case 4
                                self.StoreData.Elements{index}.NumSteps=WaveformSpec{i}{(2*k)+1};
                            case 5
                                self.StoreData.Elements{index}.FrequencyOffset=WaveformSpec{i}{(2*k)+1};
                            case 6
                                stepDutyCycle=WaveformSpec{i}{(2*k)+1};
                            end
                        end
                        if exist('stepDutyCycle','var')
                            self.StoreData.Elements{index}.PulseWidth=stepDutyCycle/self.StoreData.Elements{i}.PRF;
                        end
                        self.StoreData.Elements{index}.SampleRate=Library{l}.SampleRate;
                    case 'PhaseCoded'
                        j=numel(Library{l}.WaveformSpecification{i});
                        self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.PhaseCodedWaveform;
                        j=(j-1)/2;
                        for k=1:j
                            parameter=Library{l}.WaveformSpecification{i}{2*k};
                            validStr=validatestring(parameter,{'PRF','ChipWidth','Code','NumChips','FrequencyOffset','SequenceIndex'});
                            id=find(strcmpi(validStr,{'PRF','ChipWidth','Code','NumChips','FrequencyOffset','SequenceIndex'}));
                            switch id
                            case 1
                                self.StoreData.Elements{index}.PRF=WaveformSpec{i}{(2*k)+1};
                            case 2
                                self.StoreData.Elements{index}.ChipWidth=WaveformSpec{i}{(2*k)+1};
                            case 3
                                self.StoreData.Elements{index}.Code=WaveformSpec{i}{(2*k)+1};
                            case 4
                                self.StoreData.Elements{index}.NumChips=num2str(WaveformSpec{i}{(2*k)+1});
                            case 5
                                self.StoreData.Elements{index}.FrequencyOffset=WaveformSpec{i}{(2*k)+1};
                            case 6
                                self.StoreData.Elements{index}.SequenceIndex=WaveformSpec{i}{(2*k)+1};
                            end
                        end
                        self.StoreData.Elements{index}.SampleRate=Library{l}.SampleRate;
                    end
                    if isa(Library{l},'phased.PulseWaveformLibrary')
                        self.ProcessData.Processes{index}=phased.apps.internal.WaveformViewer.MatchedFilter;
                    else
                        j=numel(Library{l}.ProcessingSpecification{i});
                        self.ProcessData.Processes{index}=phased.apps.internal.WaveformViewer.MatchedFilter;
                        j=(j-1)/2;
                        ProcessSpec=Library{l}.ProcessingSpecification;
                        if strcmp(ProcessSpec{i}{1},'MatchedFilter')
                            for k=1:j
                                parameter=Library{l}.ProcessingSpecification{i}{2*k};
                                try
                                    validStr=validatestring(parameter,{'SpectrumWindow','SpectrumRange','SidelobeAttenuation','Nbar','Beta'});
                                catch
                                    wavelib=phased.PulseWaveformLibrary('SampleRate',Library{:}.SampleRate,'WaveformSpecification',Library{:}.WaveformSpecification);
                                    coefficientLib=getMatchedFilter(wavelib,1);
                                    if~isequal(coefficientLib,ProcessSpec{i}{(2*k)+1})
                                        throwError(View,getString(message('phased:apps:waveformapp:InvalidCoefficientsParam',parameter,LibraryName{l})));
                                        return;
                                    end
                                end
                                id=find(strcmpi(validStr,{'SpectrumWindow','SpectrumRange','SidelobeAttenuation','Nbar','Beta'}));
                                if~isempty(id)
                                    switch id
                                    case 1
                                        self.ProcessData.Processes{index}.SpectrumWindow=ProcessSpec{i}{(2*k)+1};
                                    case 2
                                        self.ProcessData.Processes{index}.SpectrumRange=ProcessSpec{i}{(2*k)+1};
                                    case 3
                                        self.ProcessData.Processes{index}.SideLobeAttenuation=ProcessSpec{i}{(2*k)+1};
                                    case 4
                                        self.ProcessData.Processes{index}.Nbar=ProcessSpec{i}{(2*k)+1};
                                    case 5
                                        self.ProcessData.Processes{index}.Beta=ProcessSpec{i}{(2*k)+1};
                                    end
                                end
                            end
                        else
                            self.ProcessData.Processes{index}=phased.apps.internal.WaveformViewer.StretchProcessor;
                            self.ProcessData.Processes{index}.RangeFFTLength=self.StoreData.Elements{i}.SampleRate/self.StoreData.Elements{i}.PRF;
                            for k=1:j
                                parameter=Library{l}.ProcessingSpecification{i}{2*k};
                                validStr=validatestring(parameter,{'ReferenceRange','RangeSpan','RangeWindow','RangeFFTLength','SideLobeAttenuation','Nbar','Beta'});
                                id=find(strcmpi(validStr,{'ReferenceRange','RangeSpan','RangeWindow','RangeFFTLength','SideLobeAttenuation','Nbar','Beta'}));
                                switch id
                                case 1
                                    self.ProcessData.Processes{index}.ReferenceRange=ProcessSpec{i}{(2*k)+1};
                                case 2
                                    self.ProcessData.Processes{index}.RangeSpan=ProcessSpec{i}{(2*k)+1};
                                case 3
                                    self.ProcessData.Processes{index}.RangeWindow=ProcessSpec{i}{(2*k)+1};
                                case 4
                                    self.ProcessData.Processes{index}.RangeFFTLength=ProcessSpec{i}{(2*k)+1};
                                case 5
                                    self.ProcessData.Processes{index}.SideLobeAttenuation=ProcessSpec{i}{(2*k)+1};
                                case 6
                                    self.ProcessData.Processes{index}.Nbar=ProcessSpec{i}{(2*k)+1};
                                case 7
                                    self.ProcessData.Processes{index}.Beta=ProcessSpec{i}{(2*k)+1};
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Hidden)
        function matfilepath=getMatFilePath(self)


            if isempty(self.MatFilePath)
                [matfile,pathname]=...
                uiputfile({'*.mat','Radar Waveform Analyzer MAT-Files(*.mat)'},getString(message('phased:apps:waveformapp:SaveasLabel')),...
                [self.DefaultName,'.mat']);
            else
                [matfile,pathname]=...
                uiputfile('*.mat',getString(message('phased:apps:waveformapp:SaveasLabel')),self.MatFilePath);
            end
            isCanceled=isequal(matfile,0)||isequal(pathname,0);
            if isCanceled
                matfilepath=0;
            else
                matfilepath=[pathname,matfile];
            end
        end
        function saveAction(self,View,matfilepath)

            self.Name=self.DefaultName;
            if nargin<3

                if isempty(self.MatFilePath)
                    matfilepath=getMatFilePath(self);
                    if isequal(matfilepath,0)
                        return
                    end
                    self.MatFilePath=matfilepath;
                else
                    matfilepath=self.MatFilePath;
                end
            end
            try

                [~,name]=fileparts(matfilepath);
                numWaveforms={View.Canvas.RectNum,View.Canvas.LinearNum,View.Canvas.StepNum,View.Canvas.PCNum,View.Canvas.FMCWNum};
                LibrarySession.data={self.StoreData,self.ProcessData};
                LibrarySession.numWaveforms=numWaveforms;
                LibrarySession.PRFPRIIndex=View.Parameters.PRFPRIIndex;
                save(matfilepath,'LibrarySession')

                self.MatFilePath=matfilepath;
            catch me
                throwError(View,getString(message('phased:apps:waveformapp:SaveFailed',name)),me);
            end
            self.notify('TitleSave',...
            phased.apps.internal.WaveformViewer.TitleEventData(name));
            self.Name=name;
        end
        function flag=savePopupActions(self,View,str)
            switch str
            case getString(message('phased:apps:waveformapp:SaveButton'))
                saveAction(self,View)
            case getString(message('phased:apps:waveformapp:SaveasLabel'))
                matfilepath=getMatFilePath(self);
                if isequal(matfilepath,0)
                    flag=1;
                    return;
                end
                flag=0;
                saveAction(self,View,matfilepath);
            end
        end
        function exportWavPopupActions(self,View,str)
            if numel(View.Canvas.WaveformList.getSelectedRows)>1
                exportLibraryPopupActions(self,View,str);
                return;
            end
            figure(View.ParametersFig);
            elem=self.StoreData.Elements;
            process=self.ProcessData.Processes;
            index=View.Canvas.SelectIdx;
            k=numel(index);
            wav=elem{index(k)};
            comp=process{index(k)};
            switch str
            case getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel'))

                exportWavAction(self,index(k));
            case getString(message('phased:apps:waveformapp:WaveformScriptLabel'))

                phased.apps.internal.WaveformViewer.exportWaveformScript(View,wav,comp);
            case getString(message('phased:apps:waveformapp:WaveformFileLabel'))

                matfilepath=getMatFilePath(self);
                if isequal(matfilepath,0)
                    return;
                end
                phased.apps.internal.WaveformViewer.exportWaveformFile(View,wav,comp,matfilepath);
            case getString(message('phased:apps:waveformapp:SimulinkLabel'))

                setAppStatus(View,true);
                phased.apps.internal.WaveformViewer.exportWaveformSimulink(wav,comp)
                setAppStatus(View,false);
            case getString(message('phased:apps:waveformapp:WaveformReportLabel'))

                phased.apps.internal.WaveformViewer.exportReport(View,wav,comp);
            end
        end
        function exportWavAction(self,index,name)

            waveform=self.StoreData;
            wav=waveform.Elements;
            wav=wav{index};
            process=self.ProcessData;
            comp=process.Processes;
            comp=comp{index};
            Waveform=phased.apps.internal.WaveformViewer.WaveformProperties(wav);
            CompressionType=phased.apps.internal.WaveformViewer.getWaveformString(class(comp));
            Compression=phased.apps.internal.WaveformViewer.compressionProperties(wav,comp);
            if index==1
                compname='compression';
                wavname='waveform';
            else
                compname=['compression',num2str(index-1)];
                wavname=['waveform',num2str(index-1)];
            end
            if~strcmp(CompressionType,'Dechirp')
                workspaceVar=evalin('base','whos');
                if numel(workspaceVar)>=1
                    for i=1:numel(workspaceVar)
                        validateNames{i}=workspaceVar(i).name;
                    end
                    waveformName=matlab.lang.makeUniqueStrings(wavname,validateNames);
                    CompressionName=matlab.lang.makeUniqueStrings(compname,validateNames);
                else
                    waveformName=matlab.lang.makeUniqueStrings(wavname);
                    CompressionName=matlab.lang.makeUniqueStrings(compname);
                end
                checkLabels={getString(message('phased:apps:waveformapp:ExportWaveformLabel'))...
                ,getString(message('phased:apps:waveformapp:ExportCompressionLabel'))};
                varNames={waveformName,CompressionName};
                items={Waveform,Compression};
                [~,okPressed]=export2wsdlg(checkLabels,varNames,items);%#ok<ASGLU>
            else
                workspaceVar=evalin('base','whos');
                if numel(workspaceVar)>=1
                    for i=1:numel(workspaceVar)
                        validateNames{i}=workspaceVar(i).name;
                    end
                    waveformName=matlab.lang.makeUniqueStrings(wavname,validateNames);
                else
                    waveformName=wavname;
                end
                checkLabels={getString(message('phased:apps:waveformapp:ExportWaveformLabel'))};
                varNames={lower(waveformName)};
                items={Waveform};
                [~,okPressed]=export2wsdlg(checkLabels,varNames,items);%#ok<ASGLU>
            end
        end
        function exportLibraryPopupActions(self,View,str)
            index=View.Canvas.WaveformList.getSelectedRows();
            Elem=self.StoreData.Elements;
            k=numel(index);
            Process=self.ProcessData.Processes;
            figure(View.ParametersFig);



            for i=1:k
                waveform=class(Elem{index(i)});
                process=class(Process{index(i)});
                if strcmp(waveform,'phased.apps.internal.WaveformViewer.FMCWWaveform')
                    if~View.Toolstrip.IsAppContainer
                        h=warndlg(getString(message('phased:apps:waveformapp:ContinuousLibrary')),...
                        getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal');
                        uiwait(h);
                    else
                        uialert(View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:ContinuousLibrary')),...
                        getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Modal',true,'Icon','warning');
                    end
                    break;
                end
            end


            phased.apps.internal.WaveformViewer.NumPulsesMsg(self,View,index);
            wav=self.StoreData.Elements;
            comp=self.ProcessData.Processes;
            j=numel(index);
            for m=1:numel(index)
                i=index(m);
                WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(wav{i}));
                if strcmp(WaveformType,'FMCWWaveform')
                    j=j-1;
                end
            end
            wavLib=cell(1,j);
            compLib=cell(1,j);
            j=0;

            for m=1:numel(index)
                j=j+1;
                i=index(m);
                WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(wav{i}));
                CompType=phased.apps.internal.WaveformViewer.getWaveformString(class(comp{i}));
                switch WaveformType
                case 'LinearFMWaveform'
                    if strcmp(wav{i}.SweepDirection,getString(message('phased:apps:waveformapp:up')))
                        SweepDirection{i}='Up';
                    elseif strcmp(wav{i}.SweepDirection,getString(message('phased:apps:waveformapp:dwn')))
                        SweepDirection{i}='Down';
                    elseif strcmp(wav{i}.SweepDirection,getString(message('phased:apps:waveformapp:triangle')))
                        SweepDirection{i}='Triangle';
                    end
                    if strcmp(wav{i}.SweepInterval,getString(message('phased:apps:waveformapp:positive')))
                        SweepInterval{i}='Positive';
                    elseif strcmp(wav{i}.SweepInterval,getString(message('phased:apps:waveformapp:symmetric')))
                        SweepInterval{i}='Symmetric';
                    end
                    if strcmp(wav{i}.Envelope,getString(message('phased:apps:waveformapp:RectangularEnv')))
                        Envelope{i}='Rectangular';
                    elseif strcmp(wav{i}.Envelope,getString(message('phased:apps:waveformapp:gaussian')))
                        Envelope{i}='Gaussian';
                    end
                    wavLib{j}={'LinearFM','PRF',wav{i}.PRF,'PulseWidth',wav{i}.PulseWidth,'FrequencyOffset',wav{i}.FrequencyOffset,'SweepBandwidth',wav{i}.SweepBandwidth,'SweepDirection',SweepDirection{i},'SweepInterval',SweepInterval{i},'Envelope',Envelope{i}};
                case 'RectangularWaveform'
                    wavLib{j}={'Rectangular','PRF',wav{i}.PRF,'PulseWidth',wav{i}.PulseWidth,'FrequencyOffset',wav{i}.FrequencyOffset};
                case 'SteppedFMWaveform'
                    wavLib{j}={'SteppedFM','PRF',wav{i}.PRF,'PulseWidth',wav{i}.PulseWidth,'FrequencyOffset',wav{i}.FrequencyOffset,'FrequencyStep',wav{i}.FrequencyStep,'NumSteps',wav{i}.NumSteps};
                case 'PhaseCodedWaveform'
                    if strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:Barker')))
                        Code{i}='Barker';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:Frank')))
                        Code{i}='Frank';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:P1')))
                        Code{i}='P1';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:P2')))
                        Code{i}='P2';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:P3')))
                        Code{i}='P3';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:P4')))
                        Code{i}='P4';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:Px')))
                        Code{i}='Px';
                    elseif strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                        Code{i}='Zadoff-Chu';
                    end
                    if strcmp(wav{i}.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                        wavLib{j}={'PhaseCoded','PRF',wav{i}.PRF,'ChipWidth',wav{i}.ChipWidth,'FrequencyOffset',wav{i}.FrequencyOffset,'Code',Code{i},'NumChips',str2double(wav{i}.NumChips),'SequenceIndex',wav{i}.SequenceIndex};
                    else
                        wavLib{j}={'PhaseCoded','PRF',wav{i}.PRF,'ChipWidth',wav{i}.ChipWidth,'FrequencyOffset',wav{i}.FrequencyOffset,'Code',Code{i},'NumChips',str2double(wav{i}.NumChips)};
                    end
                case 'FMCWWaveform'
                    j=j-1;
                end
                switch CompType
                case 'MatchedFilter'
                    if strcmp(comp{i}.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                        compLib{j}={'MatchedFilter','SpectrumWindow',comp{i}.SpectrumWindow,'SpectrumRange',comp{i}.SpectrumRange,'SideLobeAttenuation',comp{i}.SideLobeAttenuation,'Nbar',comp{i}.Nbar};
                    elseif strcmp(comp{i}.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                        compLib{j}={'MatchedFilter','SpectrumWindow',comp{i}.SpectrumWindow,'SpectrumRange',comp{i}.SpectrumRange,'SideLobeAttenuation',comp{i}.SideLobeAttenuation};
                    elseif strcmp(comp{i}.SpectrumWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                        compLib{j}={'MatchedFilter','SpectrumWindow',comp{i}.SpectrumWindow,'SpectrumRange',comp{i}.SpectrumRange,'Beta',comp{i}.Beta};
                    elseif strcmp(comp{i}.SpectrumWindow,getString(message('phased:apps:waveformapp:None')))
                        compLib{j}={'MatchedFilter','SpectrumWindow',comp{i}.SpectrumWindow};
                    else
                        compLib{j}={'MatchedFilter','SpectrumWindow',comp{i}.SpectrumWindow,'SpectrumRange',comp{i}.SpectrumRange};
                    end
                case 'StretchProcessor'
                    switch comp{i}.RangeWindow
                    case 'Chebyshev'
                        compLib{j}={'StretchProcessor','ReferenceRange',comp{i}.ReferenceRange,'RangeSpan',comp{i}.RangeSpan,'RangeWindow',comp{i}.RangeWindow,'RangeFFTLength',comp{i}.RangeFFTLength,'SideLobeAttenuation',comp{i}.SideLobeAttenuation};
                    case 'Kaiser'
                        compLib{j}={'StretchProcessor','ReferenceRange',comp{i}.ReferenceRange,'RangeSpan',comp{i}.RangeSpan,'RangeWindow',comp{i}.RangeWindow,'RangeFFTLength',comp{i}.RangeFFTLength,'Beta',comp{i}.Beta};
                    case 'Taylor'
                        compLib{j}={'StretchProcessor','ReferenceRange',comp{i}.ReferenceRange,'RangeSpan',comp{i}.RangeSpan,'RangeWindow',comp{i}.RangeWindow,'RangeFFTLength',comp{i}.RangeFFTLength,'SideLobeAttenuation',comp{i}.SideLobeAttenuation,'Nbar',comp{i}.Nbar};
                    otherwise
                        compLib{j}={'StretchProcessor','ReferenceRange',comp{i}.ReferenceRange,'RangeSpan',comp{i}.RangeSpan,'RangeWindow',comp{i}.RangeWindow,'RangeFFTLength',comp{i}.RangeFFTLength};
                    end
                end
            end
            WavLib=phased.PulseWaveformLibrary('WaveformSpecification',wavLib,...
            'SampleRate',wav{1}.SampleRate);
            CompLib=phased.PulseCompressionLibrary('WaveformSpecification',wavLib,...
            'ProcessingSpecification',compLib,...
            'SampleRate',wav{1}.SampleRate,'PropagationSpeed',wav{1}.PropagationSpeed);
            try
                step(WavLib,1);
            catch me
                throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                return
            end
            switch str
            case getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel'))


                checkLabels={getString(message('phased:apps:waveformapp:ExportWaveformLibrary')),...
                getString(message('phased:apps:waveformapp:ExportCompressionLibrary'))};
                varNames={'waveformLib','compressionLib'};
                items={WavLib,CompLib};
                [~,okPressed]=export2wsdlg(checkLabels,varNames,items);%#ok<ASGLU>
            case getString(message('phased:apps:waveformapp:WaveformScriptLabel'))

                phased.apps.internal.WaveformViewer.exportLibraryScript(self.StoreData,self.ProcessData,index);
            case getString(message('phased:apps:waveformapp:WaveformFileLabel'))


                [matfile,pathname]=...
                uiputfile({'*.mat','(*.mat)'},getString(message('phased:apps:waveformapp:SaveasLabel')),...
                [self.DefaultName,'.mat']);
                isCanceled=isequal(matfile,0)||isequal(pathname,0);
                if isCanceled
                    return
                else
                    matfilepath=[pathname,matfile];
                end
                prompt={getString(message('phased:apps:waveformapp:ExportWaveformLibrary')),getString(message('phased:apps:waveformapp:ExportCompressionLibrary'))};
                dlgtitle=getString(message('phased:apps:waveformapp:ExportToFileTitle'));
                dims=[1,60];
                definput={'waveformLib','compressionLib'};
                input=inputdlg(prompt,dlgtitle,dims,definput);
                if~isempty(input)
                    while~isempty(input)&&(isempty(input{1})||isempty(input{2}))
                        if~View.Toolstrip.IsAppContainer
                            uiwait(warndlg(getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal'));
                        else
                            uialert(View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:entervalidnames')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Icon','warning','Modal',true);
                        end
                        input=inputdlg(prompt,dlgtitle,dims,definput);
                    end
                    lib={WavLib,CompLib};
                    libchanged=cell2struct(lib,input',2);
                    save(matfilepath,'-struct','libchanged');
                end
            case getString(message('phased:apps:waveformapp:SimulinkLabel'))


                setAppStatus(View,true);
                phased.apps.internal.WaveformViewer.exportLibrarySimulink(wav{1}.SampleRate,wav{1}.PropagationSpeed,wavLib,compLib)
                setAppStatus(View,false);

            end
        end
    end
    methods(Hidden)
        function systemParameterChanged(self,data)

            index=data.Index;
            switch data.Value
            case getString(message('phased:apps:waveformapp:Rectangular'))
                self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.RectangularWaveform;
                self.StoreData.Elements{index}.SampleRate=data.SampleRate;
            case getString(message('phased:apps:waveformapp:LinearFM'))
                self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.LinearFMWaveform;
                self.StoreData.Elements{index}.SampleRate=data.SampleRate;
            case getString(message('phased:apps:waveformapp:SteppedFM'))
                self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.SteppedFMWaveform;
                self.StoreData.Elements{index}.SampleRate=data.SampleRate;
            case getString(message('phased:apps:waveformapp:PhaseCoded'))
                self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.PhaseCodedWaveform;
                self.StoreData.Elements{index}.SampleRate=data.SampleRate;
            case getString(message('phased:apps:waveformapp:FMCW'))
                self.StoreData.Elements{index}=phased.apps.internal.WaveformViewer.FMCWWaveform;
                self.StoreData.Elements{index}.SampleRate=data.SampleRate;
            end
            self.StoreData.Elements{index}.Name=data.Name;
            self.Storedataref.Name=data.Name;
        end
        function waveformParameterChanged(self,data)



            index=data.Index;
            samplerate=str2double(data.Source.View.SampleRateEdit.String);
            switch data.Value
            case getString(message('phased:apps:waveformapp:Rectangular'))
                self.Storedataref=phased.apps.internal.WaveformViewer.RectangularWaveform;
            case getString(message('phased:apps:waveformapp:LinearFM'))
                self.Storedataref=phased.apps.internal.WaveformViewer.LinearFMWaveform;
            case getString(message('phased:apps:waveformapp:SteppedFM'))
                self.Storedataref=phased.apps.internal.WaveformViewer.SteppedFMWaveform;
            case getString(message('phased:apps:waveformapp:PhaseCoded'))
                self.Storedataref=phased.apps.internal.WaveformViewer.PhaseCodedWaveform;
            case getString(message('phased:apps:waveformapp:FMCW'))
                self.Storedataref=phased.apps.internal.WaveformViewer.FMCWWaveform;
            end
            self.Storedataref.SampleRate=samplerate;
            self.notify('SelectedElement',phased.apps.internal.WaveformViewer.ElementSelectedEventData(index,self.Storedataref));
        end
        function processTypeChanged(self,data)



            index=data.Index;
            switch data.Value
            case getString(message('phased:apps:waveformapp:MatchedFilter'))
                self.ProcessDataref=phased.apps.internal.WaveformViewer.MatchedFilter;
            case getString(message('phased:apps:waveformapp:StretchProcessor'))
                self.ProcessDataref=phased.apps.internal.WaveformViewer.StretchProcessor;
            case getString(message('phased:apps:waveformapp:Dechirp'))
                self.ProcessDataref=phased.apps.internal.WaveformViewer.Dechirp;
            end
            self.notify('SelectedProcess',phased.apps.internal.WaveformViewer.ProcessTypeEventData(index,self.ProcessDataref));
            stored=self.Storedataref;
            if isa(stored,'phased.apps.internal.WaveformViewer.LinearFMWaveform')
                if isa(self.ProcessDataref,'phased.apps.internal.WaveformViewer.StretchProcessor')
                    waveform=phased.LinearFMWaveform('SweepBandwidth',stored.SweepBandwidth,...
                    'PulseWidth',stored.PulseWidth,'NumPulses',stored.NumPulses,...
                    'Envelope',stored.Envelope,'SampleRate',stored.SampleRate,...
                    'SweepInterval',stored.SweepInterval,'SweepDirection',...
                    stored.SweepDirection,'FrequencyOffset',stored.FrequencyOffset,...
                    'PRF',stored.PRF);
                    x=waveform();
                    rangefftlength=numel(x);
                    data.Source.ProcessDialog.RangeFFTLength=rangefftlength;
                    data.Source.ProcessDialog.RangeFFTLengthEdit.Value=rangefftlength;
                    self.ProcessDataref.RangeFFTLength=rangefftlength;
                end
            end
        end

        function samplerateCheck(self,View)
            SampleRate=str2double(View.SampleRateEdit.String);
            k=numel(self.StoreData.Elements);
            selectedIdx=View.Canvas.WaveformList.getSelectedRows;


            if k~=0
                for i=1:k



                    for j=1:numel(selectedIdx)
                        if i==selectedIdx(j)
                            nonSelectedWaveforms=0;
                            break
                        else
                            nonSelectedWaveforms=1;
                        end
                    end
                    if nonSelectedWaveforms==1
                        Wav=class(self.StoreData.Elements{i});
                        if strcmp(Wav,'phased.apps.internal.WaveformViewer.FMCWWaveform')
                            q=SampleRate*self.StoreData.Elements{i}.SweepTime;
                            cond=any(abs(q-round(q))>eps(q));
                            if cond
                                throwError(View,getString(message('phased:apps:waveformapp:SampleRateSTLibrary',sprintf('%d',i),'SampleRate','SweepTime')));
                                return;
                            end
                        else
                            q=SampleRate/self.StoreData.Elements{i}.PRF;
                        end
                        cond=any(abs(q-round(q))>eps(q));
                        if cond
                            throwError(View,getString(message('phased:apps:waveformapp:SampleRatePRFLibrary','SampleRate','PRF',sprintf('%d',i))));
                            return;
                        end
                        if strcmp(Wav,'phased.apps.internal.WaveformViewer.PhaseCodedWaveform')
                            q=SampleRate*self.StoreData.Elements{i}.ChipWidth;
                            cond=any(abs(q-round(q))>eps(q));
                            if cond
                                throwError(View,getString(message('phased:apps:waveformapp:SampleRateSTLibrary',sprintf('%d',i),'SampleRate','SweepTime')))
                                return;
                            end
                        end
                    end
                end
                for i=1:k
                    self.StoreData.Elements{i}.SampleRate=SampleRate;
                end
                index=View.Canvas.WaveformList.getSelectedRows();
                for i=1:numel(index)
                    self.Storedataref(i).SampleRate=SampleRate;
                end
                if numel(index)>1
                    for i=1:numel(index)
                        b=self.Storedataref(i);
                        c=self.ProcessDataref(i);
                        waveformProperties=phased.apps.internal.WaveformViewer.UpdateProperties(b);
                        compressionProperties=phased.apps.internal.WaveformViewer.UpdateProperties(c);
                        self.StoreData.Elements{index(i)}=waveformProperties;
                        self.ProcessData.Processes{index(i)}=compressionProperties;
                    end
                else
                    b=self.Storedataref;
                    c=self.ProcessDataref;
                    waveformProperties=phased.apps.internal.WaveformViewer.UpdateProperties(b);
                    compressionProperties=phased.apps.internal.WaveformViewer.UpdateProperties(c);
                    self.StoreData.Elements{index}=waveformProperties;
                    self.ProcessData.Processes{index}=compressionProperties;
                end
                setAppStatus(View,true);
                View.characteristicsAction();
                setAppStatus(View,false);
                View.addplotAction();
            end
        end

        function setElementParameters(self,View,data)

            for i=1:numel(data.Index)
                if numel(data.Index)>1
                    storedref=self.Storedataref(i);
                    processdref=self.ProcessDataref(i);
                else
                    storedref=self.Storedataref;
                    processdref=self.ProcessDataref;
                end
                samplerate=str2double(data.Source.View.SampleRateEdit.String);
                storedref.SampleRate=samplerate;
                try
                    if~isa(storedref,'phased.apps.internal.WaveformViewer.FMCWWaveform')
                        q=samplerate/storedref.PRF;
                        cond=any(abs(q-round(q))>eps(q));
                        if cond
                            if data.Source.ElementDialog.PRFLabel.Value==1
                                me=MException('',getString(message('phased:apps:waveformapp:SampleRatePRF','Sample Rate','PRF')));
                            else
                                me=MException('',getString(message('phased:apps:waveformapp:SampleRatePRI','Sample Rate','PRI')));
                            end
                            throw(me);
                        end
                        if~isa(storedref,'phased.apps.internal.WaveformViewer.PhaseCodedWaveform')
                            if~(storedref.PulseWidth<=1/storedref.PRF)
                                me=MException('',getString(message('phased:apps:waveformapp:PulseWidthPRF','PRF','Pulse width')));
                                throw(me);
                            end
                        else
                            q=samplerate*storedref.ChipWidth;
                            cond=any(abs(q-round(q))>eps(q));
                            if cond
                                me=MException('',getString(message('phased:apps:waveformapp:SampleRateChipWidth','Sample Rate','Chip Width')));
                                throw(me);
                            end
                            if~(storedref.ChipWidth<=1/(storedref.PRF*(str2double(storedref.NumChips))))
                                me=MException('',getString(message('phased:apps:waveformapp:ChipWidthNumChipsPRF','Chip Width','Number of Chips','PRF')));
                                throw(me);
                            end
                            if strcmp(storedref.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                                NC=str2double(storedref.NumChips);
                                SI=storedref.SequenceIndex;
                                k=gcd(NC,SI);
                                if k~=1
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsSeqIndex','Number of Chips','Sequence Index')));
                                    throw(me);
                                end
                            end
                            switch storedref.Code
                            case getString(message('phased:apps:waveformapp:Frank'))
                                value=str2double(storedref.NumChips);
                                root=sqrt(value);
                                if floor(root)~=root
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsPerfectSq','Number of Chips')));
                                    throw(me);
                                end
                            case getString(message('phased:apps:waveformapp:P1'))
                                value=str2double(storedref.NumChips);
                                root=sqrt(value);
                                if floor(root)~=root
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsPerfectSq','Number of Chips')));
                                    throw(me);
                                end
                            case getString(message('phased:apps:waveformapp:P2'))
                                value=str2double(storedref.NumChips);
                                root=sqrt(value);
                                if floor(root)~=root
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsPerfectSq','Number of Chips')));
                                    throw(me);
                                end
                            case getString(message('phased:apps:waveformapp:Px'))
                                value=str2double(storedref.NumChips);
                                root=sqrt(value);
                                if floor(root)~=root
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsPerfectSq','Number of Chips')));
                                    throw(me);
                                end
                            case getString(message('phased:apps:waveformapp:ZadoffChu'))
                                NC=str2double(storedref.NumChips);
                                SI=storedref.SequenceIndex;
                                k=gcd(NC,SI);
                                if k~=1
                                    me=MException('',getString(message('phased:apps:waveformapp:NumChipsSeqIndex','Number of Chips','Sequence Index')));
                                    throw(me);
                                end
                            end
                        end
                    else
                        q=samplerate*storedref.SweepTime;
                        cond=any(abs(q-round(q))>eps(q));
                        if cond
                            me=MException('',getString(message('phased:apps:waveformapp:SampleRateST','Sample Rate','Sweep Time')));
                            throw(me);
                        end
                    end
                catch me
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me)
                    return;
                end
                if isa(processdref,'phased.apps.internal.WaveformViewer.MatchedFilter')
                    if~strcmpi(processdref.SpectrumWindow,'None')
                        samplerate=str2double(data.Source.View.SampleRateEdit.String);
                        cond=any(processdref.SpectrumRange<-samplerate/2)||...
                        any(processdref.SpectrumRange>samplerate/2);
                        if cond
                            throwError(View,getString(message('phased:apps:waveformapp:InvalidSpectrumRange')));
                            return
                        end
                    end
                elseif isa(processdref,'phased.apps.internal.WaveformViewer.StretchProcessor')
                    Rmin=0;
                    Rmax=3e8*(1/(2*storedref.PRF)-(storedref.PulseWidth/2));
                    Rinterval=processdref.ReferenceRange+[-1,1]*processdref.RangeSpan/2;
                    cond=Rinterval(1)<Rmin||Rinterval(2)>Rmax;
                    if cond
                        throwError(View,getString(message('phased:apps:waveformapp:ReferenceRangeandRangeSpanCheck',sprintf('%0.2f',Rmin),sprintf('%0.2f',Rmax),sprintf('%0.2f',Rinterval(1)),sprintf('%0.2f',Rinterval(2)))));
                        return
                    end
                end
            end
            samplerateCheck(self,data.Source.View);
        end

        function elementParameterChanged(self,View,data)


            stored=self.Storedataref;
            samplerate=self.StoreData.Elements{1}.SampleRate;
            stored.SampleRate=samplerate;
            try
                value=stored.(data.Name);
                stored.(data.Name)=data.Value;
            catch me
                if ischar(data.Value)
                    try
                        stored.(data.Name)=evalin('base',data.Value);
                    catch me
                        throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                        self.notify('ElementParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,stored.(data.Name)));
                    end
                else
                    stored.(data.Name)=value;
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    self.notify('ElementParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,stored.(data.Name)));
                end
            end
        end
        function compressParameterChanged(self,View,data)


            stored=self.ProcessDataref;
            try
                value=stored.(data.Name);
                stored.(data.Name)=data.Value;
            catch me
                if ischar(data.Value)
                    try
                        stored.(data.Name)=evalin('base',data.Value);
                    catch me
                        throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                        self.notify('CompressParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,stored.(data.Name)));
                    end
                else
                    stored.(data.Name)=value;
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    self.notify('CompressParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,stored.(data.Name)));
                end
            end
        end
        function multielementParameterChanged(self,View,data)

            ind=data.View.Canvas.WaveformList.getSelectedRows();
            if numel(ind)~=numel(self.Storedataref)
                return
            end
            for i=1:numel(ind)
                stored=self.Storedataref(i);
                samplerate=self.StoreData.Elements{1}.SampleRate;
                stored.SampleRate=samplerate;
                try
                    value=stored.(data.Name);
                    stored.(data.Name)=data.Value;
                catch me
                    stored.(data.Name)=value;
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    self.notify('ElementParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,stored.(data.Name)));
                    for k=1:numel(ind)
                        self.Storedataref(k).(data.Name)=value;
                    end
                    return
                end
            end
        end
        function multicompressParameterChanged(self,View,data)

            ind=data.View.Canvas.WaveformList.getSelectedRows();
            if numel(ind)~=numel(self.ProcessDataref)
                return
            end
            for i=1:numel(ind)
                stored=self.Storedataref(i);
                processd=self.ProcessDataref(i);
                samplerate=self.StoreData.Elements{1}.SampleRate;
                stored.SampleRate=samplerate;
                try
                    value=processd.(data.Name);
                    processd.(data.Name)=data.Value;
                catch me
                    processd.(data.Name)=value;
                    throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    self.notify('CompressParameterInvalid',phased.apps.internal.WaveformViewer.ParameterInvalidEventData(data.Name,processd.(data.Name)));
                    for k=1:numel(ind)
                        self.ProcessDataref(k).(data.Name)=value;
                    end
                    return
                end
            end
        end
        function multiSelectDisable(self,data)
            ind=data.Source.WaveformList.getSelectedRows();
            for i=1:numel(ind)
                index=ind(i);
                Wav=self.StoreData.Elements{index};
                selectedWaveform=phased.apps.internal.WaveformViewer.UpdateProperties(Wav);
                self.Storedataref(i)=selectedWaveform;
                Comp=self.ProcessData.Processes{index};
                selectedCompression=phased.apps.internal.WaveformViewer.UpdateProperties(Comp);
                if strcmp(class(Comp),'phased.apps.internal.WaveformViewer.MatchedFilter')&&strcmp(class(self.ProcessDataref),'phased.apps.internal.WaveformViewer.MatchedFilter')
                    self.ProcessDataref(i)=selectedCompression;
                elseif strcmp(class(Comp),'phased.apps.internal.WaveformViewer.StretchProcessor')&&strcmp(class(self.ProcessDataref),'phased.apps.internal.WaveformViewer.StretchProcessor')
                    self.ProcessDataref(i)=selectedCompression;
                end
            end
            index=ind;
            rec=0;
            lin=0;
            stp=0;
            phc=0;
            fmc=0;
            mf=0;
            sp=0;
            for i=1:numel(index)
                if isa(self.StoreData.Elements{index(i)},'phased.apps.internal.WaveformViewer.RectangularWaveform')
                    rec=rec+1;
                elseif isa(self.StoreData.Elements{index(i)},'phased.apps.internal.WaveformViewer.LinearFMWaveform')
                    lin=lin+1;
                elseif isa(self.StoreData.Elements{index(i)},'phased.apps.internal.WaveformViewer.SteppedFMWaveform')
                    stp=stp+1;
                elseif isa(self.StoreData.Elements{index(i)},'phased.apps.internal.WaveformViewer.PhaseCodedWaveform')
                    phc=phc+1;
                elseif isa(self.StoreData.Elements{index(i)},'phased.apps.internal.WaveformViewer.FMCWWaveform')
                    fmc=fmc+1;
                end
            end
            for i=1:numel(index)
                if isa(self.ProcessData.Processes{index(i)},'phased.apps.internal.WaveformViewer.MatchedFilter')
                    mf=mf+1;
                elseif isa(self.ProcessData.Processes{index(i)},'phased.apps.internal.WaveformViewer.StretchProcessor')
                    sp=sp+1;
                end
            end



            if rec>0&&rec==numel(index)
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumPulses~=self.StoreData.Elements{index(i+1)}.NumPulses
                        data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PRF~=self.StoreData.Elements{index(i+1)}.PRF
                        data.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyOffset~=self.StoreData.Elements{index(i+1)}.FrequencyOffset
                        data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PulseWidth~=self.StoreData.Elements{index(i+1)}.PulseWidth
                        data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                end
            end



            if lin>0&&lin==numel(index)
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumPulses~=self.StoreData.Elements{index(i+1)}.NumPulses
                        data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PRF~=self.StoreData.Elements{index(i+1)}.PRF
                        data.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyOffset~=self.StoreData.Elements{index(i+1)}.FrequencyOffset
                        data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PulseWidth~=self.StoreData.Elements{index(i+1)}.PulseWidth
                        data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.SweepBandwidth~=self.StoreData.Elements{index(i+1)}.SweepBandwidth
                        data.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.SweepDirection,self.StoreData.Elements{index(i+1)}.SweepDirection)
                        data.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.SweepInterval,self.StoreData.Elements{index(i+1)}.SweepInterval)
                        data.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.Envelope,self.StoreData.Elements{index(i+1)}.Envelope)
                        data.View.Parameters.ElementDialog.EnvelopeEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.EnvelopeEdit.Enable='on';
                end
            end



            if stp>0&&stp==numel(index)
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumPulses~=self.StoreData.Elements{index(i+1)}.NumPulses
                        data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PRF~=self.StoreData.Elements{index(i+1)}.PRF
                        data.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyOffset~=self.StoreData.Elements{index(i+1)}.FrequencyOffset
                        data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PulseWidth~=self.StoreData.Elements{index(i+1)}.PulseWidth
                        data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyStep~=self.StoreData.Elements{index(i+1)}.FrequencyStep
                        data.View.Parameters.ElementDialog.FrequencyStepEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyStepEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumSteps~=self.StoreData.Elements{index(i+1)}.NumSteps
                        data.View.Parameters.ElementDialog.NumStepsEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumStepsEdit.Enable='on';
                end
            end



            if phc>0&&phc==numel(index)
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumPulses~=self.StoreData.Elements{index(i+1)}.NumPulses
                        data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PRF~=self.StoreData.Elements{index(i+1)}.PRF
                        data.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyOffset~=self.StoreData.Elements{index(i+1)}.FrequencyOffset
                        data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.ChipWidth~=self.StoreData.Elements{index(i+1)}.ChipWidth
                        data.View.Parameters.ElementDialog.ChipWidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.ChipWidthEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.Code,self.StoreData.Elements{index(i+1)}.Code)&&~strcmp(self.StoreData.Elements{index(i)}.NumChips,self.StoreData.Elements{index(i+1)}.NumChips)
                        data.View.Parameters.ElementDialog.CodeEdit.Enable='off';
                        data.View.Parameters.ElementDialog.NumChipsEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.CodeEdit.Enable='on';
                    data.View.Parameters.ElementDialog.NumChipsEdit.Enable='on';
                end
                k=0;
                for i=1:numel(index)
                    if strcmp(self.StoreData.Elements{index(i)}.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                        k=k+1;
                    end
                end
                if k>0&&k==numel(index)
                    for i=1:numel(index)-1
                        if self.StoreData.Elements{index(i)}.SequenceIndex~=self.StoreData.Elements{index(i+1)}.SequenceIndex
                            data.View.Parameters.ElementDialog.SequenceIndexEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ElementDialog.SequenceIndexEdit.Enable='on';
                    end
                end
            end



            if fmc>0&&fmc~=numel(index)
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
            elseif fmc>0&&fmc==numel(index)
                haveSimulink=builtin('license','test','SIMULINK');
                if haveSimulink
                    data.Source.View.Toolstrip.SimulinkBtn.Enabled=false;
                    data.Source.View.Toolstrip.LibrarySimulinkPopup.Enabled=false;
                    data.Source.View.Toolstrip.LibraryWorkspacePopup.Enabled=false;
                end
                data.Source.View.Toolstrip.ExportBtn.Enabled=false;
                data.Source.View.Toolstrip.LibraryScriptPopup.Enabled=false;
                data.Source.View.Toolstrip.LibraryFilePopup.Enabled=false;
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumSweeps~=self.StoreData.Elements{index(i+1)}.NumSweeps
                        data.View.Parameters.ElementDialog.NumSweepsEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumSweepsEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.SweepTime~=self.StoreData.Elements{index(i+1)}.SweepTime
                        data.View.Parameters.ElementDialog.SweepTimeEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepTimeEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.SweepBandwidth~=self.StoreData.Elements{index(i+1)}.SweepBandwidth
                        data.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepBandwidthEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.SweepDirection,self.StoreData.Elements{index(i+1)}.SweepDirection)
                        data.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepDirectionEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if~strcmp(self.StoreData.Elements{index(i)}.SweepInterval,self.StoreData.Elements{index(i+1)}.SweepInterval)
                        data.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.SweepIntervalEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
            else
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.NumPulses~=self.StoreData.Elements{index(i+1)}.NumPulses
                        data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.NumPulsesEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PRF~=self.StoreData.Elements{index(i+1)}.PRF
                        data.View.Parameters.ElementDialog.PRFEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PRFEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.FrequencyOffset~=self.StoreData.Elements{index(i+1)}.FrequencyOffset
                        data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.FrequencyOffsetEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PropagationSpeed~=self.StoreData.Elements{index(i+1)}.PropagationSpeed
                        data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PropagationSpeedEdit.Enable='on';
                end
            end
            if fmc==0&&phc==0
                for i=1:numel(index)-1
                    if self.StoreData.Elements{index(i)}.PulseWidth~=self.StoreData.Elements{index(i+1)}.PulseWidth
                        data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ElementDialog.PulseWidthEdit.Enable='on';
                end
            end



            if mf>0&&mf==numel(index)
                for i=1:numel(index)-1
                    if~strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,self.ProcessData.Processes{index(i+1)}.SpectrumWindow)
                        data.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ProcessDialog.SpectrumWindowEdit.Enable='on';
                end
                spectrumrangecount=0;
                for i=1:numel(index)
                    if~strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,getString(message('phased:apps:waveformapp:None')))
                        spectrumrangecount=spectrumrangecount+1;
                    end
                end
                if spectrumrangecount>0&&spectrumrangecount==numel(index)
                    for i=1:numel(index)-1
                        if any(self.ProcessData.Processes{index(i)}.SpectrumRange~=self.ProcessData.Processes{index(i+1)}.SpectrumRange)
                            data.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.SpectrumRangeEdit.Enable='on';
                    end
                end
                slb=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                        slb=slb+1;
                    elseif strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                        slb=slb+1;
                    end
                end
                if slb>0&&slb==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.SideLobeAttenuation~=self.ProcessData.Processes{index(i+1)}.SideLobeAttenuation
                            data.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                    end
                end
                nbarcount=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                        nbarcount=nbarcount+1;
                    end
                end
                if nbarcount>0&&nbarcount==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.Nbar~=self.ProcessData.Processes{index(i+1)}.Nbar
                            data.View.Parameters.ProcessDialog.NbarEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.NbarEdit.Enable='on';
                    end
                end
                beta=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.SpectrumWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                        beta=beta+1;
                    end
                end
                if beta>0&&beta==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.Beta~=self.ProcessData.Processes{index(i+1)}.Beta
                            data.View.Parameters.ProcessDialog.BetaEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.BetaEdit.Enable='on';
                    end
                end
            end
            if sp>0&&sp==numel(index)
                for i=1:numel(index)-1
                    if~strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,self.ProcessData.Processes{index(i+1)}.RangeWindow)
                        data.View.Parameters.ProcessDialog.RangeWindowEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ProcessDialog.RangeWindowEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.ProcessData.Processes{index(i)}.ReferenceRange~=self.ProcessData.Processes{index(i+1)}.ReferenceRange
                        data.View.Parameters.ProcessDialog.ReferenceRangeEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ProcessDialog.ReferenceRangeEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.ProcessData.Processes{index(i)}.RangeSpan~=self.ProcessData.Processes{index(i+1)}.RangeSpan
                        data.View.Parameters.ProcessDialog.RangeSpanEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ProcessDialog.RangeSpanEdit.Enable='on';
                end
                for i=1:numel(index)-1
                    if self.ProcessData.Processes{index(i)}.RangeFFTLength~=self.ProcessData.Processes{index(i+1)}.RangeFFTLength
                        data.View.Parameters.ProcessDialog.RangeFFTLengthEdit.Enable='off';
                        break
                    end
                    data.View.Parameters.ProcessDialog.RangeFFTLengthEdit.Enable='on';
                end
                slb=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,getString(message('phased:apps:waveformapp:Taylor')))
                        slb=slb+1;
                    elseif strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                        slb=slb+1;
                    end
                end
                if slb>0&&slb==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.SideLobeAttenuation~=self.ProcessData.Processes{index(i+1)}.SideLobeAttenuation
                            data.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.SideLobeAttenuationEdit.Enable='on';
                    end
                end
                nbar=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,getString(message('phased:apps:waveformapp:Taylor')))
                        nbar=nbar+1;
                    elseif strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                        nbar=nbar+1;
                    end
                end
                if nbar>0&&nbar==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.Nbar~=self.ProcessData.Processes{index(i+1)}.Nbar
                            data.View.Parameters.ProcessDialog.NbarEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.NbarEdit.Enable='on';
                    end
                end
                beta=0;
                for i=1:numel(index)
                    if strcmp(self.ProcessData.Processes{index(i)}.RangeWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                        beta=beta+1;
                    end
                end
                if beta>0&&beta==numel(index)
                    for i=1:numel(index)-1
                        if self.ProcessData.Processes{index(i)}.Beta~=self.ProcessData.Processes{index(i+1)}.Beta
                            data.View.Parameters.ProcessDialog.BetaEdit.Enable='off';
                            break
                        end
                        data.View.Parameters.ProcessDialog.BetaEdit.Enable='on';
                    end
                end
            end
        end
        function duplicateInsertionRequested(self,data)

            index=data.InsertIndex;
            Wav=self.StoreData.Elements{data.SelectIndex};
            Process=self.ProcessData.Processes{data.SelectIndex};
            DuplicateWaveform=phased.apps.internal.WaveformViewer.UpdateProperties(Wav);
            DuplicateProcess=phased.apps.internal.WaveformViewer.UpdateProperties(Process);
            DuplicateWaveform.Name=strcat(Wav.Name,'Copy');
            self.StoreData.Elements{index}=DuplicateWaveform;
            self.ProcessData.Processes{index}=DuplicateProcess;
            self.notify('ElementInserted',phased.apps.internal.WaveformViewer.ModelChangedEventData(self.Name,self.StoreData,self.ProcessData,index));
        end
        function insertionRequested(self,data)

            index=data.InsertIndex;
            SampleRate=data.SampleRate;
            addelem=phased.apps.internal.WaveformViewer.RectangularWaveform;
            addprocess=phased.apps.internal.WaveformViewer.MatchedFilter;
            PRF=addelem.PRF;
            q=SampleRate/PRF;
            cond=any(abs(q-round(q))>eps(q));
            if cond
                throwError(View,getString(message('phased:apps:waveformapp:SampleRatePRFCheck',sprintf('%d',SampleRate),sprintf('%d',PRF),'Sample Rate','PRF')));
                return
            end
            addelem.SampleRate=SampleRate;
            self.StoreData.Elements{index}=addelem;
            self.ProcessData.Processes{index}=addprocess;
            self.notify('ElementInserted',phased.apps.internal.WaveformViewer.ModelChangedEventData(self.Name,self.StoreData,self.ProcessData,index));
            self.Storedataref=addelem;
        end
        function deletionRequested(self,data)

            selectIdx=data.SelectIndex;
            self.StoreData.Elements={self.StoreData.Elements{1:selectIdx-1},self.StoreData.Elements{selectIdx+1:end}};
            self.ProcessData.Processes={self.ProcessData.Processes{1:selectIdx-1},self.ProcessData.Processes{selectIdx+1:end}};
            self.notify('ElementDeleted',phased.apps.internal.WaveformViewer.ModelChangedEventData(self.Name,self.StoreData,self.ProcessData,selectIdx));
        end
        function plotRequested(self,View,data)
            k=numel(data.Source.Canvas.WaveformList.getSelectedRows);
            ind=data.Source.Canvas.WaveformList.getSelectedRows();
            for i=1:k
                index=ind(i);
                Properties=self.StoreData.Elements{index};
                Waveform=phased.apps.internal.WaveformViewer.WaveformProperties(Properties);
                WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Properties));
                if isa(Waveform,'phased.FMCWWaveform')
                    numSamples=round(Waveform.SampleRate*Waveform.SweepTime);
                else
                    numSamples=round(Waveform.SampleRate/Waveform.PRF);
                end
                if numSamples<2
                    figure(data.Source.ParametersFig);
                    data.Source.Toolstrip.WaveformScriptPopup.Enabled=false;
                    throwError(View,getString(message('phased:apps:waveformapp:AFFsPRF','graphs')));
                    return
                end

                if any(ismember(findall(0,'type','figure'),data.Source.SpectrumFig))||strcmp(data.Type,'spectrum')
                    if numSamples<9
                        figure(data.Source.ParametersFig);
                        data.Source.Toolstrip.WaveformScriptPopup.Enabled=false;
                        throwError(View,getString(message('phased:apps:waveformapp:AFFsPRF','spectrum')))
                        return
                    end

                elseif any(ismember(findall(0,'type','figure'),data.Source.SpectrogramFig))||strcmp(data.Type,'spectrogram')
                    if numSamples<11
                        figure(data.Source.ParametersFig);
                        data.Source.Toolstrip.WaveformScriptPopup.Enabled=false;
                        throwError(View,getString(message('phased:apps:waveformapp:AFFsPRF','spectrogram')))
                        return
                    end
                end
                if strcmp(WaveformType,'FMCWWaveform')
                    numSamples=Properties.SampleRate*Properties.NumSweeps*Properties.SweepTime;
                else
                    numSamples=Properties.SampleRate*Properties.NumPulses/Properties.PRF;
                end
                if numSamples>1e9
                    figure(data.Source.ParametersFig);
                    data.Source.Toolstrip.WaveformScriptPopup.Enabled=false;
                    throwError(View,getString(message('phased:apps:waveformapp:AFFsPRF','graphs')))
                    return
                end

                if numSamples>data.Source.Parameters.NumSamplesLimit
                    figure(data.Source.ParametersFig);
                    choice=questdlg(getString(message('phased:apps:waveformapp:warnstring')),...
                    getString(message('phased:apps:waveformapp:warndlgName')),...
                    getString(message('phased:apps:waveformapp:yes')),...
                    getString(message('phased:apps:waveformapp:no')),...
                    getString(message('phased:apps:waveformapp:no')));
                    if strcmp(choice,getString(message('phased:apps:waveformapp:no')))
                        return
                    end
                    if isempty(choice)
                        return
                    end

                    data.Source.Parameters.NumSamplesLimit=numSamples;
                    break


                elseif(any(ismember(findall(0,'type','figure'),data.Source.AmbiguityFunctionContourFig))||...
                    any(ismember(findall(0,'type','figure'),data.Source.AmbiguityFunctionSurfaceFig))||...
                    strcmp(data.Type,'ambiguity function-contour')||strcmp(data.Type,'ambiguity function-surface'))&&...
                    numSamples>data.Source.Parameters.NumSamplesLimit3D
                    figure(data.Source.ParametersFig);
                    choice=questdlg(getString(message('phased:apps:arrayapp:warn3dplotstring')),...
                    getString(message('phased:apps:waveformapp:warndlgName')),...
                    'yes',...
                    'no',...
                    'no');
                    if strcmp(choice,'no')
                        return
                    end
                    if isempty(choice)
                        return
                    end

                    data.Source.Parameters.NumSamplesLimit3D=numSamples;
                    if numSamples>data.Source.Parameters.NumSamplesLimit
                        data.Source.Parameters.NumSamplesLimit=numSamples;
                    end
                    break
                end
                graphtype=data.Type;
                waveproperties=self.StoreData.Elements{index};
                compproperties=self.ProcessData.Processes{index};
                self.notify('PlotAdded',phased.apps.internal.WaveformViewer.PlotEventData(waveproperties,compproperties,graphtype,index));
            end
            data.Source.Parameters.ApplyButton.ApplyButton.Enable='off';
        end
        function characteristicsRequested(self,data)

            index=data.Index;
            waveproperties=self.StoreData.Elements{index};
            self.notify('CharacteristicsAdded',phased.apps.internal.WaveformViewer.CharacteristicsEventData(waveproperties,index));
        end
        function itemSelected(self,data)
            index=data.Index;
            if numel(data.Source.WaveformList.getSelectedRows())>1
                if data.Source.View.Parameters.WaveformChanged==1
                    data.Source.notify('ElementSelected',...
                    phased.apps.internal.WaveformViewer.ElementSelectedEventData(data.Source.SelectIdx));
                end
                indices=data.Source.WaveformList.getSelectedRows();
                k=numel(indices);
                index=-1;
                for i=1:k
                    if indices(i)==data.Source.SelectIdx
                        index=data.Source.SelectIdx;
                        break
                    end
                end




                if index~=data.Source.SelectIdx
                    data.Source.SelectIdx=indices(1);
                    data.Source.notify('ElementSelected',...
                    phased.apps.internal.WaveformViewer.ElementSelectedEventData(data.Source.SelectIdx));
                end
                data.Source.multiSelectButtonsDisable(indices);
                data.Source.notify('MultiselectDisable',...
                phased.apps.internal.WaveformViewer.MultiSelectedEventData(data.Source.View));
                return
            end
            Wav=self.StoreData.Elements{index};
            Comp=self.ProcessData.Processes{index};
            self.notify('SelectedElement',phased.apps.internal.WaveformViewer.ElementSelectedEventData(index,Wav));
            self.notify('SelectedProcess',phased.apps.internal.WaveformViewer.ProcessSelectedEventData(index,Comp));
            selectedWaveform=phased.apps.internal.WaveformViewer.UpdateProperties(Wav);
            self.Storedataref=selectedWaveform;
            selectedCompression=phased.apps.internal.WaveformViewer.UpdateProperties(Comp);
            self.ProcessDataref=selectedCompression;
        end
        function elementSelected(self,data)
            index=data.Index;
            Wav=self.StoreData.Elements{index};
            Comp=self.ProcessData.Processes{index};
            self.notify('SelectedElement',phased.apps.internal.WaveformViewer.ElementSelectedEventData(index,Wav));
            self.notify('SelectedProcess',phased.apps.internal.WaveformViewer.ProcessSelectedEventData(index,Comp));
            selectedWaveform=phased.apps.internal.WaveformViewer.UpdateProperties(Wav);
            selectedCompression=phased.apps.internal.WaveformViewer.UpdateProperties(Comp);
            self.Storedataref=selectedWaveform;
            self.ProcessDataref=selectedCompression;
        end
        function updateName(self,data)

            index=data.Index;
            elem=self.StoreData.Elements{index};
            elem.Name=data.Name;
        end
        function SampleRateValueChanged(self,View)

            View.Parameters.ApplyButton.ApplyButton.Enable='on';
            try
                SampleRate=evalin('base',View.SampleRateEdit.String);
                View.SampleRateEdit.String=num2str(SampleRate);
                validateattributes(SampleRate,{'single','double'},...
                {'finite','nonempty','scalar','real','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorSampleRate','Sample Rate')))
            catch me
                throwError(View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                View.SampleRateEdit.String=num2str(self.StoreData.Elements{1}.SampleRate);
                return;
            end
        end
    end
    events(Hidden)
NewModel
NewName
TitleSave
SystemParameterInvalid
ElementParameterInvalid
ElementInserted
ElementDeleted
PlotAdded
CharacteristicsAdded
SelectedElement
namechanged
SelectedProcess
CompressParameterView
CompressParameterInvalid
    end
    methods(Static)
        function isValid=isValidLibraryFile(Library)





            isValid=isa(Library,'phased.PulseWaveformLibrary')||isa(Library,'phased.PulseCompressionLibrary');%#ok<*STISA>
        end
        function isValid=isValidSavedFile(WaveformStruct)

            variables=fieldnames(WaveformStruct);
            Waveformstruct=WaveformStruct.(variables{1});
            k=1;
            if(numel(Waveformstruct.data)==2)
                for i=1:numel(Waveformstruct.data{1}.Elements)
                    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Waveformstruct.data{1}.Elements{i}));
                    isValid(k)=strcmp(WaveformType,'RectangularWaveform')||strcmp(WaveformType,'LinearFMWaveform')...
                    ||strcmp(WaveformType,'SteppedFMWaveform')||strcmp(WaveformType,'PhaseCodedWaveform')...
                    ||strcmp(WaveformType,'FMCWWaveform')||strcmp(WaveformType,'MatchedFilter')||strcmp(WaveformType,'StretchProcessor');
                    k=k+1;
                end
                for i=1:numel(Waveformstruct.data{1}.Elements)
                    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Waveformstruct.data{2}.Processes{i}));
                    isValid(k)=strcmp(WaveformType,'MatchedFilter')||strcmp(WaveformType,'StretchProcessor')||strcmp(WaveformType,'Dechirp');
                    k=k+1;
                end
            else
                for i=1:numel(Waveformstruct.data.Elements)
                    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Waveformstruct.data.Elements{i}));
                    isValid(k)=strcmp(WaveformType,'RectangularWaveform')||strcmp(WaveformType,'LinearFMWaveform')...
                    ||strcmp(WaveformType,'SteppedFMWaveform')||strcmp(WaveformType,'PhaseCodedWaveform')...
                    ||strcmp(WaveformType,'FMCWWaveform')||strcmp(WaveformType,'MatchedFilter')||strcmp(WaveformType,'StretchProcessor');
                    k=k+1;
                end
            end
            isValid=all(isValid==1);
        end
    end
end