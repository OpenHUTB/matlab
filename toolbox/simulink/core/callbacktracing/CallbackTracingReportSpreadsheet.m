classdef CallbackTracingReportSpreadsheet<handle
    properties
        m_modelName;
        m_Columns;
        m_Children;
        m_Obj;
        m_StageName;
    end

    properties(Hidden=true,Constant=true)
        sSNoColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolSerialNoColumnName');
        sCallbackTypeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackTypeColumnName');
        sObjectNameColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolObjectNameColumnName');
        sCallbackCodeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackCodeColumnName');
        sCallbackExecutionTimeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackExecutionTimeColumnName');

    end

    methods
        function this=CallbackTracingReportSpreadsheet(modelName,obj,stageName)
            this.m_modelName=modelName;
            this.m_Obj=obj;
            this.m_StageName=stageName;
            this.m_Columns={CallbackTracingReportSpreadsheet.sSNoColumn,...
            CallbackTracingReportSpreadsheet.sCallbackTypeColumn,...
            CallbackTracingReportSpreadsheet.sObjectNameColumn,...
            CallbackTracingReportSpreadsheet.sCallbackCodeColumn,...
            CallbackTracingReportSpreadsheet.sCallbackExecutionTimeColumn};
            this.m_Children=this.getChildren();

        end

        function children=getChildren(this)

            if~isempty(this.m_Children)
                children=this.m_Children;
                return;
            else
                model=this.m_modelName;
                stageName=this.m_StageName;
                children=populateChildren(this,model,stageName);
                this.m_Children=children;
            end
        end

        function children=populateChildren(this,model,stageName)
            bdHandle=get_param(model,'Handle');

            report=slInternal('getCallbackTracingReport',bdHandle);

            if isempty(report)
                children=[];
                return;
            end

            allData=[report.CallbackData];
            allStages=unique([allData.StageName,""],'stable');

            if(isempty(this.m_Obj.m_StageNames))
                this.m_Obj.m_StageNames=cellstr(allStages(1:end-1));
            end

            if isempty(stageName)
                stageName=this.m_Obj.m_StageNames(1);
                this.m_StageName=stageName;
            end

            totsize=count([allData.StageName],stageName);
            children=repmat(CallbackTracingReportSpreadsheetRow(),[1,totsize]);

            c=1;
            for i=1:length(report)
                callbackData=report(i).CallbackData;

                callbackType=callbackData.CallbackType;
                objectName=callbackData.ObjectName;
                callbackCode=callbackData.CallbackCode;
                calbackExecutionTime=callbackData.ExecutionTime;
                callbackExtras=callbackData.CallbackExtras;

                if(~isempty(stageName)&&strcmp(report(i).CallbackData.StageName,stageName))
                    childObj=CallbackTracingReportSpreadsheetRow(c,callbackType,objectName,callbackCode,calbackExecutionTime,callbackExtras,model);
                    children(c)=childObj;
                    c=c+1;
                end
            end
        end

        function spreadsheetObj=updateSpreadSheetChildren(spreadsheetObj,model,stageName)
            children=populateChildren(spreadsheetObj,model,stageName);

            spreadsheetObj.m_Children=children;
        end

        function spreadsheetObj=clearSpreadsheetChildren(spreadsheetObj)
            spreadsheetObj.m_Obj.m_StageNames={};
            spreadsheetObj.m_Children=[];
            children=spreadsheetObj.getChildren();
            spreadsheetObj.m_Children=children;
        end

        function updateUI(~,dialogH,spreadsheetTag)
            ssComp=dialogH.getWidgetInterface(spreadsheetTag);
            ssComp.update(true);
        end

    end

end
