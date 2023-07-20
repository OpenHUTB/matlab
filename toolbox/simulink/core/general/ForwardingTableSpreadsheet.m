classdef ForwardingTableSpreadsheet<handle




    properties(SetAccess=private,GetAccess=public)
        m_BDName;
        m_Columns;
        m_Children;
        m_MapData;
        m_UserEmptiedEntries;
        m_SelectedRowIndex;
        m_SelectedPropertyInRowIndex;
    end

    properties(SetAccess=public,GetAccess=public)
    end

    properties(Hidden=true,Constant=true)
        sOldBlockPathColumn=DAStudio.message('Simulink:dialog:ForwardingTableCol1Name');
        sOldBlockVersionColumn=DAStudio.message('Simulink:dialog:ForwardingTableCol2Name');
        sNewBlockPathColumn=DAStudio.message('Simulink:dialog:ForwardingTableCol3Name');
        sNewBlockVersionColumn=DAStudio.message('Simulink:dialog:ForwardingTableCol4Name');
        sTransformationFcnColumn=DAStudio.message('Simulink:dialog:ForwardingTableCol5Name');
    end

    methods
        function this=ForwardingTableSpreadsheet(aBDName)

            this.m_BDName=aBDName;

            this.m_Columns={
            ForwardingTableSpreadsheet.sOldBlockPathColumn,...
            ForwardingTableSpreadsheet.sOldBlockVersionColumn,...
            ForwardingTableSpreadsheet.sNewBlockPathColumn,...
            ForwardingTableSpreadsheet.sNewBlockVersionColumn,...
            ForwardingTableSpreadsheet.sTransformationFcnColumn
            };

            this.m_SelectedRowIndex=0;
            this.m_UserEmptiedEntries=false;

            this.m_Children=this.getChildren();
        end

        function aChildren=getChildren(this)


            if isempty(this.m_Children)&&~this.m_UserEmptiedEntries



                aRowsData=get_param(this.m_BDName,'ForwardingTable');
                if~isempty(aRowsData)
                    for i=1:length(aRowsData)
                        this.m_Children=[this.m_Children,ForwardingTableSpreadsheetRow(aRowsData{i})];
                    end
                end
            end
            this.m_UserEmptiedEntries=false;
            aChildren=this.m_Children;
            this.createMapData();
        end

        function createMapData(this)

            if isempty(this.m_Children)
                return;
            end


            mapData=containers.Map();


            for i=1:length(this.m_Children)
                if strcmp(this.m_Children(i).m_OldBlockPath,this.m_Children(i).m_NewBlockPath)==true
                    mapData(this.m_Children(i).m_OldBlockPath)=this.m_Children(i).m_NewBlockVersion;
                end
            end


            this.m_MapData=mapData;
        end

        function addChild(this,child)

            if~isempty(child)
                this.m_Children=[this.m_Children,ForwardingTableSpreadsheetRow(child)];
                this.m_UserEmptiedEntries=false;
            end
        end

        function deleteChild(this)

            if~isempty(this.m_Children)&&this.m_SelectedRowIndex<=length(this.m_Children)&&this.m_SelectedRowIndex>0
                this.m_Children(this.m_SelectedRowIndex)=[];
                this.m_SelectedRowIndex=0;
            end


            if isempty(this.m_Children)
                this.m_UserEmptiedEntries=true;
            end
        end

        function moveChildUp(this)

            if this.m_SelectedRowIndex>1
                this.m_Children([this.m_SelectedRowIndex-1,this.m_SelectedRowIndex])=this.m_Children([this.m_SelectedRowIndex,this.m_SelectedRowIndex-1]);
                this.m_SelectedRowIndex=this.m_SelectedRowIndex-1;
            end
        end

        function moveChildDown(this)
            if this.m_SelectedRowIndex<length(this.m_Children)
                this.m_Children([this.m_SelectedRowIndex,this.m_SelectedRowIndex+1])=this.m_Children([this.m_SelectedRowIndex+1,this.m_SelectedRowIndex]);
                this.m_SelectedRowIndex=this.m_SelectedRowIndex+1;
            end
        end

        function updateChild(this,child)


            if~isempty(child)
                this.m_Children(this.m_SelectedRowIndex)=ForwardingTableSpreadsheetRow(child);
            end
        end

        function updateChildProperty(this,propName,propValue)

            this.m_Children(this.m_SelectedRowIndex).setPropValue(propName,propValue);
        end

        function isPathProp=isPathProperty(this,propName)


            isPathProp=strcmp(propName,this.sOldBlockPathColumn)==true||strcmp(propName,this.sNewBlockPathColumn)==true;
        end

        function isVersionProp=isVersionProperty(this,propName)


            isVersionProp=strcmp(propName,this.sOldBlockVersionColumn)==true||strcmp(propName,this.sNewBlockVersionColumn)==true;
        end

        function isValidEntry=isValidMapEntry(this,mapKey)


            isValidEntry=~isempty(this.m_MapData)&&this.m_MapData.isKey(mapKey);
        end

        function value=getMapValue(this,mapKey)


            value=[];
            if this.isValidMapEntry(mapKey)
                value=this.m_MapData(mapKey);
            end
        end

        function setMapValue(this,mapKey,mapValue)

            this.m_MapData(mapKey)=mapValue;
        end

        function rowIndex=getSelectedRowIndex(this,rowData)
            rowIndex=0;


            if isempty(rowData)||isempty(this.m_Children)
                return;
            end


            for i=1:length(this.m_Children)
                if isequal(this.m_Children(i),rowData)
                    this.m_SelectedRowIndex=i;
                    rowIndex=i;
                end
            end
        end

        function rowIndex=getSelectedRowAndPropertyIndex(this,rowData,propName)

            rowIndex=this.getSelectedRowIndex(rowData);


            if rowIndex>0&&~isempty(propName)&&...
                (this.isPathProperty(propName)||this.isVersionProperty(propName)||...
                strcmp(propName,this.sTransformationFcnColumn)==true)
                this.m_SelectedPropertyInRowIndex=propName;
            else
                this.m_SelectedPropertyInRowIndex='';
            end
        end

    end
end
