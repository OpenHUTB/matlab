classdef ForwardingTableSpreadsheetRow<handle
    properties(SetAccess=public,GetAccess=public)

        m_OldBlockPath;
        m_OldBlockVersion;
        m_NewBlockPath;
        m_NewBlockVersion;
        m_TransformationFcn;
    end

    methods
        function obj=ForwardingTableSpreadsheetRow(aRowData)
            obj.m_OldBlockPath=strrep(aRowData{1},newline,' ');
            obj.m_NewBlockPath=strrep(aRowData{2},newline,' ');


            obj.m_OldBlockVersion=DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer');
            obj.m_NewBlockVersion=DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer');
            obj.m_TransformationFcn=DAStudio.message('Simulink:dialog:ForwardingTableNoTransformation');

            if 3==length(aRowData)


                obj.m_TransformationFcn=aRowData{3};
            elseif 5==length(aRowData)

                obj.m_OldBlockVersion=aRowData{3};
                obj.m_NewBlockVersion=aRowData{4};
                obj.m_TransformationFcn=aRowData{5};
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            switch aPropName
            case ForwardingTableSpreadsheet.sOldBlockPathColumn
                this.m_OldBlockPath=aPropValue;
            case ForwardingTableSpreadsheet.sOldBlockVersionColumn
                this.m_OldBlockVersion=aPropValue;
            case ForwardingTableSpreadsheet.sNewBlockPathColumn
                this.m_NewBlockPath=aPropValue;
            case ForwardingTableSpreadsheet.sNewBlockVersionColumn
                this.m_NewBlockVersion=aPropValue;
            case ForwardingTableSpreadsheet.sTransformationFcnColumn
                this.m_TransformationFcn=aPropValue;
            otherwise
                assert(false);
            end
        end

        function aPropValue=getPropValue(this,aPropName)
            switch aPropName
            case ForwardingTableSpreadsheet.sOldBlockPathColumn
                aPropValue=this.m_OldBlockPath;
            case ForwardingTableSpreadsheet.sOldBlockVersionColumn
                aPropValue=this.m_OldBlockVersion;
            case ForwardingTableSpreadsheet.sNewBlockPathColumn
                aPropValue=this.m_NewBlockPath;
            case ForwardingTableSpreadsheet.sNewBlockVersionColumn
                aPropValue=this.m_NewBlockVersion;
            case ForwardingTableSpreadsheet.sTransformationFcnColumn
                aPropValue=this.m_TransformationFcn;
            otherwise
                assert(false);
            end
        end

        function bIsValid=isValidProperty(~,aPropName)
            switch aPropName
            case ForwardingTableSpreadsheet.sOldBlockPathColumn
                bIsValid=true;
            case ForwardingTableSpreadsheet.sOldBlockVersionColumn
                bIsValid=true;
            case ForwardingTableSpreadsheet.sNewBlockPathColumn
                bIsValid=true;
            case ForwardingTableSpreadsheet.sNewBlockVersionColumn
                bIsValid=true;
            case ForwardingTableSpreadsheet.sTransformationFcnColumn
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end
    end
end