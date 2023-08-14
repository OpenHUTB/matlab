classdef Metrics<handle


    properties
        data;
        columns;
        totalBlocks;
        metrics;
        category;
        cloneDetectionStatus;
        count;
    end

    methods(Access=public)
        function this=Metrics(metrics,totalBlocks,cloneDetectionStatus)
            this.data=[];

            this.columns={DAStudio.message('sl_pir_cpp:creator:metricsSSColumn1'),...
            DAStudio.message('sl_pir_cpp:creator:metricsSSColumn2'),...
            DAStudio.message('sl_pir_cpp:creator:metricsSSColumn3')};
            this.metrics=metrics;
            this.totalBlocks=totalBlocks;
            this.category={'Overall','Exact','Similar'};
            this.cloneDetectionStatus=cloneDetectionStatus;
            this.count=50;
        end


        function children=getChildren(this,~)
            if~isempty(this.data)
                children=this.data;
                return;
            else
                if this.cloneDetectionStatus
                    metricsTypes=fieldnames(this.metrics);
                    children(1,length(metricsTypes))=...
                    CloneDetectionUI.internal.SpreadSheetItem.Metrics();
                    for i=1:length(metricsTypes)

                        percentage=(this.metrics.(metricsTypes{i})/this.totalBlocks)*100;
                        children(i)=...
                        CloneDetectionUI.internal.SpreadSheetItem.Metrics...
                        (this.category{i},percentage);
                    end
                    this.data=children;
                end

                children=this.data;
            end
        end

    end
end

