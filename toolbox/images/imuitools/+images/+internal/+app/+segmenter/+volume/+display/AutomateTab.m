classdef AutomateTab<handle



    events


AutomationStarted


AutomationStopped


AutomationRangeUpdated



AutomateOnAllBlocks


ManageAlgorithms


AddAlgorithm


ErrorThrown


OpenSettings


CloseDialogs

MetricsUpdated

GroundTruthImportRequested

AddCustomMetric

LoadCustomMetric

    end


    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.toolstrip.AutomateTab,...
        ?medical.internal.app.home.labeler.display.toolstrip.AutomateTab})

        Add matlab.ui.internal.toolstrip.DropDownButton
        NewVolume matlab.ui.internal.toolstrip.ListItemWithPopup
        VolumeFromFile matlab.ui.internal.toolstrip.ListItem
        Run matlab.ui.internal.toolstrip.Button
        Stop matlab.ui.internal.toolstrip.Button
        Start matlab.ui.internal.toolstrip.EditField
        End matlab.ui.internal.toolstrip.EditField
        Window matlab.ui.internal.toolstrip.DropDown
        Settings matlab.ui.internal.toolstrip.Button
        Gallery matlab.ui.internal.toolstrip.Gallery
        SliceCategory matlab.ui.internal.toolstrip.GalleryCategory
        VolumeCategory matlab.ui.internal.toolstrip.GalleryCategory
        AllBlocks matlab.ui.internal.toolstrip.ToggleButton
        UseParallel matlab.ui.internal.toolstrip.ToggleButton
        SkipCompleted matlab.ui.internal.toolstrip.ToggleButton
        Review matlab.ui.internal.toolstrip.ToggleButton
        Metrics matlab.ui.internal.toolstrip.DropDownButton
        BorderSize matlab.ui.internal.toolstrip.Spinner
        BorderSizeLabel matlab.ui.internal.toolstrip.Label
        StartLabel matlab.ui.internal.toolstrip.Label
        EndLabel matlab.ui.internal.toolstrip.Label

        VolumeFraction matlab.ui.internal.toolstrip.ListItemWithCheckBox
        NumberRegions matlab.ui.internal.toolstrip.ListItemWithCheckBox
        LargestRegion matlab.ui.internal.toolstrip.ListItemWithCheckBox
        SmallestRegion matlab.ui.internal.toolstrip.ListItemWithCheckBox
        Jaccard matlab.ui.internal.toolstrip.ListItemWithCheckBox
        Dice matlab.ui.internal.toolstrip.ListItemWithCheckBox
        BFScore matlab.ui.internal.toolstrip.ListItemWithCheckBox
        Custom matlab.ui.internal.toolstrip.ListItemWithCheckBox
        SelectAll matlab.ui.internal.toolstrip.ListItemWithCheckBox

Timer

SliceAlgoSettingsSource
VolumeAlgoSettingsSource
GalleryFavoriteSettingsSource

    end


    properties(SetAccess=protected,Hidden,Transient)

Tab
        AutomateOnBlocks(1,1)logical=false;

    end


    properties(Dependent,SetAccess=protected)

ApplyOnAllBlocks

    end


    properties(Access=protected,Hidden,Transient)

