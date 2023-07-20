classdef Image<handle




    properties

DataName

Data

DataDisplayLimits
DataDisplayLimitsDefault

    end

    properties

DataSource
DataBounds
IsDataValidated

    end

    properties(Dependent)

DataSize
IsRGB
RawData
IsOblique

    end

    properties(SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

        CastingMethod=[];
OriginalDataType

DataForAutomation
DataBoundsForAutomation

    end

    events
ErrorThrown
    end


    methods


        function read(self,dataName,dataSource,dataBounds,dataDisplayLimits,dataDisplayLimitsDefault,isDataValidated,castingMethod)

            self.DataName=dataName;
            self.DataSource=dataSource;
            self.IsDataValidated=isDataValidated;
            self.CastingMethod=castingMethod;

            self.DataBounds=dataBounds;
            self.DataDisplayLimits=dataDisplayLimits;
            self.DataDisplayLimitsDefault=dataDisplayLimitsDefault;

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

        end


        function[dataSlice,pixelSpacing]=getSlice(self,idx,~)

            dataSlice=[];
            if isempty(self.Data)
                return;
            end

            dataSlice=self.Data.extractFrame(idx);
            pixelSpacing=self.Data.PixelSpacing;

        end


        function intensity=getIntensity(self,position,idx,~)

            intensity=[];
            if isempty(self.Data)
                return;
            end

            dataSlice=self.getSlice(idx);
            [m,n]=size(dataSlice,[1,2]);
            if position(2)<=m&&position(1)<=n
                intensity=squeeze(dataSlice(position(2),position(1),:))';
            end

        end


        function maxIdx=getMaxSliceIndex(self,~)
            maxIdx=self.getNumSlices();
        end


        function numFrames=getNumSlices(self)

            numFrames=[];
            if isempty(self.Data)
                return;
            end

            numFrames=self.Data.NumFrames;

        end


        function pixelSpacing=getPixelSpacing(self)

            pixelSpacing=[1,1];
            if isempty(self.Data)||isempty(self.Data.PixelSpacing)
                return;
            end

            pixelSpacing=self.Data.PixelSpacing;

        end


        function planeMapping=getPlaneMapping(~,~)
            planeMapping=3;
        end


        function tempValues=getTempValues(self)

            tempValues=struct();

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
                        data=cast(self.Data.Pixels,self.OriginalDataType);
                        self.DataForAutomation=medicalImage(data,self.Data.SpatialDetails);
                        self.DataBoundsForAutomation=self.DataBounds;

                    case "normalize"




                        self.DataForAutomation=medicalImage(self.DataSource);
                        [m,n]=bounds(self.Data.Pixels,'all');
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


        function dataSlice=getSliceForAutomation(self,useOriginal,idx,~)

            dataSlice=[];
            if isempty(self.DataForAutomation)
                return;
            end

            dataSlice=self.Data.extractFrame(idx);

            if~useOriginal

                if self.IsRGB
                    rgbLimits=getRGBLimits(class(dataSlice));
                    dataSlice=images.internal.app.segmenter.volume.data.rescaleVolume(dataSlice,rgbLimits,rgbLimits,rgbLimits,[]);
                else
                    dataSlice=images.internal.app.segmenter.volume.data.rescaleVolume(dataSlice,[],[],[],self.DataBounds);
                end

            end

        end


        function data=getRawDataForAutomation(self,useOriginal)
            data=[];
            if~isempty(self.DataForAutomation)

                data=self.DataForAutomation.Pixels;

                if~useOriginal

                    if self.IsRGB
                        rgbLimits=getRGBLimits(class(data));
                        data=images.internal.app.segmenter.volume.data.rescaleVolume(data,rgbLimits,rgbLimits,rgbLimits,[]);
                    else
                        data=images.internal.app.segmenter.volume.data.rescaleVolume(data,[],[],[],self.DataBounds);
                    end

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

            self.Data=medicalImage(self.DataSource);
            self.OriginalDataType=class(self.Data.Pixels);
            self.castDataIfRequired();

            if~self.IsDataValidated


                try
                    validateattributes(self.Data.Pixels,{'numeric'},{'finite'});
                catch
                    error(message('medical:medicalLabeler:invalidData',self.DataName));
                end




                self.computeMetadata();

                self.IsDataValidated=true;

            end

        end


        function castDataIfRequired(self)





            if isempty(self.CastingMethod)

                self.CastingMethod="none";
                if(isequal(class(self.Data.Pixels),'single')||isequal(class(self.Data.Pixels),'double'))&&any(self.Data.Pixels>1,'all')

                    if isequal(floor(self.Data.Pixels),self.Data.Pixels)


                        self.CastingMethod="int16";
                    else

                        self.CastingMethod="normalize";
                    end

                end

            end

            switch self.CastingMethod

            case "int16"
                data=int16(self.Data.Pixels);
                self.Data=medicalImage(data);

            case "normalize"

                if self.IsRGB

                    rgbLimits=getRGBLimits(class(self.Data.Pixels));
                    data=images.internal.app.segmenter.volume.data.rescaleVolume(self.Data.Pixels,rgbLimits,rgbLimits,rgbLimits,[]);

                else
                    data=images.internal.app.segmenter.volume.data.rescaleVolume(self.Data.Pixels,[],[],[],self.DataBounds);
                end
                self.Data=medicalImage(data);

            case "none"

            end


        end


        function computeMetadata(self)


            [m,n]=bounds(self.Data.Pixels,'all');
            self.DataBounds=[m,n];











            if~isempty(self.Data.WindowCenter)&&~isempty(self.Data.WindowWidth)&&...
                ~all(self.Data.WindowCenter==0)&&~all(self.Data.WindowWidth==0)

                displayLimits=[self.Data.WindowCenter(1)-(self.Data.WindowWidth(1)/2),...
                self.Data.WindowCenter(1)+(self.Data.WindowWidth(1)/2)];

            else



                delta1Percent=round(0.01*diff(self.DataBounds));
                windowMin=self.DataBounds(1)+delta1Percent;
                windowMax=self.DataBounds(2)-delta1Percent;
                displayLimits=[windowMin,windowMax];

            end

            self.DataDisplayLimitsDefault=cast(displayLimits,class(self.RawData));
            self.DataDisplayLimits=self.DataDisplayLimitsDefault;

        end

    end


    methods


        function dataSize=get.DataSize(self)

            dataSize=[0,0,0];
            if~isempty(self.Data)
                dataSize=size(self.Data.Pixels);
            end

        end


        function TF=get.IsRGB(self)

            TF=false;
            if~isempty(self.Data)
                TF=~isempty(self.Data.Colormap)||size(self.Data.Pixels,4)==3;
            end

        end


        function data=get.RawData(self)

            data=[];
            if~isempty(self.Data)
                data=self.Data.Pixels;
            end

        end


        function TF=get.IsOblique(~)

            TF=false;

        end

    end

end


function limits=getRGBLimits(datatype)

    switch datatype

    case{'double','single'}
        limits=[0,1];
    case 'logical'

        limits=[0,1];
    otherwise
        limits=[intmin(datatype),intmax(datatype)];

    end

end
