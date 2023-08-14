




classdef Model<handle&matlab.mixin.SetGet

    properties(Dependent)
XSliceLocationSelected
YSliceLocationSelected
ZSliceLocationSelected

SliceManager
Show3DVolume
Renderer
Transform

CameraPosition
CameraTarget
CameraUpVector
CameraViewAngle
    end

    properties
VolumeDataInternal
LabeledVolumeDataInternal
MergedVolumeDataInternal

XSliceLocationSelectedInternal
YSliceLocationSelectedInternal
ZSliceLocationSelectedInternal

AxesOrientationInternal
SliceManagerVolume
SliceManagerLabels

Show3DVolumeInternal
RendererInternal
TransformInternal

CameraPositionInternal
CameraTargetInternal
CameraUpVectorInternal
CameraViewAngleInternal

IsLogicalData
IsCategoricalData

IntensityBreakdownIdx
VolumeConfig
OverlayConfig
LabelConfig

UniqueLabels
UniqueLabelsScaled
ScaleLabelsUtil

    end

    properties(SetAccess=private,Dependent)
VolumeData
LabeledVolumeData
MergedVolumeData

XYSlice
YZSlice
XZSlice
XYSliceLabels
YZSliceLabels
XZSliceLabels

UpsampleToCubeTransform
    end

    properties
ValidSpatialReferencingInFile
CustomTransform
TransformFromFileMetadata
BackgroundColor
CancelImportFlag

HasVolumeData
HasLabeledVolumeData

