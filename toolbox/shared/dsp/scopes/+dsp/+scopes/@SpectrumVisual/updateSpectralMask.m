function updateSpectralMask(this,propertyChangedFlag)





    if nargin<2
        propertyChangedFlag=false;
    end
    maskProps=get(this.MaskSpecificationObject);
    setPropertyValue(this,'SpectralMaskProperties',maskProps);
    hPlotter=this.Plotter;
    if isempty(hPlotter)
        return;
    end
    hMaskTester=this.MaskTesterObject;
    enabledMasks=this.MaskSpecificationObject.EnabledMasks;
    if strcmp(this.pViewType,'Spectrogram')||strcmp(this.pSpectrumType,'RMS')||...
        strcmp(this.pSpectrumUnits,'Watts')||isCCDFMode(this)

        hMaskTester.Enabled=false;
        hPlotter.SpectralMaskVisibility='None';
    elseif~isempty(this.NoDataAvailableTxt)||~isempty(this.CorrectionModeTxt)||...
        hPlotter.SamplesPerUpdateMsgStatus

        hMaskTester.Enabled=~strcmp(enabledMasks,'None');
        hPlotter.SpectralMaskVisibility='None';
    else
        hMaskTester.Enabled=~strcmp(enabledMasks,'None');
        hPlotter.SpectralMaskVisibility=enabledMasks;
    end


    if propertyChangedFlag
        redoMaskTest(this);
    end
    updateSpectralMaskReadout(this);