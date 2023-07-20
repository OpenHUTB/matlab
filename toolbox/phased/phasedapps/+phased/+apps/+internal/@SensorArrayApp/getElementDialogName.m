function elementDialog=getElementDialogName(obj)


    switch class(obj.CurrentElement)
    case 'phased.IsotropicAntennaElement'
        elementDialog=obj.ParametersPanel.IsotropicAntennaDialog;
    case 'phased.CosineAntennaElement'
        elementDialog=obj.ParametersPanel.CosineAntennaDialog;
    case 'phased.CustomAntennaElement'
        if~isPolarizationCapable(obj.CurrentElement)
            elementDialog=obj.ParametersPanel.CustomAntennaDialog;
        else
            elementDialog=obj.ParametersPanel.CustomPolarizedAntennaDialog;
        end
    case 'phased.SincAntennaElement'
        elementDialog=obj.ParametersPanel.SincAntennaDialog;
    case 'phased.GaussianAntennaElement'
        elementDialog=obj.ParametersPanel.GaussianAntennaDialog;
    case 'phased.CardioidAntennaElement'
        elementDialog=obj.ParametersPanel.CardioidAntennaDialog;
    case 'phased.CustomMicrophoneElement'
        if~obj.pFromSimulink&&obj.ToolStripDisplay.ElementGalleryItems{13}.Value
            elementDialog=obj.ParametersPanel.CardioidMicrophoneDialog;
        else
            elementDialog=obj.ParametersPanel.CustomMicrophoneDialog;
        end
    case 'phased.OmnidirectionalMicrophoneElement'
        elementDialog=obj.ParametersPanel.OmniMicrophoneDialog;
    case 'phased.IsotropicHydrophone'
        elementDialog=obj.ParametersPanel.HydrophoneDialog;
    case 'phased.IsotropicProjector'
        elementDialog=obj.ParametersPanel.ProjectorDialog;
    case 'phased.ShortDipoleAntennaElement'
        elementDialog=obj.ParametersPanel.ShortDipoleAntennaDialog;
    case 'phased.CrossedDipoleAntennaElement'
        elementDialog=obj.ParametersPanel.CrossedDipoleAntennaDialog;
    case 'phased.NRAntennaElement'
        elementDialog=obj.ParametersPanel.NRAntennaDialog;
    end
end