VolumeSize
VolumeMode
    end


    methods

        function self=Model(volData)

            self.CancelImportFlag=false;
            self.HasVolumeData=false;
            self.HasLabeledVolumeData=false;
            self.IntensityBreakdownIdx=0;


            self.Show3DVolumeInternal=true;

            if nargin>0
                self.loadDataFromWorkspace(volData,'volume','');
            else

                self.loadDataFromWorkspace(zeros(3,3,3),'dummy','');
            end

        end

        function clearModel(self)
            self.CancelImportFlag=false;
            self.HasVolumeData=false;
            self.HasLabeledVolumeData=false;
            self.IntensityBreakdownIdx=0;

            self.loadDataFromWorkspace(zeros(3,3,3),'dummy','');
            self.VolumeDataInternal=[];
            self.LabeledVolumeDataInternal=[];
            self.MergedVolumeDataInternal=[];

            self.notify('ModelCleared');
        end

        function setDefaultModelProperties(self,volSize)

            import images.internal.app.volviewToolgroup.*
            if self.HasVolumeData||self.HasLabeledVolumeData
                return
            end

            if(self.IsLogicalData&&iptgetpref('VolumeViewerUseHardware'))
                self.RendererInternal='Isosurface';
            else
                self.RendererInternal='VolumeRendering';
            end

            self.CustomTransform=eye(4);
            self.TransformInternal=self.CustomTransform;

            self.BackgroundColor=[0.3,0.75,0.93];


            self.VolumeConfig=VolumeConfiguration('default');
            if isempty(self.LabelConfig)
                self.LabelConfig=LabelConfiguration('default');
            end
            self.OverlayConfig=LabelOverlayConfiguration(self.LabelConfig,self.IntensityBreakdownIdx);


            self.CameraUpVectorInternal=[0,0,1];
            self.CameraTargetInternal=[0,0,0];
            self.CameraPositionInternal=[4,4,2.5];
            self.CameraViewAngleInternal=15;


            self.XSliceLocationSelectedInternal=mean([1,volSize(2)]);
            self.YSliceLocationSelectedInternal=mean([1,volSize(1)]);
            self.ZSliceLocationSelectedInternal=mean([1,volSize(3)]);

        end

        function setDefaultCameraPosition(self)

            self.CameraTargetInternal=[0,0,0];
            self.CameraUpVectorInternal=[0,0,1];
            self.CameraViewAngleInternal=15;
            self.CameraPosition=[4,4,2.5];

        end

        function loadNewVolumeData(self,volData,volType)


            import images.internal.app.volviewToolgroup.*

            self.IsLogicalData=islogical(volData);
            self.setDefaultModelProperties(size(volData));

            if strcmp(volType,'labels')
                self.HasLabeledVolumeData=true;
            elseif strcmp(volType,'volume')
                self.HasVolumeData=true;
            end

            if self.HasLabeledVolumeData&&self.HasVolumeData
                self.addVolume(volData,volType);
                self.mergeVolumes();
                self.setPrebuiltTransferFunction('default');
            else
                self.loadVolumeData(volData,volType);
                if isequal(volType,'labels')
                    self.setPrebuiltTransferFunction('labels');
                elseif self.IsLogicalData
                    self.setPrebuiltTransferFunction('isosurface-binary');
                else
                    self.setPrebuiltTransferFunction('default');
                end
            end

            self.setDefaultCameraPosition();

        end

        function loadVolumeData(self,volData,volType)






            volData=permute(volData,[2,1,3]);


            self.VolumeMode=volType;

            self.VolumeSize=size(volData);


            self.XSliceLocationSelectedInternal=mean([1,self.VolumeSize(1)]);
            self.YSliceLocationSelectedInternal=mean([1,self.VolumeSize(2)]);
            self.ZSliceLocationSelectedInternal=mean([1,self.VolumeSize(3)]);


            if isequal(volType,'labels')
                self.setLabelProperties(volData);
                volData=self.scaleLabeledData(volData);
                self.LabeledVolumeData=volData;
            else
                self.VolumeData=self.scaleVolumeData(volData);
            end
        end

        function addVolume(self,volData,volType)



            volData=permute(volData,[2,1,3]);


            self.VolumeMode='mixed';


            if isequal(volType,'labels')
                self.setLabelProperties(volData);
                volData=self.scaleLabeledData(volData);
                self.LabeledVolumeData=volData;
                self.VolumeDataInternal=imadjustn(self.VolumeData,[0,1],[0,(self.IntensityBreakdownIdx-1)/255]);

            else
                volData=self.scaleVolumeData(volData);
                self.VolumeData=imadjustn(volData,[0,1],[0,(self.IntensityBreakdownIdx-1)/255]);
            end
        end

        function loadNewMixedVolumeData(self,volData,volDataLabel,source1Name,source2Name,scaleTform)
            import images.internal.app.volviewToolgroup.*

            volSize=size(volData);
            if~isequal(volSize,size(volDataLabel))
                self.notify('VolumeSizesNotEqual',ErrorEventData(getString(message('images:volumeViewerToolgroup:volumeSizesNotEqual'))));
                return;
            end

            self.setDefaultModelProperties(volSize);

            self.loadMixedVolumeData(volData,volDataLabel);

            if nargin>3
                self.notify('InputSourceChange',InputSourceUpdateEventData(source1Name,"volume"));
                self.notify('InputSourceChange',InputSourceUpdateEventData(source2Name,"labels"));
            end

            self.setPrebuiltTransferFunction('default');

            if nargin==6&&~isempty(scaleTform)
                self.ValidSpatialReferencingInFile=true;
                self.TransformFromFileMetadata=scaleTform;
                self.Transform=scaleTform;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(true));
            else
                self.Transform=self.CustomTransform;
            end

            self.setDefaultCameraPosition();

        end

        function loadMixedVolumeData(self,volData,volDataLabel)


            import images.internal.app.volviewToolgroup.*
            try
                self.checkUniqueLabels(volDataLabel);
            catch ME
                self.notify('NumLabelsExceededMax',ErrorEventData(ME.message));
                return;
            end

            self.HasVolumeData=true;
            self.HasLabeledVolumeData=true;




            volData=permute(volData,[2,1,3]);
            volDataLabel=permute(volDataLabel,[2,1,3]);


            self.VolumeMode='mixed';

            self.VolumeSize=size(volData);


            self.XSliceLocationSelectedInternal=mean([1,self.VolumeSize(1)]);
            self.YSliceLocationSelectedInternal=mean([1,self.VolumeSize(2)]);
            self.ZSliceLocationSelectedInternal=mean([1,self.VolumeSize(3)]);


            volData=self.scaleVolumeData(volData);
            self.setLabelProperties(volDataLabel);
            volDataLabel=self.scaleLabeledData(volDataLabel);
            self.LabeledVolumeData=volDataLabel;
            self.VolumeData=imadjustn(volData,[0,1],[0,(self.IntensityBreakdownIdx-1)/255]);

            self.IsLogicalData=islogical(volData);
            self.mergeVolumes();


            self.triggerMergedVolumeDataChange();

        end

        function replaceLabeledVolumeData(self,volDataLabel)

            try
                self.checkUniqueLabels(volDataLabel);
            catch ME
                self.notify('NumLabelsExceededMax',ErrorEventData(ME.message));
                return;
            end




            volDataLabel=permute(volDataLabel,[2,1,3]);

            self.VolumeSize=size(volDataLabel);


            self.XSliceLocationSelectedInternal=mean([1,self.VolumeSize(1)]);
            self.YSliceLocationSelectedInternal=mean([1,self.VolumeSize(2)]);
            self.ZSliceLocationSelectedInternal=mean([1,self.VolumeSize(3)]);

            self.setLabelProperties(volDataLabel);
            volDataLabel=self.scaleLabeledData(volDataLabel);
            self.LabeledVolumeData=volDataLabel;

            if self.HasVolumeData
                self.mergeVolumes();
            end
        end

        function mergeVolumes(self)


            self.MergedVolumeDataInternal=self.VolumeData;


            labelIdx=1:self.LabelConfig.NumLabels;
            showFlags=self.LabelConfig.ShowFlags(1:end);

            self.manageLabelVisibilty(labelIdx,showFlags);
        end

        function importVolumeFromFile(self,filename,volType)

            import images.internal.app.volviewToolgroup.*
            mergedDataCleared=false;
            if self.HasVolumeData&&self.HasLabeledVolumeData
                self.MergedVolumeDataInternal=[];
                mergedDataCleared=true;
            end

            try
                [newVol,tform]=images.internal.app.volviewToolgroup.importVolumeFromFile(filename);
            catch ME
                self.notify('UnableToLoadFile',ErrorEventData(ME.message));
                return;
            end

            self.notify('CheckReplaceOrOverlay',CheckReplaceOrOverlayEventData(volType,...
            size(newVol),self.VolumeSize,self.HasVolumeData,self.HasLabeledVolumeData));

            if self.CancelImportFlag
                self.CancelImportFlag=false;
                if mergedDataCleared
                    self.mergeVolumes();
                end
                return
            else
                if strcmp(volType,'labels')
                    try
                        self.checkUniqueLabels(newVol);
                    catch ME
                        self.notify('NumLabelsExceededMax',ErrorEventData(ME.message));
                        return;
                    end
                end
            end

            if strcmp(volType,'volume')
                self.TransformFromFileMetadata=[];
            end

            self.loadNewVolumeData(newVol,volType);
            [~,fname,ext]=fileparts(filename);
            self.notify('InputSourceChange',InputSourceUpdateEventData([fname,ext],volType));

            if~isempty(tform)&&strcmp(volType,'volume')
                self.ValidSpatialReferencingInFile=true;
                self.TransformFromFileMetadata=tform;
                self.Transform=tform;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(true));
            elseif isempty(self.TransformFromFileMetadata)
                self.ValidSpatialReferencingInFile=false;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(false));
            end
        end

        function importVolumeFromDicomFolder(self,directoryName,volType)

            import images.internal.app.volviewToolgroup.*

            mergedDataCleared=false;
            if self.HasVolumeData&&self.HasLabeledVolumeData
                self.MergedVolumeDataInternal=[];
                mergedDataCleared=true;
            end

            try
                [newVol,spatialDetails,sliceDim]=dicomreadVolume(directoryName);
                newVol=squeeze(newVol);
                sliceLoc=spatialDetails.PatientPositions;
                allPixelSpacings=spatialDetails.PixelSpacings;
            catch ME
                self.notify('UnableToLoadFolder',ErrorEventData(ME.message));
                return;
            end

            self.notify('CheckReplaceOrOverlay',CheckReplaceOrOverlayEventData(volType,...
            size(newVol),self.VolumeSize,self.HasVolumeData,self.HasLabeledVolumeData));

            if self.CancelImportFlag
                self.CancelImportFlag=false;
                if mergedDataCleared
                    self.mergeVolumes();
                end
                return
            else
                if strcmp(volType,'labels')
                    try
                        self.checkUniqueLabels(newVol);
                    catch ME
                        self.notify('NumLabelsExceededMax',ErrorEventData(ME.message));
                        return;
                    end
                end
            end

            if strcmp(volType,'volume')
                self.TransformFromFileMetadata=[];
            end

            self.loadNewVolumeData(newVol,volType);
            [~,dname]=fileparts(directoryName);
            self.notify('InputSourceChange',InputSourceUpdateEventData(dname,volType));

            if strcmp(volType,'volume')
                xSpacing=allPixelSpacings(1,1);
                ySpacing=allPixelSpacings(1,2);
                zSpacing=mean(diff(sliceLoc(:,sliceDim)));
                spacings=[xSpacing,ySpacing,zSpacing];
                tform=makehgtform('scale',spacings);

                self.ValidSpatialReferencingInFile=true;
                self.TransformFromFileMetadata=tform;
                self.Transform=tform;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(true));
            end

        end

        function loadDataFromWorkspace(self,data,volType,varName,scaleTform)

            import images.internal.app.volviewToolgroup.*

            mergedDataCleared=false;
            if self.HasVolumeData&&self.HasLabeledVolumeData
                self.MergedVolumeDataInternal=[];
                mergedDataCleared=true;
            end

            self.notify('CheckReplaceOrOverlay',CheckReplaceOrOverlayEventData(volType,...
            size(data),self.VolumeSize,self.HasVolumeData,self.HasLabeledVolumeData));

            if self.CancelImportFlag
                self.CancelImportFlag=false;
                if mergedDataCleared
                    self.mergeVolumes();
                end
                return
            else
                if strcmp(volType,'labels')
                    try
                        self.checkUniqueLabels(data);
                    catch ME
                        self.notify('NumLabelsExceededMax',ErrorEventData(ME.message));
                        return;
                    end
                end
            end

            self.ValidSpatialReferencingInFile=false;

            if strcmp(volType,'volume')
                self.TransformFromFileMetadata=[];
            end

            self.loadNewVolumeData(data,volType);
            if nargin>3
                self.notify('InputSourceChange',InputSourceUpdateEventData(varName,volType));
            end

            if nargin==5&&~isempty(scaleTform)&&strcmp(volType,'volume')
                self.ValidSpatialReferencingInFile=true;
                self.TransformFromFileMetadata=scaleTform;
                self.Transform=scaleTform;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(true));
            elseif isempty(self.TransformFromFileMetadata)
                self.Transform=self.CustomTransform;
                self.notify('SpatialReferencingMetadataAvailableChange',SpatialReferencingMetadataAvailableChangeEventData(false));
            end

        end

        function modifyXSliceLocationSelectedByIncrement(self,inc)
            newVal=self.XSliceLocationSelected+inc;
            newVal=min(max(1,newVal),self.SliceManager.NumSlicesInX);
            self.XSliceLocationSelected=newVal;
        end

        function modifyYSliceLocationSelectedByIncrement(self,inc)
            newVal=self.YSliceLocationSelected+inc;
            newVal=min(max(1,newVal),self.SliceManager.NumSlicesInY);
            self.YSliceLocationSelected=newVal;
        end

        function modifyZSliceLocationSelectedByIncrement(self,inc)
            newVal=self.ZSliceLocationSelected+inc;
            newVal=min(max(1,newVal),self.SliceManager.NumSlicesInZ);
            self.ZSliceLocationSelected=newVal;
        end

        function setLabelProperties(self,volDataL)

            import images.internal.app.volviewToolgroup.*
            self.LabelConfig=LabelConfiguration(volDataL,self.UniqueLabels,self.UniqueLabelsScaled);
            self.IntensityBreakdownIdx=256-self.LabelConfig.NumLabels;
        end

        function setPrebuiltTransferFunction(self,tfName)

            settings=self.presetRenderingSettings(tfName);




            switch settings.RenderingStyle
            case 'Isosurface'
                self.VolumeConfig.Isovalue=settings.Isovalue;
                self.VolumeConfig.IsosurfaceColor=settings.IsosurfaceColor;
                self.VolumeConfig.RenderingStyle=settings.RenderingStyle;
                self.RendererInternal=settings.RenderingStyle;
                settings.Lighting=self.VolumeConfig.Lighting;
                settings.Colormap=self.VolumeConfig.Colormap;
                settings.Alphamap=self.VolumeConfig.Alphamap;

            case 'LabelVolumeRendering'
                self.LabelConfig=settings;
                self.RendererInternal=settings.RenderingStyle;

            case 'LabelOverlayRendering'
                self.OverlayConfig=settings;
                self.RendererInternal=settings.RenderingStyle;

            otherwise
                self.VolumeConfig.Lighting=settings.Lighting;
                self.VolumeConfig.Colormap=settings.Colormap;
                self.VolumeConfig.Alphamap=settings.Alphamap;
                self.VolumeConfig.RenderingStyle=settings.RenderingStyle;
                self.RendererInternal=settings.RenderingStyle;
            end

            self.notify('PresetRenderingSettingsChange',...
            images.internal.app.volviewToolgroup.PresetRenderingSettingsChangeEventData(settings,tfName));
        end

        function settings=presetRenderingSettings(self,settingName)
            import images.internal.app.volviewToolgroup.*

            switch self.VolumeMode
            case 'labels'
                settings=self.LabelConfig;
            case 'mixed'
                settings=LabelOverlayConfiguration(self.LabelConfig,self.IntensityBreakdownIdx);
            otherwise
                settings=VolumeConfiguration(settingName);
            end
        end

    end


    methods

        function restoreDefaultRendering(self)

            if~strcmp(self.VolumeMode,'volume')
                self.LabelConfig.setRenderingDefaults();
            end
            self.setPrebuiltTransferFunction('default');

            if strcmp(self.VolumeMode,'mixed')
                self.mergeVolumes();
            end


            self.triggerSliceChangeEvent();

        end

        function changeSpatialReferencing(self,evt)

            import images.internal.app.volviewToolgroup.*


            if strcmp(evt.EventData.NewValue,evt.EventData.OldValue)
                return
            end

            value=str2double(evt.EventData.NewValue);
            isValid=isfinite(value)&&isreal(value)&&value>0;


            old_tform=self.Transform;
            new_tform=self.Transform;


            if isValid
                if strcmp(evt.Source.Tag,'XAxisUnitsEditField')
                    new_tform(1,1)=value;
                elseif strcmp(evt.Source.Tag,'YAxisUnitsEditField')
                    new_tform(2,2)=value;
                else
                    new_tform(3,3)=value;
                end

                try

                    self.Transform=new_tform;

                    self.notify('CustomVoxelDimensionsChanged');

                    self.CustomTransform=new_tform;
                catch ME

                    self.notify('UnableToSetCustomVoxelDimensions',ErrorEventData(ME.message));
                    self.Transform=old_tform;
                end
            else

                self.notify('SpatialReferencingEditFieldsSet',SpatialReferencingEditFieldsSetEventData(old_tform(1,1),old_tform(2,2),old_tform(3,3)));
            end
        end

        function changeLabelColor(self,event)

            labelIdx=event.LabelIdx;
            color=event.Value;

            if length(labelIdx)~=size(color,1)
                color=repmat(color,[length(labelIdx),1]);
            end

            cmap=self.LabelConfig.Colormap;
            for i=1:numel(labelIdx)
                label=self.LabelConfig.Labels(labelIdx(i));
                k=label+1;
                cmap(k,:)=color(i,:);
            end
            self.setColormapLabels(cmap);

        end

        function changeLabelOpacity(self,event,isUpdateRendering)
            if nargin==2
                isUpdateRendering=true;
            end

            labelIdx=event.LabelIdx;
            opacity=event.Value;

            if length(labelIdx)~=length(opacity)
                opacity=repmat(opacity,[length(labelIdx),1]);
            end

            for i=1:numel(labelIdx)
                self.LabelConfig.Opacities(labelIdx(i))=opacity(i);
                if opacity(i)==0
                    self.LabelConfig.ShowFlags(labelIdx(i))=false;
                else
                    self.LabelConfig.ShowFlags(labelIdx(i))=true;
                end
            end


            if isUpdateRendering
                self.setAlphamapLabels();
            end
        end

        function changeLabelVisibility(self,event)



            labelIdx=event.LabelIdx;
            showFlags=event.Value;

            if length(labelIdx)~=length(showFlags)
                showFlags=repmat(showFlags,[length(labelIdx),1]);
            end

            for i=1:numel(labelIdx)
                self.LabelConfig.ShowFlags(labelIdx(i))=showFlags(i);
                self.LabelConfig.Opacities(labelIdx(i))=double(showFlags(i));
            end

            if self.HasVolumeData

                showFlags=repmat(showFlags,[numel(labelIdx),1]);
                self.manageLabelVisibilty(labelIdx,showFlags);
            end

            if strcmp(self.Renderer,'LabelVolumeRendering')


                self.triggerSliceChangeEvent();
            end


            self.setAlphamapLabels();
        end

        function updateVolumeMode(self,newMode)
            newMode=lower(newMode);

            self.VolumeMode=newMode;

            switch newMode
            case 'volume'
                self.triggerVolumeDataUpdate();
                self.Renderer=self.VolumeConfig.RenderingStyle;
            case 'labels'
                self.triggerLabeledVolumeDataUpdate();
                self.Renderer=self.LabelConfig.RenderingStyle;
            case 'mixed'
                self.triggerMergedVolumeDataUpdate();
                self.Renderer=self.OverlayConfig.RenderingStyle;
            end
        end
    end


    methods

        function checkUniqueLabels(self,volDataL)

            if iscategorical(volDataL)

                cats=categories(volDataL);
                numLabels=numel(cats);
                if any(isundefined(volDataL))
                    numLabels=numLabels+1;
                end

            else








                self.ScaleLabelsUtil=images.internal.app.volview.ScaleLabels(volDataL);

                self.UniqueLabels=self.ScaleLabelsUtil.UniqueLabels;

                numLabels=length(self.UniqueLabels);
                self.UniqueLabelsScaled=uint8(1:numLabels);

            end

            if numLabels>128
                ME=MException('images:invalidFile',getString(message('images:volumeViewerToolgroup:numLabelsExceeded')));
                throw(ME);
            end

        end

        function vol=scaleVolumeData(~,vol)




            limits=single([min(vol(:)),max(vol(:))]);

            if limits(2)==limits(1)


                vol=im2uint8(vol);
            else





                vol=uint8((single(vol)-single(limits(1)))./(single(limits(2)-limits(1)))*255);

            end

        end

        function volDataL=scaleLabeledData(self,volDataL)








            if~iscategorical(volDataL)
                volDataL=self.ScaleLabelsUtil.scale(volDataL);
            end
            volDataL=uint8(volDataL);

        end


        function setAlphaMapFromControlPoints(self,controlPoints)

            intensityValues=controlPoints(:,1);
            alphaValues=controlPoints(:,2);
            [uniqueIntensities,indexOfUniqueIntensities]=unique(intensityValues);
            uniqueAlphaValues=alphaValues(indexOfUniqueIntensities);

            amapVol=interp1(uniqueIntensities,uniqueAlphaValues,linspace(0,1,256));
            self.setAlphamapVol(amapVol);

        end

        function manageLabelVisibilty(self,labelIdx,showFlags)
            import images.internal.app.volviewToolgroup.*

            if~isequal(self.VolumeMode,'mixed')
                return
            end





            for i=1:numel(labelIdx)
                currLabelIdx=labelIdx(i);
                currLabelVisibility=showFlags(i);
                currLabel=self.LabelConfig.Labels(currLabelIdx);


                newLabelValue=currLabelIdx+self.IntensityBreakdownIdx-1;
                self.LabelConfig.ShowFlags(currLabelIdx)=currLabelVisibility;

                if currLabelVisibility
                    idx=self.LabeledVolumeData==currLabel;
                    self.MergedVolumeDataInternal(idx)=newLabelValue;
                else
                    idx=self.LabeledVolumeData==currLabel;
                    self.MergedVolumeDataInternal(idx)=self.VolumeData(idx);
                end
            end




            self.triggerMergedVolumeDataUpdate();
        end

        function[xySlice,xzSlice,yzSlice]=overlaySlices(self)



            labelsDisplayed=self.LabelConfig.Labels(self.LabelConfig.ShowFlags);

            if any(labelsDisplayed==0)
                cmap=self.LabelConfig.Colormap;
            else
                cmap=self.LabelConfig.Colormap(2:end,:);
            end

            [xySlice,xzSlice,yzSlice]=deal(self.XYSlice,self.XZSlice,self.YZSlice);
            maxLabel=max(self.XYSliceLabels(:));
            labelsXY=labelsDisplayed(labelsDisplayed<=maxLabel);
            if~isempty(labelsXY)
                xySlice=labeloverlay(self.XYSlice,self.XYSliceLabels,'IncludedLabels',labelsXY,'Colormap',cmap);
            end

            maxLabel=max(self.XZSliceLabels(:));
            labelsXZ=labelsDisplayed(labelsDisplayed<=maxLabel);
            if~isempty(labelsXZ)
                xzSlice=labeloverlay(self.XZSlice,self.XZSliceLabels,'IncludedLabels',labelsXZ,'Colormap',cmap);
            end
            maxLabel=max(self.YZSliceLabels(:));
            labelsYZ=labelsDisplayed(labelsDisplayed<=maxLabel);
            if~isempty(labelsYZ)
                yzSlice=labeloverlay(self.YZSlice,self.YZSliceLabels,'IncludedLabels',labelsYZ,'Colormap',cmap);
            end
        end

        function[xySlice,xzSlice,yzSlice]=overlayWithZeroSlice(self)







            labelsDisplayed=self.LabelConfig.Labels(self.LabelConfig.ShowFlags);

            if any(labelsDisplayed==0)
                cmap=self.LabelConfig.Colormap;
            else
                cmap=self.LabelConfig.Colormap(2:end,:);
            end
            [xySlice,xzSlice,yzSlice]=deal(self.XYSliceLabels,self.XZSliceLabels,self.YZSliceLabels);
            maxLabel=max(xySlice(:));
            labelsXY=labelsDisplayed(labelsDisplayed<=maxLabel);
            zeroSlice=zeros(size(xySlice,1),size(xySlice,2));
            if~isempty(labelsXY)
                xySlice=labeloverlay(zeroSlice,xySlice,'IncludedLabels',labelsXY,'Colormap',cmap,'Transparency',0);
            end

            maxLabel=max(xzSlice(:));
            labelsXZ=labelsDisplayed(labelsDisplayed<=maxLabel);
            zeroSlice=zeros(size(xzSlice,1),size(xzSlice,2));
            if~isempty(labelsXZ)
                xzSlice=labeloverlay(zeroSlice,xzSlice,'IncludedLabels',labelsXZ,'Colormap',cmap,'Transparency',0);
            end

            maxLabel=max(yzSlice(:));
            labelsYZ=labelsDisplayed(labelsDisplayed<=maxLabel);
            zeroSlice=zeros(size(yzSlice,1),size(yzSlice,2));
            if~isempty(labelsYZ)
                yzSlice=labeloverlay(zeroSlice,yzSlice,'IncludedLabels',labelsYZ,'Colormap',cmap,'Transparency',0);
            end
        end

        function exportConfig(self)

            settings=struct();

            settings.CameraPosition=self.CameraPosition;
            settings.CameraUpVector=self.CameraUpVector;
            settings.CameraTarget=self.CameraTarget;
            settings.CameraViewAngle=self.CameraViewAngle;
            settings.BackgroundColor=self.BackgroundColor;

            if isequal(self.VolumeMode,'volume')
                settings.Renderer=self.Renderer;
                settings.Colormap=self.VolumeConfig.Colormap;
                settings.Alphamap=self.VolumeConfig.Alphamap';
                settings.Lighting=self.VolumeConfig.Lighting;
                settings.IsosurfaceColor=self.VolumeConfig.IsosurfaceColor;
                settings.Isovalue=self.VolumeConfig.Isovalue;

            else
                settings.ShowIntensityVolume=strcmp(self.VolumeMode,'mixed');
                settings.LabelColor=self.LabelConfig.LabelColors;
                settings.LabelVisibility=self.LabelConfig.ShowFlags;
                settings.LabelOpacity=self.LabelConfig.Opacities;
                settings.VolumeOpacity=self.OverlayConfig.OpacityValue;
                settings.VolumeThreshold=self.OverlayConfig.Threshold/255;
            end

            self.notify('ExportDataAvailable',images.internal.app.volviewToolgroup.ExportEventData(settings));
        end

    end


    methods
        function setIsovalue(self,isoval)

            import images.internal.app.volviewToolgroup.*

            validateattributes(isoval,{'numeric'},{'scalar','finite','>=',0,'<=',1,'real','nonempty','nonsparse'});
            self.VolumeConfig.Isovalue=isoval;

            self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));

        end

        function setIsosurfaceColor(self,c)

            import images.internal.app.volviewToolgroup.*

            validateattributes(c,{'numeric'},{'vector','finite','>=',0,'<=',1,'real','nonempty','nonsparse'});
            self.VolumeConfig.IsosurfaceColor=c;

            self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));

        end

        function setLighting(self,lighting)

            import images.internal.app.volviewToolgroup.*

            validateattributes(lighting,{'numeric','logical'},{'scalar','finite'});

            self.VolumeConfig.Lighting=logical(lighting);
            self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));

        end

        function setAlphamapVol(self,amapVol,amapCP)

            import images.internal.app.volviewToolgroup.*

            validateattributes(amapVol,{'numeric'},{'vector','finite','nonnegative','nonsparse'});
            assert(numel(amapVol)==256,'Alphamap must be of length 256.');
            self.VolumeConfig.Alphamap=amapVol;

            if nargin==3
                self.VolumeConfig.AlphaControlPoints=amapCP;
            end

            switch self.Renderer
            case 'LabelOverlayRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            otherwise
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));
            end
        end

        function setAlphamapLabels(self)
            import images.internal.app.volviewToolgroup.*


            switch self.Renderer
            case 'LabelVolumeRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.LabelConfig));
            case 'LabelOverlayRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            end

        end

        function setColormapVol(self,cmapVol,cmapCP)

            import images.internal.app.volviewToolgroup.*

            validateattributes(cmapVol,{'numeric'},{'2d','finite','nonnegative','nonsparse'});
            assert(size(cmapVol,2)==3,'Colormap must have 3 columns');
            self.VolumeConfig.Colormap=cmapVol;

            if nargin==3
                self.VolumeConfig.ColorControlPoints=cmapCP;
            end

            switch self.Renderer
            case 'LabelOverlayRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            otherwise
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));
            end
        end

        function setColormapLabels(self,cmapLabels)
            import images.internal.app.volviewToolgroup.*

            validateattributes(cmapLabels,{'numeric'},{'2d','finite','nonnegative','nonsparse'});
            assert(size(cmapLabels,2)==3,'Colormap must have 3 columns');
            self.LabelConfig.Colormap=cmapLabels;
            switch self.Renderer
            case 'LabelOverlayRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            case 'LabelVolumeRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.LabelConfig));
            end



            self.triggerSliceChangeEvent();
        end

        function setOverlayConfigThreshold(self,threshold)

            import images.internal.app.volviewToolgroup.*

            self.OverlayConfig.Threshold=floor(threshold);
            if strcmp(self.Renderer,'LabelOverlayRendering')
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            end
        end

        function setOverlayConfigVolumeOpacity(self,opacityValue)

            import images.internal.app.volviewToolgroup.*

            self.OverlayConfig.OpacityValue=opacityValue;
            if strcmp(self.Renderer,'LabelOverlayRendering')
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            end
        end
    end


    methods
        function amap=getAlphamap(self)
            switch self.Renderer
            case 'LabelVolumeRendering'
                amap=self.LabelConfig.Alphamap;
            case 'LabelOverlayRendering'
                amap=self.OverlayConfig.Alphamap;
            otherwise
                amap=self.VolumeConfig.Alphamap;
            end
        end

        function cmap=getColormap(self)
            switch self.Renderer
            case 'LabelVolumeRendering'
                cmap=self.LabelConfig.Colormap;
            case 'LabelOverlayRendering'
                cmap=self.OverlayConfig.Colormap;
            otherwise
                cmap=self.VolumeConfig.Colormap;
            end
        end

        function c=getIsosurfaceColor(self)
            c=self.VolumeConfig.IsosurfaceColor;
        end

        function val=getIsovalue(self)
            val=self.VolumeConfig.Isovalue;
        end

        function lighting=getLighting(self)
            switch self.Renderer
            case 'LabelVolumeRendering'
                lighting=self.LabelConfig.Lighting;
            case 'LabelOverlayRendering'
                lighting=self.OverlayConfig.Lighting;
            otherwise
                lighting=self.VolumeConfig.Lighting;
            end
        end

        function val=getOverlayConfigThreshold(self)
            val=self.OverlayConfig.Threshold;
        end

        function val=getOverlayConfigVolumeOpacity(self)
            val=self.OverlayConfig.OpacityValue;
        end
    end


    methods

        function set.IsLogicalData(self,TF)
            validateattributes(TF,{'logical'},{'scalar'});
            self.IsLogicalData=TF;
        end

        function set.VolumeData(self,newVol)

            import images.internal.app.volviewToolgroup.*

            validateattributes(newVol,{'numeric'},{'finite','nonsparse'});



            assert(ndims(newVol)==3,'Expect 3 dimensional input');

            self.VolumeDataInternal=newVol;

            self.SliceManagerVolume=images.internal.app.volviewToolgroup.SliceManager(self.VolumeDataInternal,self.Transform);




            if~isequal(self.VolumeMode,'mixed')
                [xySlice,xzSlice,yzSlice]=deal(self.XYSlice,self.XZSlice,self.YZSlice);
                self.notify('VolumeDataChange',VolumeDataChangeEventData(self.VolumeDataInternal,xySlice,xzSlice,yzSlice,...
                self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
                self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
                self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
            end

        end

        function set.LabeledVolumeData(self,newVol)
            import images.internal.app.volviewToolgroup.*

            validateattributes(newVol,{'numeric'},{'finite','nonsparse'});



            assert(ndims(newVol)==3,'Expect 3 dimensional input');
            self.LabeledVolumeDataInternal=newVol;
            self.SliceManagerLabels=images.internal.app.volviewToolgroup.SliceManager(self.LabeledVolumeDataInternal,self.Transform);




            if~isequal(self.VolumeMode,'mixed')
                [xySlice,xzSlice,yzSlice]=self.overlayWithZeroSlice();
                self.notify('VolumeDataChange',VolumeDataChangeEventData(self.LabeledVolumeDataInternal,xySlice,xzSlice,yzSlice,...
                self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
                self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
                self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
            end

        end

        function set.MergedVolumeData(self,newVol)
            import images.internal.app.volviewToolgroup.*

            validateattributes(newVol,{'numeric'},{'finite','nonsparse'});



            assert(ndims(newVol)==3,'Expect 3 dimensional input');
            self.MergedVolumeDataInternal=newVol;

            [xySlice,xzSlice,yzSlice]=self.overlaySlices();
            self.notify('VolumeDataChange',VolumeDataChangeEventData(self.MergedVolumeDataInternal,xySlice,xzSlice,yzSlice,...
            self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
            self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
            self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
        end

        function set.Renderer(self,renderStr)

            import images.internal.app.volviewToolgroup.*

            str=validatestring(renderStr,{'VolumeRendering','Isosurface','MaximumIntensityProjection',...
            'LabelVolumeRendering','LabelOverlayRendering'});

            self.RendererInternal=renderStr;
            switch renderStr
            case 'LabelVolumeRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.LabelConfig));
            case 'LabelOverlayRendering'
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.OverlayConfig));
            otherwise
                self.VolumeConfig.RenderingStyle=str;
                self.notify('VolumeRenderingSettingsChange',VolumeRenderingSettingsChangeEventData(self.VolumeConfig));
            end

        end

        function set.Transform(self,tform)

            import images.internal.app.volviewToolgroup.*

            validateattributes(tform,{'single','double'},{'2d','finite'});

            assert(isequal(size(tform),[4,4]),'Unexpected Transform size');
            assert(isequal(tform(:,4),[0;0;0;1]),'Specified Transform is non-affine');
            assert(isdiag(tform),'Expect pure scale transformation.');

            xRatioInRange=(self.XSliceLocationSelected-1)/(self.SliceManager.NumSlicesInX-1);
            yRatioInRange=(self.YSliceLocationSelected-1)/(self.SliceManager.NumSlicesInY-1);
            zRatioInRange=(self.ZSliceLocationSelected-1)/(self.SliceManager.NumSlicesInZ-1);

            self.TransformInternal=tform;

            if self.HasLabeledVolumeData
                self.SliceManagerLabels=images.internal.app.volviewToolgroup.SliceManager(self.LabeledVolumeData,tform);
            end

            if self.HasVolumeData
                self.SliceManagerVolume=images.internal.app.volviewToolgroup.SliceManager(self.VolumeData,tform);
            end



            self.XSliceLocationSelectedInternal=xRatioInRange*(self.SliceManager.NumSlicesInX-1)+1;
            self.YSliceLocationSelectedInternal=yRatioInRange*(self.SliceManager.NumSlicesInY-1)+1;
            self.ZSliceLocationSelectedInternal=zRatioInRange*(self.SliceManager.NumSlicesInZ-1)+1;

            if isequal(self.Renderer,'LabelVolumeRendering')
                [xySlice,xzSlice,yzSlice]=self.overlayWithZeroSlice();
            elseif isequal(self.Renderer,'LabelOverlayRendering')
                [xySlice,xzSlice,yzSlice]=self.overlaySlices();
            else
                [xySlice,xzSlice,yzSlice]=deal(self.XYSlice,self.XZSlice,self.YZSlice);
            end

            self.notify('SpatialReferencingChange',SpatialReferencingChangeEventData(self.Transform,...
            xySlice,xzSlice,yzSlice,self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,...
            self.SliceManager.NumSlicesInZ,self.XSliceLocationSelected,self.YSliceLocationSelected,...
            self.ZSliceLocationSelected,self.ValidSpatialReferencingInFile));

        end

        function set.XSliceLocationSelected(self,xSliceNumber)

            import images.internal.app.volviewToolgroup.*

            validateattributes(xSliceNumber,{'numeric'},{'scalar','finite','positive','nonsparse'});
            inDataBounds=xSliceNumber<=self.SliceManager.NumSlicesInX;
            assert(inDataBounds,'Attempt to set X Slice outside of data bounds');
            self.XSliceLocationSelectedInternal=xSliceNumber;

            switch self.VolumeMode
            case 'volume'
                yzSlice=self.YZSlice;
            case 'labels'
                [~,~,yzSlice]=self.overlayWithZeroSlice();
            case 'mixed'
                [~,~,yzSlice]=self.overlaySlices();
            otherwise
                yzSlice=[];
            end

            self.notify('YZSliceChange',SliceChangeEventData(yzSlice,self.SliceManager.NumSlicesInX,xSliceNumber));

        end

        function set.YSliceLocationSelected(self,ySliceNumber)

            import images.internal.app.volviewToolgroup.*

            validateattributes(ySliceNumber,{'numeric'},{'scalar','finite','positive','nonsparse'});
            inDataBounds=ySliceNumber<=self.SliceManager.NumSlicesInY;
            assert(inDataBounds,'Attempt to set Y Slice outside of data bounds');
            self.YSliceLocationSelectedInternal=ySliceNumber;

            switch self.VolumeMode
            case 'volume'
                xzSlice=self.XZSlice;
            case 'labels'
                [~,xzSlice]=self.overlayWithZeroSlice();
            case 'mixed'
                [~,xzSlice]=self.overlaySlices();
            otherwise
                xzSlice=[];
            end

            self.notify('XZSliceChange',SliceChangeEventData(xzSlice,self.SliceManager.NumSlicesInY,ySliceNumber));

        end

        function set.ZSliceLocationSelected(self,zSliceNumber)

            import images.internal.app.volviewToolgroup.*

            validateattributes(zSliceNumber,{'numeric'},{'scalar','finite','positive','nonsparse'});
            inDataBounds=zSliceNumber<=self.SliceManager.NumSlicesInZ;
            assert(inDataBounds,'Attempt to set Z Slice outside of data bounds');
            self.ZSliceLocationSelectedInternal=zSliceNumber;

            switch self.VolumeMode
            case 'volume'
                xySlice=self.XYSlice;
            case 'labels'
                xySlice=self.overlayWithZeroSlice();
            case 'mixed'
                xySlice=self.overlaySlices();
            otherwise
                xySlice=[];
            end

            self.notify('XYSliceChange',SliceChangeEventData(xySlice,self.SliceManager.NumSlicesInZ,zSliceNumber));

        end

        function set.Show3DVolume(self,TF)

            import images.internal.app.volviewToolgroup.*

            self.Show3DVolumeInternal=TF;
            self.notify('VolumeDisplayChange',VolumeDisplayChangeEventData(self.Show3DVolume));

        end

        function set.CameraPosition(self,pos)

            import images.internal.app.volviewToolgroup.*

            self.CameraPositionInternal=pos;
            self.notify('CameraPositionChange',CameraPositionChangeEventData(self.CameraPosition,...
            self.CameraUpVector,self.CameraTarget,self.CameraViewAngle));

        end

        function set.CameraTarget(self,newTarget)

            import images.internal.app.volviewToolgroup.*

            self.CameraTargetInternal=newTarget;

            self.notify('CameraPositionChange',CameraPositionChangeEventData(self.CameraPosition,...
            self.CameraUpVector,self.CameraTarget,self.CameraViewAngle));

        end

        function set.CameraUpVector(self,newUpVec)

            import images.internal.app.volviewToolgroup.*

            self.CameraUpVectorInternal=newUpVec;

            self.notify('CameraPositionChange',CameraPositionChangeEventData(self.CameraPosition,...
            self.CameraUpVector,self.CameraTarget,self.CameraViewAngle));

        end

        function set.CameraViewAngle(self,newAngle)

            import images.internal.app.volviewToolgroup.*

            validateattributes(newAngle,{'numeric'},...
            {'scalar','real','finite','nonempty','nonsparse','>=',0,'<',180},...
            mfilename,'CameraViewAngle');

            self.CameraViewAngleInternal=newAngle;

            self.notify('CameraPositionChange',CameraPositionChangeEventData(self.CameraPosition,...
            self.CameraUpVector,self.CameraTarget,self.CameraViewAngle));

        end

        function set.BackgroundColor(self,newColor)

            self.BackgroundColor=newColor;
            self.notify('BackgroundColorChange',images.internal.app.volviewToolgroup.BackgroundColorChangeEventData(newColor));

        end
    end


    methods

        function v=get.VolumeData(self)
            v=self.VolumeDataInternal;
        end

        function v=get.MergedVolumeData(self)
            v=self.MergedVolumeDataInternal;
        end

        function v=get.LabeledVolumeData(self)
            v=self.LabeledVolumeDataInternal;
        end

        function renStr=get.Renderer(self)
            renStr=self.RendererInternal;
        end

        function cf=get.VolumeConfig(self)
            cf=self.VolumeConfig;
        end

        function cf=get.OverlayConfig(self)
            import images.internal.app.volviewToolgroup.*
            self.OverlayConfig.computeOverlayConfiguration(self.LabelConfig,self.IntensityBreakdownIdx);
            cf=self.OverlayConfig;
        end

        function tform=get.Transform(self)
            tform=self.TransformInternal;
        end

        function sliceManager=get.SliceManager(self)
            if strcmp(self.VolumeMode,'labels')
                sliceManager=self.SliceManagerLabels;
            else
                sliceManager=self.SliceManagerVolume;
            end
        end

        function slice=get.XSliceLocationSelected(self)
            slice=self.XSliceLocationSelectedInternal;
        end

        function slice=get.YSliceLocationSelected(self)
            slice=self.YSliceLocationSelectedInternal;
        end

        function slice=get.ZSliceLocationSelected(self)
            slice=self.ZSliceLocationSelectedInternal;
        end

        function slice=get.XYSlice(self)
            slice=self.SliceManagerVolume.getXYSlice(self.ZSliceLocationSelected);
        end

        function slice=get.XZSlice(self)
            slice=self.SliceManagerVolume.getXZSlice(self.YSliceLocationSelected);
        end

        function slice=get.YZSlice(self)
            slice=self.SliceManagerVolume.getYZSlice(self.XSliceLocationSelected);
        end

        function slice=get.XYSliceLabels(self)
            slice=self.SliceManagerLabels.getXYSlice(self.ZSliceLocationSelected);
        end

        function slice=get.XZSliceLabels(self)
            slice=self.SliceManagerLabels.getXZSlice(self.YSliceLocationSelected);
        end

        function slice=get.YZSliceLabels(self)
            slice=self.SliceManagerLabels.getYZSlice(self.XSliceLocationSelected);
        end

        function tf=get.Show3DVolume(self)
            tf=self.Show3DVolumeInternal;
        end

        function pos=get.CameraPosition(self)
            pos=self.CameraPositionInternal;
        end

        function targ=get.CameraTarget(self)
            targ=self.CameraTargetInternal;
        end

        function uv=get.CameraUpVector(self)
            uv=self.CameraUpVectorInternal;
        end

        function ang=get.CameraViewAngle(self)
            ang=self.CameraViewAngleInternal;
        end

        function tform=get.UpsampleToCubeTransform(self)
            volDims=self.VolumeSize;
            maxDim=max(volDims);
            scaledDims=maxDim./volDims;
            tform=makehgtform('scale',[scaledDims(1),scaledDims(2),scaledDims(3)]);
        end


        function triggerVolumeDataChange(self)
            self.VolumeData=self.VolumeDataInternal;
        end

        function triggerLabeledVolumeDataChange(self)
            self.LabeledVolumeData=self.LabeledVolumeDataInternal;
        end

        function triggerMergedVolumeDataChange(self)
            self.MergedVolumeData=self.MergedVolumeDataInternal;
        end

        function triggerVolumeDataUpdate(self)


            import images.internal.app.volviewToolgroup.*
            [xySlice,xzSlice,yzSlice]=deal(self.XYSlice,self.XZSlice,self.YZSlice);
            self.notify('VolumeDataUpdate',VolumeDataChangeEventData(self.VolumeDataInternal,xySlice,xzSlice,yzSlice,...
            self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
            self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
            self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
        end

        function triggerLabeledVolumeDataUpdate(self)


            import images.internal.app.volviewToolgroup.*
            [xySlice,xzSlice,yzSlice]=self.overlayWithZeroSlice();
            self.notify('VolumeDataUpdate',VolumeDataChangeEventData(self.LabeledVolumeDataInternal,xySlice,xzSlice,yzSlice,...
            self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
            self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
            self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
        end

        function triggerMergedVolumeDataUpdate(self)


            import images.internal.app.volviewToolgroup.*
            [xySlice,xzSlice,yzSlice]=self.overlaySlices();
            self.notify('VolumeDataUpdate',VolumeDataChangeEventData(self.MergedVolumeDataInternal,xySlice,xzSlice,yzSlice,...
            self.SliceManager.NumSlicesInX,self.SliceManager.NumSlicesInY,self.SliceManager.NumSlicesInZ,...
            self.XSliceLocationSelected,self.YSliceLocationSelected,self.ZSliceLocationSelected,self.IsLogicalData,...
            self.HasVolumeData,self.HasLabeledVolumeData,self.VolumeMode));
        end

        function triggerSliceChangeEvent(self)
            self.XSliceLocationSelected=self.XSliceLocationSelectedInternal;
            self.YSliceLocationSelected=self.YSliceLocationSelectedInternal;
            self.ZSliceLocationSelected=self.ZSliceLocationSelectedInternal;
        end

        function triggerRendererChange(self)
            self.Renderer=self.RendererInternal;
        end
    end


    events
ModelCleared
VolumeDataChange
VolumeDataUpdate
XYSliceChange
YZSliceChange
XZSliceChange
VolumeDisplayChange
CameraPositionChange
VolumeRenderingSettingsChange
SpatialReferencingChange
SpatialReferencingMetadataAvailableChange
UnableToLoadFile
UnableToLoadFolder
UnableToSetCustomVoxelDimensions
PresetRenderingSettingsChange
BackgroundColorChange
CustomVoxelDimensionsChanged
SpatialReferencingEditFieldsSet
NumLabelsExceededMax
VolumeSizesNotEqual
InputSourceChange
CheckReplaceOrOverlay
ExportDataAvailable
    end

end
