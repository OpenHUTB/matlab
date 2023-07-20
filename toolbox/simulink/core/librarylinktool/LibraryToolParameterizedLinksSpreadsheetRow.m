classdef LibraryToolParameterizedLinksSpreadsheetRow<handle

    properties(SetAccess=public,GetAccess=public)
        m_ParameterizedBlockHandle;
        m_Checkbox;
        m_ModifiedBlock;
        m_Parameter;
m_ParameterizedValue
        m_LibraryValue;
        m_Children;
        m_IsParameterizedBlock;
    end
    methods(Static,Access=public)

        function handleStyleCheckbox(obj,ssTag,ssDlg,propertyName,propertyValue)
            ParameterizedLinksTable=ssDlg.getUserData(ssTag);
            selectionCount=ParameterizedLinksTable.m_SelectionCount;

            if obj{1}.m_IsParameterizedBlock=='0'
                return;
            end

            if propertyValue=='1'
                selectionCount=selectionCount+1;
            else
                selectionCount=selectionCount-1;
            end

            obj{1}.m_Checkbox='1';

            ParameterizedLinksTable.updateRow(ssDlg,ssTag,obj{1});
            ParameterizedLinksTable.updateSelectionCount(ssDlg,ssTag,selectionCount);

            if selectionCount>0
                ssDlg.setEnabled('ParameterizedPushButton',true);
                ssDlg.setEnabled('ParameterizedRestoreButton',true);
            else
                ssDlg.setEnabled('ParameterizedPushButton',false);
                ssDlg.setEnabled('ParameterizedRestoreButton',false);
            end
        end
    end
    methods(Access=public)
        function obj=LibraryToolParameterizedLinksSpreadsheetRow(parameterizedBlockHandle,modifiedBlock,parameterName,parameterizedValue,libraryValue,children,isParameterizedBlock)
            if(nargin>0)
                obj.m_ParameterizedBlockHandle=parameterizedBlockHandle;
                obj.m_Checkbox='0';
                obj.m_ModifiedBlock=modifiedBlock;
                obj.m_Parameter=parameterName;
                obj.m_ParameterizedValue=parameterizedValue;
                obj.m_LibraryValue=libraryValue;
                obj.m_Children=children;
                obj.m_IsParameterizedBlock=isParameterizedBlock;
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            switch aPropName
            otherwise
                assert(false);
            end
        end

        function aPropValue=getPropValue(this,aPropName)
            switch aPropName
            case LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn
                aPropValue=this.m_ModifiedBlock;
            case LibraryToolParameterizedLinksSpreadsheet.sParameterColumn
                aPropValue=this.m_Parameter;
            case LibraryToolParameterizedLinksSpreadsheet.sParameterizedValueColumn
                aPropValue=this.m_ParameterizedValue;
            case LibraryToolParameterizedLinksSpreadsheet.sLibraryValueColumn
                aPropValue=this.m_LibraryValue;
            otherwise
                assert(false);
            end
        end

        function bIsValid=isValidProperty(~,aPropName)
            switch aPropName
            case LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn
                bIsValid=true;
            case LibraryToolParameterizedLinksSpreadsheet.sParameterColumn
                bIsValid=true;
            case LibraryToolParameterizedLinksSpreadsheet.sParameterizedValueColumn
                bIsValid=true;
            case LibraryToolParameterizedLinksSpreadsheet.sLibraryValueColumn
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            switch(aPropName)
            case LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end

        function isHier=isHierarchical(~)
            isHier=true;
        end

        function children=getHierarchicalChildren(this)
            children=this.m_Children;
        end
        function getPropertyStyle(obj,aPropName,propertyStyle)
            switch(aPropName)
            case LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn
                if obj.m_IsParameterizedBlock=='1'
                    checkValue='on';
                    if strcmp(obj.m_Checkbox,'0')
                        checkValue='off';
                    end
                    propertyStyle.WidgetInfo=struct('Type','checkbox',...
                    'Value',checkValue,...
                    'Callback',@(obj,tag,dlg,prop,value)LibraryToolParameterizedLinksSpreadsheetRow.handleStyleCheckbox(obj,tag,dlg,prop,value));
                end
            end
        end
        function isHyperlink=propertyHyperlink(this,propName,clicked)
            isHyperlink=false;
            switch propName
            case LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn
                isHyperlink=true;
            otherwise
                isHyperlink=false;
            end

            if clicked
                if strcmp(propName,LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn)
                    if this.m_IsParameterizedBlock=='1'
                        block=this.m_ModifiedBlock;
                    else
                        parameterizedBlockName=getfullname(this.m_ParameterizedBlockHandle);
                        block=[parameterizedBlockName,'/',this.m_ModifiedBlock];
                    end
                end
                result=strsplit(block,'/');
                model=result{1};
                editedlinkstool('Highlight',model,block);
            end
        end

    end
end