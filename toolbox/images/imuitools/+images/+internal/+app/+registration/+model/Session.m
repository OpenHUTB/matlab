classdef Session<handle





    properties(Access=private)
alignments
fixedImage
movingImage
movingRGBImage
fixedReferencingObject
movingReferencingObject
initialMovingReferencingObject
initialMovingTransform
selectedAlignmentIndex
entryCardIndex
initialArguments
isFixedRGB
isMovingRGB
isFixedNormalized
isMovingNormalized

userLoadedTransform
userLoadedFixedRefObj
userLoadedMovingRefObj
    end

    events
updatedFixedAndMovingImages
updatedSettingsPanel
updateScrollPanel
addEntryCard
updateEntryCard
finalizeEntryCard
alignmentExported
alignmentFunctionGenerated
registrationStarted
registrationFinished
errorThrown
    end

    properties(Dependent)

currentAlignment
numberOfAlignments

    end

    methods
        function self=Session()

            self.fixedImage=[];
            self.movingImage=[];
            self.movingRGBImage=[];

            self.runDummyRegistrations();
        end

        function startSession(self,varargin)
            notify(self,'registrationStarted');
            self.alignments=[];
            params=parse_inputs(varargin{:});
            self.fixedImage=params.Results.fixedImage;
            self.movingImage=params.Results.movingImage;
            self.movingRGBImage=params.Results.movingRGBImage;

            self.initialArguments=params.Results.initialAlignments;
            self.selectedAlignmentIndex=params.Results.alignmentIndex;

            self.fixedReferencingObject=params.Results.fixedReferencingObject;
            self.initialMovingReferencingObject=params.Results.movingReferencingObject;
            self.initialMovingTransform=params.Results.initialMovingTransform;
            self.userLoadedTransform=params.Results.userLoadedTransform;
            self.userLoadedFixedRefObj=params.Results.userLoadedFixedRefObj;
            self.userLoadedMovingRefObj=params.Results.userLoadedMovingRefObj;

            self.isFixedRGB=params.Results.isFixedRGB;
            self.isMovingRGB=params.Results.isMovingRGB;
            self.isFixedNormalized=params.Results.isFixedNormalized;
            self.isMovingNormalized=params.Results.isMovingNormalized;


            if self.userLoadedTransform
                [self.movingImage,self.movingReferencingObject]=imwarp(self.movingImage,...
                self.initialMovingReferencingObject,self.initialMovingTransform,'SmoothEdges',true);
                if~isempty(self.movingRGBImage)
                    [self.movingRGBImage,~]=imwarp(self.movingRGBImage,...
                    self.initialMovingReferencingObject,self.initialMovingTransform,'SmoothEdges',true);
                end
            else
                self.movingReferencingObject=self.initialMovingReferencingObject;
            end

            self.createAlignmentsFromNames(self.initialArguments);


            drawnow;
            if isvalid(self)
                self.addScrollPanel(self.fixedImage,self.movingImage);
                self.setImagePairs(self.fixedImage,self.movingImage);
                notify(self,'registrationFinished');
            end

        end

        function alignment=get.currentAlignment(self)
            alignment=self.alignments(self.selectedAlignmentIndex);
        end

        function number=get.numberOfAlignments(self)
            number=numel(self.alignments);
        end

        function addNewAlignment(self,alignmentType,varargin)



            newAlignment=images.internal.app.registration.model.Alignment;
            self.alignments=[self.alignments,newAlignment];
            if~strcmp(alignmentType,'Nonrigid')
                self.alignments(end).rigidOperation=self.setUpRigidOperatorFromName(alignmentType);
            else

                self.alignments(end).useNonrigidOperation=true;
                self.alignments(end).useOnlyNonrigidOperation=true;
            end

            self.selectedAlignmentIndex=self.numberOfAlignments;




            id=self.selectedAlignmentIndex;
            if nargin>2

                modelNumber=varargin{1};
            else
                self.entryCardIndex=self.entryCardIndex+1;
                modelNumber=num2str(self.entryCardIndex);
            end
            self.alignments(end).entryName=alignmentType;
            self.alignments(end).entryNumber=modelNumber;
            self.addAlignmentEntryCard(alignmentType,id,modelNumber,true);


            self.setImagePairs(self.fixedImage,self.movingImage);
            if nargin==2
                self.updateSettingsPanel();
            end
        end

        function setCurrentAlignment(self,alignmentIdx)

            self.selectedAlignmentIndex=alignmentIdx;
            imageData.fixed=self.fixedImage;
            imageData.moving=self.currentAlignment.registeredImage;
            imageData.fixedRefObj=self.fixedReferencingObject;
            imageData.movingRefObj=self.fixedReferencingObject;
            if isempty(imageData.moving)
                imageData.moving=self.movingImage;
                imageData.movingRefObj=self.movingReferencingObject;
            end
            imageData.featureData=self.getFeatureLocations();
            evtData=images.internal.app.registration.model.customEventData(imageData);
            notify(self,'updatedFixedAndMovingImages',evtData);

            self.updateSettingsPanel();

        end

        function deleteCurrentAlignment(self,alignmentIdx)

            self.alignments(alignmentIdx)=[];

        end

        function[]=runCurrentAlignment(self)

            s=warning('off','all');
            lastwarn('');

            notify(self,'registrationStarted');

            try

                self.currentAlignment.runAlignment(self.fixedImage,self.movingImage,...
                self.movingRGBImage,...
                self.fixedReferencingObject,self.movingReferencingObject);
                if isempty(lastwarn)

                    self.currentAlignment.statusMessage='';
                    self.finalizeAlignmentEntryCard();
                    self.currentAlignment.entryStatus=true;
                    imageData.moving=self.currentAlignment.registeredImage;
                    imageData.movingRefObj=self.fixedReferencingObject;
                else
                    self.showErrorDialog();
                    self.setRedDraftState();
                    imageData.moving=self.movingImage;
                    imageData.movingRefObj=self.movingReferencingObject;
                end
            catch ME
                self.showErrorDialog(ME);
                self.setRedDraftState();
                imageData.moving=self.movingImage;
                imageData.movingRefObj=self.movingReferencingObject;
            end

            imageData.fixed=self.fixedImage;
            imageData.fixedRefObj=self.fixedReferencingObject;
            imageData.featureData=self.getFeatureLocations();
            evtData=images.internal.app.registration.model.customEventData(imageData);
            notify(self,'updatedFixedAndMovingImages',evtData);
            notify(self,'registrationFinished');

            warning(s);

        end

        function showErrorDialog(self,varargin)

            import images.internal.app.registration.ui.*;

            if any(contains(self.currentAlignment.entryName,{'SURF','FAST','MSER','BRISK','Harris','MinEigen','KAZE','ORB'}))
                self.currentAlignment.statusMessage=getMessageString('poorQualityFeatures');
            elseif~isempty(lastwarn)
                [msgstr,msgid]=lastwarn;
                if strcmp(msgid,'images:imregcorr:weakPeakCorrelation')
                    msgstr=getString(message([msgid,'App']));
                end
                self.currentAlignment.statusMessage=msgstr;
            elseif nargin>1
                ME=varargin{1};
                self.currentAlignment.statusMessage=ME.message;
            else
                self.currentAlignment.statusMessage='';

                return;
            end

            data.Message=self.currentAlignment.statusMessage;
            data.Title=getMessageString('registrationError');
            evtData=images.internal.app.registration.model.customEventData(data);
            notify(self,'errorThrown',evtData);

        end

        function setRedDraftState(self)
            self.currentAlignment.registeredImage=[];
            self.currentAlignment.registeredRGBImage=[];
            self.updateAlignmentEntryCard(false);
            self.currentAlignment.entryStatus=false;
        end

        function updateAlignmentParameters(self,~,evtData)

            self.currentAlignment.entryStatus=true;
            self.currentAlignment.statusMessage='';


            self.currentAlignment.useNonrigidOperation=evtData.data.nonrigid.NonrigidSelected;
            self.currentAlignment.nonrigidOperation.demonsProperty.numberOfIterations=evtData.data.nonrigid.Iterations;
            self.currentAlignment.nonrigidOperation.demonsProperty.accumulatedFieldSmoothing=evtData.data.nonrigid.Smoothing;
            self.currentAlignment.nonrigidOperation.demonsProperty.pyramidLevels=evtData.data.nonrigid.PyramidLevels;

            if~strcmp(self.currentAlignment.entryName,'Nonrigid')
                self.currentAlignment.rigidOperation.tformType=evtData.data.Tform;
            end

            registrationPerformed=false;

            switch self.currentAlignment.entryName

            case{'FAST','BRISK','Harris','MinEigen'}
                self.currentAlignment.rigidOperation.featureProperty.upright=evtData.data.Upright;
                self.currentAlignment.rigidOperation.featureProperty.featureNumber=evtData.data.FeatureNumber;
                self.currentAlignment.rigidOperation.featureProperty.featureQuality=evtData.data.FeatureQuality;
                notify(self,'registrationStarted');
                self.currentAlignment.rigidOperation.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
                registrationPerformed=true;

            case 'ORB'
                self.currentAlignment.rigidOperation.featureProperty.numLevels=evtData.data.NumLevels;
                self.currentAlignment.rigidOperation.featureProperty.scaleFactor=evtData.data.ScaleFactor;
                self.currentAlignment.rigidOperation.featureProperty.featureQuality=evtData.data.FeatureQuality;
                notify(self,'registrationStarted');
                self.currentAlignment.rigidOperation.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
                registrationPerformed=true;

            case{'SURF','MSER'}
                self.currentAlignment.rigidOperation.featureProperty.upright=evtData.data.Upright;
                self.currentAlignment.rigidOperation.featureProperty.featureNumber=evtData.data.FeatureNumber;
                self.currentAlignment.rigidOperation.featureProperty.featureQuality=evtData.data.FeatureQuality;
                notify(self,'registrationStarted');
                self.currentAlignment.rigidOperation.getMatchingFeatures(self.fixedImage,self.movingImage,'SSD');
                registrationPerformed=true;
            case 'KAZE'
                self.currentAlignment.rigidOperation.featureProperty.upright=evtData.data.Upright;
                self.currentAlignment.rigidOperation.featureProperty.featureNumber=evtData.data.FeatureNumber;
                self.currentAlignment.rigidOperation.featureProperty.featureQuality=evtData.data.FeatureQuality;
                self.currentAlignment.rigidOperation.featureProperty.diffusion=evtData.data.Diffusion;
                notify(self,'registrationStarted');
                self.currentAlignment.rigidOperation.getMatchingFeatures(self.fixedImage,self.movingImage,'SSD');
                registrationPerformed=true;
            case 'Monomodal'
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.normalize=evtData.data.Normalize;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.applyBlur=evtData.data.ApplyBlur;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.blurValue=evtData.data.BlurValue;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.alignCenters=evtData.data.AlignCenters;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.GradientMagnitudeTolerance=evtData.data.GradMagTol;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MinimumStepLength=evtData.data.MinStepLength;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumStepLength=evtData.data.MaxStepLength;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumIterations=evtData.data.MaxIterations;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.RelaxationFactor=evtData.data.RelaxFactor;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.pyramidLevels=evtData.data.PyramidLevels;
            case 'Multimodal'
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.normalize=evtData.data.Normalize;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.applyBlur=evtData.data.ApplyBlur;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.blurValue=evtData.data.BlurValue;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.alignCenters=evtData.data.AlignCenters;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.GrowthFactor=evtData.data.GrowthFactor;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.Epsilon=evtData.data.Epsilon;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.InitialRadius=evtData.data.InitialRadius;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumIterations=evtData.data.MaxIterations;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.pyramidLevels=evtData.data.PyramidLevels;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.NumberOfSpatialSamples=evtData.data.NumSamples;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.NumberOfHistogramBins=evtData.data.NumBins;
                self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.UseAllPixels=evtData.data.UseAllPixels;
            case 'Phase Correlation'
                self.currentAlignment.rigidOperation.correlationProperty.window=evtData.data.Window;
            end

            self.updateAlignmentEntryCard(true);
            self.setCurrentAlignment(self.selectedAlignmentIndex);

            if registrationPerformed
                notify(self,'registrationFinished');
            end

        end

        function updateSettingsPanel(self)
            settingsData=self.gatherSettingsData(false);
            evtData=images.internal.app.registration.model.customEventData(settingsData);
            notify(self,'updatedSettingsPanel',evtData);
        end

        function settingsData=gatherSettingsData(self,TF)


            settingsData.nonrigid.NonrigidSelected=self.currentAlignment.useNonrigidOperation;
            settingsData.nonrigid.Iterations=self.currentAlignment.nonrigidOperation.demonsProperty.numberOfIterations;
            settingsData.nonrigid.Smoothing=self.currentAlignment.nonrigidOperation.demonsProperty.accumulatedFieldSmoothing;
            settingsData.nonrigid.PyramidLevels=self.currentAlignment.nonrigidOperation.demonsProperty.pyramidLevels;

            if~strcmp(self.currentAlignment.entryName,'Nonrigid')
                settingsData.Tform=self.currentAlignment.rigidOperation.tformType;
            end

            switch self.currentAlignment.entryName
            case{'SURF','FAST','MSER','BRISK','Harris','MinEigen'}
                settingsData.Upright=self.currentAlignment.rigidOperation.featureProperty.upright;
                settingsData.FeatureNumber=self.currentAlignment.rigidOperation.featureProperty.featureNumber;
                settingsData.FeatureQuality=self.currentAlignment.rigidOperation.featureProperty.featureQuality;
            case 'ORB'
                settingsData.ScaleFactor=self.currentAlignment.rigidOperation.featureProperty.scaleFactor;
                settingsData.NumLevels=self.currentAlignment.rigidOperation.featureProperty.numLevels;
                settingsData.FeatureQuality=self.currentAlignment.rigidOperation.featureProperty.featureQuality;
            case 'KAZE'
                settingsData.Upright=self.currentAlignment.rigidOperation.featureProperty.upright;
                settingsData.FeatureNumber=self.currentAlignment.rigidOperation.featureProperty.featureNumber;
                settingsData.FeatureQuality=self.currentAlignment.rigidOperation.featureProperty.featureQuality;
                settingsData.Diffusion=self.currentAlignment.rigidOperation.featureProperty.diffusion;
            case 'Monomodal'
                settingsData.Normalize=self.currentAlignment.rigidOperation.iterativeIntensityProperty.normalize;
                settingsData.ApplyBlur=self.currentAlignment.rigidOperation.iterativeIntensityProperty.applyBlur;
                settingsData.BlurValue=self.currentAlignment.rigidOperation.iterativeIntensityProperty.blurValue;
                settingsData.AlignCenters=self.currentAlignment.rigidOperation.iterativeIntensityProperty.alignCenters;
                settingsData.GradMagTol=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.GradientMagnitudeTolerance;
                settingsData.MinStepLength=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MinimumStepLength;
                settingsData.MaxStepLength=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumStepLength;
                settingsData.MaxIterations=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumIterations;
                settingsData.RelaxFactor=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.RelaxationFactor;
                settingsData.PyramidLevels=self.currentAlignment.rigidOperation.iterativeIntensityProperty.pyramidLevels;
            case 'Multimodal'
                settingsData.Normalize=self.currentAlignment.rigidOperation.iterativeIntensityProperty.normalize;
                settingsData.ApplyBlur=self.currentAlignment.rigidOperation.iterativeIntensityProperty.applyBlur;
                settingsData.BlurValue=self.currentAlignment.rigidOperation.iterativeIntensityProperty.blurValue;
                settingsData.AlignCenters=self.currentAlignment.rigidOperation.iterativeIntensityProperty.alignCenters;
                settingsData.MaxIterations=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.MaximumIterations;
                settingsData.PyramidLevels=self.currentAlignment.rigidOperation.iterativeIntensityProperty.pyramidLevels;
                settingsData.GrowthFactor=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.GrowthFactor;
                settingsData.Epsilon=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.Epsilon;
                settingsData.InitialRadius=self.currentAlignment.rigidOperation.iterativeIntensityProperty.optimizer.InitialRadius;
                settingsData.NumSamples=self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.NumberOfSpatialSamples;
                settingsData.NumBins=self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.NumberOfHistogramBins;
                settingsData.UseAllPixels=self.currentAlignment.rigidOperation.iterativeIntensityProperty.metric.UseAllPixels;
            case 'Phase Correlation'
                settingsData.Window=self.currentAlignment.rigidOperation.correlationProperty.window;
            end

            if TF

                settingsData.userLoadedTransform=self.userLoadedTransform;
                settingsData.userLoadedFixedRefObj=self.userLoadedFixedRefObj;
                settingsData.userLoadedMovingRefObj=self.userLoadedMovingRefObj;
                settingsData.fixedReferencingObject=self.fixedReferencingObject;
                settingsData.movingReferencingObject=self.initialMovingReferencingObject;
                settingsData.alignmentType=self.currentAlignment.entryName;
                settingsData.isFixedRGB=self.isFixedRGB;
                settingsData.isMovingRGB=self.isMovingRGB;
                settingsData.isFixedNormalized=self.isFixedNormalized;
                settingsData.isMovingNormalized=self.isMovingNormalized;

                if any(contains(self.currentAlignment.entryName,{'SURF','FAST','MSER','BRISK','Harris','MinEigen','KAZE','ORB'}))
                    settingsData.MatchThreshold=self.currentAlignment.rigidOperation.featureProperty.matchThreshold;
                    settingsData.MaxRatio=self.currentAlignment.rigidOperation.featureProperty.maxRatio;
                end


                switch self.currentAlignment.entryName
                case 'SURF'
                    settingsData.MetricThreshold=self.currentAlignment.rigidOperation.featureProperty.metricThreshold;
                    settingsData.NumOctaves=self.currentAlignment.rigidOperation.featureProperty.numOctaves;
                    settingsData.NumScaleLevels=self.currentAlignment.rigidOperation.featureProperty.numScaleLevels;
                case 'FAST'
                    settingsData.MinContrast=self.currentAlignment.rigidOperation.featureProperty.minContrast;
                    settingsData.MinQuality=self.currentAlignment.rigidOperation.featureProperty.minQuality;
                case 'MSER'
                    settingsData.ThresholdDelta=self.currentAlignment.rigidOperation.featureProperty.thresholdDelta;
                    settingsData.RegionAreaRange=self.currentAlignment.rigidOperation.featureProperty.regionAreaRange;
                    settingsData.MaxAreaVariation=self.currentAlignment.rigidOperation.featureProperty.maxAreaVariation;
                case 'BRISK'
                    settingsData.MinContrast=self.currentAlignment.rigidOperation.featureProperty.minContrast;
                    settingsData.MinQuality=self.currentAlignment.rigidOperation.featureProperty.minQuality;
                    settingsData.NumOctaves=self.currentAlignment.rigidOperation.featureProperty.numOctaves;
                case{'Harris','MinEigen'}
                    settingsData.MinQuality=self.currentAlignment.rigidOperation.featureProperty.minQuality;
                    settingsData.FilterSize=self.currentAlignment.rigidOperation.featureProperty.filterSize;
                case 'KAZE'
                    settingsData.Threshold=self.currentAlignment.rigidOperation.featureProperty.threshold;
                    settingsData.NumOctaves=self.currentAlignment.rigidOperation.featureProperty.numOctaves;
                    settingsData.NumScaleLevels=self.currentAlignment.rigidOperation.featureProperty.numScaleLevels;
                    settingsData.Diffusion=self.currentAlignment.rigidOperation.featureProperty.diffusion;
                case 'ORB'
                    settingsData.ScaleFactor=self.currentAlignment.rigidOperation.featureProperty.scaleFactor;
                    settingsData.NumLevels=self.currentAlignment.rigidOperation.featureProperty.numLevels;
                end
            end

        end

        function runDummyRegistrations(self)




            dummyRegistrations={'MSER','Phase Correlation','Monomodal'};
            I=uint8(magic(16));
            for ii=1:length(dummyRegistrations)
                try
                    newAlignment=images.internal.app.registration.model.Alignment;
                    newAlignment.rigidOperation=self.setUpRigidOperatorFromName(dummyRegistrations{ii});
                    if strcmp(dummyRegistrations{ii},'MSER')
                        newAlignment.rigidOperation.getMatchingFeatures(I,I,'SSD');
                    end
                    newAlignment.runAlignment(I,I,imref2d(size(I)),imref2d(size(I)));
                catch

                end
            end

        end

    end

    methods

        function[]=setImagePairs(self,fixed,moving)
            self.fixedImage=fixed;
            self.movingImage=moving;
            imageData.fixed=self.fixedImage;
            imageData.moving=self.movingImage;
            imageData.fixedRefObj=self.fixedReferencingObject;
            imageData.movingRefObj=self.movingReferencingObject;
            imageData.featureData=self.getFeatureLocations();
            evtData=images.internal.app.registration.model.customEventData(imageData);
            notify(self,'updatedFixedAndMovingImages',evtData);
        end

        function addScrollPanel(self,fixed,moving)
            imageData.fixed=fixed;
            imageData.moving=moving;
            imageData.fixedRefObj=self.fixedReferencingObject;
            imageData.movingRefObj=self.movingReferencingObject;
            evtData=images.internal.app.registration.model.customEventData(imageData);
            notify(self,'updateScrollPanel',evtData);
        end

        function addAlignmentEntryCard(self,modelName,id,modelNumber,status)
            evtData=self.packageCardData(modelName,id,modelNumber,status);
            notify(self,'addEntryCard',evtData);
        end

        function updateAlignmentEntryCard(self,status)
            evtData=self.packageCardData(self.currentAlignment.entryName,...
            self.selectedAlignmentIndex,self.currentAlignment.entryNumber,status);
            notify(self,'updateEntryCard',evtData);
        end

        function finalizeAlignmentEntryCard(self)
            cardData.Quality=self.currentAlignment.metrics.ssim;
            cardData.Time=self.currentAlignment.elapsedTime;
            cardData.Draft=false;
            cardData.Index=self.selectedAlignmentIndex;
            cardData.statusMessage=self.currentAlignment.statusMessage;
            evtData=images.internal.app.registration.model.customEventData(cardData);
            notify(self,'finalizeEntryCard',evtData);
        end

        function evtData=packageCardData(self,modelName,id,modelNumber,status)
            cardData.Status=status;
            cardData.NameMessage=modelName;
            cardData.ModelNumber=modelNumber;
            cardData.ID=id;
            if any(strcmp(cardData.NameMessage,{'SURF','FAST','MSER','BRISK','Harris','MinEigen','KAZE','ORB'}))
                cardData.numMatched=size(self.currentAlignment.rigidOperation.indexPairs,1);
                cardData.numFixed=size(self.currentAlignment.rigidOperation.fixedValidPoints,1);
                cardData.numMoving=size(self.currentAlignment.rigidOperation.movingValidPoints,1);
                if status
                    cardData.Status=getFeatureBasedAlignmentStatus(...
                    self.currentAlignment.rigidOperation.tformType,cardData.numMatched);
                    if cardData.Status
                        self.currentAlignment.statusMessage='';
                    else
                        self.currentAlignment.statusMessage=images.internal.app.registration.ui.getMessageString('fewMatchedFeatures');
                    end
                end
                self.currentAlignment.entryStatus=cardData.Status;
            end
            cardData.statusMessage=self.currentAlignment.statusMessage;
            evtData=images.internal.app.registration.model.customEventData(cardData);
        end

        function featureData=getFeatureLocations(self)


            featureData=struct('fixed',[NaN,NaN],'moving',[NaN,NaN]);

            if~isempty(self.alignments)&&any(strcmp(self.currentAlignment.entryName,{'SURF','FAST','MSER','BRISK','Harris','MinEigen','KAZE','ORB'}))
                featureData.fixed=self.currentAlignment.rigidOperation.fixedMatchedPoints;
                featureData.moving=self.currentAlignment.rigidOperation.movingMatchedPoints;
            end

        end

        function exportToWorkspace(self)


            if~isempty(self.movingRGBImage)
                imageData.RegisteredImage=self.currentAlignment.registeredRGBImage;
            else
                imageData.RegisteredImage=self.currentAlignment.registeredImage;
            end

            imageData.SpatialRefObj=self.fixedReferencingObject;

            if~strcmp(self.currentAlignment.entryName,'Nonrigid')
                imageData.Transformation=self.currentAlignment.rigidOperation.tform;
            end

            if~isempty(self.currentAlignment.nonrigidOperation.displacementField)
                imageData.DisplacementField=self.currentAlignment.nonrigidOperation.displacementField;
            end

            evtData=images.internal.app.registration.model.customEventData(imageData);
            notify(self,'alignmentExported',evtData)

        end

        function exportToFunction(self)
            settingsData=self.gatherSettingsData(true);
            evtData=images.internal.app.registration.model.customEventData(settingsData);
            notify(self,'alignmentFunctionGenerated',evtData)
        end

    end

    methods(Access=private)

        function[]=createAlignmentsFromNames(self,nameCellArray)
            self.alignments=[];
            self.entryCardIndex=0;
            for idx=1:length(nameCellArray)
                newAlignment=images.internal.app.registration.model.Alignment;
                self.alignments=[self.alignments,newAlignment];
                self.selectedAlignmentIndex=idx;
                self.entryCardIndex=idx;
                self.alignments(idx).entryName=nameCellArray{idx};
                self.alignments(idx).entryNumber=num2str(idx);
                self.alignments(idx).rigidOperation=self.setUpRigidOperatorFromName(nameCellArray{idx});
                modelNumber=num2str(idx);
                self.addAlignmentEntryCard(nameCellArray{idx},idx,modelNumber,true);
            end

            if~isempty(self.alignments)
                self.updateSettingsPanel();
            end

        end

        function operator=setUpRigidOperatorFromName(self,nameString)
            switch nameString
            case 'Monomodal'
                operator=images.internal.app.registration.model.IterativeIntensityOperator('monomodal');
            case 'Multimodal'
                operator=images.internal.app.registration.model.IterativeIntensityOperator('multimodal');
            case 'Phase Correlation'
                operator=images.internal.app.registration.model.CorrelationOperator;
            case 'SURF'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.SURF;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'SSD');
            case 'FAST'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.FAST;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
            case 'BRISK'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.BRISK;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
            case 'Harris'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.Harris;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
            case 'MinEigen'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.MinEigen;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
            case 'MSER'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.MSER;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'SSD');
            case 'KAZE'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.KAZE;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'SSD');
            case 'ORB'
                operator=images.internal.app.registration.model.FeatureOperator;
                operator.featureProperty=images.internal.app.registration.model.ORB;
                operator.getMatchingFeatures(self.fixedImage,self.movingImage,'Hamming');
            otherwise
                assert(false,'Error: Rigid Operator name not specified correctly.');
            end
        end
    end

