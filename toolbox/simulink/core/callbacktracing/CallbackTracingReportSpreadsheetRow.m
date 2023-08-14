classdef CallbackTracingReportSpreadsheetRow<handle

    properties(SetAccess=public,GetAccess=public)
        m_SNo;
        m_CallbackType;
        m_ObjectName;
        m_CallbackCode;
        m_CallbackExecutionTime;
        m_CallbackExtras;
        m_ModelName;
    end

    methods(Static,Access=public)

    end

    methods(Access=public)
        function obj=CallbackTracingReportSpreadsheetRow(sno,callbackType,objectName,callbackCode,callbackExecutionTime,callbackExtras,modelName)
            if(nargin>0)
                obj.m_SNo=string(sno);
                obj.m_CallbackType=callbackType;
                obj.m_ObjectName=objectName;
                obj.m_CallbackCode=callbackCode;
                obj.m_CallbackExecutionTime=callbackExecutionTime;
                obj.m_CallbackExtras=callbackExtras;
                obj.m_ModelName=modelName;
            end
        end

        function setPropValue(~,aPropName,~)
            switch aPropName
            otherwise
                assert(false);
            end
        end

        function aPropValue=getPropValue(this,aPropName)
            switch aPropName
            case CallbackTracingReportSpreadsheet.sSNoColumn
                aPropValue=this.m_SNo;
            case CallbackTracingReportSpreadsheet.sCallbackTypeColumn
                aPropValue=this.m_CallbackType;
            case CallbackTracingReportSpreadsheet.sObjectNameColumn
                if(~isempty(this.m_CallbackExtras))
                    aPropValue=strcat(this.m_CallbackExtras,"@",this.m_ObjectName);
                else
                    aPropValue=this.m_ObjectName;
                end
            case CallbackTracingReportSpreadsheet.sCallbackCodeColumn
                aPropValue=this.m_CallbackCode;
            case CallbackTracingReportSpreadsheet.sCallbackExecutionTimeColumn
                aPropValue=this.m_CallbackExecutionTime;
            otherwise
                assert(false);
            end
        end

        function bIsValid=isValidProperty(~,aPropName)
            switch aPropName
            case CallbackTracingReportSpreadsheet.sSNoColumn
                bIsValid=true;
            case CallbackTracingReportSpreadsheet.sCallbackTypeColumn
                bIsValid=true;
            case CallbackTracingReportSpreadsheet.sObjectNameColumn
                bIsValid=true;
            case CallbackTracingReportSpreadsheet.sCallbackCodeColumn
                bIsValid=true;
            case CallbackTracingReportSpreadsheet.sCallbackExecutionTimeColumn
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            switch propName
            case CallbackTracingReportSpreadsheet.sObjectNameColumn
                isHyperlink=true;
            otherwise
                isHyperlink=false;
            end
            if clicked
                if strcmp(propName,CallbackTracingReportSpreadsheet.sObjectNameColumn)
                    objectPath=this.m_ObjectName;
                end
                CallbackTracing('Highlight',objectPath);
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(~,~)
            bIsReadOnly=true;
        end
    end
end