classdef Automation<handle




    events




Iterate



LabelsUpdated



ErrorThrown



AutomationStarting




AutomationStopped



RangeUpdated



ReviewResults



ProgressUpdated



GroundTruthLoaded

    end


    properties(SetAccess=private,Hidden,Transient)

        StopRequested(1,1)logical=false;

        IsRunning(1,1)logical=false;

        SliceDirection(1,1)=3;

        Start(1,1)double=1;

        End(1,1)double=1;

        Current(1,1)double=1;

        AutomateOnAllBlocks(1,1)logical=false;

        BorderSize(1,1)double=0;

        UseParallel(1,1)logical=false;

        SkipCompleted(1,1)logical=true;

        Review(1,1)logical=false;

WaitbarParent

        CustomMetric='';

        UseCustomMetric(1,1)logical=false;

        QualityMetrics=string.empty;

        Morphometrics=["VolumeFraction";"NumberOfRegions";"LargestRegion";"SmallestRegion"];

    end


    properties(Access=private,Hidden,Transient)

Algorithm

        CurrentFolder char='';

        TargetFolder char='';

        BlockFileNames string

        GoldStandard=[];

    end


    methods




        function start(self,alg,currentLabel,isVolume,settingsStruct,hfig)










            s=warning;
            warning('off');

            self.StopRequested=false;
            self.IsRunning=true;

            try

                self.WaitbarParent=hfig;
                instantiateAlgorithm(self,alg,currentLabel,isVolume,settingsStruct);
                initialize(self.Algorithm);

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                cleanUpAutomation(self);
                warning(s);
                return;

            end

            evt=images.internal.app.segmenter.volume.events.AlgorithmIterationEventData(self.Algorithm.ExecutionMode,self.Algorithm.UseScaledVolume);
            notify(self,'AutomationStarting',evt);

            iterate(self);

            warning(s);

        end




        function stop(self)




            self.StopRequested=true;
            cleanUpAutomation(self);

        end




        function setRange(self,startVal,endVal,maxVal)






            if self.IsRunning


                return;
            end



            if isscalar(startVal)
                startVal=round(double(startVal));
                if startVal>0&&startVal<=maxVal
                    self.Start=double(startVal);
                end
            end

            if isscalar(endVal)
                endVal=round(double(endVal));
                if endVal>0&&endVal<=maxVal
                    self.End=double(endVal);
                end
            end

            self.Current=self.Start;

            notify(self,'RangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(self.Start,self.End));

        end




        function setDirection(self,sliceDir)



            if self.IsRunning


                return;
            end

            self.SliceDirection=sliceDir;

        end




        function setCurrentIdx(self,idx)
            self.Current=idx;
        end




        function run(self,I,labels)




            [success,labels]=runAlgorithm(self,I,labels);

            if success
                notify(self,'LabelsUpdated',images.internal.app.segmenter.volume.events.LabelEventData(labels));




                drawnow('limitrate');
            end

        end




        function runOnVolume(self,I,labels,useOriginalData,r,g,b,cmap,blockedImageIndex)




            if self.Review
                previousLabels=uint8(labels);
            end

            [success,labels]=runAlgorithm(self,I,labels);

            if~success
                return;
            end

            if self.Review
                if isa(self.GoldStandard,'blockedImage')
                    goldStandard=squeeze(getBlock(self.GoldStandard,blockedImageIndex));
                else
                    goldStandard=self.GoldStandard;
                end
                useMetrics=true;
                if self.UseCustomMetric
                    customMetric=self.CustomMetric;
                else
                    customMetric='';
                end
                if~isempty(goldStandard)
                    qualityMetrics=self.QualityMetrics;
                else
                    qualityMetrics=string.empty;
                end
                morphometrics=self.Morphometrics;
                cats=categories(labels);
                try
                    metrics=computeMetrics(I,previousLabels,uint8(labels),cats,goldStandard,useMetrics,morphometrics,customMetric,qualityMetrics);
                catch ME
                    notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                    cleanUpAutomation(self);
                end
                notify(self,'ReviewResults',images.internal.app.segmenter.volume.events.ReviewResultsEventData(I,labels,cats,metrics,string.empty,useOriginalData,[],r,g,b,cmap));
            else
                notify(self,'LabelsUpdated',images.internal.app.segmenter.volume.events.LabelEventData(labels));
            end




            drawnow('limitrate');

            cleanUpAutomation(self);

        end




        function apply(self,vol,labels,names,mode,dim,useOriginalData,r,g,b,completedBlocks,blockMap,cmap)

            h5BlockAdapter=images.blocked.H5Blocks();
            h5BlockAdapter.GZIPLevel=1;

            try


                alg=self.Algorithm;

                self.CurrentFolder=labels.Source;
                self.TargetFolder=tempname(self.CurrentFolder);

                params={'Resume',false,'OutputLocation',self.TargetFolder,...
                'Adapter',{h5BlockAdapter,images.blocked.MATBlocks},...
                'UseParallel',self.UseParallel,'BorderSize',self.BorderSize,...
                'Cancellable',true};

                if~isempty(self.WaitbarParent)
                    params=[params,{'Parent',self.WaitbarParent}];
                end

                goldStandard=self.GoldStandard;

                if isa(goldStandard,'blockedImage')
                    params=[params,{'ExtraImages',[vol,goldStandard]}];
                else
                    params=[params,{'ExtraImages',vol}];
                end

                if self.SkipCompleted

                    if all(completedBlocks(:))
                        error(message('images:segmenter:allMarkedComplete'));
                    end

                    bls=selectBlockLocations(labels);
                    bo=bls.BlockOrigin;
                    completedBlocks=permute(completedBlocks,[2,1,3]);
                    bo(completedBlocks,:)=[];
                    bls=blockLocationSet(ones(size(bo,1),1),bo,bls.BlockSize);

                    params=[params,{'BlockLocationSet',bls}];

                else
                    params=[params,{'BlockSize',labels.BlockSize}];
                end

                if self.Review
                    useMetrics=true;
                    if self.UseCustomMetric
                        customMetric=self.CustomMetric;
                    else
                        customMetric='';
                    end
                    if~isempty(goldStandard)
                        qualityMetrics=self.QualityMetrics;
                    else
                        qualityMetrics=string.empty;
                    end
                    morphometrics=self.Morphometrics;
                else
                    useMetrics=false;
                    customMetric='';
                    qualityMetrics=string.empty;
                    morphometrics=string.empty;
                end

                if self.UseParallel
                    progressIndicator=parallel.pool.DataQueue;
                    afterEach(progressIndicator,@(data)notify(self,'ProgressUpdated',images.internal.app.segmenter.volume.events.AutomationProgressEventData(data)));
                else
                    progressIndicator=images.internal.app.segmenter.volume.events.ProgressIndicator();
                    addlistener(progressIndicator,'ProgressUpdated',@(src,evt)notify(self,'ProgressUpdated',evt));
                end

                if strcmp(mode,'slice')
                    if isa(goldStandard,'blockedImage')
                        fcn=@(bs,vol,goldStandard)runSliceBlocks(bs,names,alg,vol,goldStandard,useOriginalData,r,g,b,dim,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator);
                    else
                        fcn=@(bs,vol)runSliceBlocks(bs,names,alg,vol,goldStandard,useOriginalData,r,g,b,dim,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator);
                    end
                else
                    if isa(goldStandard,'blockedImage')
                        fcn=@(bs,vol,goldStandard)runVolumeBlocks(bs,names,alg,vol,goldStandard,useOriginalData,r,g,b,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator);
                    else
                        fcn=@(bs,vol)runVolumeBlocks(bs,names,alg,vol,goldStandard,useOriginalData,r,g,b,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator);
                    end
                end

                [labels,metricsbim]=labels.apply(fcn,params{:});

                metrics=gather(metricsbim);

                try %#ok<TRYNC>
                    rmdir(fullfile(self.TargetFolder,'output2'),'s');
                end

                if self.Review
                    s=dir(fullfile(self.TargetFolder,'output1','L1','*.h5'));

                    if~isempty(s)

                        self.BlockFileNames(numel(s),1)="";
                        filenamesWithoutExtension(numel(s),1)="";

                        for idx=1:numel(s)
                            filename=s(idx).name;
                            [~,noExtension,~]=fileparts(filename);
                            self.BlockFileNames(idx)=string(fullfile(self.TargetFolder,'output1','L1',filename));
                            filenamesWithoutExtension(idx)=string(noExtension);
                        end

                        notify(self,'ReviewResults',images.internal.app.segmenter.volume.events.ReviewResultsEventData(vol,labels,names,metrics,filenamesWithoutExtension,useOriginalData,blockMap,r,g,b,cmap));

                    else
                        moveAllResults(self);
                    end
                else
                    moveAllResults(self);
                end

                clearFolders(self);
                cleanUpAutomation(self);

            catch ME

                clearFolders(self);
                cleanUpAutomation(self);

                if~self.StopRequested
                    notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                end
            end

        end




        function acceptAutomationResults(self,acceptedBlocks)

            if~isempty(self.CurrentFolder)
                if all(acceptedBlocks)
                    moveAllResults(self);
                elseif any(acceptedBlocks)
                    moveSomeResults(self,acceptedBlocks);
                else
                    discardAllResults(self);
                end
            end

        end




        function iterate(self)


            if self.StopRequested
                cleanUpAutomation(self);
                return;
            end

            notify(self,'Iterate',images.internal.app.segmenter.volume.events.AlgorithmIterationEventData(self.Algorithm.ExecutionMode,self.Algorithm.UseScaledVolume));

        end




        function validateAutomationRange(self,maxVal)




            TF=false;

            if self.Start>maxVal
                self.Start=maxVal;
                TF=true;
            end

            if self.End>maxVal
                self.End=maxVal;
                TF=true;
            end

            self.Current=self.Start;

            if TF
                notify(self,'RangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(self.Start,self.End));
            end

        end




        function automateOnAllBlocks(self,useAllBlocks,borderSize,useParallel,skipCompleted,reviewResults)
            self.AutomateOnAllBlocks=useAllBlocks;
            self.BorderSize=borderSize;
            self.UseParallel=useParallel;
            self.SkipCompleted=skipCompleted;
            self.Review=reviewResults;
        end




        function setCustomMetric(self,metric)
            self.CustomMetric=metric;
        end




        function updateAutomationMetrics(self,evt)

            morphometrics=string.empty;

            if evt.VolumeFraction
                morphometrics=[morphometrics;"VolumeFraction"];
            end

            if evt.NumberRegions
                morphometrics=[morphometrics;"NumberOfRegions"];
            end

            if evt.LargestRegion
                morphometrics=[morphometrics;"LargestRegion"];
            end

            if evt.SmallestRegion
                morphometrics=[morphometrics;"SmallestRegion"];
            end

            self.Morphometrics=morphometrics;

            qualityMetrics=string.empty;

            if evt.Jaccard
                qualityMetrics=[qualityMetrics;"Jaccard"];
            end

            if evt.Dice
                qualityMetrics=[qualityMetrics;"Dice"];
            end

            if evt.BFScore
                qualityMetrics=[qualityMetrics;"BFScore"];
            end

            self.QualityMetrics=qualityMetrics;

            self.UseCustomMetric=evt.Custom;

        end




        function setGoldStandard(self,goldStandard,referenceLabels)

            try
                if isa(goldStandard,'blockedImage')

                    sz=goldStandard.Size;

                    if numel(sz)~=3
                        error(message('images:segmenter:invalidBlockedImageGroundTruth'));
                    end

                    if isa(referenceLabels,'blockedImage')
                        if~isequal(sz(1:3),referenceLabels.Size(1:3))||...
                            ~isequal(goldStandard.BlockSize(1:3),referenceLabels.BlockSize(1:3))
                            error(message('images:segmenter:invalidBlockedImageGroundTruth'));
                        end
                    else



                        error(message('images:segmenter:invalidGroundTruth'));
                    end

                elseif isa(referenceLabels,'blockedImage')
                    if isequal(size(goldStandard),referenceLabels.BlockSize)
                        error(message('images:segmenter:invalidBlockGroundTruth'));
                    end
                else
                    if~isequal(size(goldStandard),size(referenceLabels))
                        error(message('images:segmenter:invalidGroundTruth'));
                    end
                end
            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
            end

            self.GoldStandard=goldStandard;
            notify(self,'GroundTruthLoaded',images.internal.app.segmenter.volume.events.VolumeEventData(true));

        end




        function clear(self)

            self.GoldStandard=[];
            notify(self,'GroundTruthLoaded',images.internal.app.segmenter.volume.events.VolumeEventData(false));

        end

    end


    methods(Access=private)


        function instantiateAlgorithm(self,alg,currentLabel,isVolume,settingsStruct)

            metaClass=meta.class.fromName(alg);

            if isempty(metaClass)
                if isempty(which(alg))
                    error(message('images:segmenter:algorithmNotFound'));
                else


                    if isVolume
                        self.Algorithm=images.internal.app.segmenter.volume.automation.CustomVolumeFunction(currentLabel,settingsStruct);
                    else
                        self.Algorithm=images.internal.app.segmenter.volume.automation.CustomSliceFunction(currentLabel,settingsStruct);
                    end

                    self.Algorithm.FunctionHandle=str2func(['@(I,mask)',alg,'(I,mask);']);
                    self.Algorithm.FunctionHandleWithNoMask=str2func(['@(I)',alg,'(I);']);

                end
            elseif~isAutomationAlgorithm(self,metaClass)
                error(message('images:segmenter:algorithmNotValid'));
            else
                algHandle=str2func(['@(x,y)',alg,'(x,y);']);
                self.Algorithm=algHandle(currentLabel,settingsStruct);
            end

            addlistener(self.Algorithm,'StopAutomation',@(~,~)stop(self));

        end


        function[success,labels]=runAlgorithm(self,I,labels)

            success=false;

            if self.StopRequested
                cleanUpAutomation(self);
                return;
            end

            try



                cats=categories(labels);
                sz=size(labels);

                labels=run(self.Algorithm,I,labels);

                if~iscategorical(labels)
                    error(message('images:segmenter:autoNonCat'));
                end

                if sz~=size(labels)
                    error(message('images:segmenter:autoSizeMismatch'));
                end

                if~isequal(cats,categories(labels))
                    error(message('images:segmenter:autoCatMismatch'));
                end

            catch ME



                if strcmp(ME.identifier,'MATLAB:nomem')
                    myMessage=getString(message('images:segmenter:outOfMemoryAutomation'));
                else
                    myMessage=ME.message;
                end

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(myMessage));
                self.StopRequested=true;
                cleanUpAutomation(self);
                return;
            end

            if self.StopRequested
                cleanUpAutomation(self);
                return;
            end

            success=true;

        end


        function cleanUpAutomation(self)

            delete(self.Algorithm)
            self.Algorithm=[];
            self.IsRunning=false;
            self.Current=self.Start;
            notify(self,'AutomationStopped');

        end


        function TF=isAutomationAlgorithm(~,metaClass)



            metaSuperclass=metaClass.SuperclassList;
            superclasses={metaSuperclass.Name};

            TF=ismember('images.automation.volume.Algorithm',superclasses)&&...
            ~metaClass.Abstract;

        end


        function moveAllResults(self)
            if~isempty(self.CurrentFolder)
                movefile(fullfile(self.TargetFolder,'output1','L1','*.*'),fullfile(self.CurrentFolder,'L1'),'f');
                try %#ok<TRYNC>
                    rmdir(self.TargetFolder,'s');
                end
            end
        end


        function discardAllResults(self)
            try %#ok<TRYNC>
                rmdir(self.TargetFolder,'s');
            end
        end


        function moveSomeResults(self,acceptedBlocks)


            self.BlockFileNames(acceptedBlocks)=[];

            for idx=1:numel(self.BlockFileNames)
                delete(self.BlockFileNames(idx))
            end

            moveAllResults(self);

        end


        function clearFolders(self)
            self.TargetFolder='';
            self.CurrentFolder='';
            self.BlockFileNames=string.empty;
        end

    end

end


function[labels,metrics]=runSliceBlocks(bs,cats,alg,I,goldStandard,useOriginalData,r,g,b,dim,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator)




    if~useOriginalData
        I=images.internal.app.segmenter.volume.data.rescaleVolume(squeeze(I),r,g,b);
    end

    labels=images.internal.app.segmenter.volume.data.stitchedCategorical(bs.Data,1:numel(cats),cats);

    cats=categories(labels);
    sz=size(labels);

    for idx=1:sz(dim)

        switch dim
        case 1
            slice=squeeze(labels(idx,:,:,:));
            dataslice=squeeze(I(idx,:,:,:));
            labels(idx,:,:,:)=run(alg,dataslice,slice);
        case 2
            slice=squeeze(labels(:,idx,:,:));
            dataslice=squeeze(I(:,idx,:,:));
            labels(:,idx,:,:)=run(alg,dataslice,slice);
        case 3
            slice=squeeze(labels(:,:,idx,:));
            dataslice=squeeze(I(:,:,idx,:));
            labels(:,:,idx,:)=run(alg,dataslice,slice);
        end

    end

    if~iscategorical(labels)
        error(message('images:segmenter:autoNonCat'));
    end

    if sz~=size(labels)
        error(message('images:segmenter:autoSizeMismatch'));
    end

    if~isequal(cats,categories(labels))
        error(message('images:segmenter:autoCatMismatch'));
    end

    labels=uint8(labels);

    metrics=computeMetrics(I,bs.Data,labels,cats,goldStandard,useMetrics,morphometrics,customMetric,qualityMetrics);

    send(progressIndicator,bs.BlockSub);

end


function[labels,metrics]=runVolumeBlocks(bs,cats,alg,I,goldStandard,useOriginalData,r,g,b,useMetrics,morphometrics,customMetric,qualityMetrics,progressIndicator)




    if~useOriginalData
        I=images.internal.app.segmenter.volume.data.rescaleVolume(squeeze(I),r,g,b);
    end

    labels=images.internal.app.segmenter.volume.data.stitchedCategorical(bs.Data,1:numel(cats),cats);

    cats=categories(labels);
    sz=size(labels);

    labels=run(alg,I,labels);

    if~iscategorical(labels)
        error(message('images:segmenter:autoNonCat'));
    end

    if sz~=size(labels)
        error(message('images:segmenter:autoSizeMismatch'));
    end

    if~isequal(cats,categories(labels))
        error(message('images:segmenter:autoCatMismatch'));
    end

    labels=uint8(labels);

    metrics=computeMetrics(I,bs.Data,labels,cats,goldStandard,useMetrics,morphometrics,customMetric,qualityMetrics);

    send(progressIndicator,bs.BlockSub);

end

function metrics=computeMetrics(I,labels1,labels2,cats,goldStandard,useMetrics,morphometrics,customMetric,qualityMetrics)

    metrics=struct;

    if useMetrics

        if any(strcmp(morphometrics,"VolumeFraction"))
            metrics.VolumeFraction=computeMetricsPerLabel(I,labels1,labels2,cats,goldStandard,'images.internal.app.segmenter.volume.automation.metrics.volumeFraction');
        end

        if any(contains(morphometrics,"Region"))
            [numRegions,largeRegion,smallRegion]=computeThreeMetricsPerLabel(I,labels1,labels2,cats,goldStandard,'images.internal.app.segmenter.volume.automation.metrics.regionProperties');

            if any(strcmp(morphometrics,"NumberOfRegions"))
                metrics.NumberOfRegions=numRegions;
            end

            if any(strcmp(morphometrics,"LargestRegion"))
                metrics.LargestRegion=largeRegion;
            end

            if any(strcmp(morphometrics,"SmallestRegion"))
                metrics.SmallestRegion=smallRegion;
            end

        end

        if~isempty(qualityMetrics)
            for idx=1:numel(qualityMetrics)
                switch qualityMetrics(idx)

                case "Jaccard"
                    metrics.Jaccard=computeMetricsPerLabel(I,labels1,labels2,cats,goldStandard,'images.internal.app.segmenter.volume.automation.metrics.jaccard');
                case "BFScore"
                    metrics.BFScore=computeMetricsPerLabel(I,labels1,labels2,cats,goldStandard,'images.internal.app.segmenter.volume.automation.metrics.bfscore');
                case "Dice"
                    metrics.Dice=computeMetricsPerLabel(I,labels1,labels2,cats,goldStandard,'images.internal.app.segmenter.volume.automation.metrics.dice');

                end
            end
        end

        if~isempty(customMetric)
            try
                [val,name]=computeCustomMetricsPerLabel(I,labels1,labels2,cats,goldStandard,customMetric);
                metrics.Custom=val;
                metrics.CustomName=name;
            catch ME
                error(message('images:segmenter:customMetricError',ME.message));
            end
        end

    end

end

function val=computeMetricsPerLabel(I,labels1,labels2,cats,gTruth,metricFunction)

    metricHandle=str2func(['@(info)',metricFunction,'(info);']);

    val=cell(size(cats));

    for idx=1:numel(cats)

        try
            s=struct('Volume',I,'PriorMask',labels1==idx,'Mask',labels2==idx,'GroundTruth',gTruth==idx);
            val{idx}=metricHandle(s);
        catch
            val{idx}=nan;
        end

    end

end

function[val,name]=computeCustomMetricsPerLabel(I,labels1,labels2,cats,gTruth,metricFunction)

    [~,metricFunction]=images.internal.app.segmenter.volume.automation.getFileParts(metricFunction);

    metricHandle=str2func(['@(info)',metricFunction,'(info);']);

    val=cell(size(cats));
    name=string(getString(message('images:segmenter:customMetric')));


    for idx=1:numel(cats)

        s=struct('Volume',I,'PriorMask',labels1==idx,'Mask',labels2==idx,'GroundTruth',gTruth==idx);
        [metric,name]=metricHandle(s);
        name=string(name);
        if~isnumeric(metric)
            error(message('images:segmenter:customMetricRequiresScalar'));
        end
        if~isstring(name)
            error(message('images:segmenter:customMetricRequiresString'));
        end
        if~isequal(numel(metric),numel(name))
            error(message('images:segmenter:customMetricSizeMismatch'));
        end
        for i=1:numel(metric)
            val{idx,i}=metric(i);
        end

    end

end

function[val1,val2,val3]=computeThreeMetricsPerLabel(I,labels1,labels2,cats,gTruth,metricFunction)


    metricHandle=str2func(['@(info)',metricFunction,'(info);']);

    val1=cell(size(cats));
    val2=cell(size(cats));
    val3=cell(size(cats));

    for idx=1:numel(cats)

        s=struct('Volume',I,'PriorMask',labels1==idx,'Mask',labels2==idx,'GroundTruth',gTruth);
        [val1{idx},val2{idx},val3{idx}]=metricHandle(s);

    end

end
