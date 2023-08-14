classdef EquallySpacedPortSection<flexibleportplacement.dialog.SpecificationSection




    properties(Constant)
        SidesColumnOrder={...
        char(ConnectorPlacement.RectSide.LEFT),...
        char(ConnectorPlacement.RectSide.TOP),...
        char(ConnectorPlacement.RectSide.RIGHT),...
        char(ConnectorPlacement.RectSide.BOTTOM)};

        TableTag='SidesTable';
    end

    properties
        SelectedConnector=flexibleportplacement.connector.Connector.empty();
        SelectedColIdx=[];
    end

    methods
        function obj=EquallySpacedPortSection(spec)
            assert(metaclass(spec)==?flexibleportplacement.specification.EquallySpacedPortSpec);
            obj=obj@flexibleportplacement.dialog.SpecificationSection(spec);
        end

        function sectionItems=getSectionItems(obj)
            helpText=obj.createHelpText();
            controlButtonGroup=obj.createControlButtonGroup();
            moveButtonGroup=obj.createMoveButtonGroup();
            table=obj.createConnectorTable();

            sectionItems={helpText,controlButtonGroup,moveButtonGroup,table};
        end
    end







    methods(Access=private)

        function helpGroup=createHelpText(~)
            helpText.Type='text';
            helpText.WordWrap=true;
            helpText.Name=DAStudio.message('Simulink:dialog:FPPInstructions');


            helpGroup.Type='group';
            helpGroup.Items={helpText};
        end

        function controlButtonGroup=createControlButtonGroup(obj)
            defaultFontSize=[];
            revertButton=obj.createButton(DAStudio.message('Simulink:dialog:FPPRevertToDefault'),'revertToDefault',1,1,defaultFontSize);
            addSpacer=obj.createButton(DAStudio.message('Simulink:dialog:FPPAddSpacer'),'addSpacer',1,2,defaultFontSize);
            removeSpacer=obj.createButton(DAStudio.message('Simulink:dialog:FPPRemoveSpacer'),'removeSpacer',1,3,defaultFontSize);

            controlButtonGroup.Type='group';
            controlButtonGroup.Name=DAStudio.message('Simulink:dialog:FPPControlTitle');
            controlButtonGroup.LayoutGrid=[1,3];
            controlButtonGroup.Items={revertButton,addSpacer,removeSpacer};
        end

        function moveButtonGroup=createMoveButtonGroup(obj)
            arrowButtonFontSize=17;



            moveUpButton=obj.createButton(char(8593),'moveConnectorUp',1,2,arrowButtonFontSize);
            moveDownButton=obj.createButton(char(8595),'moveConnectorDown',3,2,arrowButtonFontSize);
            moveRightButton=obj.createButton(char(8594),'moveConnectorRight',2,3,arrowButtonFontSize);
            moveLeftButton=obj.createButton(char(8592),'moveConnectorLeft',2,1,arrowButtonFontSize);

            moveButtonGroup.Type='group';
            moveButtonGroup.Name=DAStudio.message('Simulink:dialog:FPPMovePortTitle');
            moveButtonGroup.LayoutGrid=[3,3];
            moveButtonGroup.Items={...
            moveUpButton,...
            moveDownButton,...
            moveLeftButton,...
            moveRightButton};
        end

        function button=createButton(obj,text,callbackMethod,row,col,fontSize)
            button.Type='pushbutton';
            button.Name=text;
            button.Source=obj;
            button.ObjectMethod=callbackMethod;
            button.Tag=callbackMethod;
            button.DialogRefresh=true;
            button.ColSpan=[col,col];
            button.RowSpan=[row,row];

            if~isempty(fontSize)
                button.FontPointSize=fontSize;
            end
        end

        function table=createConnectorTable(obj)
            table.Name=DAStudio.message('Simulink:dialog:FPPPortTableTitle');
            table.Type='table';
            table.Data=obj.getTableData();
            table.Tag=obj.TableTag;
            table.Size=obj.getTableSize();
            table.Editable=true;
            table.ColHeader=obj.getTableColumnHeader();
            table.ColumnCharacterWidth=obj.getTableColumnWidth();
            table.ItemClickedCallback=@(dlg,row,col,~)obj.ItemInTableClicked(dlg,row,col);
        end

        function header=getTableColumnHeader(obj)
            baseMsgID='Simulink:dialog:FPPPortTable';
            header=cellfun(@(side)DAStudio.message([baseMsgID,side]),...
            obj.SidesColumnOrder,...
            'UniformOutput',false);
        end

        function colWidth=getTableColumnWidth(obj)
            width=7;

            nCol=numel(obj.SidesColumnOrder);
            colWidth=width*ones(1,nCol);
        end

        function tableText=makeTableEntryForConnector(~,connector)

            if isempty(connector)
                text='';
            else
                text=connector.DisplayName;
            end









            tableText.Type='hyperlink';
            tableText.ForegroundColor=[0,0,0];
            tableText.Name=text;
        end

        function tableData=getTableData(obj)
            connectorMatrix=obj.getMatrixOfConnectorsForTable();

            tableData=cellfun(@(c)obj.makeTableEntryForConnector(c),connectorMatrix,'UniformOutput',false);
        end
    end





    methods
        function moveConnectorUp(obj)
            if~isempty(obj.SelectedConnector)
                obj.Specification.decreaseConnectorIndex(obj.SelectedConnector)
                obj.onTableChange();
            end
        end

        function moveConnectorDown(obj)
            if~isempty(obj.SelectedConnector)
                obj.Specification.increaseConnectorIndex(obj.SelectedConnector)
                obj.onTableChange();
            end
        end

        function moveConnectorRight(obj)
            obj.moveConnectorSidways(+1);
        end

        function moveConnectorLeft(obj)
            obj.moveConnectorSidways(-1);
        end

        function revertToDefault(obj)
            obj.Specification.revertToDefault();
            obj.onTableChange();
        end

        function addSpacer(obj)
            if~isempty(obj.SelectedColIdx)
                selectedSideStr=obj.SidesColumnOrder{obj.SelectedColIdx};
                selectedSide=ConnectorPlacement.RectSide.(selectedSideStr);
                obj.Specification.addSpacer(selectedSide);
                obj.onTableChange();
            end
        end

        function removeSpacer(obj)
            if~isempty(obj.SelectedConnector)
                obj.Specification.removeSpacer(obj.SelectedConnector);
                obj.onTableChange();
            end
        end

        function ItemInTableClicked(obj,~,ddgRow,ddgCol)

            row=ddgRow+1;
            col=ddgCol+1;

            obj.setSelectedConnector(row,col);
            obj.SelectedColIdx=col;

            obj.sanitizeTableSelection(ddgRow,ddgCol);
        end
    end





    methods(Access=private)
        function moveConnectorSidways(obj,moveAmount)
            if~isempty(obj.SelectedConnector)&&~isempty(obj.SelectedColIdx)


                currentColIdx=obj.SelectedColIdx;
                newColIdx=currentColIdx+moveAmount;


                if(newColIdx>numel(obj.SidesColumnOrder))
                    newColIdx=1;
                end
                if(newColIdx<1)
                    newColIdx=numel(obj.SidesColumnOrder);
                end


                newSideStr=obj.SidesColumnOrder{newColIdx};
                newSide=ConnectorPlacement.RectSide.(newSideStr);

                obj.Specification.moveConnectorToSide(obj.SelectedConnector,newSide);
                obj.onTableChange();
            end
        end

        function onTableChange(obj)
            obj.Dialog.enableApplyButton(true);
            obj.reselectConnector();
        end

        function reselectConnector(obj)




            tableOfConnectors=obj.getMatrixOfConnectorsForTable();
            connector=obj.SelectedConnector;

            isConnector=cellfun(...
            @(tableElement)(~isempty(tableElement)...
            &&~isempty(connector)...
            &&tableElement==connector),...
            tableOfConnectors);


            [row,col]=find(isConnector);

            if isempty(row)
                obj.clearSelection();
                return;
            end

            assert(isscalar(row));


            obj.SelectedColIdx=col;



            ddgRow=row-1;
            ddgCol=col-1;

            obj.Dialog.selectTableItem(obj.TableTag,ddgRow,ddgCol)
        end

        function clearSelection(obj)
            obj.Dialog.selectTableItem(obj.TableTag,-1,-1)
            obj.SelectedConnector=flexibleportplacement.connector.Connector.empty();
            obj.SelectedColIdx=[];
        end

        function setSelectedConnector(obj,row,col)
            connectorMatrix=obj.getMatrixOfConnectorsForTable();
            obj.SelectedConnector=connectorMatrix{row,col};
        end

        function sanitizeTableSelection(obj,ddgRow,ddgCol)




            obj.Dialog.selectTableItem(obj.TableTag,ddgRow,ddgCol)
        end

        function maxPortsPerSide=getMaxNumberOfPortsPerSide(obj)
            sideData=obj.Specification.SideData;
            portsOnSides=struct2cell(sideData);
            numPortsOnSide=cellfun(@numel,portsOnSides);
            maxPortsPerSide=max(numPortsOnSide);








            maxPortsPerSide=maxPortsPerSide+1;
        end

        function tSize=getTableSize(obj)
            maxPortsPerSide=obj.getMaxNumberOfPortsPerSide();
            nSides=numel(obj.SidesColumnOrder);
            tSize=[maxPortsPerSide,nSides];
        end

        function connectorMatrix=getMatrixOfConnectorsForTable(obj)
            maxPortsPerSide=obj.getMaxNumberOfPortsPerSide();
            numSides=numel(obj.SidesColumnOrder);

            sideData=obj.Specification.SideData;

            connectorMatrix=cell(maxPortsPerSide,numSides);

            for iSide=1:numSides
                side=obj.SidesColumnOrder{iSide};
                ports=sideData.(side);
                for iPorts=1:maxPortsPerSide
                    if iPorts>numel(ports)
                        connector=flexibleportplacement.connector.Connector.empty();
                    else
                        connector=ports(iPorts);
                    end
                    connectorMatrix(iPorts,iSide)={connector};
                end
            end
        end

    end
end


