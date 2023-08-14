classdef Logs<handle






    properties
        data;
        columns;
        historyVersions;
        ddgBottomObj;
    end

    methods(Access=public)
        function this=Logs(ddgBottomObj,historyVersions)
            this.data=[];
            this.columns={DAStudio.message('sl_pir_cpp:creator:logsSSColumn1')};
            this.historyVersions=historyVersions;
            this.ddgBottomObj=ddgBottomObj;
        end


        function children=getChildren(this,~)
            if~isempty(this.data)
                children=this.data;
                return;
            else
                if~isempty(this.historyVersions)

                    len=length(this.historyVersions);
                    children(1,len)=...
                    CloneDetectionUI.internal.SpreadSheetItem.Logs();

                    for i=len:-1:1
                        children(len-i+1)=CloneDetectionUI.internal.SpreadSheetItem.Logs(this.ddgBottomObj.model,...
                        char(this.historyVersions(i)),false);
                    end
                else
                    children=[];
                end
                this.data=children;
                children=this.data;
            end
        end

    end
end

