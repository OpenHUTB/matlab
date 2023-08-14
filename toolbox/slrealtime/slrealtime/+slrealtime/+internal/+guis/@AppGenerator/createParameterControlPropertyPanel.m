function createParameterControlPropertyPanel(this)








    clear options;
    options.Tag=this.ParameterControlPropsFigPanel_tag;
    options.Title=this.Control_msg;
    options.Region="right";
    options.Resizable=true;
    options.Maximizable=false;
    options.Contextual=true;
    options.PermissibleRegions="right";
    panel=matlab.ui.internal.FigurePanel(options);
    this.App.add(panel);
    grid=uigridlayout(panel.Figure);
    grid.ColumnWidth={'2x','3x',50};
    grid.RowHeight={25,25,25,25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    function controlNameChanged(this,e)
        prevControlName=e.PreviousValue;

        function revert()
            this.ParameterControlNameEditField.Value=prevControlName;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedParam=this.BindingTable.Selection;
        newControlName=e.Value;
        controlType=this.BindingData{selectedParam}.ControlType;
        [allOtherControlNames,allOtherControlTypes]=this.getAllControlNamesAndTypes(selectedParam);



        if~isvarname(newControlName)
            throwError(this.InvalidControlName_msg);
            return;
        end

        if~strcmp(controlType,'Parameter Table')


            if any(strcmp(newControlName,allOtherControlNames))
                throwError(this.ControlNameInUse_msg);
                return;
            end
        else




            idxs=strcmp(newControlName,allOtherControlNames);
            if~isempty(setdiff(allOtherControlTypes(idxs),controlType))
                throwError(this.ControlNameInUseByType_msg);
                return;
            end
        end



        this.BindingData{selectedParam}.ControlName=newControlName;
        this.BindingTable.Data{selectedParam,this.BindingTableControlNameColIdx}=newControlName;



        if~strcmp(prevControlName,newControlName)
            if this.PropsMap.isKey(prevControlName)
                comp=this.PropsMap(prevControlName);
                this.PropsMap(newControlName)=comp;
                this.PropsMap.remove(prevControlName);
            end
        end
    end
    label=uilabel(grid);
    label.Layout.Row=1;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ControlName_msg;
    label.Tooltip={this.ControlNameParamPropTooltip_msg};
    this.ParameterControlNameEditField=uieditfield(grid,'text');
    this.ParameterControlNameEditField.Layout.Row=1;
    this.ParameterControlNameEditField.Layout.Column=[2,3];
    this.ParameterControlNameEditField.ValueChangedFcn=@(o,e)controlNameChanged(this,e);



    function ParameterPropertyControlTypeChanged(this,e)
        prevControlType=e.PreviousValue;

        function revert()
            this.ParameterControlTypeDropDown.Value=prevControlType;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedParam=this.BindingTable.Selection;
        controlName=this.BindingData{selectedParam}.ControlName;
        prevControlName=controlName;
        newControlType=e.Value;
        [allOtherControlNames,~]=this.getAllControlNamesAndTypes(selectedParam);




        if strcmp(prevControlType,'Parameter Table')&&...
            ~strcmp(newControlType,'Parameter Table')&&...
            any(strcmp(controlName,allOtherControlNames))
            throwError(this.ControlNameInUseChange_msg);
            return;
        end



        if strcmp(newControlType,'Parameter Table')
            this.ParameterConvToCompEditField.Value='';
            this.ParameterConvToCompEditField.Enable='off';
            this.BindingData{selectedParam}.ConvToComp='';

            this.ParameterConvToTargetEditField.Value='';
            this.ParameterConvToTargetEditField.Enable='off';
            this.BindingData{selectedParam}.ConvToTarget='';
        else
            this.ParameterConvToCompEditField.Enable='on';

            this.ParameterConvToTargetEditField.Enable='on';
        end



        this.BindingData{selectedParam}.ControlType=newControlType;
        this.BindingTable.Data{selectedParam,this.BindingTableControlTypeColIdx}=newControlType;



        if~strcmp(prevControlType,newControlType)&&this.PropsMap.isKey(prevControlName)
            this.PropsMap.remove(controlName);
            this.createComponentForPropsMap(controlName,newControlType);
            this.closePropertyInspector();
        end
    end
    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ControlType_msg;
    label.Tooltip={this.ControlTypeParamPropTooltip_msg};
    this.ParameterControlTypeDropDown=uidropdown(grid);
    this.ParameterControlTypeDropDown.Items=this.ParameterControlTypes;
    this.ParameterControlTypeDropDown.Layout.Row=2;
    this.ParameterControlTypeDropDown.Layout.Column=[2,3];
    this.ParameterControlTypeDropDown.ValueChangedFcn=@(o,e)ParameterPropertyControlTypeChanged(this,e);



    function ParameterPropertyConvToCompChanged(this,e)
        prevConvFunc=e.PreviousValue;

        function revert()
            this.ParameterConvToCompEditField.Value=prevConvFunc;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedParam=this.BindingTable.Selection;
        newConvFunc=e.Value;



        if~isempty(newConvFunc)
            valid=true;
            try
                temp=eval(newConvFunc);
                if~isa(temp,'function_handle')
                    valid=false;
                end
            catch
                valid=false;
            end
            if~valid
                throwError(this.InvalidConvToComp_msg);
                return;
            end
        end



        this.BindingData{selectedParam}.ConvToComp=newConvFunc;
    end
    label=uilabel(grid);
    label.Layout.Row=3;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ConvertToComponent_msg;
    label.Tooltip={this.ConvToCompParamPropTooltip_msg};
    this.ParameterConvToCompEditField=uieditfield(grid,'text');
    this.ParameterConvToCompEditField.Layout.Row=3;
    this.ParameterConvToCompEditField.Layout.Column=[2,3];
    this.ParameterConvToCompEditField.ValueChangedFcn=@(o,e)ParameterPropertyConvToCompChanged(this,e);



    function ParameterPropertyConvToTargetChanged(this,e)
        prevConvFunc=e.PreviousValue;

        function revert()
            this.ParameterConvToTargetEditField.Value=prevConvFunc;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedParam=this.BindingTable.Selection;
        newConvFunc=e.Value;



        if~isempty(newConvFunc)
            valid=true;
            try
                temp=eval(newConvFunc);
                if~isa(temp,'function_handle')
                    valid=false;
                end
            catch
                valid=false;
            end
            if~valid
                throwError(this.InvalidConvToTarget_msg);
                return;
            end
        end



        this.BindingData{selectedParam}.ConvToTarget=newConvFunc;
    end
    label=uilabel(grid);
    label.Layout.Row=4;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ConvertToTarget_msg;
    label.Tooltip={this.ConvToTargetParamPropTooltip_msg};
    this.ParameterConvToTargetEditField=uieditfield(grid,'text');
    this.ParameterConvToTargetEditField.Layout.Row=4;
    this.ParameterConvToTargetEditField.Layout.Column=[2,3];
    this.ParameterConvToTargetEditField.ValueChangedFcn=@(o,e)ParameterPropertyConvToTargetChanged(this,e);




    function configureButtonPushed(this)
        if this.PropsMap.isKey(this.ParameterControlNameEditField.Value)
            this.openPropertyInspector(this.PropsMap(this.ParameterControlNameEditField.Value));
        end
    end
    this.ParameterControlConfigureButton=uibutton(grid);
    this.ParameterControlConfigureButton.Text='';
    this.ParameterControlConfigureButton.Icon=this.Settings_icon24;
    this.ParameterControlConfigureButton.Layout.Row=5;
    this.ParameterControlConfigureButton.Layout.Column=3;
    this.ParameterControlConfigureButton.ButtonPushedFcn=@(o,e)configureButtonPushed(this);
end