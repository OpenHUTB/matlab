classdef(Hidden)OptionalParametersPanel<matlab.visualize.task.internal.view.VisualizeDataBaseView






    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase})
        OptionsGrid matlab.ui.container.GridLayout
    end

    methods

        function obj=OptionalParametersPanel(parentContainer,model)
            obj@matlab.visualize.task.internal.view.VisualizeDataBaseView(parentContainer,model);
        end


        function updateView(obj,model)
            obj.Model=model.OptionalParamModel;
            obj.updateParametersView();
        end
    end

    methods(Access=protected)

        function createComponents(obj)
            obj.OptionsGrid=uigridlayout(obj.ParentContainer,'Padding',[0,5,0,0]);
            obj.OptionsGrid.RowHeight={obj.RowHeight};
        end


        function valueChanged(obj,~,~)
            notify(obj,'ValueChangedEvent')
        end
    end

    methods(Access=?hVisualizeTaskBase)

        function model=getModel(obj)
            model=obj.Model;
        end


        function createEmptyOptionsRow(obj)
            obj.OptionsGrid.ColumnWidth={'fit',obj.IconSize};
            obj.OptionsGrid.RowHeight={obj.RowHeight};

            tagString='1';
            optionalParamDropDown=uidropdown('Parent',obj.OptionsGrid,...
            'Enable','off',...
            'Tag',tagString,...
            'Items',{getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'))},...
            'ItemsData',{'select variable'},...
            'DropDownOpeningFcn',@(e,d)obj.dropDownOpeningCallback(d.Source));
            optionalParamDropDown.Layout.Row=1;
            optionalParamDropDown.Layout.Column=1;
            optionalParamDropDown.ValueChangedFcn=@(e,d)obj.optionalPropertyChanged(d);

            isEnabled=obj.optionalParamDropDownUpdate(optionalParamDropDown);
            optionalParamDropDown.Enable=isEnabled;
            if~isEnabled
                optionalParamDropDown.Tooltip=getString(message('MATLAB:graphics:visualizedatatask:NoProperties'));
            else
                optionalParamDropDown.Tooltip=getString(message('MATLAB:graphics:visualizedatatask:SelectParametersTooltip'));
            end

            addButton=uiimage(obj.OptionsGrid,...
            'ScaleMethod','none',...
            'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
            'Enable',false,...
            'Tag',tagString,...
            'ImageClickedFcn',@(e,d)obj.addOptionsRow(d));
            addButton.Layout.Row=1;
            addButton.Layout.Column=2;
        end


        function updateParametersView(obj)
            optionalParameters=obj.Model.getAllOptionsRows();
            delete(obj.OptionsGrid.Children);

            if isempty(optionalParameters)
                obj.createEmptyOptionsRow();
                return;
            end
            obj.OptionsGrid.ColumnWidth={'fit','fit',obj.IconSize,obj.IconSize};
            obj.OptionsGrid.RowHeight=num2cell(repmat(obj.RowHeight,1,numel(optionalParameters)));
            [itemsData,items]=obj.Model.getAllOptionalParameters();
            optionalParamDropDown=matlab.ui.control.DropDown.empty();

            addButtons=matlab.ui.control.Image.empty();
            for i=1:numel(optionalParameters)
                param=optionalParameters(i);
                uiNum=1;
                rowTag=num2str(i);
                optionalParamDropDown(i)=uidropdown('Parent',obj.OptionsGrid,...
                'Tag',rowTag,...
                'Items',items,...
                'ItemsData',itemsData,...
                'DropDownOpeningFcn',@(e,d)obj.dropDownOpeningCallback(d.Source));
                optionalParamDropDown(i).Layout.Row=i;
                optionalParamDropDown(i).Layout.Column=uiNum;
                optionalParamDropDown(i).ValueChangedFcn=@(e,d)obj.optionalPropertyChanged(d);

                uiNum=uiNum+1;
                if param.IsSelected
                    optionalParamDropDown(i).Value=param.Name;


                    obj.createOptionalValue(param,i,uiNum);
                end


                obj.dropDownOpeningCallback(optionalParamDropDown(i));
                uiNum=uiNum+1;

                removeButton=uiimage(obj.OptionsGrid,...
                'ScaleMethod','none',...
                'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','remove.png'),...
                'Enable','on',...
                'Tag',rowTag,...
                'ImageClickedFcn',@(e,d)obj.removeOptionsRow(param.Name,d));
                removeButton.Layout.Row=i;
                removeButton.Layout.Column=uiNum;
                uiNum=uiNum+1;

                addButtons(i)=uiimage(obj.OptionsGrid,...
                'ScaleMethod','none',...
                'ImageSource',fullfile(matlabroot,'toolbox','matlab','plottools','+matlab','+visualize','+task','+internal','+icons','add.png'),...
                'Enable','on',...
                'ImageClickedFcn',@(e,d)obj.addOptionsRow(d),...
                'Tag',rowTag);
                addButtons(i).Layout.Row=i;
                addButtons(i).Layout.Column=uiNum;
            end
            if numel(optionalParameters)==numel(obj.Model.VizParameters)
                set(addButtons,'Enable','off');
            end
        end




        function createOptionalValue(obj,param,i,uiNum)
            propType=param.Type;
            if strcmpi(propType,'numeric')
                paramValueField=uieditfield(obj.OptionsGrid,'numeric',...
                'Tag',num2str(i),...
                'Value',param.DefaultValue);
                paramValueField.Layout.Row=i;
                paramValueField.Layout.Column=uiNum;
                paramValueField.ValueChangedFcn=@(e,d)obj.propertyValueChanged(d);
            else
                if contains(propType,'{')
                    propVal=extractBetween(replace(propType,'''',''),'{','}');
                    propVal=strtrim(strsplit(propVal{1},','));
                else
                    propVal=feval(extractAfter(propType,'='));
                end
                paramValueField=uidropdown('Parent',obj.OptionsGrid,...
                'Tag',num2str(i),...
                'Items',propVal);
                paramValueField.Layout.Row=i;
                paramValueField.Layout.Column=uiNum;
                paramValueField.ValueChangedFcn=@(e,d)obj.propertyValueChanged(d);
            end
            if~isempty(param.SelectedValue)
                set(paramValueField,'Value',param.SelectedValue);
            end
        end


        function addOptionsRow(obj,d)
            prevRowInd=str2double(d.Source.Tag);
            newOptionsRow=matlab.visualize.task.internal.model.OptionalParameters("select","select variable",[],[]);

            obj.Model.addOptionsRowAtIndex(newOptionsRow,prevRowInd+1);

            obj.updateParametersView();
        end


        function removeOptionsRow(obj,paramName,d)
            selectedProperty=paramName;
            if~strcmpi(selectedProperty,'select variable')
                optionsProperties=obj.Model.getVizParamData(selectedProperty);
                if~isempty(optionsProperties)
                    optionsProperties.IsSelected=false;
                    optionsProperties.SelectedValue=[];
                end
            end

            rowInd=str2double(d.Source.Tag);
            obj.Model.removeOptionsRowAtIndex(rowInd);


            obj.valueChanged(d.Source,'');
            obj.updateParametersView();
        end


        function optionalPropertyChanged(obj,d)
            selectedProperty=string(d.Value);
            isSelected=true;
            previousProperty=obj.Model.getVizParamData(d.PreviousValue);
            if~isempty(previousProperty)
                previousProperty.IsSelected=false;
            end
            if strcmpi(selectedProperty,'select variable')
                isSelected=false;
            end

            rowIndex=str2double(d.Source.Tag);

            optionsProperties=obj.Model.getVizParamData(selectedProperty);
            if isempty(optionsProperties)
                optionsProperties=matlab.visualize.task.internal.model.OptionalParameters("select","select variable",[],[]);
            end
            optionsProperties.IsSelected=isSelected;

            obj.Model.updateOptionsRows(optionsProperties,rowIndex);


            obj.valueChanged(d.Source,d.Value);
            obj.updateParametersView();
        end


        function propertyValueChanged(obj,d)
            rowIndex=str2double(d.Source.Tag);

            obj.Model.updateRowValue(d.Source.Value,rowIndex);


            obj.valueChanged(d.Source,d.Value);
        end


        function isEnabled=optionalParamDropDownUpdate(obj,optionalParamDropDown)


            [optionalParamDropDown.ItemsData,optionalParamDropDown.Items]=obj.Model.getAllOptionalParameters();
            isEnabled=numel(optionalParamDropDown.Items)>1;
        end



        function dropDownOpeningCallback(obj,dropDown)


            [dropDown.ItemsData,dropDown.Items]=obj.Model.getAllParameters(dropDown.Value);
        end
    end
end