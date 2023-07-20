classdef(Hidden)DataModel<handle






    properties
        DataRows matlab.visualize.task.internal.model.DataProperties
        MappedDataRows matlab.visualize.task.internal.model.DataProperties
        ShowAllVariables(1,1)logical
        doCreateMappings(1,1)logical
        CacheCounter=0
        ConfigurationNames string=string.empty
        SelectedConfiguration string=string.empty
        hasConfigurationError(1,1)logical
    end

    properties(Constant)
        SELECT_VAR="select variable"
        DEFAULT_VALUE="default value"
    end

    methods
        function obj=DataModel()
            obj.DataRows=matlab.visualize.task.internal.model.DataProperties.empty();
        end

        function setCachedRowStateData(obj,dataRow)
            rowData=struct('WorkspaceVarName',dataRow.WorkspaceVarName,...
            'VariableName',dataRow.VariableName,...
            'IsTabular',dataRow.IsTabular,...
            'CacheCounter',obj.CacheCounter);

            dataRow.MappedChannel.updateMappedDataAndCachedRow(rowData);
        end




        function fetchTabularDropDownItems(obj,tableDropDown,tableVar,channel)
            if obj.ShowAllVariables&&(isempty(channel)||channel.IsRequired)
                items{1}=getString(message('MATLAB:graphics:visualizedatatask:AllVariablesLabel'));
                itemsData{1}=tableVar;
            else
                items{1}=getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'));
                itemsData{1}='select variable';
            end

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
            catch
                items{1}=getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'));
                itemsData{1}='select variable';
            end
            tableDropDown.Items=items;
            tableDropDown.ItemsData=itemsData;
        end

        function clearMappedRowsIfNeeded(obj)
            if~isempty(obj.MappedDataRows)
                obj.DataRows=obj.MappedDataRows;
                obj.MappedDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
                obj.CacheCounter=obj.CacheCounter+1;
                obj.hasConfigurationError=false;
            end
        end


        function deserializeDataState(obj,state,channelMetaData)
            obj.ShowAllVariables=state.ShowAllVariables;
            if isfield(state,'SelectedConfiguration')
                obj.SelectedConfiguration=state.SelectedConfiguration;
            end
            if isfield(state,'hasConfigurationError')
                obj.hasConfigurationError=state.hasConfigurationError;
            end
            if isfield(state,'ConfigurationNames')
                obj.ConfigurationNames=state.ConfigurationNames;
            end

            if isempty(state.DataRows)
                obj.DataRows=matlab.visualize.task.internal.model.DataProperties.empty();
            else
                dataRows=state.DataRows;
                newDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
                for i=1:numel(dataRows)
                    if i<=numel(channelMetaData)
                        chData=channelMetaData(i);
                    else
                        chData=[];
                    end
                    newDataRows(i)=matlab.visualize.task.internal.model.DataProperties();
                    newDataRows(i).deserializeDataParameters(dataRows(i),chData);
                end
                obj.DataRows=newDataRows;
            end

            if isempty(state.MappedDataRows)||isempty(channelMetaData)
                obj.MappedDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
            else
                dataRows=state.MappedDataRows;
                newDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
                for i=1:numel(dataRows)
                    newDataRows(i)=matlab.visualize.task.internal.model.DataProperties();
                    if i<=numel(channelMetaData)
                        chData=channelMetaData(i);
                    else
                        chData=[];
                    end
                    newDataRows(i).deserializeDataParameters(dataRows(i),chData);
                end
                obj.MappedDataRows=newDataRows;
            end
        end

        function dataRows=getAllSelectedDataRows(obj)
            dataRows=matlab.visualize.task.internal.model.DataProperties.empty();
            for i=1:numel(obj.DataRows)
                varName=obj.DataRows(i).VariableName;
                if(~strcmpi(varName,'select variable')&&...
                    ~strcmpi(varName,'default value'))
                    dataRows(end+1)=obj.DataRows(i);
                end
            end
        end

        function dataRows=getAllSelectedDataRowsForMapping(obj)
            dataRows=matlab.visualize.task.internal.model.DataProperties.empty();
            for i=1:numel(obj.DataRows)
                varName=obj.DataRows(i).VariableName;
                if obj.DataRows(i).IsTabular||(~strcmpi(varName,'select variable')&&...
                    ~strcmpi(varName,'default value'))
                    dataRows(end+1)=obj.DataRows(i);
                end
            end
        end

        function newdataRow=addDataRowAtIndex(obj,prevRowInd)
            obj.clearMappedRowsIfNeeded();

            prevRow=obj.getRowData(prevRowInd);

            newdataRow=matlab.visualize.task.internal.model.DataProperties();



            if prevRow.IsTabular
                newdataRow.WorkspaceVarName=prevRow.WorkspaceVarName;
                newdataRow.IsTabular=prevRow.IsTabular;
            end

            if~isempty(newdataRow.MappedChannel)
                obj.setCachedRowStateData(newdataRow);
            end

            obj.DataRows=[obj.DataRows(1:prevRowInd),newdataRow,obj.DataRows(prevRowInd+1:end)];
        end

        function removeDataRowAtIndex(obj,rowIndex)
            obj.clearMappedRowsIfNeeded();

            if~isempty(obj.DataRows(rowIndex).MappedChannel)
                obj.DataRows(rowIndex).MappedChannel.DataMapped='select variable';
                obj.DataRows(rowIndex).MappedChannel.MappedRow=[];
            end
            obj.DataRows(rowIndex)=[];
        end

        function hasTable=hasTableDataRow(obj)
            hasTable=false;
            for i=1:numel(obj.DataRows)
                if obj.DataRows(i).IsTabular
                    hasTable=true;
                    break;
                end
            end
        end

        function dataRow=updateTableDataRow(obj,selectedVariable,rowIndex)
            obj.clearMappedRowsIfNeeded();

            dataRow=obj.getRowData(rowIndex);
            dataRow.VariableName=selectedVariable;

            if~isempty(dataRow.MappedChannel)
                obj.setCachedRowStateData(dataRow);
            end

            obj.DataRows(rowIndex)=dataRow;
        end

        function dataRow=updateDataRow(obj,workspaceVarName,rowIndex)
            obj.clearMappedRowsIfNeeded();

            if isempty(obj.DataRows)
                dataRow=matlab.visualize.task.internal.model.DataProperties();
            else
                dataRow=obj.getRowData(rowIndex);
            end

            dataRow.WorkspaceVarName=workspaceVarName;
            dataRow.VariableName=workspaceVarName;
            dataRow.IsTabular=isa(...
            matlab.visualize.task.internal.model.DataModel.getEvaluatedData(workspaceVarName),...
            'tabular');

            if dataRow.IsTabular&&...
                ~strcmpi(workspaceVarName,obj.SELECT_VAR)&&...
                ~strcmpi(workspaceVarName,obj.DEFAULT_VALUE)

                dataRow.VariableName=obj.SELECT_VAR;
            end

            if~isempty(dataRow.MappedChannel)
                obj.setCachedRowStateData(dataRow);
            end
            obj.DataRows(rowIndex)=dataRow;
        end

        function rowData=getRowData(obj,rowIndex)
            rowData=obj.DataRows(rowIndex);
        end

        function dataRows=getAllDataRows(obj)
            if isempty(obj.MappedDataRows)
                dataRows=obj.DataRows;
            else
                dataRows=obj.MappedDataRows;
            end
        end
    end

    methods(Static,Hidden)


        function data=getEvaluatedData(varName)
            data=[];
            if~strcmpi(varName,'select variable')&&...
                ~strcmpi(varName,'default value')
                try
                    if contains(varName,'.')||evalin('base',strcat("exist('",varName,"', 'var') == 1"))
                        data=evalin('base',varName);
                    end
                catch
                end
            end
        end

        function varToPreSelect=getUnambiguousWorkspaceVar()
            varToPreSelect='';
            workspaceVariables=evalin('base','who');
            if numel(workspaceVariables)==1
                varToPreSelect=workspaceVariables{1};
            end
        end

        function tblVarNames=getTableVariableNames(workspaceVar)
            tblVarNames=workspaceVar.Properties.VariableNames;
        end







        function isDataValid=filterWorkspaceVariables(wsVar,channel)
            if isempty(channel)
                isDataValid=true;
                return;
            end

            if isa(wsVar,'tabular')
                isDataValid=true;
                return;
            end


            isDataValid=false;
            if isempty(wsVar)
                return;
            end


            orig_state=warning('off','all');
            if~isempty(channel.CustomValidationFcn)
                isDataValid=hgfeval({channel.CustomValidationFcn},...
                wsVar,channel);
            else
                for i=1:numel(channel.KeyType)
                    keyTypes=channel.KeyType(i);
                    try
                        [attrClass,attrType]=matlab.visualize.task.internal.model.DataModel.cleanUpTypeAttributes(keyTypes);

                        validateattributes(wsVar,attrClass,attrType);

                        isDataValid=true;
                        break;
                    catch
                    end
                end
            end


            warning(orig_state);
        end

        function[attrClass,attrType]=cleanUpTypeAttributes(keyTypes)
            keyTypes=replace(keyTypes,'ncols=','ncols ');
            keyTypes=replace(keyTypes,'choices=','');
            keyTypes=replace(keyTypes,'cellstr','cell');
            keyTypes=replace(keyTypes,'ncols=','ncols ');
            keyTypes=replace(keyTypes,'numel=','numel ');
            keyTypes=replace(keyTypes,'nrows=','nrows ');
            keyTypes=replace(keyTypes,'=','= ');
            keys=string(split(keyTypes));
            attrClass=keys{1};
            if strcmpi(attrClass,'vector')
                attrClass=["numeric"];
                attrType={'vector'};
            elseif strcmpi(attrClass,'positive')
                attrClass=["numeric"];
                attrType={'positive'};
            else
                attrType={};
            end
            keys(1)=[];
            for i=1:numel(keys)
                keyAttr=str2num(keys(i));%#ok<ST2NM>
                if~isempty(keyAttr)
                    attrType{end+1}=keyAttr;
                else
                    attrType{end+1}=keys(i);%#ok<*AGROW>
                end
            end
        end
    end
end