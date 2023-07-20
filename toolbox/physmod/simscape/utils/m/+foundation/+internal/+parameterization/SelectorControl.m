classdef SelectorControl<handle




    properties
Model
View
    end

    properties(Access=private)
        BlockParamListenerHandle=event.listener.empty;
        ListenerHandles=event.listener.empty;
        InputHighlightStyle=uistyle('BackgroundColor',[175,218,255]./255);
ManufacturerNamesMap
SelectedManufacturerXMLName
    end

    methods
        function obj=SelectorControl(model,view)



            obj.Model=model;
            obj.View=view;


            if isvalid(obj.View)
                splitBlockPath=split(obj.Model.BlockPath,'/');
                blockName=splitBlockPath{end};
                obj.View.Title=strcat(...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:BlockParameterizationManager')),": ",...
                blockName);
            end

            internalObject=get_param(obj.Model.ModelName,'InternalObject');


            if isempty(obj.BlockParamListenerHandle)
                obj.createParameterSetListener();
            end


            obj.ListenerHandles(1)=listener(obj.Model,'ModelUpdated',@(source,event)obj.modelUpdated(source,event));
            obj.ListenerHandles(end+1)=listener(obj.Model,'StatusChanged',@obj.modelStatusChanged);
            obj.ListenerHandles(end+1)=listener(obj.Model,'EnableReset',@obj.enableReset);
            obj.ListenerHandles(end+1)=listener(internalObject,'SLGraphicalEvent::CLOSE_MODEL_EVENT',@(source,event)obj.deleteObject(source,event));
            obj.ListenerHandles(end+1)=listener(internalObject,'SLGraphicalEvent::REMOVE_BLOCK_MODEL_EVENT',@(source,event)obj.deleteObject(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View.SelectManufacturerDropdown,'ValueChanged',@obj.updateManufacturer);
            obj.ListenerHandles(end+1)=listener(obj.View.PartSpecUITable,'CellSelection',@obj.openManufacturerURL);
            obj.ListenerHandles(end+1)=listener(obj.View.ComparePartsUITable,'CellSelection',@obj.differenceTheBlock);
            obj.ListenerHandles(end+1)=listener(obj.View.CompareWithBlockUITable,'CellEdit',@obj.differenceTableCellEdited);
            obj.ListenerHandles(end+1)=listener(obj.View.DisplaySettingsAll,'ValueChanged',@(source,event)obj.settingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.DisplaySettingsVisible,'ValueChanged',@(source,event)obj.settingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.ApplyAllButton,'ButtonPushed',@obj.updateTheBlock);
            obj.ListenerHandles(end+1)=listener(obj.View.ResetAllButton,'ButtonPushed',@obj.resetBlockColumn);
            obj.ListenerHandles(end+1)=listener(obj.View.HighlightEditableColumnsButton,'ValueChanged',@(source,event)obj.highlightEditfields(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.HighlightDifferencesButton,'ValueChanged',@(source,event)obj.highlightTableCheckBoxChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View,'AppClosed',@obj.appClosed);


            notify(obj.Model,'ModelUpdated');
        end

        function value=get.SelectedManufacturerXMLName(obj)


            if~isempty(obj.ManufacturerNamesMap)
                matchingIdx=find(strcmp(obj.ManufacturerNamesMap(:,1),obj.Model.SelectedManufacturer));
                value=obj.ManufacturerNamesMap{matchingIdx,2};%#ok<*FNDSB>
            end
        end

        function createParameterSetListener(obj)


            blockName=get_param(obj.Model.BlockHandle,'name');
            blockParent=get_param(obj.Model.BlockHandle,'Parent');
            blockObject=get_param(...
            strcat(blockParent,'/',blockName),'Object');
            obj.BlockParamListenerHandle=listener(...
            blockObject,'SLGraphicalEvent::BLOCK_PARAMETER_CHANGE_EVENT',@(source,event)obj.blockParameterUpdated(source,event));
        end

        function modelStatusChanged(obj,~,~)


            if isvalid(obj.View)...
                &&isvalid(obj.View.StatusLabel)...
                &&~strcmp(obj.View.StatusLabel.Text,obj.Model.Status)
                obj.View.StatusLabel.Text=obj.Model.Status;
            end
        end

        function modelUpdated(obj,~,~)


            if isvalid(obj.View)


                availableManufacturers=obj.Model.AvailableManufacturers;
                availableParts=obj.Model.AvailableParts;

                if isempty(obj.View.SelectManufacturerDropdown.Items)
                    if~isempty(availableParts)
                        manufacturersXMLNameCell=availableParts{1,1}(2,:);
                        matchStrings=["_"," "];
                        erasedManufacturerNames=erase(availableManufacturers,matchStrings);
                        erasedManufacturerXMLNames=erase(manufacturersXMLNameCell,matchStrings);
                        equivalentManufacturerNames={};
                        for manufacturerIdx=1:length(availableManufacturers)


                            matchIdx=find(strcmp(erasedManufacturerXMLNames,erasedManufacturerNames(manufacturerIdx)));
                            if~isempty(matchIdx)
                                equivalentManufacturerNames=[equivalentManufacturerNames;manufacturersXMLNameCell(matchIdx(1))];%#ok<*AGROW>
                            end
                        end
                        equivalentManufacturerNames=[...
                        {getString(message('physmod:simscape:utils:BlockParameterizationManager:AllManufacturer'))};...
                        equivalentManufacturerNames];
                    else
                        equivalentManufacturerNames=availableManufacturers;
                    end
                    obj.ManufacturerNamesMap=[availableManufacturers,equivalentManufacturerNames];

                    for manufacturerIdx=1:length(availableManufacturers)
                        obj.View.SelectManufacturerDropdown.addItem(...
                        obj.ManufacturerNamesMap{manufacturerIdx,2});
                    end
                    obj.View.SelectManufacturerDropdown.SelectedIndex=1;
                    obj.View.SelectManufacturerDropdown.Value=...
                    getString(message(...
                    'physmod:simscape:utils:BlockParameterizationManager:AllManufacturer'));
                end


                if isvalid(obj.View.SelectManufacturerDropdown)...
                    &&~all(all(strcmp(obj.View.SelectManufacturerDropdown.Value,obj.SelectedManufacturerXMLName)))
                    obj.View.SelectManufacturerDropdown.Value=obj.SelectedManufacturerXMLName;
                end


                if isempty(obj.View.ComparePartsUITable.Data)||...
                    ~isequal(height(obj.View.ComparePartsUITable.Data(:,1)),...
                    length(availableParts{1}'))||...
                    ~all(strcmp(obj.View.ComparePartsUITable.Data{:,1},...
                    availableParts{1}'))

                    [variableNames,partData,row,column]=comparePartsTable(obj.Model);

                    if~isempty(partData)&&...
                        ~isempty(row)&&~isempty(column)


                        obj.View.ComparePartsUITable.Data=...
                        cell2table(partData,'VariableNames',variableNames);
                        addHighlight(obj.View.ComparePartsUITable,...
                        row,column,obj.InputHighlightStyle);
                        eventData=foundation.internal.common.model.EventData...
                        ([row(1),column(1)]);
                        differenceTheBlock(obj,eventData,eventData);
                    end
                end
            end
        end

        function HelpButtonPushed(~)

            helpview("sps","PreparameterizedComponents");
        end

        function deleteObject(obj,~,~)



            if isvalid(obj.View)&&~strcmp(obj.View.State,'TERMINATED')
                delete(obj.Model);
                delete(obj.View);
                delete(obj.BlockParamListenerHandle);
                obj.delete;
            end
        end

        function appClosed(obj,~,~)

            delete(obj.BlockParamListenerHandle);
        end




























        function updateManufacturer(obj,~,~)




            if~isempty(obj.ManufacturerNamesMap)
                matchingIdx=find(strcmp(obj.ManufacturerNamesMap(:,2),obj.View.SelectManufacturerDropdown.Value));
                obj.Model.SelectedManufacturer=obj.ManufacturerNamesMap{matchingIdx,1};
            end

            obj.Model.SelectedPart=obj.Model.AvailableParts{1}{1};
            notify(obj.Model,'ModelUpdated');
        end











        function updateTheBlock(obj,~,~)
            if~isempty(obj.Model.Index)



                delete(obj.BlockParamListenerHandle);
                obj.Model.updateBlockWithParameters;
                obj.createParameterSetListener();
                tableData=obj.updateCompareWithBlockTable();
                tableData=obj.checkVisibility(tableData);
                obj.View.CompareWithBlockUITable.Data=tableData;
                obj.checkBlockTag();
                obj.checkButtonStatus();
            end
        end

        function tableData=updateCompareWithBlockTable(obj,~)

            switch nargin
            case 1
                tableData=obj.Model.differenceBlockWithParameters;
            case 2
                tableData=obj.Model.differenceBlockWithParameters('REFRESH');
            end
        end

        function resetBlockColumn(obj,~,~)


            tableData=obj.View.CompareWithBlockUITable.Data;
            tableData=obj.checkVisibility(tableData);



            obj.BlockParamListenerHandle.Enabled=false;

            tableData=obj.Model.updateBlockColumn(tableData);
            obj.View.CompareWithBlockUITable.Data=tableData;


            obj.BlockParamListenerHandle.Enabled=true;

            obj.disableResetAllButton();
            obj.checkBlockTag();
        end

        function openManufacturerURL(~,~,eventData)


            if~isempty(eventData.Indices)&&...
                isequal(eventData.Source.Data{eventData.Indices(1)},...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:WebLink')))
                manufacturerURL=eventData.Source.Data{eventData.Indices(1),...
                eventData.Indices(2)};
                if~contains(manufacturerURL,"www")
                    manufacturerURL=strcat("www.",manufacturerURL);
                end
                if~contains(manufacturerURL,["https","http"])
                    manufacturerURL=strcat("https://",manufacturerURL);
                end
                web(manufacturerURL);
            end
        end

        function differenceTheBlock(obj,~,eventData)


            if isprop(eventData,'Indices')&&~isempty(eventData.Indices)||...
                isprop(eventData,'Payload')
                obj.View.StatusLabel.Text='';


                if isprop(eventData,'Indices')
                    obj.Model.Index=eventData.Indices(1);

                    row=ones(width(...
                    obj.View.ComparePartsUITable.Data),1)*eventData.Indices(1);
                    column=(1:width(obj.View.ComparePartsUITable.Data))';
                    addHighlight(obj.View.ComparePartsUITable,...
                    row,column,obj.InputHighlightStyle);
                else

                    obj.Model.Index=eventData.Payload(1);
                end


                tableData=obj.updateCompareWithBlockTable();
                tableData=obj.checkVisibility(tableData);
                obj.View.CompareWithBlockUITable.Data=tableData;
                obj.checkButtonStatus();
                if~contains(obj.View.CompareWithBlockUITable.ColumnName{obj.Model.DifferenceTableColumnOrder.ParamValue},':')
                    obj.checkBlockTag();
                end
                obj.View.CompareWithBlockUITable.ColumnName{obj.Model.DifferenceTableColumnOrder.PartValue}=strcat(...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartValue')),...
                ':',obj.Model.SelectedPart);


                tableDataModel=obj.Model.TableData;

                if length(obj.View.PartSpecUITable.Data)~=length(tableDataModel)||...
                    ~all(all(strcmp(obj.View.PartSpecUITable.Data,tableDataModel)))
                    obj.View.PartSpecUITable.Data=tableDataModel;
                    obj.View.PartSpecUITable.ColumnWidth={200,2048};
                end
            end
        end

        function checkButtonStatus(obj)

            if~isempty(obj.View.CompareWithBlockUITable.Data)
                if all(~obj.View.CompareWithBlockUITable.Data{:,obj.Model.DifferenceTableColumnOrder.Override})
                    if obj.View.ApplyAllButton.Enabled
                        obj.disableApplyAllButton();
                    end
                else
                    if~obj.View.ApplyAllButton.Enabled
                        obj.View.ApplyAllButton.Enabled=true;
                    end
                end
            end
        end

        function checkBlockTag(obj)



            if~isempty(obj.View.CompareWithBlockUITable.Data)
                if obj.View.DisplaySettingsAll.Value&&...
                    all(~obj.View.CompareWithBlockUITable.Data{:,obj.Model.DifferenceTableColumnOrder.Override})



                    obj.View.CompareWithBlockUITable.ColumnName{obj.Model.DifferenceTableColumnOrder.ParamValue}=strcat(...
                    getString(message('physmod:simscape:utils:BlockParameterizationManager:PresentBlockValue')),...
                    ':',obj.Model.SelectedPart);
                    obj.Model.setBlockLinkWithPart();
                else
                    obj.View.CompareWithBlockUITable.ColumnName{obj.Model.DifferenceTableColumnOrder.ParamValue}=getString(...
                    message('physmod:simscape:utils:BlockParameterizationManager:PresentBlockValue'));
                end
            end
        end

        function differenceTableCellEdited(obj,~,eventData)



            if obj.View.HighlightDifferencesButton.Value
                obj.disableHighlightDifferencesButton();
                obj.highlightTableCheckBoxChanged();

            end
            if obj.View.HighlightEditableColumnsButton.Value
                obj.disableHighlightEditableColumnsButton();
                obj.highlightEditfields();
            end

            tableData=eventData.Source.Data;
            shortparamNames=obj.Model.BlockInformation.Row;
            if obj.View.DisplaySettingsVisible.Value&&...
                isequal(height(shortparamNames),...
                length(obj.Model.BlockInformation.Properties.CustomProperties.Visible))
                shortparamNames=shortparamNames(obj.Model.BlockInformation.Properties.CustomProperties.Visible);
            end
            switch eventData.Indices(2)
            case obj.Model.DifferenceTableColumnOrder.Override

                rowIdx=eventData.Indices(1);
                if~eventData.NewData

                    tableData(rowIdx,...
                    obj.Model.DifferenceTableColumnOrder.ParamValue)=...
                    tableData(rowIdx,obj.Model.DifferenceTableColumnOrder.PartValue);
                    tableData{rowIdx,...
                    obj.Model.DifferenceTableColumnOrder.Override}=false;

                    paramName=shortparamNames{rowIdx};
                    paramValue=tableData{rowIdx,obj.Model.DifferenceTableColumnOrder.ParamValue};
                    obj.Model.updateBlockParameter(paramName,paramValue);
                else

                    tableData{rowIdx,obj.Model.DifferenceTableColumnOrder.Override}=false;
                end
            case obj.Model.DifferenceTableColumnOrder.ParamValue

                rowIdx=eventData.Indices(1);

                paramName=shortparamNames{rowIdx};
                paramValue=eventData.NewData;

                obj.Model.updateBlockParameter(paramName,paramValue);
                tableData{:,obj.Model.DifferenceTableColumnOrder.Override}=...
                ~strcmp(tableData{:,obj.Model.DifferenceTableColumnOrder.PartValue},...
                tableData{:,obj.Model.DifferenceTableColumnOrder.ParamValue});
            end
            obj.View.CompareWithBlockUITable.Data=tableData;
            obj.checkBlockTag();
            obj.checkButtonStatus();
            obj.enableResetAllButton;
        end

        function settingsChanged(obj,~,~)



            if obj.View.HighlightDifferencesButton.Value
                obj.disableHighlightDifferencesButton();
                obj.highlightTableCheckBoxChanged();

            end
            if obj.View.HighlightEditableColumnsButton.Value
                obj.disableHighlightEditableColumnsButton();
                obj.highlightEditfields();
            end

            tableData=obj.Model.differenceBlockWithParameters();
            tableData=obj.checkVisibility(tableData);
            obj.View.CompareWithBlockUITable.Data=tableData;
            obj.checkBlockTag();
        end

        function tableData=checkVisibility(obj,tableData)



            if obj.View.DisplaySettingsVisible.Value&&...
                isequal(height(tableData),...
                length(obj.Model.BlockInformation.Properties.CustomProperties.Visible))
                visibleIdx=obj.Model.BlockInformation.Properties.CustomProperties.Visible;
                tableData=tableData(visibleIdx,:);
            end
        end

        function blockParameterUpdated(obj,~,~)




            if obj.View.HighlightDifferencesButton.Value||...
                obj.View.HighlightEditableColumnsButton.Value
                if~isempty(obj.View.CompareWithBlockUITable.StyleConfigurations)
                    styleIndex=find(isequal(...
                    obj.View.CompareWithBlockUITable.StyleConfigurations{:,"Style"},obj.InputHighlightStyle));
                    obj.View.CompareWithBlockUITable.removeStyle(styleIndex);
                    obj.View.HighlightDifferencesButton.Value=false;
                    obj.View.HighlightEditableColumnsButton.Value=false;
                end
            end


            tableData=obj.updateCompareWithBlockTable('REFRESH');
            tableData=obj.checkVisibility(tableData);
            obj.View.CompareWithBlockUITable.Data=tableData;
            obj.checkBlockTag();
            obj.checkButtonStatus();
            obj.View.CompareWithBlockUITable.ColumnName{obj.Model.DifferenceTableColumnOrder.PartValue}=strcat(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:PartValue')),...
            ':',obj.Model.SelectedPart);
            obj.enableResetAllButton;
        end

        function highlightEditfields(obj,~,~)


            if obj.View.HighlightEditableColumnsButton.Value
                editableColumns=find(obj.View.CompareWithBlockUITable.ColumnEditable);
                rows=height(obj.View.CompareWithBlockUITable.Data);
                [rowVector,columnVector]=obj.Model.highlightEditableColumns(rows,editableColumns);
                addHighlight(obj.View.CompareWithBlockUITable,rowVector,columnVector,obj.InputHighlightStyle);
            else
                obj.View.CompareWithBlockUITable.removeStyle;
                obj.View.StatusLabel.Text='';
            end


            if obj.View.HighlightDifferencesButton.Value
                obj.disableHighlightDifferencesButton();
            end
        end

        function highlightTableCheckBoxChanged(obj,~,~)


            if obj.View.HighlightDifferencesButton.Value
                tableData=obj.View.CompareWithBlockUITable.Data;

                [row,column]=obj.Model.highlightCellsInCompareWithBlock(tableData);
                addHighlight(obj.View.CompareWithBlockUITable,row,column,obj.InputHighlightStyle);
            else
                obj.View.CompareWithBlockUITable.removeStyle;
                obj.View.StatusLabel.Text='';
            end


            if obj.View.HighlightEditableColumnsButton.Value
                obj.disableHighlightEditableColumnsButton();
            end
        end

        function enableResetAllButton(obj)
            if~obj.View.ResetAllButton.Enabled
                obj.View.ResetAllButton.Enabled=true;
            end
        end

        function enableReset(obj,~,~)

            obj.enableResetAllButton;
        end

        function disableResetAllButton(obj)
            if obj.View.ResetAllButton.Enabled
                obj.View.ResetAllButton.Enabled=false;
            end
            if~obj.View.ApplyAllButton.Enabled
                obj.View.ApplyAllButton.Enabled=true;
            end
        end

        function disableApplyAllButton(obj)
            obj.View.ApplyAllButton.Enabled=false;
        end

        function disableHighlightEditableColumnsButton(obj)
            obj.View.HighlightEditableColumnsButton.Value=false;
        end

        function disableHighlightDifferencesButton(obj)
            obj.View.HighlightDifferencesButton.Value=false;
        end















































































    end
end
function addHighlight(tableToHighlight,row,column,highlightStyle)
    if~isempty(tableToHighlight.StyleConfigurations)
        styleIndex=find(isequal(tableToHighlight.StyleConfigurations{:,"Style"},highlightStyle));
    end

    tableToHighlight.addStyle(highlightStyle,'cell',[row,column]);

    if exist('styleIndex','var')&&~isempty(styleIndex)
        tableToHighlight.removeStyle(styleIndex);
    end
end