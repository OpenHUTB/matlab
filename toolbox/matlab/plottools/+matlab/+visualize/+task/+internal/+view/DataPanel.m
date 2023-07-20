classdef(Hidden)DataPanel<matlab.visualize.task.internal.view.VisualizeDataBaseView







    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase})
        DataGrid matlab.ui.container.GridLayout
        DataSubGrid matlab.ui.container.GridLayout
        ConfigurationGrid matlab.ui.container.GridLayout
        DataMainGrid matlab.ui.container.GridLayout
        RequiredLabelGrid matlab.ui.container.GridLayout
    end

    events

DataSelectionChanged

ConfigurationChanged
    end

    properties(Access=?hVisualizeTaskBase,Constant)
        SELECT_VAR="select variable"
        DEFAULT_VALUE="default value"
        DATASELECTION_EVENT="DataSelectionChanged"
        CONFIGSELECTION_EVENT="ConfigurationChanged"
        REMOVE_BUTTON="removeButton"
        ADD_BUTTON="addButton"
        ROW_HEIGHT=23
    end

    methods

        function obj=DataPanel(parentContainer,model)
            obj@matlab.visualize.task.internal.view.VisualizeDataBaseView(parentContainer,model);
        end


        function updateView(obj,model)
            obj.Model=model.DataModel;
            if~isempty(obj.Model.ConfigurationNames)

                obj.createOrUpdateConfigurationDropDown();
            else
                obj.deleteConfigurationGridIfNeeded();
            end
            obj.updateDataView();
        end





        function updateSubView(obj,model)
            obj.Model=model.DataModel;


            obj.updateWarningIconIfNeeded();

            obj.updateDataView();
        end

        function config=getSelectedConfiguration(obj)
            config='';
            if~isempty(obj.ConfigurationGrid)
                configDrpDown=findobj(obj.ConfigurationGrid,'-isa','matlab.ui.control.DropDown','Tag','1');
                config=configDrpDown.Value;
            end
        end
    end

    methods(Access=protected)

        function createComponents(obj)
            obj.DataMainGrid=uigridlayout(obj.ParentContainer,'ColumnWidth',{'fit','fit'},...
            'RowHeight',{'fit'},...
            'Padding',[0,0,0,0],...
            'ColumnSpacing',0);


            obj.DataSubGrid=uigridlayout(obj.DataMainGrid,'ColumnWidth',{'fit','fit'},...
            'RowHeight',{'fit'},...
            'RowSpacing',0,...
            'Padding',[0,0,0,0],...
            'ColumnSpacing',obj.Padding);
            obj.DataSubGrid.Layout.Row=1;
            obj.DataSubGrid.Layout.Column=1;

            obj.DataGrid=uigridlayout(obj.DataSubGrid,'Padding',[0,0,0,0]);
            obj.DataGrid.Layout.Row=1;
            obj.DataGrid.Layout.Column=1;
            obj.RequiredLabelGrid=uigridlayout(obj.DataSubGrid,'Padding',[0,0,0,0]);
            obj.RequiredLabelGrid.Layout.Row=1;
            obj.RequiredLabelGrid.Layout.Column=2;
        end



        function deleteConfigurationGridIfNeeded(obj)
            if~isempty(obj.ConfigurationGrid)&&isvalid(obj.ConfigurationGrid)&&~isempty(obj.ConfigurationGrid.Children)
                delete(obj.ConfigurationGrid.Children);
                delete(obj.ConfigurationGrid);
            end
            obj.DataSubGrid.Layout.Row=1;
        end



        function createEmptyDataRow(obj)
            delete(obj.DataGrid.Children);
            delete(obj.RequiredLabelGrid.Children);
            obj.DataGrid.ColumnWidth={'fit','fit',obj.IconSize};
            obj.RequiredLabelGrid.ColumnWidth={'fit'};
            obj.DataGrid.RowHeight={obj.RowHeight};
            obj.RequiredLabelGrid.RowHeight={obj.RowHeight};

            tagString='1';
            dataLabel=uilabel(obj.DataGrid,'Tag',tagString);
            dataLabel.Layout.Row=1;
            dataLabel.Layout.Column=1;
            dataLabel.Text=getString(message('MATLAB:graphics:visualizedatatask:DataLabel'));

            primaryDropDown=matlab.ui.control.internal.model.WorkspaceDropDown('Parent',obj.DataGrid,...
            'Tag',tagString);
            primaryDropDown.Layout.Row=1;
            primaryDropDown.Layout.Column=2;
            primaryDropDown.ValueChangedFcn=@(e,d)obj.dataDropdownChanged(primaryDropDown.Tag,d.Value,d.PreviousValue);

            addButton=uiimage(obj.DataGrid,...
            'ScaleMethod','none',...
            'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
            'Enable','off',...
            'UserData',obj.ADD_BUTTON,...
            'Tag',tagString,...
            'ImageClickedFcn',@(e,d)obj.addRow(d));
            addButton.Layout.Row=1;
            addButton.Layout.Column=3;
        end


        function valueChanged(~,~,~)

        end
    end

    methods(Access=?hVisualizeTaskBase)

        function model=getModel(obj)
            model=obj.Model;
        end


        function addRow(obj,d)
            prevRowInd=str2double(d.Source.Tag);

            newdataRow=obj.Model.addDataRowAtIndex(prevRowInd);


            obj.addNewRowInView(newdataRow,prevRowInd+1);
        end



        function addNewRowInView(obj,dataRow,rowInd)

            totalRows=numel(obj.Model.getAllDataRows());
            obj.DataGrid.RowHeight=num2cell(repmat(22,1,totalRows));
            obj.RequiredLabelGrid.RowHeight=num2cell(repmat(22,1,totalRows));
            hasTableRow=obj.Model.hasTableDataRow();


            for i=totalRows:-1:rowInd+1
                idx=num2str(i-1);
                newRowTag=num2str(i);
                allRowComponents=findobj(obj.DataGrid,'Tag',idx);
                for j=1:numel(allRowComponents)
                    rowComp=allRowComponents(j);
                    rowComp.Tag=newRowTag;
                    rowComp.Layout.Row=i;
                end

                allRequiredComponents=findobj(obj.RequiredLabelGrid,'Tag',idx);
                for j=1:numel(allRequiredComponents)
                    rowComp=allRequiredComponents(j);
                    rowComp.Tag=newRowTag;
                    rowComp.Layout.Row=i;
                end
            end

            rowTag=num2str(rowInd);
            uiNum=1;


            dataLabel=uilabel(obj.DataGrid,'Text','','Tag',rowTag);
            dataLabel.Layout.Row=rowInd;
            dataLabel.Layout.Column=1;
            uiNum=uiNum+1;


            primaryDropDown=matlab.ui.control.internal.model.WorkspaceDropDown('Parent',obj.DataGrid,...
            'UseDefaultAsPlaceholder',false,...
            'FilterVariablesFcn',@(x)obj.Model.filterWorkspaceVariables(x,dataRow.MappedChannel),...
            'Tag',rowTag);
            primaryDropDown.ValueChangedFcn=@(e,d)obj.dataDropdownChanged(primaryDropDown.Tag,d.Value,d.PreviousValue);
            primaryDropDown.Layout.Row=rowInd;
            primaryDropDown.Layout.Column=uiNum;
            uiNum=uiNum+1;
            if obj.hasVariableSelected(dataRow)
                if~any(strcmp(primaryDropDown.ItemsData,dataRow.WorkspaceVarName))
                    primaryDropDown.ItemsData{end+1}=dataRow.WorkspaceVarName;
                    primaryDropDown.Items{end+1}=dataRow.WorkspaceVarName;
                end
                primaryDropDown.Value=dataRow.WorkspaceVarName;
            end

            if dataRow.IsTabular
                varDropDown=uidropdown(obj.DataGrid,'Tag',rowTag,...
                'ValueChangedFcn',@(e,d)obj.tableColumnSelected(d));
                obj.Model.fetchTabularDropDownItems(varDropDown,dataRow.WorkspaceVarName,dataRow.MappedChannel);
                varDropDown.DropDownOpeningFcn=@(e,d)obj.updateTableVariableDrpDown(varDropDown,dataRow.WorkspaceVarName,dataRow.MappedChannel);
                varDropDown.Layout.Row=rowInd;
                varDropDown.Layout.Column=uiNum;
            end
            if hasTableRow
                uiNum=uiNum+1;
            end

            removeButton=uiimage(obj.DataGrid,...
            'ScaleMethod','none',...
            'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','remove.png'),...
            'Enable','on',...
            'Tag',rowTag,...
            'UserData',obj.REMOVE_BUTTON,...
            'ImageClickedFcn',@(e,d)obj.removeRow(d));
            removeButton.Layout.Row=rowInd;
            removeButton.Layout.Column=uiNum;
            uiNum=uiNum+1;

            addButton=uiimage(obj.DataGrid,...
            'ScaleMethod','none',...
            'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
            'Enable','on',...
            'Tag',rowTag,...
            'UserData',obj.ADD_BUTTON,...
            'ImageClickedFcn',@(e,d)obj.addRow(d));
            addButton.Layout.Row=rowInd;
            addButton.Layout.Column=uiNum;
        end


        function hasVar=hasVariableSelected(obj,dataRow)
            hasVar=~strcmpi(dataRow.WorkspaceVarName,obj.SELECT_VAR)&&...
            ~strcmpi(dataRow.WorkspaceVarName,obj.DEFAULT_VALUE);
        end


        function removeRow(obj,d)
            rowTag=d.Source.Tag;


            obj.Model.removeDataRowAtIndex(str2double(d.Source.Tag));


            obj.removeRowInView(rowTag);


            notify(obj,obj.DATASELECTION_EVENT);
        end



        function removeRowInView(obj,rowTag)

            rowInd=str2double(rowTag);
            totalRows=numel(obj.Model.getAllDataRows());
            if totalRows==0
                obj.createEmptyDataRow();
                return;
            end


            delete(findobj(obj.DataGrid,'Tag',rowTag));
            delete(findobj(obj.RequiredLabelGrid,'Tag',rowTag));


            for i=rowInd+1:(totalRows+1)
                newRowInd=i-1;
                allComp=findobj(obj.DataGrid,'Tag',num2str(i));
                set(allComp,'Tag',num2str(newRowInd));
                for j=1:numel(allComp)
                    allComp(j).Layout.Row=newRowInd;
                end

                allComp=findobj(obj.RequiredLabelGrid,'Tag',num2str(i));
                set(allComp,'Tag',num2str(newRowInd));
                for j=1:numel(allComp)
                    allComp(j).Layout.Row=newRowInd;
                end
            end

            dataLabel=findobj(obj.DataGrid,'-isa','matlab.ui.control.Label','Tag','1');

            if isempty(dataLabel.Text)
                dataLabel.Text=getString(message('MATLAB:graphics:visualizedatatask:DataLabel'));
            end

            obj.DataGrid.RowHeight=num2cell(repmat(22,1,totalRows));
            obj.RequiredLabelGrid.RowHeight=num2cell(repmat(22,1,totalRows));
        end


        function dataDropdownChanged(obj,tagStr,newValue,previousValue)
            selectedVarName=string(newValue);
            rowInd=str2double(tagStr);


            hadTableRow=obj.Model.hasTableDataRow();
            dataRow=obj.Model.updateDataRow(selectedVarName,rowInd);

            doPreSelect=obj.updateDataRowInView(dataRow,hadTableRow,rowInd);

            donotNotify=dataRow.IsTabular&&...
            (strcmpi(previousValue,obj.SELECT_VAR)||strcmpi(previousValue,obj.DEFAULT_VALUE));
            if~donotNotify||doPreSelect
                notify(obj,obj.DATASELECTION_EVENT);
            end
        end

        function doPreSelect=updateDataRowInView(obj,dataRow,hadTableRow,rowInd)

            rowTag=num2str(rowInd);
            hasTableRow=obj.Model.hasTableDataRow();
            totalRows=numel(obj.Model.getAllDataRows());

            tableVarDropDown=findobj(obj.DataGrid,'Tag',rowTag,'-isa','matlab.ui.control.DropDown');
            doPreSelect=false;
            doNotify=false;
            mappedChannel=dataRow.MappedChannel;


            obj.updateWarningIconIfNeeded();

            if dataRow.IsTabular
                if~hadTableRow
                    if isempty(mappedChannel)
                        obj.DataGrid.ColumnWidth={'fit','fit','fit',obj.IconSize,obj.IconSize};
                    else
                        obj.DataGrid.ColumnWidth={'fit','fit','fit'};
                    end
                end
                uiNum=3;
                if isempty(tableVarDropDown)
                    tableVarDropDown=uidropdown(obj.DataGrid,'Tag',rowTag,...
                    'ValueChangedFcn',@(e,d)obj.tableColumnSelected(d));
                    tableVarDropDown.DropDownOpeningFcn=@(e,d)obj.updateTableVariableDrpDown(tableVarDropDown,dataRow.WorkspaceVarName,dataRow.MappedChannel);
                    tableVarDropDown.Layout.Row=rowInd;
                    tableVarDropDown.Layout.Column=uiNum;
                end
                obj.Model.fetchTabularDropDownItems(tableVarDropDown,dataRow.WorkspaceVarName,dataRow.MappedChannel);

                if~doPreSelect&&~isempty(mappedChannel)&&...
                    strcmpi(dataRow.VariableName,obj.SELECT_VAR)&&...
                    numel(tableVarDropDown.ItemsData)==2
                    preSelectVarName=tableVarDropDown.ItemsData{2};
                    tableVarDropDown.Value=preSelectVarName;
                    dataRow.VariableName=preSelectVarName;
                    obj.Model.setCachedRowStateData(dataRow);
                    doPreSelect=true;
                elseif~strcmpi(dataRow.VariableName,obj.SELECT_VAR)
                    if~any(strcmp(tableVarDropDown.ItemsData,dataRow.VariableName))
                        tableVarDropDown.Items{end+1}=extractAfter(dataRow.VariableName,'.');
                        tableVarDropDown.ItemsData{end+1}=dataRow.VariableName;
                    end
                    tableVarDropDown.Value=dataRow.VariableName;
                elseif strcmpi(tableVarDropDown.ItemsData{1},dataRow.WorkspaceVarName)&&strcmpi(dataRow.VariableName,obj.SELECT_VAR)
                    dataRow.VariableName=tableVarDropDown.Value;
                    if~isempty(mappedChannel)
                        obj.Model.setCachedRowStateData(dataRow);
                    end
                    doNotify=true;
                end
                uiNum=uiNum+1;
                doPreSelect=doPreSelect||doNotify;
            else

                if hasTableRow
                    uiNum=4;
                else
                    uiNum=3;
                    if~isempty(mappedChannel)
                        obj.DataGrid.ColumnWidth={'fit','fit'};
                    else
                        obj.DataGrid.ColumnWidth={'fit','fit',obj.IconSize,obj.IconSize};
                    end
                end
                if~isempty(tableVarDropDown)
                    delete(tableVarDropDown);
                end
            end


            for i=1:totalRows
                addButton=findobj(obj.DataGrid,'UserData',obj.ADD_BUTTON,'Tag',num2str(i));
                removeButton=findobj(obj.DataGrid,'UserData',obj.REMOVE_BUTTON,'Tag',num2str(i));
                uiControlNum=uiNum;
                if isempty(mappedChannel)
                    if isempty(removeButton)
                        removeButton=uiimage(obj.DataGrid,...
                        'ScaleMethod','none',...
                        'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','remove.png'),...
                        'Enable','on',...
                        'UserData',obj.REMOVE_BUTTON,...
                        'Tag',rowTag,...
                        'ImageClickedFcn',@(e,d)obj.removeRow(d));
                    end
                    removeButton.Layout.Row=i;
                    removeButton.Layout.Column=uiControlNum;
                    uiControlNum=uiControlNum+1;

                    if isempty(addButton)
                        addButton=uiimage(obj.DataGrid,...
                        'ScaleMethod','none',...
                        'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
                        'Enable','on',...
                        'UserData',obj.ADD_BUTTON,...
                        'Tag',rowTag,...
                        'ImageClickedFcn',@(e,d)obj.addRow(d));
                    end
                    addButton.Enable='on';
                    addButton.Layout.Row=i;
                    addButton.Layout.Column=uiControlNum;
                elseif~isempty(addButton)
                    delete(addButton);
                    delete(removeButton);
                end
            end


            obj.updateRequiredLabelIfNeeded(dataRow,rowInd);
        end

        function updateDataView(obj)
            dataRows=obj.Model.getAllDataRows();

            if isempty(dataRows)
                obj.createEmptyDataRow();
                return;
            end

            hasTableRow=obj.Model.hasTableDataRow();



            if hasTableRow
                obj.DataGrid.ColumnWidth={'fit','fit','fit',obj.IconSize,obj.IconSize};
            else
                obj.DataGrid.ColumnWidth={'fit','fit',obj.IconSize,obj.IconSize};
            end

            obj.RequiredLabelGrid.ColumnWidth={'fit','fit'};

            doNotify=false;
            doTableVariableUpdate=false;
            doPreSelectTableVar=false;
            workspaceVarToPreselect=obj.Model.getUnambiguousWorkspaceVar();

            totalRows=numel(dataRows);

            obj.DataGrid.RowHeight=num2cell(repmat(obj.ROW_HEIGHT,1,totalRows));
            obj.RequiredLabelGrid.RowHeight=num2cell(repmat(obj.ROW_HEIGHT,1,totalRows));

            for i=1:totalRows
                dataRow=dataRows(i);
                if obj.Model.doCreateMappings&&~isempty(dataRow.MappedChannel)
                    obj.Model.setCachedRowStateData(dataRow);
                end


                obj.createOrUpdateDataLabel(dataRow,i);


                [doPreSelectWorkspaceVar,workspaceVarToPreselect,hasTableRow]=obj.createOrUpdateWorkspaceDropDown(dataRow,i,hasTableRow,workspaceVarToPreselect);
                if doPreSelectWorkspaceVar

                    doNotify=true;
                end


                [doPreSelectTableVar,doTableVariableUpdate]=obj.createOrUpdateTableVariableDropDown(hasTableRow,dataRow,i,...
                doTableVariableUpdate,doPreSelectTableVar);
                if doPreSelectTableVar

                    doNotify=true;
                end


                obj.createOrUpdatePlusMinusButton(dataRow,i,hasTableRow);


                obj.updateRequiredLabelIfNeeded(dataRow,i);
            end
            i=i+1;
            hasMoreRows=findobj(obj.DataGrid,'Tag',num2str(i));
            if~isempty(hasMoreRows)
                while(~isempty(hasMoreRows))

                    rowTag=num2str(i);
                    delete(findobj(obj.DataGrid,'Tag',rowTag));
                    delete(findobj(obj.RequiredLabelGrid,'Tag',rowTag));
                    i=i+1;
                    hasMoreRows=findobj(obj.DataGrid,'Tag',num2str(i));
                end
            end

            if doNotify
                if~isempty(obj.Model.MappedDataRows)
                    obj.Model.MappedDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
                end
                obj.Model.DataRows=dataRows;
                notify(obj,obj.DATASELECTION_EVENT);
            end
        end



        function createOrUpdateConfigurationDropDown(obj)
            if isempty(obj.ConfigurationGrid)||~isvalid(obj.ConfigurationGrid)
                obj.ConfigurationGrid=uigridlayout(obj.DataMainGrid,'Padding',[0,0,0,0]);
                obj.ConfigurationGrid.Layout.Row=1;
                obj.ConfigurationGrid.Layout.Column=1;
            end

            obj.DataSubGrid.Layout.Row=2;
            obj.ConfigurationGrid.RowHeight=num2cell(repmat(obj.ROW_HEIGHT,1,1));
            obj.ConfigurationGrid.ColumnWidth={'fit','fit',23};

            rowNum=1;
            rowTag=num2str(rowNum);
            configDrpDown=findobj(obj.ConfigurationGrid,'-isa','matlab.ui.control.DropDown','Tag',rowTag);

            if isempty(configDrpDown)
                dataLabel=uilabel(obj.ConfigurationGrid,'Tag',rowTag,...
                'Text',getString(message('MATLAB:graphics:visualizedatatask:ConfigurationLabel')));
                dataLabel.Layout.Row=rowNum;
                dataLabel.Layout.Column=1;

                configDrpDown=uidropdown(obj.ConfigurationGrid,'Tag',rowTag,...
                'Tooltip',getString(message('MATLAB:graphics:visualizedatatask:ConfigurationTooltip')),...
                'ValueChangedFcn',@(e,d)obj.configDrpDownSelectionChanged(d));
                configDrpDown.Layout.Row=rowNum;
                configDrpDown.Layout.Column=2;
            end

            obj.updateWarningIconIfNeeded();



            configDrpDown.Items=obj.Model.ConfigurationNames;

            dataRows=obj.Model.getAllDataRows();
            configDrpDown.Value=dataRows(1).MappedChannel.ConfigurationName;
            obj.Model.SelectedConfiguration=configDrpDown.Value;
        end


        function updateWarningIconIfNeeded(obj)

            warningIcon=findobj(obj.ConfigurationGrid,'-isa','matlab.ui.control.Image','Tag','1');
            if obj.Model.hasConfigurationError
                if isempty(warningIcon)
                    warningIcon=uiimage(obj.ConfigurationGrid,...
                    'ScaleMethod','none',...
                    'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','warning.png'),...
                    'Enable','on',...
                    'Tag','1',...
                    'Tooltip',getString(message('MATLAB:graphics:visualizedatatask:ConfigurationMapError')));
                end
                warningIcon.Layout.Row=1;
                warningIcon.Layout.Column=3;
            else
                delete(warningIcon);
            end
        end



        function configDrpDownSelectionChanged(obj,eventData)
            obj.Model.SelectedConfiguration=eventData.Value;

            notify(obj,obj.CONFIGSELECTION_EVENT);
        end

        function createOrUpdatePlusMinusButton(obj,dataRow,rowNum,hasTableRow)
            colNum=3;
            rowTag=num2str(rowNum);

            mappedChannel=dataRow.MappedChannel;
            if hasTableRow
                colNum=4;
            end
            addButton=findobj(obj.DataGrid,'UserData',obj.ADD_BUTTON,'Tag',rowTag);
            removeButton=findobj(obj.DataGrid,'UserData',obj.REMOVE_BUTTON,'Tag',rowTag);
            if isempty(mappedChannel)
                if isempty(removeButton)
                    removeButton=uiimage(obj.DataGrid,...
                    'ScaleMethod','none',...
                    'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','remove.png'),...
                    'Enable','on',...
                    'UserData',obj.REMOVE_BUTTON,...
                    'Tag',rowTag,...
                    'ImageClickedFcn',@(e,d)obj.removeRow(d));
                end
                removeButton.Layout.Row=rowNum;
                removeButton.Layout.Column=colNum;
                colNum=colNum+1;

                if isempty(addButton)
                    addButton=uiimage(obj.DataGrid,...
                    'ScaleMethod','none',...
                    'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
                    'Enable','on',...
                    'UserData',obj.ADD_BUTTON,...
                    'Tag',rowTag,...
                    'ImageClickedFcn',@(e,d)obj.addRow(d));
                end
                addButton.Enable='on';
                addButton.Layout.Row=rowNum;
                addButton.Layout.Column=colNum;
            else
                delete([addButton;removeButton]);
            end
        end

        function[doPreSelectTableVar,doUpdate]=createOrUpdateTableVariableDropDown(obj,hasTableRow,dataRow,rowNum,doUpdate,doPreSelectTableVar)
            rowTag=num2str(rowNum);

            tableVarDrpDown=findobj(obj.DataGrid,'-isa','matlab.ui.control.DropDown','Tag',rowTag);
            if hasTableRow
                if dataRow.IsTabular
                    mappedChannel=dataRow.MappedChannel;
                    if isempty(tableVarDrpDown)
                        tableVarDrpDown=uidropdown(obj.DataGrid,'Tag',rowTag,...
                        'ValueChangedFcn',@(e,d)obj.tableColumnSelected(d));
                        tableVarDrpDown.Layout.Row=rowNum;
                        tableVarDrpDown.Layout.Column=3;
                    end

                    obj.Model.fetchTabularDropDownItems(tableVarDrpDown,dataRow.WorkspaceVarName,mappedChannel);
                    tableVarDrpDown.DropDownOpeningFcn=@(e,d)obj.updateTableVariableDrpDown(tableVarDrpDown,dataRow.WorkspaceVarName,mappedChannel);
                    tableVarDrpDown.Value=tableVarDrpDown.ItemsData{1};

                    if~doPreSelectTableVar&&~isempty(mappedChannel)&&...
                        strcmpi(dataRow.VariableName,obj.SELECT_VAR)&&...
                        numel(tableVarDrpDown.ItemsData)==2&&~doUpdate
                        preSelectVarName=tableVarDrpDown.ItemsData{2};
                        tableVarDrpDown.Value=preSelectVarName;
                        dataRow.VariableName=preSelectVarName;

                        obj.Model.setCachedRowStateData(dataRow);
                        doPreSelectTableVar=true;
                    elseif~strcmpi(dataRow.VariableName,obj.SELECT_VAR)
                        if~any(strcmp(tableVarDrpDown.ItemsData,dataRow.VariableName))
                            tableVarDrpDown.Items{end+1}=extractAfter(dataRow.VariableName,'.');
                            tableVarDrpDown.ItemsData{end+1}=dataRow.VariableName;
                        end
                        tableVarDrpDown.Value=dataRow.VariableName;
                        doUpdate=true;
                    elseif strcmpi(tableVarDrpDown.ItemsData{1},dataRow.WorkspaceVarName)&&...
                        strcmpi(dataRow.VariableName,obj.SELECT_VAR)&&...
                        ~isempty(dataRow.MappedChannel)
                        dataRow.VariableName=tableVarDrpDown.Value;
                        obj.Model.setCachedRowStateData(dataRow);
                        doPreSelectTableVar=true;
                        doUpdate=true;
                    else
                        dataRow.VariableName=tableVarDrpDown.ItemsData{1};
                        if~isempty(dataRow.MappedChannel)
                            obj.Model.setCachedRowStateData(dataRow);
                        end
                    end
                else
                    delete(tableVarDrpDown);
                end
            else
                delete(tableVarDrpDown);
            end
        end

        function[doPreSelectWorkspaceVar,workspaceVarToPreselect,hasTableRow]=createOrUpdateWorkspaceDropDown(obj,dataRow,rowNum,hasTableRow,workspaceVarToPreselect)
            doPreSelectWorkspaceVar=false;
            rowTag=num2str(rowNum);
            mappedChannel=dataRow.MappedChannel;




            delete(findobj(obj.DataGrid,'-isa','matlab.ui.control.internal.model.WorkspaceDropDown','Tag',rowTag));
            workspaceDrpDown=matlab.ui.control.internal.model.WorkspaceDropDown('Parent',obj.DataGrid,...
            'UseDefaultAsPlaceholder',(~isempty(mappedChannel)&&~mappedChannel.IsRequired),...
            'FilterVariablesFcn',@(x)obj.Model.filterWorkspaceVariables(x,mappedChannel),...
            'Tag',rowTag);
            workspaceDrpDown.ValueChangedFcn=@(e,d)obj.dataDropdownChanged(workspaceDrpDown.Tag,d.Value,d.PreviousValue);


            if~strcmpi(dataRow.WorkspaceVarName,obj.SELECT_VAR)&&...
                ~strcmpi(dataRow.WorkspaceVarName,obj.DEFAULT_VALUE)
                if~any(strcmp(workspaceDrpDown.ItemsData,dataRow.WorkspaceVarName))
                    workspaceDrpDown.ItemsData{end+1}=dataRow.WorkspaceVarName;
                    workspaceDrpDown.Items{end+1}=dataRow.WorkspaceVarName;
                end
                workspaceDrpDown.Value=dataRow.WorkspaceVarName;
            elseif~isempty(workspaceVarToPreselect)&&~isempty(mappedChannel)&&mappedChannel.IsRequired


                workspaceData=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(workspaceVarToPreselect);
                if isa(workspaceData,'tabular')
                    hasTableRow=true;
                    dataRow.IsTabular=true;
                    obj.DataGrid.ColumnWidth={'fit','fit','fit',obj.IconSize,obj.IconSize};

                    if~any(strcmp(workspaceDrpDown.ItemsData,workspaceVarToPreselect))
                        workspaceDrpDown.ItemsData{end+1}=workspaceVarToPreselect;
                        workspaceDrpDown.Items{end+1}=workspaceVarToPreselect;
                    end
                    workspaceDrpDown.Value=workspaceVarToPreselect;

                    dataRow.WorkspaceVarName=workspaceVarToPreselect;
                elseif obj.Model.filterWorkspaceVariables(workspaceData,mappedChannel)
                    if~any(strcmp(workspaceDrpDown.ItemsData,workspaceVarToPreselect))
                        workspaceDrpDown.ItemsData{end+1}=workspaceVarToPreselect;
                        workspaceDrpDown.Items{end+1}=workspaceVarToPreselect;
                    end
                    workspaceDrpDown.Value=workspaceVarToPreselect;

                    dataRow.WorkspaceVarName=workspaceVarToPreselect;
                    dataRow.VariableName=workspaceVarToPreselect;
                    obj.Model.setCachedRowStateData(dataRow);



                    workspaceVarToPreselect=[];
                end

                doPreSelectWorkspaceVar=true;
            end

            workspaceDrpDown.Layout.Row=rowNum;
            workspaceDrpDown.Layout.Column=2;
        end

        function createOrUpdateDataLabel(obj,dataRow,rowNum)
            rowTag=num2str(rowNum);
            dataLabel=findobj(obj.DataGrid,'-isa','matlab.ui.control.Label','Tag',rowTag);
            mappedChannel=dataRow.MappedChannel;
            if isempty(dataLabel)
                dataLabel=uilabel(obj.DataGrid,'Tag',rowTag);
                dataLabel.Layout.Row=rowNum;
                dataLabel.Layout.Column=1;
            end



            if rowNum==1&&isempty(mappedChannel)
                dataLabel.Text=getString(message('MATLAB:graphics:visualizedatatask:DataLabel'));
            elseif~isempty(mappedChannel)
                dataLabel.Text=mappedChannel.Description;
            else
                dataLabel.Text='';
            end
        end

        function tableColumnSelected(obj,d)
            if~strcmp(d.Value,d.PreviousValue)
                rowInd=str2double(d.Source.Tag);

                dataRow=obj.Model.updateTableDataRow(string(d.Value),rowInd);

                obj.updateRequiredLabelIfNeeded(dataRow,rowInd);

                notify(obj,obj.DATASELECTION_EVENT);
            end
        end




        function updateTableVariableDrpDown(obj,tableDropDown,tableVar,channel)
            if obj.Model.ShowAllVariables&&(isempty(channel)||channel.IsRequired)
                items{1}=getString(message('MATLAB:graphics:visualizedatatask:AllVariablesLabel'));
                itemsData{1}=tableVar;
            else
                items{1}=getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'));
                itemsData{1}='select variable';
            end
            prevValue=tableDropDown.Value;
            try
                tableData=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(tableVar);
                allVars=tableData.Properties.VariableNames;



                if isa(tableData,'timetable')
                    timeVar=tableData.Properties.DimensionNames{1};
                    tableVariable=[tableVar,'.',timeVar];
                    evaluatedVar=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(tableVariable);

                    if matlab.visualize.task.internal.model.DataModel.filterWorkspaceVariables(evaluatedVar,channel)
                        items{end+1}=timeVar;%#ok<*AGROW>
                        itemsData{end+1}=tableVariable;
                    end
                end

                for i=1:numel(allVars)
                    tableVariable=matlab.internal.tabular.generateDotSubscripting(tableData,i,tableVar);
                    evaluatedVar=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(tableVariable);

                    if matlab.visualize.task.internal.model.DataModel.filterWorkspaceVariables(evaluatedVar,channel)
                        items{end+1}=allVars{i};%#ok<*AGROW>
                        itemsData{end+1}=tableVariable;
                    end
                end
                tableDropDown.Items=items;
                tableDropDown.ItemsData=itemsData;
            catch
                tableDropDown.Items={getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'))};
                tableDropDown.ItemsData={'select variable'};
                tableDropDown.Value=tableDropDown.ItemsData{1};
            end
            obj.tableColumnSelected(struct('Source',tableDropDown,'Value',tableDropDown.Value,'PreviousValue',prevValue));
        end

        function updateRequiredLabelIfNeeded(obj,dataRow,rowInd)
            if~isempty(dataRow.MappedChannel)&&dataRow.MappedChannel.IsRequired&&strcmpi(dataRow.VariableName,"select variable")
                obj.DataGrid.ColumnWidth{end-1}='fit';
                obj.DataGrid.ColumnWidth{end}='fit';
                rowTag=num2str(rowInd);
                requiredLabel=findobj(obj.RequiredLabelGrid,'-isa','matlab.ui.control.Label','Tag',rowTag);
                if isempty(requiredLabel)
                    requiredLabel=uilabel(obj.RequiredLabelGrid,'Text','*','FontColor','red','FontWeight','bold','Tag',num2str(rowInd));
                    requiredLabel.Layout.Row=rowInd;
                    requiredLabel.Layout.Column=1;

                    requiredLabel=uilabel(obj.RequiredLabelGrid,'Text',getString(message('MATLAB:graphics:visualizedatatask:RequiredFieldLabel')),'Tag',num2str(rowInd));
                    requiredLabel.Layout.Row=rowInd;
                    requiredLabel.Layout.Column=2;
                end
            else
                delete(findobj(obj.RequiredLabelGrid,'Tag',num2str(rowInd)));
            end
        end
    end
end