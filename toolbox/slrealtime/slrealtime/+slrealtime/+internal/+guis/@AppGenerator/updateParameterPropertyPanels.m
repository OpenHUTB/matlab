function updateParameterPropertyPanels(this,row)





    e.Value=slrealtime.internal.displayBlockPath(this.BindingData{row}.BlockPath);
    e.PreviousValue=e.Value;
    this.ParameterBlockPathEditField.Value=e.Value;


    e.Value=this.BindingData{row}.ParamName;
    e.PreviousValue=e.Value;
    this.ParameterNameEditField.Value=e.Value;


    e.Value=this.BindingData{row}.ControlName;
    e.PreviousValue=e.Value;
    this.ParameterControlNameEditField.Value=e.Value;
    this.ParameterControlNameEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.ControlType;
    e.PreviousValue=e.Value;
    this.ParameterControlTypeDropDown.Value=e.Value;
    this.ParameterControlTypeDropDown.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.ConvToComp;
    e.PreviousValue=e.Value;
    this.ParameterConvToCompEditField.Value=e.Value;
    this.ParameterConvToCompEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.ConvToTarget;
    e.PreviousValue=e.Value;
    this.ParameterConvToTargetEditField.Value=e.Value;
    this.ParameterConvToTargetEditField.ValueChangedFcn(this,e);

    e.Value=this.BindingData{row}.Element;
    e.PreviousValue=e.Value;
    this.ParameterElementEditField.Value=e.Value;
    this.ParameterElementEditField.ValueChangedFcn(this,e);
end
