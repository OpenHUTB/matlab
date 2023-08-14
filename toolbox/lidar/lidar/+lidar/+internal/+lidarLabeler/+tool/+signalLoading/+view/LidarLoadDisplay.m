
classdef LidarLoadDisplay<vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadDisplay



    properties(Access=protected)


        PackageRoot=["vision.labeler.loading","lidar.labeler.loading"];
    end

    properties(Constant,Access=protected)
        signalLoadPanelY=37;
    end




    methods

        function this=LidarLoadDisplay(parent)
            this=this@vision.internal.videoLabeler.tool.signalLoading.view.SignalLoadDisplay(parent);
        end

        function isAdded=addingPointCloudSource(this)
            isAdded=this.signalAddButtonCallback();
        end
    end

    methods(Access=protected)
        function calculatePositions(this)

            parentPos=this.Parent.Position;
            parentWidth=parentPos(3);

            loadPanelWidth=parentWidth-(this.LeftPadding+this.RightPadding);

            this.SignalLoadPanelPos=[this.LeftPadding,this.signalLoadPanelY...
            ,loadPanelWidth,this.LoadPanelHeight];

            textPopupY=this.signalLoadPanelY+this.LoadPanelHeight+this.HeightPadding;
            this.SignalSourceTextPos=[this.LeftPadding,textPopupY...
            ,this.TextWidth,this.TextPopupHeight];

            popupX=this.SignalSourceTextPos(3)+this.WidthPadding;
            this.SignalSourcePopupPos=[popupX,textPopupY,this.PopupWidth...
            ,this.TextPopupHeight];
        end

        function accept=isSourceSupported(~,name)
            if strcmp(name,'vision.labeler.loading.PointCloudSequenceSource')...
                ||strcmp(name,'vision.labeler.loading.VelodyneLidarSource')...
                ||strcmp(name,'lidar.labeler.loading.LasFileSequenceSource')...
                ||strcmp(name,'lidar.labeler.loading.RosbagSource')...
                ||strcmp(name,'lidar.labeler.loading.CustomPointCloudSource')
                accept=true;
            else
                accept=false;
            end
        end

        function defaultSourceIdx=defaultSignalSource(this)



            defaultSourceIdx=([this.SignalSourceList.Name]==string(vision.getMessage('vision:labeler:PointCloudSequenceDisplayName')));
        end
    end
end
