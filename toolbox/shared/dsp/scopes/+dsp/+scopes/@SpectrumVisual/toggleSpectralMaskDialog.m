function toggleSpectralMaskDialog(this,varargin)




    if nargin>1
        this.SpectralMaskDialogEnabled=varargin{1};
    else
        this.SpectralMaskDialogEnabled=~this.SpectralMaskDialogEnabled;
    end

    if this.SimscapeMode&&this.InvalidSettingsInSimscapeMode
        this.SpectralMaskDialogEnabled=false;
    end

    dirtyState=getDirtyStatus(this);
    setPropertyValue(this,'ShowSpectralMaskDialog',this.SpectralMaskDialogEnabled);
    restoreDirtyStatus(this,dirtyState);

    dlg=getSpectralMaskDialog(this);
    if isempty(dlg)&&~this.SpectralMaskDialogEnabled
        return
    end
    dlgName=getString(message('dspshared:SpectrumAnalyzer:SpectralMask'));
    if isempty(dlg)
        register=@matlabshared.scopes.measurements.registerMeasurementDialog;
        dialogConstructor=@dsp.scopes.SpectralMaskDialog;
        register(this,dlgName,dialogConstructor,this.SpectralMaskDialogEnabled);

        updateControlDialog(this,'SpectralMask');
        bestFitLegendLocation(this.Plotter);
    end
    setMeasurementDialogVisibility(this.DialogMgr,dlgName,this.SpectralMaskDialogEnabled);

    if this.IsRemoveScreenMsg
        this.Application.screenMsg(false);
    end

    updateSpanReadOut(this);
    updateSamplesPerUpdateMessage(this);
    updateNoDataAvailableMessage(this);
    updateCorrectionModeMessage(this);

    status=uiservices.logicalToOnOff(this.SpectralMaskDialogEnabled);
    if isfield(this.Handles,'SpectralMaskButton')
        set(this.Handles.SpectralMaskButton,'State',status);
    end
end