WindowCurrent
WindowMax

        SelectedAlgorithm char='';
        IsAlgorithmVolumeBased(1,1)logical
        CanUseParallel(1,1)logical=false;

        UnsavedTemplates matlab.desktop.editor.Document=matlab.desktop.editor.Document.empty;
        IsUnsavedTemplateVolume logical=logical.empty;

        Map containers.Map

        ShowMetricsControls(1,1)logical=false;

    end


    methods




        function self=AutomateTab(showMetrics)

            self.ShowMetricsControls=showMetrics;

            self.Map=containers.Map;
            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('images:segmenter:automateTab')));
            self.Tab.Tag="AutomateTab";

            self.Timer=timer('Name','AlgorithmTimer',...
            'TimerFcn',@(~,~)updateUnsavedAlgorithmTemplates(self),...
            'ObjectVisibility','off',...
            'Period',2,...
            'ExecutionMode','fixedSpacing');

            self.setSettingsSource();

            createTab(self);

        end




        function delete(self)

            state=saveState(self.Gallery.Popup);

            galleryFavSetting=self.GalleryFavoriteSettingsSource();
            galleryFavSetting.PersonalValue=state;

            delete(self.Map);
            delete(self.Gallery);

            if isvalid(self.Timer)
                stop(self.Timer);
                delete(self.Timer);
            end

        end




        function enable(self)

            self.Add.Enabled=true;
            self.Gallery.Enabled=true;

            if isempty(self.SelectedAlgorithm)
                self.Run.Enabled=false;
            else
                self.Run.Enabled=true;
            end

            self.Stop.Enabled=false;

            enableRange(self);
            enableSettings(self);
            enableBlocked(self);
            enableReview(self);

        end




        function disable(self)

            self.Add.Enabled=false;
            self.Gallery.Enabled=false;
            self.Run.Enabled=false;
            self.Stop.Enabled=false;
            self.Settings.Enabled=false;
            self.AllBlocks.Enabled=false;
            self.Review.Enabled=false;
            self.Metrics.Enabled=false;
            self.UseParallel.Enabled=false;
            self.BorderSize.Enabled=false;
            self.BorderSizeLabel.Enabled=false;
            self.SkipCompleted.Enabled=false;

            disableRange(self);

        end




        function disableDuringAutomation(self)

            self.Add.Enabled=false;
            self.Gallery.Enabled=false;
            self.Run.Enabled=false;
            self.Stop.Enabled=true;
            self.Settings.Enabled=false;
            self.AllBlocks.Enabled=false;
            self.Review.Enabled=false;
            self.Metrics.Enabled=false;
            self.UseParallel.Enabled=false;
            self.BorderSize.Enabled=false;
            self.BorderSizeLabel.Enabled=false;
            self.SkipCompleted.Enabled=false;

            disableRange(self);

        end




        function setAutomationRangeBounds(self,currentVal,maxVal)

            self.WindowCurrent=currentVal;
            self.WindowMax=maxVal;

        end




        function setAutomationRange(self,startVal,endVal)

            self.Start.Value=num2str(startVal);
            self.End.Value=num2str(endVal);

        end




        function displayAutomationRange(self,currentSlice,maxSlice)

            switch self.Window.SelectedIndex

            case 1
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(currentSlice);
            case 2
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(1);
            case 3
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(maxSlice);
            end

            self.WindowCurrent=currentSlice;
            self.WindowMax=maxSlice;

            notify(self,'AutomationRangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(str2double(self.Start.Value),str2double(self.End.Value)));

        end




        function refresh(self)

            refreshGallery(self);

        end




        function updateUnsavedAlgorithmTemplates(self)

            if isvalid(self)&&~isempty(self.UnsavedTemplates)

                templatesStillOpen=arrayfun(@(x)x.Opened,self.UnsavedTemplates);

                self.UnsavedTemplates(~templatesStillOpen)=[];
                self.IsUnsavedTemplateVolume(~templatesStillOpen)=[];

                if~isempty(self.UnsavedTemplates)

                    templatesSaved=~arrayfun(@(x)x.Modified,self.UnsavedTemplates);

                    for idx=1:numel(self.UnsavedTemplates)
                        if templatesSaved(idx)

                            fullPath=self.UnsavedTemplates(idx).Filename;
                            [~,fileName]=images.internal.app.segmenter.volume.automation.getFileParts(fullPath);

                            addToGallery(self,fullPath,fileName,self.IsUnsavedTemplateVolume(idx));

                        end
                    end

                    self.UnsavedTemplates(templatesSaved)=[];
                    self.IsUnsavedTemplateVolume(templatesSaved)=[];

                    refresh(self);

                end

                if isempty(self.UnsavedTemplates)&&isvalid(self.Timer)
                    stop(self.Timer);
                end

            end

        end




        function addAlgorithm(self,alg,isVolumeBased)

            [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(alg);
            addToGallery(self,alg,name,isVolumeBased);

            refresh(self);

        end




        function enableBlockedApply(self,TF)

            self.AutomateOnBlocks=TF;
            self.CanUseParallel=TF&&matlab.internal.parallel.isPCTInstalled();
            enableBlocked(self);

        end




        function enableQualityMetrics(self,TF)

            self.Jaccard.Enabled=TF;
            self.Dice.Enabled=TF;
            self.BFScore.Enabled=TF;

            if TF
                if~self.Jaccard.Value&&~self.Dice.Value&&~self.BFScore.Value
                    self.Jaccard.Value=true;
                end
                updateMetrics(self);
            end

        end




        function enableCustomMetrics(self,TF)

            self.Custom.Enabled=TF;

            if TF
                self.Custom.Value=true;
                updateMetrics(self);
            end

        end




        function addCustomMetric(self,metric)

            [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(metric);
            [fullPath,success]=validatePath(self,metric,name);

            if~success
                return;
            end

            notify(self,'AddCustomMetric',images.internal.app.segmenter.volume.events.VolumeEventData(fullPath));

            addMetricToPopupList(self,name);

            enableCustomMetrics(self,true);

        end

    end


    methods(Access=protected)


        function setSettingsSource(self)

            self.SliceAlgoSettingsSource=@()settings().images.VolumeSegmenter.SliceAlgorithmList;
            self.VolumeAlgoSettingsSource=@()settings().images.VolumeSegmenter.VolumeAlgorithmList;
            self.GalleryFavoriteSettingsSource=@()settings().images.VolumeSegmenter.GalleryFavorites;

        end


        function addToGallery(self,fullPath,fileName,isVolumeAlgorithm)

            try
                [fullPath,success]=validatePath(self,fullPath,fileName);

                if~success
                    return;
                end


                sliceAlgoListSetting=self.SliceAlgoSettingsSource();
                volAlgoListSetting=self.VolumeAlgoSettingsSource();

                metaClass=meta.class.fromName(fullPath);

                if isempty(metaClass)

                    if isVolumeAlgorithm
                        volAlgoListSetting.PersonalValue=[volAlgoListSetting.ActiveValue,string(fullPath)];
                    else
                        sliceAlgoListSetting.PersonalValue=[sliceAlgoListSetting.ActiveValue,string(fullPath)];
                    end

                else


                    metaSuperclass=metaClass.SuperclassList;
                    superclasses={metaSuperclass.Name};

                    if metaClass.Abstract
                        error(message('images:segmenter:abstractClass'));
                    end

                    if~ismember({'images.automation.volume.Algorithm'},superclasses)
                        error(message('images:segmenter:invalidSuperclass'));
                    end

                    if strcmp(eval([metaClass.Name,'.ExecutionMode']),'slice')
                        sliceAlgoListSetting.PersonalValue=[sliceAlgoListSetting.ActiveValue,string(fullPath)];
                    elseif strcmp(eval([metaClass.Name,'.ExecutionMode']),'volume')
                        volAlgoListSetting.PersonalValue=[volAlgoListActiveValue,string(fullPath)];
                    else
                        error(message('images:segmenter:invalidExecutionMode'));
                    end

                end

            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
            end

        end


        function[fullPath,success]=validatePath(self,fullPath,fileName)

            try
                [~,~,fcnExt]=fileparts(fullPath);
                [fcnPath,~]=images.internal.app.segmenter.volume.automation.getFileParts(fullPath);

                if~exist(fullPath,'file')
                    error(message('images:segmenter:fileDoesNotExist'));
                end

                if~strcmpi(fcnExt,'.m')
                    error(message('images:segmenter:fileNotMFile'));
                end

                if isempty(fcnPath)
                    error(message('images:segmenter:pathNotValid'));
                end



                fid=fopen(fullPath,'r');
                closeFile=onCleanup(@()fclose(fid));
                fullPath=fopen(fid);
                clear closeFile;

                whichPath=which(fileName);

                if isempty(whichPath)
                    addpath(fcnPath);
                elseif~strcmpi(whichPath,fullPath)
                    error(message('images:segmenter:multipleFilesOnPath'));
                end

                success=true;

            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                success=false;
            end

        end


        function refreshGallery(self)


            sliceAlgoListSetting=self.SliceAlgoSettingsSource();
            volAlgoListSetting=self.VolumeAlgoSettingsSource();

            sliceAlgorithmList=sliceAlgoListSetting.ActiveValue;
            volumeAlgorithmList=volAlgoListSetting.ActiveValue;

            state=saveState(self.Gallery.Popup);


            algorithmList=self.SliceCategory.Children;

            if~isempty(algorithmList)

                for idx=1:numel(algorithmList)

                    if~any(strcmp(algorithmList(idx).Tag,sliceAlgorithmList))
                        remove(self.SliceCategory,algorithmList(idx));
                        if isKey(self.Map,algorithmList(idx))
                            remove(self.Map,algorithmList(idx));
                        end
                    end

                end

            end

            algorithmList=self.VolumeCategory.Children;

            if~isempty(algorithmList)

                for idx=1:numel(algorithmList)

                    if~any(strcmp(algorithmList(idx).Tag,volumeAlgorithmList))
                        remove(self.VolumeCategory,algorithmList(idx));
                        if isKey(self.Map,algorithmList(idx))
                            remove(self.Map,algorithmList(idx));
                        end
                    end

                end

            end


            for idx=1:numel(sliceAlgorithmList)

                try

                    item=getChildByTag(self.SliceCategory,sliceAlgorithmList(idx));

                    metaClass=meta.class.fromName(sliceAlgorithmList(idx));

                    if~isempty(metaClass)
                        item.Text=getAlgorithmName(self,metaClass);
                        item.Description=getAlgorithmDescription(self,metaClass);
                        item.Icon=getAlgorithmIcon(self,metaClass);
                    else
                        [~,name,~]=fileparts(sliceAlgorithmList(idx));
                        item.Text=name;
                        item.Description=getString(message('images:segmenter:functionDescription'));
                        item.Icon=getCustomIcon(self,true);
                    end

                catch

                    metaClass=meta.class.fromName(sliceAlgorithmList(idx));

                    if~isempty(metaClass)
                        item=matlab.ui.internal.toolstrip.ToggleGalleryItem(getAlgorithmName(self,metaClass),getAlgorithmIcon(self,metaClass));
                        item.Description=getAlgorithmDescription(self,metaClass);
                    else
                        [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(sliceAlgorithmList(idx));
                        item=matlab.ui.internal.toolstrip.ToggleGalleryItem(name,getCustomIcon(self,true));
                        item.Description=getString(message('images:segmenter:functionDescription'));
                    end

                    item.Tag=sliceAlgorithmList(idx);
                    add(self.SliceCategory,item);
                    addlistener(item,'ValueChanged',@(src,evt)runAutomation(self,evt));

                end

            end


            for idx=1:numel(volumeAlgorithmList)

                try

                    item=getChildByTag(self.VolumeCategory,volumeAlgorithmList(idx));

                    metaClass=meta.class.fromName(volumeAlgorithmList(idx));

                    if~isempty(metaClass)
                        item.Text=getAlgorithmName(self,metaClass);
                        item.Description=getAlgorithmDescription(self,metaClass);
                        item.Icon=getAlgorithmIcon(self,metaClass);
                    else
                        [~,name,~]=fileparts(volumeAlgorithmList(idx));
                        item.Text=name;
                        item.Description=getString(message('images:segmenter:functionDescription'));
                        item.Icon=getCustomIcon(self,false);
                    end

                catch

                    metaClass=meta.class.fromName(volumeAlgorithmList(idx));

                    if~isempty(metaClass)
                        item=matlab.ui.internal.toolstrip.ToggleGalleryItem(getAlgorithmName(self,metaClass),getAlgorithmIcon(self,metaClass));
                        item.Description=getAlgorithmDescription(self,metaClass);
                    else
                        [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(volumeAlgorithmList(idx));
                        item=matlab.ui.internal.toolstrip.ToggleGalleryItem(name,getCustomIcon(self,false));
                        item.Description=getString(message('images:segmenter:functionDescription'));
                    end

                    item.Tag=volumeAlgorithmList(idx);
                    add(self.VolumeCategory,item);
                    addlistener(item,'ValueChanged',@(src,evt)runAutomation(self,evt));

                end

            end

            loadState(self.Gallery.Popup,state);

        end


        function validateAlgorithmList(self)


            sliceAlgoListSetting=self.SliceAlgoSettingsSource();
            volAlgoListSetting=self.VolumeAlgoSettingsSource();

            sliceAlgorithmList=sliceAlgoListSetting.ActiveValue;
            volumeAlgorithmList=volAlgoListSetting.ActiveValue;



            algorithmsToTrim=false(size(sliceAlgorithmList));

            for idx=1:numel(sliceAlgorithmList)

                metaClass=meta.class.fromName(sliceAlgorithmList(idx));

                if isempty(metaClass)

                    [path,name]=images.internal.app.segmenter.volume.automation.getFileParts(sliceAlgorithmList(idx));
                    if isempty(which(name))

                        if exist(path,'dir')
                            addpath(path);
                        end

                        if isempty(which(sliceAlgorithmList(idx)))
                            algorithmsToTrim(idx)=true;
                        end

                    end
                else

                    metaSuperclass=metaClass.SuperclassList;
                    superclasses={metaSuperclass.Name};

                    if~strcmp(eval([metaClass.Name,'.ExecutionMode']),'slice')||~ismember('images.automation.volume.Algorithm',superclasses)||metaClass.Abstract
                        algorithmsToTrim(idx)=true;
                    end

                end

            end

            sliceAlgorithmList(algorithmsToTrim)=[];
            sliceAlgoListSetting.PersonalValue=sliceAlgorithmList;



            algorithmsToTrim=false(size(volumeAlgorithmList));

            for idx=1:numel(volumeAlgorithmList)

                metaClass=meta.class.fromName(volumeAlgorithmList(idx));

                if isempty(metaClass)

                    [path,name]=images.internal.app.segmenter.volume.automation.getFileParts(volumeAlgorithmList(idx));
                    if isempty(which(name))

                        if exist(path,'dir')
                            addpath(path);
                        end

                        if isempty(which(volumeAlgorithmList(idx)))
                            algorithmsToTrim(idx)=true;
                        end

                    end
                else

                    metaSuperclass=metaClass.SuperclassList;
                    superclasses={metaSuperclass.Name};

                    if~strcmp(eval([metaClass.Name,'.ExecutionMode']),'volume')||~ismember('images.automation.volume.Algorithm',superclasses)||metaClass.Abstract
                        algorithmsToTrim(idx)=true;
                    end

                end

            end

            volumeAlgorithmList(algorithmsToTrim)=[];
            volAlgoListSetting.PersonalValue=volumeAlgorithmList;

            refreshGallery(self);

        end


        function scrape(self)




            pkg=meta.package.fromName('images.automation.volume');

            volumeAlgorithmList=string.empty;
            sliceAlgorithmList=string.empty;

            if~isempty(pkg)

                for idx=1:numel(pkg.ClassList)

                    metaClass=pkg.ClassList(idx);
                    metaSuperclass=metaClass.SuperclassList;
                    superclasses={metaSuperclass.Name};

                    if ismember('images.automation.volume.Algorithm',superclasses)
                        if strcmp(eval([metaClass.Name,'.ExecutionMode']),'volume')&&~metaClass.Abstract

                            volumeAlgorithmList(end+1)=metaClass.Name;%#ok<AGROW>

                        elseif strcmp(eval([metaClass.Name,'.ExecutionMode']),'slice')&&ismember('images.automation.volume.Algorithm',superclasses)&&~metaClass.Abstract

                            sliceAlgorithmList(end+1)=metaClass.Name;%#ok<AGROW>

                        end
                    end

                end

            end


            sliceAlgoListSetting=self.SliceAlgoSettingsSource();
            volAlgoListSetting=self.VolumeAlgoSettingsSource();

            sliceAlgoListSetting.PersonalValue=sliceAlgorithmList;
            volAlgoListSetting.PersonalValue=volumeAlgorithmList;

        end


        function name=getAlgorithmName(~,metaClass)

            try
                name=eval([metaClass.Name,'.Name']);
                TF=ischar(name)||isstring(name);
            catch
                TF=false;
            end

            if~TF
                name=getString(message('images:segmenter:defaultName'));
            end

        end


        function desc=getAlgorithmDescription(~,metaClass)

            try
                desc=eval([metaClass.Name,'.Description']);
                TF=ischar(desc)||isstring(desc);
            catch
                TF=false;
            end

            if~TF
                desc=getString(message('images:segmenter:defaultDescription'));
            end

        end


        function icon=getAlgorithmIcon(~,metaClass)

            try

                icon=eval([metaClass.Name,'.Icon']);

                if isnumeric(icon)

                    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(icon));
                elseif~isa(icon,'matlab.ui.internal.toolstrip.Icon')


                    icon=matlab.ui.internal.toolstrip.Icon(icon);
                end

                TF=true;

            catch

                TF=false;
            end

            if~TF
                icon=matlab.ui.internal.toolstrip.Icon.MATLAB_24;
            end

        end


        function addSliceAlgorithm(self)

            notify(self,'AddAlgorithm',...
            images.internal.app.segmenter.volume.events.AutomationStartedEventData(...
            '',false,struct.empty,[]));

        end


        function addVolumeAlgorithm(self)

            notify(self,'AddAlgorithm',...
            images.internal.app.segmenter.volume.events.AutomationStartedEventData(...
            '',true,struct.empty,[]));

        end


        function startTimer(self)

            if~strcmp(self.Timer.Running,'on')
                start(self.Timer);
            end

        end


        function newSliceClassTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','sliceClass.template');
            codeString=fileread(templateFile);

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=false;

            startTimer(self);

        end


        function newSliceFunctionTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','sliceFunction.template');
            codeString=fileread(templateFile);

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=false;

            startTimer(self);

        end


        function newVolumeClassTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','volumeClass.template');
            codeString=fileread(templateFile);

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=true;

            startTimer(self);

        end


        function newVolumeFunctionTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','volumeFunction.template');
            codeString=fileread(templateFile);

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=true;

            startTimer(self);

        end


        function manageAlgorithms(self)

            self.SelectedAlgorithm='';
            self.Run.Enabled=false;
            self.Settings.Enabled=false;

            deselectAllOtherGalleryItems(self,gobjects);

            notify(self,'ManageAlgorithms');

        end


        function rangeUpdated(self)

            self.Window.SelectedIndex=-1;

            notify(self,'AutomationRangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(str2double(self.Start.Value),str2double(self.End.Value)));

        end


        function dropDownUpdated(self)

            switch self.Window.SelectedIndex

            case 1
                self.Start.Value=num2str(self.WindowCurrent);
                self.End.Value=num2str(self.WindowCurrent);
            case 2
                self.Start.Value=num2str(self.WindowCurrent);
                self.End.Value=num2str(1);
            case 3
                self.Start.Value=num2str(self.WindowCurrent);
                self.End.Value=num2str(self.WindowMax);
            end

            notify(self,'AutomationRangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(str2double(self.Start.Value),str2double(self.End.Value)));

        end


        function enableRange(self)

            TF=false;

            sliceAlgorithms=self.SliceCategory.Children;

            if~isempty(sliceAlgorithms)

                for idx=1:numel(sliceAlgorithms)
                    TF=TF|sliceAlgorithms(idx).Value;
                end

            end

            if isvalid(self.AllBlocks)
                TF=TF&&~self.AllBlocks.Value;
            end

            self.Start.Editable=TF;
            self.End.Editable=TF;
            self.Start.Enabled=TF;
            self.End.Enabled=TF;
            self.Window.Enabled=TF;
            self.StartLabel.Enabled=TF;
            self.EndLabel.Enabled=TF;

        end


        function enableBlocked(self)

            if~isvalid(self.AllBlocks)
                return
            end

            TF=self.Run.Enabled&&self.AutomateOnBlocks;

            self.AllBlocks.Enabled=TF;
            self.UseParallel.Enabled=TF&&self.CanUseParallel&&self.AllBlocks.Value;
            self.BorderSize.Enabled=TF&&self.AllBlocks.Value;
            self.BorderSizeLabel.Enabled=TF&&self.AllBlocks.Value;
            self.SkipCompleted.Enabled=TF&&self.AllBlocks.Value;

            enableReview(self);

        end


        function enableReview(self)

            TF=false;

            volumeAlgorithms=self.VolumeCategory.Children;

            if~isempty(volumeAlgorithms)

                for idx=1:numel(volumeAlgorithms)
                    TF=TF|volumeAlgorithms(idx).Value;
                end

            end

            if isvalid(self.AllBlocks)
                TF=TF||self.ApplyOnAllBlocks;
            end

            self.Review.Enabled=TF;
            self.Metrics.Enabled=TF&&self.Review.Value;

        end


        function enableSettings(self)

            if isempty(self.SelectedAlgorithm)
                self.Settings.Enabled=false;
                return;
            end

            metaClass=meta.class.fromName(self.SelectedAlgorithm);

            if isempty(metaClass)
                self.Settings.Enabled=false;
            else

                metaSuperclass=metaClass.SuperclassList;
                superclasses={metaSuperclass.Name};

                if ismember('images.automation.volume.Algorithm',superclasses)&&~metaClass.Abstract

                    f=str2func([self.SelectedAlgorithm,'.getSettings']);
                    settingsObj=f();

                    if isempty(settingsObj)
                        self.Settings.Enabled=false;
                    else
                        if~isKey(self.Map,self.SelectedAlgorithm)
                            self.Map(self.SelectedAlgorithm)=settingsObj;
                        end
                        self.Settings.Enabled=true;
                    end

                else
                    self.Settings.Enabled=false;
                end

            end

        end


        function openSettings(self)

            if isKey(self.Map,self.SelectedAlgorithm)

                notify(self,'OpenSettings',...
                images.internal.app.segmenter.volume.events.AutomationSettingsEventData(...
                self.Map(self.SelectedAlgorithm)));

            end

        end


        function disableRange(self)
            self.Start.Editable=false;
            self.End.Editable=false;
            self.Start.Enabled=false;
            self.End.Enabled=false;
            self.Window.Enabled=false;
            self.StartLabel.Enabled=false;
            self.EndLabel.Enabled=false;
        end


        function runPushed(self,~)

            if isempty(self.SelectedAlgorithm)
                return;
            end

            if isKey(self.Map,self.SelectedAlgorithm)
                obj=self.Map(self.SelectedAlgorithm);
                s=obj.Parameters;
                if isempty(s)
                    initialize(obj);
                    s=obj.Parameters;
                end
            else
                s=struct.empty;
            end

            notify(self,'AutomationStarted',...
            images.internal.app.segmenter.volume.events.AutomationStartedEventData(...
            self.SelectedAlgorithm,self.IsAlgorithmVolumeBased,s,[]));

        end


        function runAutomation(self,evt)

            if isfile(evt.Source.Tag)
                [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(evt.Source.Tag);
                self.SelectedAlgorithm=name;
            else
                self.SelectedAlgorithm=evt.Source.Tag;
            end

            self.IsAlgorithmVolumeBased=evt.Source.Parent==self.VolumeCategory;

            evt.Source.Value=true;

            deselectAllOtherGalleryItems(self,evt.Source);

            self.Run.Enabled=true;

            enableRange(self);
            enableSettings(self);
            enableReview(self);
            enableBlocked(self);

        end


        function deselectAllOtherGalleryItems(self,obj)

            notify(self,'CloseDialogs');

            child=self.SliceCategory.Children;

            for idx=1:numel(child)
                if child(idx)~=obj
                    child(idx).Value=false;
                end
            end

            child=self.VolumeCategory.Children;

            for idx=1:numel(child)
                if child(idx)~=obj
                    child(idx).Value=false;
                end
            end

        end


        function automateOnBlocksPushed(self)
            enableRange(self);
            enableBlocked(self);
            updateBlockSettings(self);
        end


        function updateBlockSettings(self)

            notify(self,'AutomateOnAllBlocks',images.internal.app.segmenter.volume.events.AutomateBlockedImageEventData(...
            self.AllBlocks.Value,self.BorderSize.Value,...
            self.UseParallel.Value,self.SkipCompleted.Value,...
            self.Review.Value&&self.Review.Enabled));

        end


        function reviewPushed(self)
            enableReview(self);
            updateBlockSettings(self);
        end


        function icon=getCustomIcon(~,isSliceBased)
            if isSliceBased
                icon=matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_CustomSlice_24.png'));
            else
                icon=matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_CustomVolume_24.png'));
            end
        end


        function updateGalleryFavorites(self)

            galleryFavSetting=self.GalleryFavoriteSettingsSource();
            state=galleryFavSetting.ActiveValue;

            if~isempty(state)
                loadState(self.Gallery.Popup,state);
            end

        end


        function updateMetrics(self)

            notify(self,'MetricsUpdated',images.internal.app.segmenter.volume.events.MetricsUpdatedEventData(self.VolumeFraction.Value,...
            self.NumberRegions.Value,self.LargestRegion.Value,...
            self.SmallestRegion.Value,self.Jaccard.Value&&self.Jaccard.Enabled,...
            self.Dice.Value&&self.Dice.Enabled,self.BFScore.Value&&self.BFScore.Enabled,...
            self.Custom.Value&&self.Custom.Enabled));

            self.SelectAll.Value=checkIfAllMetricsSelected(self);

        end


        function selectAllMetrics(self)

            TF=self.SelectAll.Value;

            self.VolumeFraction.Value=TF;
            self.NumberRegions.Value=TF;
            self.LargestRegion.Value=TF;
            self.SmallestRegion.Value=TF;
            self.Jaccard.Value=TF;
            self.Dice.Value=TF;
            self.BFScore.Value=TF;
            self.Custom.Value=TF;

            updateMetrics(self);

        end


        function addMetricToPopupList(self,name)

            self.Custom.Text=name;

        end


        function TF=checkIfAllMetricsSelected(self)

            TF=self.VolumeFraction.Value&&...
            self.NumberRegions.Value&&self.LargestRegion.Value&&...
            self.SmallestRegion.Value&&self.Jaccard.Value&&...
            self.Dice.Value&&self.BFScore.Value&&...
            self.Custom.Value;

        end


        function TF=checkIfAnyMetricsSelected(self)

            TF=any([self.VolumeFraction.Value,...
            self.NumberRegions.Value,self.LargestRegion.Value,...
            self.SmallestRegion.Value,self.Jaccard.Value,...
            self.Dice.Value,self.BFScore.Value,...
            self.Custom.Value]);

        end


        function metricFromFile(self)
            notify(self,'LoadCustomMetric');
        end


        function metricFromTemplate(~)
            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','customMetric.template');
            codeString=fileread(templateFile);

            matlab.desktop.editor.newDocument(codeString);
        end

    end


    methods(Access=protected)


        function createTab(self)

            createAddAlgorithmSection(self);
            createDirectionSection(self);
            createBlockedImageSection(self);
            createReviewSection(self);
            createRunSection(self);

        end

        function createAddAlgorithmSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:algorithm')));
            section.CollapsePriority=20;


            column=section.addColumn();

            sliceHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:sliceHeader')));

            sliceFromFileButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:fromFile')),matlab.ui.internal.toolstrip.Icon.OPEN_16);
            sliceFromFileButton.Description=getString(message('images:segmenter:fromFileTooltip'));
            sliceFromFileButton.ShowDescription=false;
            sliceFromFileButton.Tag="ImportSliceAlgorithmFile";
            addlistener(sliceFromFileButton,'ItemPushed',@(~,~)addSliceAlgorithm(self));

            popup=matlab.ui.internal.toolstrip.PopupList();

            functionButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:newFunction')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FunctionTemplate_16.png')));
            functionButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            functionButton.ShowDescription=false;
            functionButton.Tag="NewSliceAlgorithmFunction";
            addlistener(functionButton,'ItemPushed',@(~,~)newSliceFunctionTemplate(self));

            classButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:newClass')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ClassTemplate_16.png')));
            classButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            classButton.ShowDescription=false;
            classButton.Tag="NewSliceAlgorithmClass";
            addlistener(classButton,'ItemPushed',@(~,~)newSliceClassTemplate(self));

            add(popup,functionButton);
            add(popup,classButton);

            newSliceButton=matlab.ui.internal.toolstrip.ListItemWithPopup(getString(message('images:segmenter:new')),matlab.ui.internal.toolstrip.Icon.NEW_16);
            newSliceButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            newSliceButton.ShowDescription=false;
            newSliceButton.Tag="NewSliceAlgorithm";
            newSliceButton.Popup=popup;

            volumeHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:volumeBased')));
            volumeHeader.Tag="VolumeHeader";

            volumeFromFileButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:fromFile')),matlab.ui.internal.toolstrip.Icon.OPEN_16);
            volumeFromFileButton.Description=getString(message('images:segmenter:customAlgorithmTooltip'));
            volumeFromFileButton.ShowDescription=false;
            volumeFromFileButton.Tag="ImportVolumeAlgorithmFile";
            addlistener(volumeFromFileButton,'ItemPushed',@(~,~)addVolumeAlgorithm(self));
            self.VolumeFromFile=volumeFromFileButton;

            popup=matlab.ui.internal.toolstrip.PopupList();

            functionButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:newFunction')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FunctionTemplate_16.png')));
            functionButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            functionButton.ShowDescription=false;
            functionButton.Tag="NewVolumeAlgorithmFunction";
            addlistener(functionButton,'ItemPushed',@(~,~)newVolumeFunctionTemplate(self));

            classButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:newClass')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ClassTemplate_16.png')));
            classButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            classButton.ShowDescription=false;
            classButton.Tag="NewVolumeAlgorithmClass";
            addlistener(classButton,'ItemPushed',@(~,~)newVolumeClassTemplate(self));

            add(popup,functionButton);
            add(popup,classButton);

            newVolumeButton=matlab.ui.internal.toolstrip.ListItemWithPopup(getString(message('images:segmenter:new')),matlab.ui.internal.toolstrip.Icon.NEW_16);
            newVolumeButton.Description=getString(message('images:segmenter:newAlgoTooltip'));
            newVolumeButton.ShowDescription=false;
            newVolumeButton.Tag="NewVolumeAlgorithm";
            newVolumeButton.Popup=popup;
            self.NewVolume=newVolumeButton;

            manageHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:manageHeader')));

            manageButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:manageAlgorithm')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','FilterRegions_16.png')));
            manageButton.ShowDescription=false;
            manageButton.Tag="ManageAlgorithms";
            manageButton.Description=getString(message('images:segmenter:manageAlgorithmTooltip'));
            addlistener(manageButton,'ItemPushed',@(~,~)manageAlgorithms(self));

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,sliceHeader);
            add(popup,sliceFromFileButton);
            add(popup,newSliceButton);
            add(popup,volumeHeader);
            add(popup,volumeFromFileButton);
            add(popup,newVolumeButton);
            add(popup,manageHeader);
            add(popup,manageButton);

            self.Add=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:customAlgorithm')),matlab.ui.internal.toolstrip.Icon.NEW_24);
            self.Add.Tag='Add';
            self.Add.Description=getString(message('images:segmenter:customAlgorithmTooltip'));
            self.Add.Popup=popup;
            column.add(self.Add);

            column=section.addColumn();


            self.SliceCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('images:segmenter:sliceBySlice')));
            self.SliceCategory.Tag='SliceAutomationGallery';

            self.VolumeCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('images:segmenter:volumeBased')));
            self.VolumeCategory.Tag='VolumeAutomationGallery';

            popup=matlab.ui.internal.toolstrip.GalleryPopup('ShowSelection',true,'FavoritesEnabled',true);
            popup.add(self.SliceCategory);
            popup.add(self.VolumeCategory);

            self.Gallery=matlab.ui.internal.toolstrip.Gallery(popup,'MaxColumnCount',6,'MinColumnCount',2);
            self.Gallery.Tag='AlgorithmGallery';
            column.add(self.Gallery);

            column=section.addColumn();
            self.Settings=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:algorithmSettings')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Parameters_24.png')));
            self.Settings.Tag='Settings';
            self.Settings.Description=getString(message('images:segmenter:algorithmSettingsTooltip'));
            column.add(self.Settings);
            addlistener(self.Settings,'ButtonPushed',@(~,~)openSettings(self));



            sliceAlgoListSetting=self.SliceAlgoSettingsSource();
            volAlgoListSetting=self.VolumeAlgoSettingsSource();

            sliceAlgorithmList=sliceAlgoListSetting.ActiveValue;
            volumeAlgorithmList=volAlgoListSetting.ActiveValue;



            if(isempty(sliceAlgorithmList)&&isempty(volumeAlgorithmList))||(numel(sliceAlgorithmList)==1&&sliceAlgorithmList(1)=="")||(numel(volumeAlgorithmList)==1&&volumeAlgorithmList(1)=="")
                scrape(self);
            end

            validateAlgorithmList(self);

        end

        function createDirectionSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:direction')));

            column=section.addColumn();

            spaceLabel=matlab.ui.internal.toolstrip.Label(' ');
            column.add(spaceLabel);

            self.StartLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:startSlice')));
            self.StartLabel.Tag="StartLabel";
            column.add(self.StartLabel);

            self.EndLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:endSlice')));
            self.EndLabel.Tag="EndLabel";
            column.add(self.EndLabel);

            column=section.addColumn('Width',120);

            self.Window=matlab.ui.internal.toolstrip.DropDown({getString(message('images:segmenter:currentSlice'));getString(message('images:segmenter:beginningToCurrent'));getString(message('images:segmenter:currentToEnd'))});
            self.Window.Description=getString(message('images:segmenter:windowPresetsTooltip'));
            self.Window.Tag='Window';
            column.add(self.Window);
            self.Window.SelectedIndex=1;

            self.Start=matlab.ui.internal.toolstrip.EditField();
            self.Start.Description=getString(message('images:segmenter:windowStartTooltip'));
            self.Start.Tag='Start';
            column.add(self.Start);

            self.End=matlab.ui.internal.toolstrip.EditField();
            self.End.Description=getString(message('images:segmenter:windowEndTooltip'));
            self.End.Tag='End';
            column.add(self.End);

            addlistener(self.Start,'ValueChanged',@(~,~)rangeUpdated(self));
            addlistener(self.End,'ValueChanged',@(~,~)rangeUpdated(self));
            addlistener(self.Window,'ValueChanged',@(~,~)dropDownUpdated(self));

        end

        function createBlockedImageSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:blockedImageTab')));
            column=section.addColumn();


            self.AllBlocks=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:automateOverAllBlocks')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_AutomateAllBlocks_24.png')));
            self.AllBlocks.Tag='AutomateAllBlocks';
            self.AllBlocks.Description=getString(message('images:segmenter:automateOverAllBlocksTooltip'));
            addlistener(self.AllBlocks,'ValueChanged',@(~,~)automateOnBlocksPushed(self));
            column.add(self.AllBlocks);

            column=section.addColumn('HorizontalAlignment','center');
            self.BorderSizeLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:borderSize')));
            self.BorderSizeLabel.Tag="BorderSizeLabel";


            self.BorderSize=matlab.ui.internal.toolstrip.Spinner([0,500],0);
            self.BorderSize.Tag='BorderSize';
            self.BorderSize.Description=getString(message('images:segmenter:borderSizeTooltip'));
            addlistener(self.BorderSize,'ValueChanged',@(~,~)updateBlockSettings(self));

            column.add(self.BorderSize);
            column.add(self.BorderSizeLabel);

            column=section.addColumn();
            self.UseParallel=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:useParallel')),...
            matlab.ui.internal.toolstrip.Icon.PARALLEL_16);
            self.UseParallel.Tag='Parallel';

            if matlab.internal.parallel.isPCTInstalled()
                self.UseParallel.Description=getString(message('images:segmenter:useParallelTooltip'));
            else
                self.UseParallel.Description=getString(message('images:segmenter:noUseParallel'));
            end

            addlistener(self.UseParallel,'ValueChanged',@(~,~)updateBlockSettings(self));
            column.add(self.UseParallel);

            self.SkipCompleted=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:skipComplete')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_SkipComplete_16.png')));
            self.SkipCompleted.Tag='SkipCompleted';
            self.SkipCompleted.Description=getString(message('images:segmenter:skipCompleteTooltip'));
            addlistener(self.SkipCompleted,'ValueChanged',@(~,~)updateBlockSettings(self));
            self.SkipCompleted.Value=true;
            column.add(self.SkipCompleted);

        end

        function createReviewSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:reviewTitle')));
            section.CollapsePriority=10;
            column=section.addColumn();

            self.Review=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:review')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Review_24.png')));
            self.Review.Tag='Review';
            self.Review.Description=getString(message('images:segmenter:reviewTooltip'));
            addlistener(self.Review,'ValueChanged',@(~,~)reviewPushed(self));
            column.add(self.Review);

            morphometricHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:morphometricHeader')));
            qualityHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:qualityHeader')));
            customHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:customMetricsHeader')));
            allHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:allHeader')));

            self.VolumeFraction=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:volumeFraction')));
            self.VolumeFraction.ShowDescription=false;
            self.VolumeFraction.Value=true;
            self.VolumeFraction.Tag="VolumeFraction";
            addlistener(self.VolumeFraction,'ValueChanged',@(~,~)updateMetrics(self));

            self.NumberRegions=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:numRegions')));
            self.NumberRegions.ShowDescription=false;
            self.NumberRegions.Value=true;
            self.NumberRegions.Tag="NumberRegions";
            addlistener(self.NumberRegions,'ValueChanged',@(~,~)updateMetrics(self));

            self.LargestRegion=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:largestRegion')));
            self.LargestRegion.ShowDescription=false;
            self.LargestRegion.Value=true;
            self.LargestRegion.Tag="LargestRegion";
            addlistener(self.LargestRegion,'ValueChanged',@(~,~)updateMetrics(self));

            self.SmallestRegion=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:smallestRegion')));
            self.SmallestRegion.ShowDescription=false;
            self.SmallestRegion.Value=true;
            self.SmallestRegion.Tag="SmallestRegion";
            addlistener(self.SmallestRegion,'ValueChanged',@(~,~)updateMetrics(self));

            self.Jaccard=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:jaccardMetric')));
            self.Jaccard.ShowDescription=false;
            self.Jaccard.Value=false;
            self.Jaccard.Enabled=false;
            self.Jaccard.Tag="Jaccard";
            addlistener(self.Jaccard,'ValueChanged',@(~,~)updateMetrics(self));

            self.Dice=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:diceMetric')));
            self.Dice.ShowDescription=false;
            self.Dice.Value=false;
            self.Dice.Enabled=false;
            self.Dice.Tag="Dice";
            addlistener(self.Dice,'ValueChanged',@(~,~)updateMetrics(self));

            self.BFScore=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:bfscoreMetric')));
            self.BFScore.ShowDescription=false;
            self.BFScore.Value=false;
            self.BFScore.Enabled=false;
            self.BFScore.Tag="BFScore";
            addlistener(self.BFScore,'ValueChanged',@(~,~)updateMetrics(self));

            customPopup=matlab.ui.internal.toolstrip.PopupList();
            fromFile=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:fromFile')));
            fromFile.ShowDescription=false;
            fromTemplate=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:customMetricTemplate')));
            fromTemplate.ShowDescription=false;
            add(customPopup,fromFile);
            add(customPopup,fromTemplate);
            addlistener(fromFile,'ItemPushed',@(~,~)metricFromFile(self));
            addlistener(fromTemplate,'ItemPushed',@(~,~)metricFromTemplate(self));

            addCustomMetrics=matlab.ui.internal.toolstrip.ListItemWithPopup(getString(message('images:segmenter:selectCustom')));
            addCustomMetrics.ShowDescription=false;
            addCustomMetrics.Popup=customPopup;
            addCustomMetrics.Tag="SelectCustomMetric";

            groundTruthPopup=matlab.ui.internal.toolstrip.PopupList();
            fromWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:LoadGroundTruthFromWorkspace')));
            fromWorkspace.ShowDescription=false;
            fromWorkspace.Tag="GroundTruthFromWorkspace";
            add(groundTruthPopup,fromWorkspace);

            addlistener(fromWorkspace,'ItemPushed',@(~,~)notify(self,'GroundTruthImportRequested'));

            addGroundTruthMetric=matlab.ui.internal.toolstrip.ListItemWithPopup(getString(message('images:segmenter:selectGroundTruth')));
            addGroundTruthMetric.ShowDescription=false;
            addGroundTruthMetric.Popup=groundTruthPopup;
            addGroundTruthMetric.Tag="AddGroundTruth";

            self.Custom=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:customMetric')));
            self.Custom.ShowDescription=false;
            self.Custom.Value=false;
            self.Custom.Enabled=false;
            self.Custom.Tag="CustomMetric";
            addlistener(self.Custom,'ValueChanged',@(~,~)updateMetrics(self));

            self.SelectAll=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:selectAll')));
            self.SelectAll.ShowDescription=false;
            self.SelectAll.Value=false;
            self.SelectAll.Tag="SelectAll";
            addlistener(self.SelectAll,'ValueChanged',@(~,~)selectAllMetrics(self));

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,morphometricHeader);
            add(popup,self.VolumeFraction);
            add(popup,self.NumberRegions);
            add(popup,self.LargestRegion);
            add(popup,self.SmallestRegion);
            add(popup,qualityHeader);
            add(popup,addGroundTruthMetric);
            add(popup,self.Jaccard);
            add(popup,self.Dice);
            add(popup,self.BFScore);
            add(popup,customHeader);
            add(popup,addCustomMetrics);
            add(popup,self.Custom);
            add(popup,allHeader);
            add(popup,self.SelectAll);

            validateAlgorithmList(self);
            updateGalleryFavorites(self);

            self.Metrics=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:metrics')),...
            matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
            self.Metrics.Tag='Metrics';
            self.Metrics.Description=getString(message('images:segmenter:metricsTooltip'));
            self.Metrics.Popup=popup;

            if self.ShowMetricsControls
                column=section.addColumn();
                column.add(self.Metrics);
            end

        end

        function createRunSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:run')));
            section.CollapsePriority=30;
            column=section.addColumn();

            self.Run=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:run')),matlab.ui.internal.toolstrip.Icon.RUN_24);
            self.Run.Tag='Run';
            self.Run.Description=getString(message('images:segmenter:runTooltip'));
            column.add(self.Run);
            addlistener(self.Run,'ButtonPushed',@(src,evt)runPushed(self,evt));


            column=section.addColumn();

            self.Stop=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:stop')),matlab.ui.internal.toolstrip.Icon.END_24);
            self.Stop.Tag='Stop';
            self.Stop.Description=getString(message('images:segmenter:stopTooltip'));
            column.add(self.Stop);
            addlistener(self.Stop,'ButtonPushed',@(~,~)notify(self,'AutomationStopped'));

        end

    end

    methods




        function TF=get.ApplyOnAllBlocks(self)
            TF=self.AutomateOnBlocks&&self.AllBlocks.Value;
        end

    end


end