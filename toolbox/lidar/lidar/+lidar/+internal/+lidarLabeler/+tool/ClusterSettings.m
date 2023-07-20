classdef ClusterSettings<driving.internal.groundTruthLabeler.tool.ClusterSettings




    methods

        function this=ClusterSettings(tool)
            this@driving.internal.groundTruthLabeler.tool.ClusterSettings(tool);
        end


        function open(this,viewClustersFlag,kmeansNumClusters)
            if isempty(this.Dialog)||~isvalid(this.Dialog)||~isvalid(this.Dialog.FigureHandle)
                this.Dialog=lidar.internal.lidarLabeler.tool.ClusterSettingsDialog(this.Container);
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
    end
end

function tf=useAppContainer(~)
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end