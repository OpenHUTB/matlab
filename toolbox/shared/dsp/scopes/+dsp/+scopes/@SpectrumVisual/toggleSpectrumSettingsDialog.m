function toggleSpectrumSettingsDialog(this,varargin)




    if nargin>1
        this.SpectrumSettingsDialogEnabled=varargin{1};
    else
        this.SpectrumSettingsDialogEnabled=~this.SpectrumSettingsDialogEnabled;
    end

    if this.SimscapeMode&&this.InvalidSettingsInSimscapeMode
        this.SpectrumSettingsDialogEnabled=false;
    end

    dirtyState=getDirtyStatus(this);
    setPropertyValue(this,'ShowSettingsDialog',this.SpectrumSettingsDialogEnabled);
    restoreDirtyStatus(this,dirtyState);

    dlg=getSpectrumSettingsDialog(this);
    if isempty(dlg)&&~this.SpectrumSettingsDialogEnabled
        return
    end
    dlgName=getString(message('dspshared:SpectrumAnalyzer:SpectrumSettings'));
    if isempty(dlg)
        register=@matlabshared.scopes.measurements.registerMeasurementDialog;
        dialogConstructor=@dsp.scopes.SpectrumSettingsDialog;
        register(this,dlgName,dialogConstructor,this.SpectrumSettingsDialogEnabled);

        updateControlDialog(this,'SpectrumSettings');
        bestFitLegendLocation(this.Plotter);
    end
    setMeasurementDialogVisibility(this.DialogMgr,dlgName,this.SpectrumSettingsDialogEnabled);

    if this.IsRemoveScreenMsg
        this.Application.screenMsg(false);
    end

    updateSpanReadOut(this);
    updateSamplesPerUpdateMessage(this);
    updateNoDataAvailableMessage(this);
    updateCorrectionModeMessage(this);

    status=uiservices.logicalToOnOff(this.SpectrumSettingsDialogEnabled);
    set(this.Handles.SpectrumSettingsSplitButton,'State',status);
    if isfield(this.Handles,'SpectrumSettingsButton')
        set(this.Handles.SpectrumSettingsButton,'State',status);
    end
end