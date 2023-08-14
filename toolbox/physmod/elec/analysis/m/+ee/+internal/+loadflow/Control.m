classdef Control<handle




    properties
        Model(1,1){mustBeValid}
        View(1,1){mustBeValid}
    end

    properties(Access=private)
        InputHighlightStyle=uistyle('BackgroundColor',[175,218,255]./255);
        ListenerHandles=event.listener.empty;
    end

    methods
        function obj=Control(model,view)




            obj.Model=model;
            obj.View=view;


            obj.ListenerHandles(1)=listener(obj.Model,'StatusChanged',@obj.ModelStatusChanged);
            obj.ListenerHandles(end+1)=listener(obj.Model,'ValueChanged',@obj.ModelValueChanged);


            obj.ListenerHandles(end+1)=listener(obj.View.SettingsFrequencyAndTime,'ValueChanged',@(source,event)obj.SettingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.SettingsTimeAndSteadyState,'ValueChanged',@(source,event)obj.SettingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.SettingsLocal,'ValueChanged',@(source,event)obj.SettingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.SettingsStatic,'ValueChanged',@(source,event)obj.SettingsChanged(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.SettingsDynamic,'ValueChanged',@(source,event)obj.SettingsChanged(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View.RefreshButton,'ButtonPushed',@(source,event)obj.RefreshButtonPushed);
            obj.ListenerHandles(end+1)=listener(obj.View.RunButton,'ButtonPushed',@(source,event)obj.RunButtonPushed);
            obj.ListenerHandles(end+1)=listener(obj.View.ExportButton,'ButtonPushed',@(source,event)obj.ExportButtonPushed);


            obj.ListenerHandles(end+1)=listener(obj.View.TimeEdit,'ValueChanged',@(source,event)obj.TimeEditChanged);
            obj.ListenerHandles(end+1)=listener(obj.View.TimeSlider,'ValueChanging',@(source,event)obj.TimeSliderChanging);
            obj.ListenerHandles(end+1)=listener(obj.View.TimeSlider,'ValueChanged',@(source,event)obj.TimeSliderChanged);


            obj.ListenerHandles(end+1)=listener(obj.View.HighlightblocksinmodelCheckBox,'ValueChanged',@(source,event)obj.HighlightblocksinmodelCheckBox(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.HighlightinputsintableCheckBox,'ValueChanged',@(source,event)obj.HighlightinputsintableCheckBox(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View.NodeUITable,'CellEdit',@(source,event)obj.NodeUITableCellEdit(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.NodeUITable,'CellSelection',@(source,event)obj.TableCellSelection(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View.BusbarUITable,'CellEdit',@(source,event)obj.BusbarUITableCellEdit(source,event));
            obj.ListenerHandles(end+1)=listener(obj.View.BusbarUITable,'CellSelection',@(source,event)obj.TableCellSelection(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View.ConnectionUITable,'CellSelection',@(source,event)obj.TableCellSelection(source,event));


            obj.ListenerHandles(end+1)=listener(obj.View,'ObjectBeingDestroyed',@(source,event)obj.resetModelHighlight);


            notify(obj.Model,'ValueChanged');
        end

        function resetModelHighlight(obj)

            obj.Model.IsHighlighted=false;
        end

        function delete(obj)
            delete(obj.ListenerHandles);
            delete(obj.View);
            delete(obj.Model);
        end
    end


    methods(Access=private)
        function disableViewControls(obj)

            obj.View.HighlightinputsintableCheckBox.Enabled=false;
            obj.View.HighlightblocksinmodelCheckBox.Enabled=false;
            obj.View.RefreshButton.Enabled=false;
            obj.View.SettingsButton.Enabled=false;
            obj.View.RunButton.Enabled=false;
            obj.View.TimeSlider.Enabled=false;
            obj.View.TimeEdit.Enabled=false;
            obj.View.ExportButton.Enabled=false;
        end

        function enableViewControls(obj)

            obj.View.HighlightinputsintableCheckBox.Enabled=true;

            if obj.View.SettingsDynamic.Value&&...
                ~obj.View.TimeSlider.Enabled&&...
                ~obj.View.TimeEdit.Enabled
                obj.View.TimeSlider.Enabled=true;
                obj.View.TimeEdit.Enabled=true;
            end
            obj.View.RefreshButton.Enabled=true;
            obj.View.SettingsButton.Enabled=true;

            if~obj.Model.Error
                obj.View.RunButton.Enabled=true;
                obj.View.ExportButton.Enabled=true;
                obj.View.RefreshButton.Description=getString(message('physmod:ee:loadflow:RefreshButtonDescription'));
                obj.View.RunButton.Description=getString(message('physmod:ee:loadflow:RunButtonDescription'));
                obj.View.ExportButton.Description=getString(message('physmod:ee:loadflow:ExportButtonDescription'));
            else
                obj.View.RunButton.Enabled=false;
                obj.View.TimeSlider.Enabled=false;
                obj.View.TimeEdit.Enabled=false;
                obj.View.ExportButton.Enabled=false;
                obj.View.RefreshButton.Description=obj.Model.Status;
                obj.View.RunButton.Description=obj.Model.Status;
                obj.View.ExportButton.Description=obj.Model.Status;
            end
        end

        function BusbarUITableCellEdit(obj,~,event)

            obj.disableViewControls;

            tableinputmask=obj.Model.getBusbarTableInputMask;
            if tableinputmask(event.Indices(1),event.Indices(2))...
                &&(~isnumeric(event.NewData)||~isnan(event.NewData))
                obj.Model.setBusbarBlockProperty(event.Indices,event.PreviousData,event.NewData);
            else

                obj.View.BusbarUITable.Data{event.Indices(1),event.Indices(2)}=event.PreviousData;
            end
            obj.enableViewControls;
        end

        function NodeUITableCellEdit(obj,~,event)

            obj.disableViewControls;

            tableinputmask=obj.Model.getTableInputMask;
            if tableinputmask(event.Indices(1),event.Indices(2))...
                &&(~isnumeric(event.NewData)||~isnan(event.NewData))
                obj.Model.setAcNodeBlockProperty(event.Indices,event.PreviousData,event.NewData);
            else

                obj.View.NodeUITable.Data{event.Indices(1),event.Indices(2)}=event.PreviousData;
            end
            obj.enableViewControls;
        end

        function TableCellSelection(obj,~,event)

            rowNumbers=unique(event.Indices(:,1));
            if~isempty(rowNumbers)
                if~obj.View.HighlightblocksinmodelCheckBox.Enabled
                    obj.View.HighlightblocksinmodelCheckBox.Enabled=true;
                end
                rowNames=event.Source.Data.Properties.RowNames(rowNumbers);
                obj.Model.highlightBlocks(rowNames);
            else
                if obj.View.HighlightblocksinmodelCheckBox.Enabled
                    obj.View.HighlightblocksinmodelCheckBox.Enabled=false;
                end
            end
        end

        function ExportButtonPushed(obj)

            filterSpecification={...
            '*.xlsx',getString(message('physmod:ee:loadflow:xlsx'));...
            '*.mat',getString(message('physmod:ee:loadflow:mat'));
            '*.csv',getString(message('physmod:ee:loadflow:csv'));...
            };
            title=getString(message('physmod:ee:loadflow:ExportUIPutFileTitle'));
            suggestedFileName=[obj.Model.Name,'_loadflow_results'];
            [fileName,pathName,filterIndex]=uiputfile(filterSpecification,title,suggestedFileName);
            if isnumeric(fileName)...
                &&fileName==0...
                &&isnumeric(pathName)...
                &&pathName==0...
                &&isnumeric(filterIndex)...
                &&filterIndex==0


                obj.View.bringToFront();
                return
            end
            nodes=obj.View.NodeUITable.DisplayData;
            nodes.Properties.RowNames=strrep(nodes.Properties.RowNames,newline,' ');
            busbars=obj.View.BusbarUITable.DisplayData;
            busbars.Properties.RowNames=strrep(busbars.Properties.RowNames,newline,' ');
            connections=obj.View.ConnectionUITable.DisplayData;
            connections.Properties.RowNames=strrep(connections.Properties.RowNames,newline,' ');
            connections.("From Busbar")=strrep(connections.("From Busbar"),newline,' ');
            connections.("To Busbar")=strrep(connections.("To Busbar"),newline,' ');
            switch filterIndex
            case 1
                absoluteFileName=fullfile(pathName,fileName);
                if exist(absoluteFileName,'file')
                    delete(absoluteFileName);
                end
                warningState=warning('off','MATLAB:xlswrite:AddSheet');
                writetable(nodes,absoluteFileName,'Sheet','Nodes','WriteRowNames',true);
                writetable(busbars,absoluteFileName,'Sheet','Busbars','WriteRowNames',true);
                writetable(connections,absoluteFileName,'Sheet','Connections','WriteRowNames',true);
                warning(warningState.state,'MATLAB:xlswrite:AddSheet');
            case 2
                save(fullfile(pathName,fileName),'nodes','busbars','connections');
            case 3
                [~,fileName,fileExtension]=fileparts(fileName);
                absoluteFileName=fullfile(pathName,[fileName,'_nodes',fileExtension]);
                writetable(nodes,absoluteFileName,'WriteRowNames',true);
                absoluteFileName=fullfile(pathName,[fileName,'_busbars',fileExtension]);
                writetable(busbars,absoluteFileName,'WriteRowNames',true);
                absoluteFileName=fullfile(pathName,[fileName,'_connections',fileExtension]);
                writetable(connections,absoluteFileName,'WriteRowNames',true);
            otherwise
                error(message('physmod:ee:loadflow:UseSupportedFileFormat'));
            end
        end

        function HelpButtonPushed(~)

            web(fullfile(docroot,'physmod','sps','ref','loadflowanalyzer-app.html'));
        end

        function HighlightblocksinmodelCheckBox(obj,~,~)

            obj.disableViewControls;
            if obj.Model.IsHighlighted~=obj.View.HighlightblocksinmodelCheckBox.Value
                obj.Model.IsHighlighted=obj.View.HighlightblocksinmodelCheckBox.Value;
                obj.Model.highlightBlocks;
            end
            obj.enableViewControls;
        end

        function HighlightinputsintableCheckBox(obj,~,~)

            if obj.View.HighlightinputsintableCheckBox.Value
                obj.highlightInputsInTable(obj.View.NodeUITable,obj.Model.getTableInputMask,obj.InputHighlightStyle);
                obj.highlightInputsInTable(obj.View.BusbarUITable,obj.Model.getBusbarTableInputMask,obj.InputHighlightStyle);
            else
                obj.View.NodeUITable.removeStyle;
                obj.View.BusbarUITable.removeStyle;
            end
        end

        function ModelStatusChanged(obj,~,~)
            if isvalid(obj.View)...
                &&isvalid(obj.View.StatusLabel)...
                &&~strcmp(obj.View.StatusLabel.Text,obj.Model.Status)
                obj.View.StatusLabel.Text=obj.Model.Status;
                if strcmp(getString(message('physmod:ee:loadflow:StatusClosing')),obj.Model.Status)
                    obj.delete;
                end
            end
        end

        function ModelValueChanged(obj,~,~)

            if isvalid(obj.View)

                figureName=[getString(message('physmod:ee:loadflow:SimscapeElectricalLoadFlowAnalyzer')),': ',obj.Model.Name];
                if~strcmp(obj.View.Title,figureName)
                    obj.View.Title=figureName;
                end

                switch obj.Model.SolverConfiguration
                case 'FrequencyAndTime'
                    obj.View.SettingsFrequencyAndTime.Value=true;
                case 'TimeAndSteadyState'
                    obj.View.SettingsTimeAndSteadyState.Value=true;
                case 'Local'
                    obj.View.SettingsLocal.Value=true;
                end

                if obj.View.HighlightblocksinmodelCheckBox.Value~=obj.Model.IsHighlighted
                    obj.View.HighlightblocksinmodelCheckBox.Value=obj.Model.IsHighlighted;
                end

                obj.HighlightinputsintableCheckBox;

                obj.View.TimeEdit.Value=num2str(obj.Model.SimulationTime);

                obj.View.TimeSlider.Value=obj.Model.SimulationTime;
                obj.View.TimeSlider.Limits=obj.Model.getSimulationLimits;
                obj.View.TimeSlider.Labels={...
                num2str(obj.View.TimeSlider.Limits(1)),obj.View.TimeSlider.Limits(1);...
                num2str(obj.View.TimeSlider.Limits(2)),obj.View.TimeSlider.Limits(2);...
                };

                if~strcmp(obj.View.StatusLabel.Text,obj.Model.Status)
                    obj.View.StatusLabel.Text=obj.Model.Status;
                end

                table=obj.Model.getNodeTable;

                table.Properties.RowNames=regexprep(table.Properties.RowNames,['^',obj.Model.Name,'/'],'');

                if~isequaln(obj.View.NodeUITable.Data,table)

                    nColumns=size(table,2);
                    columnEditable=false(1,nColumns);
                    columnEditable([2,3,4,7,10,12,13])=true;

                    obj.View.NodeUITable.Data=table;
                    obj.View.NodeUITable.ColumnEditable=columnEditable;
                end

                table=obj.Model.getBusbarTable;

                table.Properties.RowNames=regexprep(table.Properties.RowNames,['^',obj.Model.Name,'/'],'');

                if~isequaln(obj.View.BusbarUITable.Data,table)

                    nColumns=size(table,2);
                    columnEditable=false(1,nColumns);
                    columnEditable(2)=true;

                    obj.View.BusbarUITable.Data=table;
                    obj.View.BusbarUITable.ColumnEditable=columnEditable;
                end

                table=obj.Model.getConnectionTable;

                table.Properties.RowNames=regexprep(table.Properties.RowNames,['^',obj.Model.Name,'/'],'');
                table.("From Busbar")=regexprep(table.("From Busbar"),['^',obj.Model.Name,'/'],'');
                table.("To Busbar")=regexprep(table.("To Busbar"),['^',obj.Model.Name,'/'],'');
                obj.View.ConnectionUITable.Data=table;

                obj.Model.highlightBlocks;

                obj.enableViewControls;
            end
        end

        function RefreshButtonPushed(obj)


            obj.disableViewControls;

            obj.Model.update();
            obj.enableViewControls;
        end

        function RunButtonPushed(obj)


            obj.disableViewControls;


            obj.Model.run();
            if obj.Model.Error
                obj.enableViewControls;
            end
        end

        function SettingsChanged(obj,~,~)

            if obj.View.SettingsFrequencyAndTime.Value...
                &&~strcmp('FrequencyAndTime',obj.Model.SolverConfiguration)
                obj.Model.SolverConfiguration='FrequencyAndTime';
            elseif obj.View.SettingsTimeAndSteadyState.Value...
                &&~strcmp('TimeAndSteadyState',obj.Model.SolverConfiguration)
                obj.Model.SolverConfiguration='TimeAndSteadyState';
            elseif obj.View.SettingsLocal.Value...
                &&~strcmp('Local',obj.Model.SolverConfiguration)
                obj.Model.SolverConfiguration='Local';
            end
            if obj.View.SettingsStatic.Value...
                &&~strcmp('Static',obj.Model.SimulationConfiguration)
                obj.Model.SimulationConfiguration='Static';
                obj.View.TimeSlider.Enabled=false;
                obj.View.TimeEdit.Enabled=false;
            elseif obj.View.SettingsDynamic.Value...
                &&~strcmp('Dynamic',obj.Model.SimulationConfiguration)
                obj.Model.SimulationConfiguration='Dynamic';
                obj.View.TimeSlider.Enabled=true;
                obj.View.TimeEdit.Enabled=true;
            end
        end

        function TimeEditChanged(obj,~,~)
            timeEditBoxNumericValue=str2double(obj.View.TimeEdit.Value);


            if timeEditBoxNumericValue<obj.View.TimeSlider.Limits(1)||...
                timeEditBoxNumericValue>obj.View.TimeSlider.Limits(2)
                errordlg(getString(message('physmod:ee:loadflow:SimulationTimeBoundsExceeded',...
                obj.View.TimeSlider.Limits(1),obj.View.TimeSlider.Limits(2))),...
                getString(message('physmod:ee:loadflow:ErrorDialogTitle')),'modal');
            end


            if timeEditBoxNumericValue<obj.View.TimeSlider.Limits(1)
                obj.Model.SimulationTime=obj.View.TimeSlider.Limits(1);
            elseif timeEditBoxNumericValue>obj.View.TimeSlider.Limits(2)
                obj.Model.SimulationTime=obj.View.TimeSlider.Limits(2);
            else
                obj.Model.SimulationTime=timeEditBoxNumericValue;
            end
            obj.RefreshButtonPushed;
        end

        function TimeSliderChanged(obj,~,~)
            obj.Model.SimulationTime=obj.View.TimeSlider.Value;
            obj.RefreshButtonPushed;
        end

        function TimeSliderChanging(obj,~,~)
            obj.Model.SimulationTime=obj.View.TimeSlider.Value;
            obj.View.TimeEdit.Value=num2str(obj.Model.SimulationTime);
        end
    end

    methods(Static,Access=private)
        function highlightInputsInTable(uiTable,tableInputMask,inputHighlightStyle)


            [row,col]=find(tableInputMask);
            if isrow(tableInputMask)
                row=row';
                col=col';
            end

            if~isempty(uiTable.StyleConfigurations)
                styleIndex=find(isequal(uiTable.StyleConfigurations{:,"Style"},inputHighlightStyle));
            end

            uiTable.addStyle(inputHighlightStyle,'cell',[row,col]);

            if exist('styleIndex','var')
                uiTable.removeStyle(styleIndex);
            end
        end
    end
end

function mustBeValid(value)
    if~isa(value,'double')&&~isvalid(value)
        error(message('physmod:ee:loadflow:ControlInputIsInvalid'));
    end
end