end

function params=parse_inputs(varargin)


    params=inputParser;

    params.FunctionName=mfilename;

    defaultAlignments={'Phase Correlation','MSER','SURF'};
    defaultFixedReferencingObject=imref2d();
    defaultMovingReferencingObject=imref2d();
    defaultInitialTransform=affine2d();
    defaultAlignmentIndex=1;
    defaultBoolean=false;

    addOptional(params,'fixedImage',@validateImage);
    addOptional(params,'movingImage',@validateImage);
    addOptional(params,'movingRGBImage',@validateImage);

    addOptional(params,'initialAlignments',defaultAlignments,@(x)isa(x,'cell'));
    addOptional(params,'fixedReferencingObject',defaultFixedReferencingObject,@(x)isa(x,'imref2d'));
    addOptional(params,'movingReferencingObject',defaultMovingReferencingObject,@(x)isa(x,'imref2d'));
    addOptional(params,'initialMovingTransform',defaultInitialTransform,@validateInitialTransformation);
    addOptional(params,'alignmentIndex',defaultAlignmentIndex,@isnumeric);
    addOptional(params,'userLoadedTransform',defaultBoolean,@islogical);
    addOptional(params,'userLoadedFixedRefObj',defaultBoolean,@islogical);
    addOptional(params,'userLoadedMovingRefObj',defaultBoolean,@islogical);
    addOptional(params,'isFixedRGB',defaultBoolean,@islogical);
    addOptional(params,'isMovingRGB',defaultBoolean,@islogical);
    addOptional(params,'isFixedNormalized',defaultBoolean,@islogical);
    addOptional(params,'isMovingNormalized',defaultBoolean,@islogical);

    parse(params,varargin{:});

    function TF=validateInitialTransformation(x)
        TF=isa(x,'affine2d')||isa(x,'projective2d');
    end

    function TF=validateImage(im)
        validateattributes(im,{'numeric','logical'});
        TF=true;
    end

end

function TF=getFeatureBasedAlignmentStatus(tformType,numMatchedPoints)

    switch tformType
    case 'rigid'
        minNumPoints=2;
    case 'similarity'
        minNumPoints=2;
    case 'affine'
        minNumPoints=3;
    case 'projective'
        minNumPoints=4;
    end

    if numMatchedPoints>=minNumPoints
        TF=true;
    else
        TF=false;
    end

end
