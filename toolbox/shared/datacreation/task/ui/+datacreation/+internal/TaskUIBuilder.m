classdef(Hidden)TaskUIBuilder<handle





    properties(Access=public)

app

    end


    methods(Access=public)


        function obj=TaskUIBuilder(inApp)
            obj.app=inApp;
        end


        function buildUI(obj,containerParent)

            createTaskContainer(obj,containerParent);
            createStorageSection(obj);
            createDataCreationTools(obj);
            createStoragePropertiesSection(obj);
            createDisplayResultsSection(obj);

        end


        function setContainerVisible(obj,visibleState)



        end


        function setFigureName(obj)
            obj.app.getParent().Name=message('datacreation:datacreation:DataCreationLiveTask_Label').getString;
        end

    end


    methods(Access=protected)


        function createTaskContainer(obj,containerParent)

            obj.app.UIComponents.FigureGrid=uigridlayout(containerParent);
            obj.app.UIComponents.FigureGrid.ColumnWidth={'fit'};
            obj.app.UIComponents.FigureGrid.RowHeight={'fit','fit','fit','fit'};
            obj.app.UIComponents.FigureGrid.Padding=[0,0,0,0];
            obj.app.UIComponents.FigureGrid.RowSpacing=0;
        end


        function createStorageSection(obj)


            obj.app.UIComponents.StorageAccordion=matlab.ui.container.internal.Accordion('Parent',obj.app.UIComponents.FigureGrid);

            obj.app.UIComponents.StorageAccordionPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.app.UIComponents.StorageAccordion);
            obj.app.UIComponents.StorageAccordionPanel.Title=message('datacreation:datacreation:storageTypeLabel').getString;

            obj.app.UIComponents.StorageGrid=uigridlayout(obj.app.UIComponents.StorageAccordionPanel);
            obj.app.UIComponents.StorageGrid.ColumnWidth={'fit'};
            obj.app.UIComponents.StorageGrid.RowHeight={'fit'};

            obj.app.UIComponents.StorageDropDown=uidropdown(obj.app.UIComponents.StorageGrid);
            obj.app.UIComponents.StorageDropDown.Items=getStorageSupportedItems(obj);

            obj.app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:timeseriesButtonLabel').getString;
            obj.app.UIComponents.StorageDropDown.Tooltip=message('datacreation:datacreation:variableTypeTooltip').getString;
        end


        function itemsSupported=getStorageSupportedItems(obj)



            itemsSupported={...
            message('datacreation:datacreation:dataArrayButtonLabel').getString,...
            message('datacreation:datacreation:timeseriesButtonLabel').getString,...
            message('datacreation:datacreation:timeTableButtonLabel').getString,...
            message('datacreation:datacreation:vectorButtonLabel').getString};


        end


        function createStoragePropertiesSection(obj)

            obj.app.UIComponents.StoragePropAccordion=matlab.ui.container.internal.Accordion('Parent',obj.app.UIComponents.FigureGrid);
            obj.app.UIComponents.StoragePropAccordionPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.app.UIComponents.StoragePropAccordion);
            obj.app.UIComponents.StoragePropAccordionPanel.Title=message('datacreation:datacreation:storagePropertiesLabel').getString;

            obj.app.UIComponents.StoragePropGrid=uigridlayout(obj.app.UIComponents.StoragePropAccordionPanel);
            obj.app.UIComponents.StoragePropGrid.ColumnWidth={'fit','fit','fit','fit'};
            obj.app.UIComponents.StoragePropGrid.RowHeight={'fit','fit'};

            obj.app.UIComponents.VectorTypeDropDownLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.VectorTypeDropDownLabel.HorizontalAlignment='left';
            obj.app.UIComponents.VectorTypeDropDownLabel.Text=message('datacreation:datacreation:storageTypeVectorDropDownLabel').getString;

            obj.app.UIComponents.VectorTypeDropDown=uidropdown(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.VectorTypeDropDown.Items={...
            message('datacreation:datacreation:vectorTypeRow').getString,...
            message('datacreation:datacreation:vectorTypeColumn').getString};
            obj.app.UIComponents.VectorTypeDropDown.Enable=matlab.lang.OnOffSwitchState.off;

            obj.app.UIComponents.VectorTypeDropDown.Value=message('datacreation:datacreation:vectorTypeColumn').getString;
            obj.app.UIComponents.VectorTypeDropDown.Tooltip=message('datacreation:datacreation:storageTypeVectorDropDownTip').getString;

            createDataTypeLabelAndWidget(obj);

            obj.app.UIComponents.ColumnNameLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.ColumnNameLabel.Text=...
            message('datacreation:datacreation:tableVarName').getString;

            obj.app.UIComponents.ColumnNameLabel.Visible=false;

            obj.app.UIComponents.ColumnNameField=uieditfield(obj.app.UIComponents.StoragePropGrid);

            obj.app.UIComponents.ColumnNameField.Value='Var1';
            obj.app.UIComponents.ColumnNameField.Visible=false;
            obj.app.UIComponents.ColumnNameField.Tooltip=message('datacreation:datacreation:tableVarNameEditTip').getString;

            obj.app.UIComponents.TimeDurationLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.TimeDurationLabel.Text=message('datacreation:datacreation:timeTableDurationLabel').getString;

            obj.app.UIComponents.TimeDurationLabel.Visible=false;

            obj.app.UIComponents.DurationDropDown=uidropdown(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.DurationDropDown.Items={...
            message('datacreation:datacreation:secondsDurationType').getString...
            ,message('datacreation:datacreation:minutesDurationType').getString...
            ,message('datacreation:datacreation:hoursDurationType').getString...
            ,message('datacreation:datacreation:daysDurationType').getString...
            ,message('datacreation:datacreation:yearsDurationType').getString};

            obj.app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:secondsDurationType').getString;
            obj.app.UIComponents.DurationDropDown.Visible=false;
            obj.app.UIComponents.DurationDropDown.Tooltip=message('datacreation:datacreation:timeTableDurationTip').getString;
        end


        function createDataTypeLabelAndWidget(obj)
            createDataTypeLabel(obj);
            createDataTypeWidget(obj);

        end


        function createDataTypeLabel(obj)
            obj.app.UIComponents.DataTypeDropDownLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.DataTypeDropDownLabel.HorizontalAlignment='left';
            obj.app.UIComponents.DataTypeDropDownLabel.Text=getDataTypeLabelStr(obj);
        end


        function msgOut=getDataTypeLabelStr(~)
            msgOut=message('datacreation:datacreation:dataTypeVectorDropDownLabel').getString;
        end


        function createDataTypeWidget(obj)
            obj.app.UIComponents.DataTypeDropDown=uidropdown(obj.app.UIComponents.StoragePropGrid);

            obj.app.UIComponents.DataTypeDropDown.Items={message('datacreation:datacreation:doubleDataType').getString...
            ,message('datacreation:datacreation:singleDataType').getString...
            ,message('datacreation:datacreation:halfDataType').getString...
            ,message('datacreation:datacreation:uint8DataType').getString...
            ,message('datacreation:datacreation:int8DataType').getString...
            ,message('datacreation:datacreation:uint16DataType').getString...
            ,message('datacreation:datacreation:int16DataType').getString...
            ,message('datacreation:datacreation:uint32DataType').getString...
            ,message('datacreation:datacreation:int32DataType').getString...
            ,message('datacreation:datacreation:uint64DataType').getString...
            ,message('datacreation:datacreation:int64DataType').getString
            };

            obj.app.UIComponents.DataTypeDropDown.Tooltip=message('datacreation:datacreation:dataTypeToolTip').getString;
        end


        function createDataCreationTools(obj)

            obj.app.UIComponents.DataCreationAccordion=matlab.ui.container.internal.Accordion('Parent',obj.app.UIComponents.FigureGrid);
            obj.app.UIComponents.DataCreationAccordionPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.app.UIComponents.DataCreationAccordion);
            obj.app.UIComponents.DataCreationAccordionPanel.Title=message('datacreation:datacreation:dataCreationToolsLabel').getString;

            obj.app.UIComponents.ToolsGrid=uigridlayout(obj.app.UIComponents.DataCreationAccordionPanel);
            obj.app.UIComponents.ToolsGrid.ColumnWidth={650,200};
            obj.app.UIComponents.ToolsGrid.RowHeight={350};
            obj.app.UIComponents.ToolsGrid.Padding(1)=0;
            obj.app.UIComponents.ToolsGrid.ColumnSpacing=0;




            obj.app.UIComponents.DrawDataWidget=datacreation.internal.UIDatacreation(obj.app.UIComponents.ToolsGrid);

            obj.app.UIComponents.DrawDataWidget.Layout.Row=1;
            obj.app.UIComponents.DrawDataWidget.Layout.Column=1;

            obj.app.UIComponents.TableGrid=uigridlayout(obj.app.UIComponents.ToolsGrid);
            obj.app.UIComponents.TableGrid.ColumnWidth={200};
            obj.app.UIComponents.TableGrid.RowHeight={323};
            obj.app.UIComponents.TableGrid.Padding=[0,0,0,0];
            obj.app.UIComponents.TableGrid.ColumnSpacing=0;


            obj.app.UIComponents.UITable=uitable(obj.app.UIComponents.TableGrid);
            obj.app.UIComponents.UITable.ColumnName={...
            message('datacreation:datacreation:tableDataColumn').getString...
            };
            obj.app.UIComponents.UITable.RowName={};
            obj.app.UIComponents.UITable.Layout.Row=1;
            obj.app.UIComponents.UITable.Layout.Column=1;
            obj.app.UIComponents.UITable.ColumnEditable=true;

            dataColumnFormat=getTableDataColumnFormat(obj);
            obj.app.UIComponents.UITable.ColumnFormat=dataColumnFormat;

            s=uistyle('HorizontalAlignment','left');
            obj.app.UIComponents.UITable.addStyle(s);

        end


        function dataColumnFormat=getTableDataColumnFormat(obj)
            dataColumnFormat={'numeric'};
        end


        function createDisplayResultsSection(obj)

            obj.app.UIComponents.DisplayResultsAccordion=matlab.ui.container.internal.Accordion('Parent',obj.app.UIComponents.FigureGrid);
            obj.app.UIComponents.DisplayResultsAccordionPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.app.UIComponents.DisplayResultsAccordion);
            obj.app.UIComponents.DisplayResultsAccordionPanel.Title=message('datacreation:datacreation:displayResults').getString;

            obj.app.UIComponents.ResultsGrid=uigridlayout(obj.app.UIComponents.DisplayResultsAccordionPanel);
            obj.app.UIComponents.ResultsGrid.ColumnWidth={'fit'};
            obj.app.UIComponents.ResultsGrid.RowHeight={'fit'};

            obj.app.UIComponents.DisplayPlotCheck=uicheckbox(obj.app.UIComponents.ResultsGrid);
            obj.app.UIComponents.DisplayPlotCheck.Text=message('datacreation:datacreation:plotResults').getString;
        end


        function l=buildSectionHeader(~,parent,title)
            l=uilabel(parent);
            l.Text=title;
            l.FontWeight='bold';
        end

    end
end
