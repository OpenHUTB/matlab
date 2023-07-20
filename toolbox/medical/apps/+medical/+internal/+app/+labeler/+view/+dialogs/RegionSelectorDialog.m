classdef RegionSelectorDialog<images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog




    properties

SliceDirection
StartIdx
IsDataOblique

    end

    methods

        function self=RegionSelectorDialog(loc,alpha,contrastLimits,rotationState,idx,isDataOblique,pixSize,sliceDirection)

            self@images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog(loc,alpha,contrastLimits,rotationState);

            self.Size=[500,600];

            self.StartIdx=idx;
            self.IsDataOblique=isDataOblique;
            self.SliceDirection=sliceDirection;
            self.Slice.PixelSize=pixSize;

        end


        function initialize(self)

            requestSliceAtLocation(self,self.StartIdx)

            self.Slider.Enabled=true;
            self.Slice.Enabled=true;

            self.Summary.Enabled=true;
            self.Summary.Empty=false;

            self.Slice.Image.Visible=true;

            refreshSummary(self);

        end


        function updateSummary(self,data,color)

            if sum(data>0)<2


                if self.IsDataOblique
                    sliceDir=double(self.SliceDirection);
                else
                    sliceDir=string(self.SliceDirection);
                end

                if isempty(sliceDir)
                    msg=getString(message('medical:medicalLabeler:notEnoughInterpolationDataImage'));
                else
                    msg=getString(message('medical:medicalLabeler:notEnoughInterpolationDataVolume',sliceDir));
                end


                evt=medical.internal.app.labeler.events.ErrorEventData(msg);
                notify(self,'ThrowError',evt);
                return;

            end

            if any(data==2)&&sum(data==2)<2


                evt=medical.internal.app.labeler.events.ErrorEventData(getString(message('medical:medicalLabeler:noMatchingRegionInterpolationData')));
                notify(self,'ThrowError',evt);
                return;
            end

            draw(self.Summary,data,color);

        end

    end

    methods(Access=protected)


        function requestSliceAtLocation(self,idx)
            evt=medical.internal.app.labeler.events.SliceEventData(idx,self.SliceDirection);
            notify(self,'SliceAtLocationRequested',evt);
        end


        function refreshSummary(self)

            if isempty(self.Value)
                val=0;
                color=[0,0,0];
            else
                val=self.Value;
                color=self.Colormap(val+1,:);
            end

            evt=images.internal.app.segmenter.volume.events.SummaryUpdatedEventData(val,color);
            evt.SliceDirection=self.SliceDirection;
            notify(self,'UpdateSummary',evt);


        end

    end

end
