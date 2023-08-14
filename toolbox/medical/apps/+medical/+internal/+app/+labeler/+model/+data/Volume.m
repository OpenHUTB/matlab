classdef Volume<handle&matlab.mixin.SetGet




    properties

DataName

Data

DataDisplayLimits
DataDisplayLimitsDefault

DataBounds

    end

    properties

RenderingStyle
RenderingPreset
AlphaControlPoints
ColorControlPoints

    end

    properties(SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

DataSource

IsDataValidated

        CastingMethod=[];

    end

    properties(Dependent)

DataSize
Transform
SpatialDetails
IsRGB
IsOblique
RawData

    end

    properties(SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

OriginalDataType

DataForAutomation
DataBoundsForAutomation

    end

    events
ErrorThrown
    end

    methods


        function read(self,dataName,dataSource,dataBounds,dataDisplayLimits,dataDisplayLimitsDefault,isDataValidated,renderingPreset,renderingStyle,alphaControlPts,colorControlPts,castingMethod)

            self.DataName=dataName;
            self.DataSource=dataSource;
            self.IsDataValidated=isDataValidated;
            self.CastingMethod=castingMethod;

            self.DataBounds=dataBounds;
            self.DataDisplayLimits=dataDisplayLimits;
            self.DataDisplayLimitsDefault=dataDisplayLimitsDefault;

            self.setVolumeRenderingSettings(renderingPreset,renderingStyle,alphaControlPts,colorControlPts)

            self.readData();

        end


        function clear(self)

            self.CastingMethod=[];
            self.DataSource=[];
            self.DataName=[];
            self.IsDataValidated=false;
            self.Data=[];
            self.DataDisplayLimits=[];
            self.DataDisplayLimitsDefault=[];

            self.RenderingStyle=[];
            self.RenderingPreset=[];
            self.AlphaControlPoints=[];
            self.ColorControlPoints=[];

        end


        function[dataSlice,pixelSpacing]=getSlice(self,idx,sliceDirection)

            dataSlice=[];
            pixelSpacing=[1,1];
            if isempty(self.Data)
                return;
            end

            if self.IsOblique

                switch double(sliceDirection)
                case 1
                    dataSlice=squeeze(self.Data.Voxels(idx,:,:));
                case 2
                    dataSlice=squeeze(self.Data.Voxels(:,idx,:));
                case 3
                    dataSlice=squeeze(self.Data.Voxels(:,:,idx));
                end

            else

                [dataSlice,~,pixelSpacing]=self.Data.extractSlice(idx,string(sliceDirection));

            end

        end


        function intensity=getIntensity(self,position,idx,sliceDirection)

            intensity=[];
            if isempty(self.Data)
                return;
            end

            dataSlice=self.getSlice(idx,sliceDirection);
            [m,n]=size(dataSlice,[1,2]);
            if position(2)<=m&&position(1)<=n
                intensity=dataSlice(position(2),position(1));
            end

        end


        function maxIdx=getMaxSliceIndex(self,sliceDirection)

            maxIdx=[];
            if isempty(self.Data)
                return;
            end

            if self.IsOblique

                maxIdx=size(self.Data.Voxels,double(sliceDirection));

            else

                switch sliceDirection

                case medical.internal.app.labeler.enums.SliceDirection.Transverse
                    maxIdx=self.Data.NumTransverseSlices;
                case medical.internal.app.labeler.enums.SliceDirection.Coronal
                    maxIdx=self.Data.NumCoronalSlices;
                case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                    maxIdx=self.Data.NumSagittalSlices;

                end

            end

        end


        function numSlicesASC=getNumSlices(self)

            numSlicesASC=[];
            if isempty(self.Data)
                return;
            end

            if self.IsOblique








                numSlicesASC=size(self.Data.Voxels,1:3);
                numSlicesASC=fliplr(numSlicesASC);

            else

                numSlicesASC=[...
                self.Data.NumTransverseSlices,...
                self.Data.NumSagittalSlices,...
                self.Data.NumCoronalSlices];
            end

        end


        function pixelSpacingTSC=getPixelSpacing(self)




            pixelSpacingTSC=ones(3,2);
            if isempty(self.Data)||isempty(self.Data.VoxelSpacing)
                return;
            end

            if self.IsOblique
                pixelSpacingTSC(1,:)=self.Data.VoxelSpacing([1,2]);
                pixelSpacingTSC(2,:)=self.Data.VoxelSpacing([1,3]);
                pixelSpacingTSC(3,:)=self.Data.VoxelSpacing([2,3]);

                pixelSpacingTSC(pixelSpacingTSC==0)=1;

            else

                [~,~,pixelSpacingTSC(1,:)]=self.Data.extractSlice(1,string(medical.internal.app.labeler.enums.SliceDirection.Transverse));
                [~,~,pixelSpacingTSC(2,:)]=self.Data.extractSlice(1,string(medical.internal.app.labeler.enums.SliceDirection.Sagittal));
                [~,~,pixelSpacingTSC(3,:)]=self.Data.extractSlice(1,string(medical.internal.app.labeler.enums.SliceDirection.Coronal));

            end

        end


        function planeMappingTSC=getPlaneMappingTSC(self)

            planeMappingTSC=[3,2,1];

            if~self.IsOblique
                planeMappingTSC(1)=find(self.Data.PlaneMapping=="transverse");
                planeMappingTSC(2)=find(self.Data.PlaneMapping=="sagittal");
                planeMappingTSC(3)=find(self.Data.PlaneMapping=="coronal");
            end

        end


        function planeMapping=getPlaneMapping(self,sliceDirection)

            if self.IsOblique
                planeMapping=double(sliceDirection);
            else
                planeMapping=find(self.Data.PlaneMapping==lower(string(sliceDirection)));
            end

        end


        function[data,axesLabels,tform]=getDataForDisplay(self,displayConvention)

            if isempty(self.Data)
                data=[];
                axesLabels=["","",""];
                tform=eye(4);
                return;
            end

            if self.IsOblique

                data=self.Data.Voxels;
                tform=self.Transform;
                axesLabels=["","",""];


            else
                data=self.Data.Voxels;
                tform=self.Transform;
                labels=split(self.Data.VolumeGeometry.PatientCoordinateSystem,'');
                axesLabels=labels(2:4)';

                displayConvention=lower(displayConvention);







                switch self.Data.VolumeGeometry.PatientCoordinateSystem

                case{"RAS+","LPS+"}





                    if displayConvention=="radiological"
                        flipLRTransform=false;
                    elseif displayConvention=="neurological"
                        flipLRTransform=true;
                    end

                case "LAS+"
                    if displayConvention=="radiological"
                        flipLRTransform=true;
                    elseif displayConvention=="neurological"
                        flipLRTransform=false;
                    end

                otherwise
                    flipLRTransform=false;

                end

                if flipLRTransform

                    tform(1,1:3)=-tform(1,1:3);
                    if any(axesLabels=="L")
                        axesLabels=replace(axesLabels,"L","R");
                    else
                        axesLabels=replace(axesLabels,"R","L");
                    end

                end

            end

        end


        function setVolumeRenderingSettings(self,renderingPreset,renderingStyle,alphaControlPts,colorControlPts)

            self.RenderingPreset=renderingPreset;
            self.RenderingStyle=renderingStyle;
            self.AlphaControlPoints=alphaControlPts;
            self.ColorControlPoints=colorControlPts;

            if~isempty(self.DataBounds)

                if renderingPreset==medical.internal.app.labeler.model.PresetRenderingOptions.Default||...
                    renderingPreset==medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale

                    self.AlphaControlPoints(1,1)=self.DataBounds(1);
                    self.AlphaControlPoints(end,1)=self.DataBounds(2);
                    self.ColorControlPoints(1,1)=self.DataBounds(1);
                    self.ColorControlPoints(end,1)=self.DataBounds(2);

                end

            end

        end


        function[renderingPreset,renderingStyle,alphaControlPts,colorControlPts]=getRenderingSettings(self)

            renderingPreset=self.RenderingPreset;
            renderingStyle=self.RenderingStyle;
            alphaControlPts=self.AlphaControlPoints;
            colorControlPts=self.ColorControlPoints;

        end


        function setVolumeRenderingPreset(self,renderingPreset)
            self.RenderingPreset=renderingPreset;
        end


        function tempValues=getTempValues(self)

            tempValues=struct();

            tempValues.RenderingPreset=self.RenderingPreset;
            tempValues.RenderingStyle=self.RenderingStyle;
            tempValues.AlphaControlPoints=self.AlphaControlPoints;
            tempValues.ColorControlPoints=self.ColorControlPoints;

            tempValues.IsDataValidated=self.IsDataValidated;
            tempValues.DataBounds=self.DataBounds;
            tempValues.DataDisplayLimits=self.DataDisplayLimits;
            tempValues.DataDisplayLimitsDefault=self.DataDisplayLimitsDefault;

            tempValues.CastingMethod=self.CastingMethod;

        end


        function sanitizeDataForAutomation(self,useOriginal)

            try

                if useOriginal

                    switch self.CastingMethod

                    case "none"
                        self.DataForAutomation=self.Data;
                        self.DataBoundsForAutomation=self.DataBounds;

                    case "int16"
                        data=cast(self.Data.Voxels,self.OriginalDataType);
                        self.DataForAutomation=medicalVolume(data,self.Data.VolumeGeometry);
                        self.DataBoundsForAutomation=cast(self.DataBounds,self.OriginalDataType);

                    case "normalize"




                        self.DataForAutomation=medicalVolume(self.DataSource);
                        [m,n]=bounds(self.DataForAutomation.Voxels,'all');
                        self.DataBoundsForAutomation=[m,n];

                    end

                else







                    self.DataForAutomation=self.Data;
                    self.DataBoundsForAutomation=self.DataBounds;

                end

            catch


                self.DataForAutomation=self.Data;
                self.DataBoundsForAutomation=self.DataBounds;
            end

        end


        function dataSlice=getSliceForAutomation(self,useOriginal,idx,sliceDirection)

            dataSlice=[];
            if isempty(self.DataForAutomation)
                return;
            end

            if self.IsOblique

                switch double(sliceDirection)
                case 1
                    dataSlice=squeeze(self.DataForAutomation.Voxels(idx,:,:));
                case 2
                    dataSlice=squeeze(self.DataForAutomation.Voxels(:,idx,:));
                case 3
                    dataSlice=squeeze(self.DataForAutomation.Voxels(:,:,idx));
                end

            else

                dataSlice=self.DataForAutomation.extractSlice(idx,string(sliceDirection));

            end

            if~useOriginal
                dataSlice=images.internal.app.segmenter.volume.data.rescaleVolume(dataSlice,[],[],[],self.DataBoundsForAutomation);
            end

        end


        function data=getRawDataForAutomation(self,useOriginal)
            data=[];
            if~isempty(self.DataForAutomation)

                data=self.DataForAutomation.Voxels;

                if~useOriginal
                    data=images.internal.app.segmenter.volume.data.rescaleVolume(data,[],[],[],self.DataBoundsForAutomation);
                end

            end

        end


        function clearAutomationData(self)
            self.DataForAutomation=[];
            self.DataBoundsForAutomation=[];
        end

    end

    methods(Access=protected)


        function readData(self)

            self.Data=medicalVolume(self.DataSource);
            self.OriginalDataType=class(self.Data.Voxels);
            self.castDataIfRequired();

            if~self.IsDataValidated


                try
                    validateattributes(self.Data.Voxels,{'numeric'},{'finite'});
                catch
                    error(message('medical:medicalLabeler:invalidData',self.DataName));
                end


                if~images.internal.app.segmenter.volume.data.isVolume(self.Data.Voxels)
                    error(message('images:segmenter:invalidVolume'));
                end




                self.computeMetadata();

                self.IsDataValidated=true;

            end

        end


        function castDataIfRequired(self)





            if isempty(self.CastingMethod)

                self.CastingMethod="none";
                if(isequal(class(self.Data.Voxels),'single')||isequal(class(self.Data.Voxels),'double'))&&any(self.Data.Voxels>1,'all')

                    if isequal(floor(self.Data.Voxels),self.Data.Voxels)


                        self.CastingMethod="int16";
                    else

                        self.CastingMethod="normalize";
                    end

                end

            end

            switch self.CastingMethod

            case "int16"
                data=int16(self.Data.Voxels);
                self.Data=medicalVolume(data,self.Data.VolumeGeometry);
            case "normalize"
                data=images.internal.app.segmenter.volume.data.rescaleVolume(self.Data.Voxels,[],[],[],self.DataBounds);
                self.Data=medicalVolume(data,self.Data.VolumeGeometry);
            case "none"

            end


        end


        function computeMetadata(self)


            [m,n]=bounds(self.Data.Voxels,'all');
            self.DataBounds=[m,n];











            if~isempty(self.Data.WindowCenters)&&~isempty(self.Data.WindowWidths)&&...
                ~all(self.Data.WindowCenters==0)&&~all(self.Data.WindowWidths==0)

                displayLimits=[self.Data.WindowCenters(1)-(self.Data.WindowWidths(1)/2),...
                self.Data.WindowCenters(1)+(self.Data.WindowWidths(1)/2)];

            else



                delta1Percent=round(0.01*diff(self.DataBounds));
                windowMin=self.DataBounds(1)+delta1Percent;
                windowMax=self.DataBounds(2)-delta1Percent;
                displayLimits=[windowMin,windowMax];

            end

            self.DataDisplayLimitsDefault=cast(displayLimits,class(self.Data.Voxels));
            self.DataDisplayLimits=self.DataDisplayLimitsDefault;


            if self.RenderingPreset==medical.internal.app.labeler.model.PresetRenderingOptions.Default||...
                self.RenderingPreset==medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale

                self.AlphaControlPoints(1,1)=self.DataBounds(1);
                self.AlphaControlPoints(end,1)=self.DataBounds(2);
                self.ColorControlPoints(1,1)=self.DataBounds(1);
                self.ColorControlPoints(end,1)=self.DataBounds(2);

            end

        end

    end


    methods


        function volTransform=get.Transform(self)

            volTransform=eye(4);

            try







                if self.Data.VolumeGeometry.IsAffine

                    tform=self.Data.VolumeGeometry.affinetform3d();
                    volTransform=tform.A;

                elseif medical.internal.spatial.isAffineEnough(self.Data.VolumeGeometry)

                    tform=vol.VolumeGeometry.oneSliceIntrinsicToWorldMapping(1);
                    volTransform=tform.A;

                end

            catch

            end

        end


        function dataSize=get.DataSize(self)

            dataSize=[0,0,0];
            if~isempty(self.Data)
                dataSize=size(self.Data.Voxels);
            end

        end


        function spatialDetails=get.SpatialDetails(self)

            spatialDetails=[];
            if~isempty(self.Data)
                spatialDetails=self.Data.VolumeGeometry;
            end

        end


        function TF=get.IsRGB(self)

            TF=false;
            if~isempty(self.Data)
                TF=ndims(self.Data.Voxels)>3;
            end

        end


        function TF=get.IsOblique(self)





            TF=false;
            if~isempty(self.Data)
                TF=self.Data.Orientation=="oblique"||any(self.Data.PlaneMapping=="unknown");
            end

        end

    end

end
