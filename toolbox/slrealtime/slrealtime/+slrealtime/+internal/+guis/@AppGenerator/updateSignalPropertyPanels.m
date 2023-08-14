function updateSignalPropertyPanels(this,row)





    e.Value=slrealtime.internal.displayBlockPath(this.BindingData{row}.BlockPath);
    e.PreviousValue=e.Value;
    this.SignalBlockPathEditField.Value=e.Value;


    e.Value=num2str(this.BindingData{row}.PortIndex);
    e.PreviousValue=e.Value;
    this.SignalPortIndexEditField.Value=e.Value;


    e.Value=this.BindingData{row}.SignalName;
    e.PreviousValue=e.Value;
    this.SignalNameEditField.Value=e.Value;


    e.Value=this.BindingData{row}.ControlName;
    e.PreviousValue=e.Value;
    this.SignalControlNameEditField.Value=e.Value;
    this.SignalControlNameEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.ControlType;
    e.PreviousValue=e.Value;
    this.SignalControlTypeDropDown.Value=e.Value;
    this.SignalControlTypeDropDown.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.BusElement;
    e.PreviousValue=e.Value;
    this.SignalBusElementEditField.Value=e.Value;
    this.SignalBusElementEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.PropertyName;
    e.PreviousValue=e.Value;
    this.SignalPropertyNameEditField.Value=e.Value;
    this.SignalPropertyNameEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.Decimation;
    e.PreviousValue=e.Value;
    this.SignalDecimationEditField.Value=e.Value;
    this.SignalDecimationEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.ArrayIndex;
    e.PreviousValue=e.Value;
    this.SignalArrayIndexEditField.Value=e.Value;
    this.SignalArrayIndexEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.Callback;
    e.PreviousValue=e.Value;
    this.SignalCallbackEditField.Value=e.Value;
    this.SignalCallbackEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.LineWidth;
    e.PreviousValue=e.Value;
    this.SignalLineWidthEditField.Value=e.Value;
    this.SignalLineWidthEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.LineStyle;
    e.PreviousValue=e.Value;
    this.SignalLineStyleDropDown.Value=e.Value;
    this.SignalLineStyleDropDown.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.LineColor;
    e.PreviousValue=e.Value;
    this.SignalLineColorEditField.Value=e.Value;
    this.SignalLineColorEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.LineMarker;
    e.PreviousValue=e.Value;
    this.SignalLineMarkerDropDown.Value=e.Value;
    this.SignalLineMarkerDropDown.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.LineMarkerSize;
    e.PreviousValue=e.Value;
    this.SignalLineMarkerSizeEditField.Value=e.Value;
    this.SignalLineMarkerSizeEditField.ValueChangedFcn(this,e);
end
