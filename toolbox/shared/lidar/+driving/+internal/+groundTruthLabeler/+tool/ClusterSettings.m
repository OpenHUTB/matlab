classdef ClusterSettings<handle




    properties
Dialog
ToolGroup
Container
    end

    properties(Dependent)
ClusterData
DistanceThreshold
AngleThreshold
MinDistance
NumClusters
    end

    events
ClusterSettingsChanged
StartColoringByClusters
StopColoringByClusters
    end

    properties(Access=protected)

        ModeInternal='segmentLidarData';
        ClusterDataInternal=false;

        DistanceThresholdInternal=0.5;
        AngleThresholdInternal=5;

        DistanceThresholdRange=[0,10];
        AngleThresholdRange=[0,180];

        MinDistanceInternal=0.5;
        NumClustersInternal=0.1;

        MinDistanceRange=[0.001,10];
        NumClustersRange=[0,1];

DialogListener

    end


    methods

        function this=ClusterSettings(tool)
            this.Container=tool.Tool;
        end

        function open(this,viewClustersFlag,kmeansNumClusters)
            if isempty(this.Dialog)||~isvalid(this.Dialog)


                this.Dialog=driving.internal.groundTruthLabeler.tool.ClusterSettingsDialog(this.Container);
                update(this.Dialog,this.ModeInternal,this.DistanceThreshold,...
                this.AngleThreshold,...
                this.MinDistance,...
                this.NumClusters);
                this.DialogListener{1}=event.listener(this.Dialog,'ClusterSettingsChanged',@(src,evt)settingsChangedCallback(this,evt));
                this.DialogListener{2}=event.listener(this.Dialog,'StartColoringByClusters',@(~,~)startColoringByClusters(this));
                this.DialogListener{3}=event.listener(this.Dialog,'StopColoringByClusters',@(~,~)stopColoringByClusters(this));
                this.DialogListener{4}=event.listener(this.Dialog,'ClusterSettingsChanging',@(src,evt)settingsChangingCallback(this,evt));
                updateSliderDisplay(this);
                this.Dialog.Visible='on';


                this.Dialog.ViewClustersCheckbox.Value=viewClustersFlag;


                if~useAppContainer
                    this.Dialog.KMeansNumClustersText.String=num2str(kmeansNumClusters);
                else
                    this.Dialog.KMeansNumClustersText.Value=num2str(kmeansNumClusters);
                end

            else
                figure(this.Dialog.Dlg);
            end
        end

        function close(this)
            try %#ok<TRYNC>
                this.DialogListener={};
                delete(this.Dialog);
                this.Dialog=[];
            end
        end

        function delete(this)
            close(this);
            delete(this);
        end

    end

    methods(Access=protected)

        function settingsChangedCallback(this,evt)

            this.ModeInternal=evt.Mode;
            this.ClusterDataInternal=evt.ClusterData;
            this.DistanceThreshold=evt.DistanceThreshold;
            this.AngleThreshold=evt.AngleThreshold;

            this.MinDistance=evt.MinDistance;
            this.NumClusters=evt.NumClusters;

            packageEventData(this);
            updateSliderDisplay(this);
        end

        function settingsChangingCallback(this,evt)
            this.DistanceThreshold=evt.DistanceThreshold;
            this.AngleThreshold=evt.AngleThreshold;
            this.MinDistance=evt.MinDistance;
            this.NumClusters=evt.NumClusters;

            updateSliderDisplay(this);
        end

        function updateSliderDisplay(this)
            eventData=driving.internal.groundTruthLabeler.tool.LidarClusterEventData(...
            this.ClusterDataInternal,...
            this.ModeInternal,...
            this.DistanceThresholdInternal,...
            this.AngleThresholdInternal,...
            this.MinDistanceInternal,...
            this.NumClustersInternal);

            try %#ok<TRYNC>
                updateSliderDisplay(this.Dialog,eventData);
            end
        end

        function startColoringByClusters(this)
            notify(this,'StartColoringByClusters');
        end

        function stopColoringByClusters(this)
            notify(this,'StopColoringByClusters');
        end

        function packageEventData(this)
            eventData=driving.internal.groundTruthLabeler.tool.LidarClusterEventData(...
            this.ClusterDataInternal,...
            this.ModeInternal,...
            this.DistanceThresholdInternal,...
            this.AngleThresholdInternal,...
            this.MinDistanceInternal,...
            this.NumClustersInternal);

            notify(this,'ClusterSettingsChanged',eventData);
        end

    end

    methods

        function set.ClusterData(this,TF)

            this.ClusterDataInternal=TF;

            if TF

            else
                close(this)
            end

            packageEventData(this);

        end

        function TF=get.ClusterData(this)
            TF=this.ClusterDataInternal;
        end

        function set.DistanceThreshold(this,percent)

            this.DistanceThresholdInternal=this.DistanceThresholdRange(1)+...
            percent*(this.DistanceThresholdRange(2)-this.DistanceThresholdRange(1));
        end

        function percent=get.DistanceThreshold(this)

            percent=(this.DistanceThresholdInternal-this.DistanceThresholdRange(1))/...
            (this.DistanceThresholdRange(2)-this.DistanceThresholdRange(1));
        end

        function set.AngleThreshold(this,percent)

            this.AngleThresholdInternal=this.AngleThresholdRange(1)+...
            percent*(this.AngleThresholdRange(2)-this.AngleThresholdRange(1));
        end

        function percent=get.AngleThreshold(this)

            percent=(this.AngleThresholdInternal-this.AngleThresholdRange(1))/...
            (this.AngleThresholdRange(2)-this.AngleThresholdRange(1));
        end

        function set.MinDistance(this,percent)

            this.MinDistanceInternal=this.MinDistanceRange(1)+...
            percent*(this.MinDistanceRange(2)-this.MinDistanceRange(1));
        end

        function percent=get.MinDistance(this)

            percent=(this.MinDistanceInternal-this.MinDistanceRange(1))/...
            (this.MinDistanceRange(2)-this.MinDistanceRange(1));
        end

        function set.NumClusters(this,percent)

            this.NumClustersInternal=this.NumClustersRange(1)+...
            percent*(this.NumClustersRange(2)-this.NumClustersRange(1));
        end

        function percent=get.NumClusters(this)

            percent=(this.NumClustersInternal-this.NumClustersRange(1))/...
            (this.NumClustersRange(2)-this.NumClustersRange(1));
        end

    end

end

function tf=useAppContainer(~)
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end