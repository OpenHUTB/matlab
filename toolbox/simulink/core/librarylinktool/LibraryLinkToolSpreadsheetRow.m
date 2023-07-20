classdef LibraryLinkToolSpreadsheetRow<handle
    properties(SetAccess=public,GetAccess=public)
        m_BlockName;
        m_LibraryBlock;
        m_Selected;
        m_Children;
        m_BlockParent;

    end

    methods(Static,Access=public)
        function[selectionCount,updatedRowsList]=checkorUncheckAllDownInHierarchy(ssTag,row,propValue,selectionCount,updatedRowsList)
            children=row.m_Children;
            if~isempty(row.m_Children)
                for i=1:length(children)
                    child=children(i);

                    if propValue=='1'&&child.m_Selected~='1'
                        selectionCount=selectionCount+1;
                    elseif propValue=='0'&&child.m_Selected~='0'
                        selectionCount=selectionCount-1;
                    end

                    child.m_Selected=propValue;

                    updatedRowsList{end+1}=child;
                    [selectionCount,updatedRowsList]=LibraryLinkToolSpreadsheetRow.checkorUncheckAllDownInHierarchy(ssTag,child,propValue,selectionCount,updatedRowsList);
                end
            end
        end
        function handleStyleCheckbox(obj,ssTag,ssDlg,propertyName,propertyValue)
            blocksTable=ssDlg.getUserData(ssTag);
            selectionCount=blocksTable.m_SelectionCount;
            updatedRowsList={};
            if propertyValue=='1'
                selectionCount=selectionCount+1;
            else
                selectionCount=selectionCount-1;
            end

            obj{1}.m_Selected=propertyValue;
            updatedRowsList={obj{1}};

            [selectionCount,updatedRowsList]=LibraryLinkToolSpreadsheetRow.checkorUncheckAllDownInHierarchy(ssTag,obj{1},propertyValue,selectionCount,updatedRowsList);

            blocksTable.updateRow(ssDlg,ssTag,obj{1});
            blocksTable.updateSelectionCount(ssDlg,ssTag,selectionCount);

            ssComp=ssDlg.getWidgetInterface(ssTag);
            ssComp.update(updatedRowsList);
            ssComp.expand(obj{1},false);

            if selectionCount>0
                ssDlg.setEnabled('PushButton',true);
                ssDlg.setEnabled('RestoreButton',true);
            else
                ssDlg.setEnabled('PushButton',false);
                ssDlg.setEnabled('RestoreButton',false);
            end
        end
    end

    methods(Access=public)
        function obj=LibraryLinkToolSpreadsheetRow(blockPath,libraryPath,children,parent)
            if(nargin>0)
                obj.m_BlockName=blockPath;
                obj.m_LibraryBlock=libraryPath;
                obj.m_Selected='0';
                obj.m_Children=children;
                obj.m_BlockParent=parent;
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
            case LibraryLinkToolSpreadsheet.sBlockNameColumn
                aPropValue=this.m_BlockName;
            case LibraryLinkToolSpreadsheet.sLibraryNameColumn
                aPropValue=this.m_LibraryBlock;
            otherwise
                assert(false);
            end
        end

        function getPropertyStyle(obj,aPropName,propertyStyle)
            switch(aPropName)
            case LibraryLinkToolSpreadsheet.sBlockNameColumn
                checkValue='on';
                if strcmp(obj.m_Selected,'0')
                    checkValue='off';
                end
                propertyStyle.WidgetInfo=struct('Type','checkbox',...
                'Value',checkValue,...
                'Callback',...
                @(obj,tag,dlg,prop,value)...
                LibraryLinkToolSpreadsheetRow.handleStyleCheckbox(obj,tag,dlg,prop,value));
            end
        end

        function bIsValid=isValidProperty(~,aPropName)
            switch aPropName
            case LibraryLinkToolSpreadsheet.sBlockNameColumn
                bIsValid=true;
            case LibraryLinkToolSpreadsheet.sLibraryNameColumn
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            isHyperlink=true;
            if clicked
                if strcmp(propName,LibraryLinkToolSpreadsheet.sBlockNameColumn)
                    block=this.m_BlockName;
                elseif strcmp(propName,LibraryLinkToolSpreadsheet.sLibraryNameColumn)
                    block=this.m_LibraryBlock;
                end
                result=strsplit(block,'/');
                model=result{1};
                editedlinkstool('Highlight',model,block);
            end
        end


        function label=getDisplayLabel(this)
            label=this.m_BlockName;
        end

        function children=getChildren(this)
            children=this.m_Children;
        end

        function isHier=isHierarchical(~)
            isHier=true;
        end
        function children=getHierarchicalChildren(this)
            children=this.m_Children;
        end
        function[bIsReadOnly]=isReadonlyProperty(~,aPropName)
            switch(aPropName)
            case LibraryLinkToolSpreadsheet.sBlockNameColumn
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end
    end
end