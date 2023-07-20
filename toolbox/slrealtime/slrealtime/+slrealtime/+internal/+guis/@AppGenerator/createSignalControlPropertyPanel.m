function createSignalControlPropertyPanel(this)








    options.Tag=this.SignalControlPropsFigPanel_tag;
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
    grid.RowHeight={25,25,25,25};
    grid.ColumnSpacing=3;
    grid.RowSpacing=3;
    grid.Padding=[5,5,5,5];



    function controlNameChanged(this,e)
        prevControlName=e.PreviousValue;

        function revert()
            this.SignalControlNameEditField.Value=prevControlName;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        newControlName=e.Value;
        controlType=this.BindingData{selectedSignal}.ControlType;
        [allOtherControlNames,allOtherControlTypes]=this.getAllControlNamesAndTypes(selectedSignal);



        if~strcmp(controlType,'NONE')&&~isvarname(newControlName)
            throwError(this.InvalidControlName_msg);
            return;
        end

        if~(strcmp(controlType,'Signal Table')||strcmp(controlType,'Axes'))



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



        this.BindingData{selectedSignal}.ControlName=newControlName;
        this.BindingTable.Data{selectedSignal,this.BindingTableControlNameColIdx}=newControlName;



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
    label.Tooltip={this.ControlNameSignalPropTooltip_msg};
    this.SignalControlNameEditField=uieditfield(grid,'text');
    this.SignalControlNameEditField.Layout.Row=1;
    this.SignalControlNameEditField.Layout.Column=[2,3];
    this.SignalControlNameEditField.ValueChangedFcn=@(o,e)controlNameChanged(this,e);



    function controlTypeChanged(this,e)
        prevControlType=e.PreviousValue;

        function revert()
            this.SignalControlTypeDropDown.Value=prevControlType;
        end
        function throwError(msg)
            uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(msg),this.Error_msg,'CloseFcn',@(~,~)revert());
        end

        selectedSignal=this.BindingTable.Selection;
        controlName=this.BindingData{selectedSignal}.ControlName;
        prevControlName=controlName;
        newControlType=e.Value;
        [allOtherControlNames,~]=this.getAllControlNamesAndTypes(selectedSignal);

        if strcmp(newControlType,'NONE')






            controlName='';
            this.SignalControlNameEditField.Value=controlName;
            this.SignalControlNameEditField.Enable='off';
            this.BindingData{selectedSignal}.ControlName=controlName;
            this.BindingTable.Data{selectedSignal,this.BindingTableControlNameColIdx}=controlName;
        else




            this.SignalControlNameEditField.Enable='on';





            switchedFromSignalTable=strcmp(prevControlType,'Signal Table')&&~strcmp(newControlType,'Signal Table');
            switchedFromAxes=strcmp(prevControlType,'Axes')&&~strcmp(newControlType,'Axes');
            if(switchedFromSignalTable||switchedFromAxes)&&...
                any(strcmp(controlName,allOtherControlNames))
                throwError(this.ControlNameInUseChange_msg);
                return;
            end




            if strcmp(prevControlType,'NONE')
                controlName=this.getUniqueControlName();
                this.SignalControlNameEditField.Value=controlName;
                this.BindingData{selectedSignal}.ControlName=controlName;
                this.BindingTable.Data{selectedSignal,this.BindingTableControlNameColIdx}=controlName;
            end
        end



        this.SignalControlNameEditField.Enable='on';
        this.SignalControlTypeDropDown.Enable='on';
        this.SignalBusElementEditField.Enable='on';
        this.SignalPropertyNameEditField.Enable='on';
        this.SignalDecimationEditField.Enable='on';
        this.SignalArrayIndexEditField.Enable='on';
        this.SignalCallbackEditField.Enable='on';
        if strcmp(newControlType,'Signal Table')

            this.SignalPropertyNameEditField.Value='';
            this.SignalPropertyNameEditField.Enable='off';
            this.BindingData{selectedSignal}.PropertyName='';

            this.SignalDecimationEditField.Value='';
            this.SignalDecimationEditField.Enable='off';
            this.BindingData{selectedSignal}.Decimation='';

            this.SignalArrayIndexEditField.Value='';
            this.SignalArrayIndexEditField.Enable='off';
            this.BindingData{selectedSignal}.ArrayIndex='';

            this.SignalBusElementEditField.Value='';
            this.SignalBusElementEditField.Enable='off';
            this.BindingData{selectedSignal}.BusElement='';

            this.SignalCallbackEditField.Value='';
            this.SignalCallbackEditField.Enable='off';
            this.BindingData{selectedSignal}.Callback='';

            this.showSignalPropertyPanels();

        elseif strcmp(newControlType,'Axes')
            this.SignalPropertyNameEditField.Value='';
            this.SignalPropertyNameEditField.Enable='off';
            this.BindingData{selectedSignal}.PropertyName='';

            this.showSignalWithLinePropertyPanels();

        elseif strcmp(newControlType,'NONE')
            this.SignalPropertyNameEditField.Value='';
            this.SignalPropertyNameEditField.Enable='off';
            this.BindingData{selectedSignal}.PropertyName='';

            this.SignalArrayIndexEditField.Value='';
            this.SignalArrayIndexEditField.Enable='off';
            this.BindingData{selectedSignal}.ArrayIndex='';

            this.SignalCallbackEditField.Value='';
            this.SignalCallbackEditField.Enable='off';
            this.BindingData{selectedSignal}.Callback='';

            this.showSignalPropertyPanels();
        else
            this.showSignalPropertyPanels();
        end



        this.BindingData{selectedSignal}.ControlType=newControlType;
        this.BindingTable.Data{selectedSignal,this.BindingTableControlTypeColIdx}=newControlType;



        if strcmp(newControlType,'NONE')
            if this.PropsMap.isKey(prevControlName)
                this.PropsMap.remove(prevControlName);
                this.closePropertyInspector();
            end
            this.SignalControlConfigureButton.Visible='off';
        else
            if~strcmp(prevControlType,newControlType)
                if this.PropsMap.isKey(prevControlName)
                    this.PropsMap.remove(controlName);
                end
                this.createComponentForPropsMap(controlName,newControlType);
                this.closePropertyInspector();
            end
            this.SignalControlConfigureButton.Visible='on';
        end
    end
    label=uilabel(grid);
    label.Layout.Row=2;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.ControlType_msg;
    label.Tooltip={this.ControlTypeSignalPropTooltip_msg};
    this.SignalControlTypeDropDown=uidropdown(grid);
    this.SignalControlTypeDropDown.Items=this.SignalControlTypes;
    this.SignalControlTypeDropDown.Layout.Row=2;
    this.SignalControlTypeDropDown.Layout.Column=[2,3];
    this.SignalControlTypeDropDown.ValueChangedFcn=@(o,e)controlTypeChanged(this,e);



    function propertyNameChanged(this,e)
        this.BindingData{this.BindingTable.Selection}.PropertyName=e.Value;
    end
    label=uilabel(grid);
    label.Layout.Row=3;
    label.Layout.Column=1;
    label.HorizontalAlignment='left';
    label.Text=this.PropertyName_msg;
    label.Tooltip={this.PropertyNameSignalPropTooltip_msg};
    this.SignalPropertyNameEditField=uieditfield(grid,'text');
    this.SignalPropertyNameEditField.Layout.Row=3;
    this.SignalPropertyNameEditField.Layout.Column=[2,3];
    this.SignalPropertyNameEditField.ValueChangedFcn=@(o,e)propertyNameChanged(this,e);



    function configureButtonPushed(this)
        if this.PropsMap.isKey(this.SignalControlNameEditField.Value)
            this.openPropertyInspector(this.PropsMap(this.SignalControlNameEditField.Value));
        end
    end
    this.SignalControlConfigureButton=uibutton(grid);
    this.SignalControlConfigureButton.Text='';
    this.SignalControlConfigureButton.Icon=this.Settings_icon24;
    this.SignalControlConfigureButton.Layout.Row=4;
    this.SignalControlConfigureButton.Layout.Column=3;
    this.SignalControlConfigureButton.ButtonPushedFcn=@(o,e)configureButtonPushed(this);
end