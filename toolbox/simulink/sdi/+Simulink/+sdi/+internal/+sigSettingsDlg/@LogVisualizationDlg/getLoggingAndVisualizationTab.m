function tab=getLoggingAndVisualizationTab(this,visualizationProps)



    logVisGroup.Tag='logVisGroup';
    logVisGroup.Type='group';
    logVisGroup.Items={};
    curRow=1;

    ps=getPortSettings(this);


    customNameCheck.Tag='chkCustomName';
    customNameCheck.Type='checkbox';
    customNameCheck.Name=getString(message('SDI:dialogs:SigSettingsCustomNameLabel'));
    customNameCheck.ToolTip=getString(message('SDI:dialogs:SigSettingsCustomNameTooltip'));
    customNameCheck.Value=ps.UseCustomName;
    customNameCheck.ObjectMethod='loggingSettingChangeCB';
    customNameCheck.MethodArgs={'%dialog'};
    customNameCheck.ArgDataTypes={'handle'};
    customNameCheck.RowSpan=[curRow,curRow];
    customNameCheck.ColSpan=[1,1];

    customNameEdit.Tag='txtCustomName';
    customNameEdit.Type='edit';
    customNameEdit.Value=ps.CustomName;
    customNameEdit.Enabled=ps.UseCustomName;
    customNameEdit.RowSpan=customNameCheck.RowSpan;
    customNameEdit.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{customNameCheck,customNameEdit}];
    curRow=curRow+1;


    decimateCheck.Tag='chkDecimate';
    decimateCheck.Type='checkbox';
    decimateCheck.Name=getString(message('SDI:dialogs:SigSettingsDecimationLabel'));
    decimateCheck.ToolTip=getString(message('SDI:dialogs:SigSettingsDecimationTooltip'));
    decimateCheck.Value=ps.DecimateData;
    decimateCheck.ObjectMethod='loggingSettingChangeCB';
    decimateCheck.MethodArgs={'%dialog'};
    decimateCheck.ArgDataTypes={'handle'};
    decimateCheck.RowSpan=[curRow,curRow];
    decimateCheck.ColSpan=[1,1];

    decimateEdit.Tag='txtDecimate';
    decimateEdit.Type='edit';
    decimateEdit.Value=ps.Decimation;
    decimateEdit.Enabled=ps.DecimateData;
    decimateEdit.RowSpan=decimateCheck.RowSpan;
    decimateEdit.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{decimateCheck,decimateEdit}];
    curRow=curRow+1;


    maxPointsCheck.Tag='chkMaxPoints';
    maxPointsCheck.Type='checkbox';
    maxPointsCheck.Name=getString(message('SDI:dialogs:SigSettingsMaxPointsLabel'));
    maxPointsCheck.ToolTip=getString(message('SDI:dialogs:SigSettingsMaxPointsTooltip'));
    maxPointsCheck.Value=ps.LimitDataPoints;
    maxPointsCheck.ObjectMethod='loggingSettingChangeCB';
    maxPointsCheck.MethodArgs={'%dialog'};
    maxPointsCheck.ArgDataTypes={'handle'};
    maxPointsCheck.RowSpan=[curRow,curRow];
    maxPointsCheck.ColSpan=[1,1];

    maxPointsEdit.Tag='txtMaxPoints';
    maxPointsEdit.Type='edit';
    maxPointsEdit.Value=ps.MaxPoints;
    maxPointsEdit.Enabled=ps.LimitDataPoints;
    maxPointsEdit.RowSpan=maxPointsCheck.RowSpan;
    maxPointsEdit.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{maxPointsCheck,maxPointsEdit}];
    curRow=curRow+1;


    sampleTimeLabel.Tag='lblSampleTime';
    sampleTimeLabel.Type='text';
    sampleTimeLabel.Name=getString(message('SDI:dialogs:SigSettingsSampleTimeLabel'));
    sampleTimeLabel.ToolTip=getString(message('SDI:dialogs:SigSettingsSampleTimeTooltip'));
    sampleTimeLabel.RowSpan=[curRow,curRow];
    sampleTimeLabel.ColSpan=[1,1];

    sampleTimeEdit.Tag='txtSampleTime';
    sampleTimeEdit.Type='edit';
    sampleTimeEdit.Value=ps.SampleTime;
    sampleTimeEdit.RowSpan=sampleTimeLabel.RowSpan;
    sampleTimeEdit.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{sampleTimeLabel,sampleTimeEdit}];
    curRow=curRow+1;


    framesLabel.Tag='lblFrameMode';
    framesLabel.Type='text';
    framesLabel.Name=getString(message('SDI:dialogs:SigSettingsFrameLabel'));
    framesLabel.ToolTip=getString(message('SDI:dialogs:SigSettingsFrameTooltip'));
    framesLabel.RowSpan=[curRow,curRow];
    framesLabel.ColSpan=[1,1];

    framesCombo.Tag=this.FRAME_MODE_TAG;
    framesCombo.Type='combobox';
    framesCombo.Values=[1,0];
    framesCombo.Value=0;
    framesCombo.Entries={...
    getString(message('SDI:dialogs:SigSettingsFrameMode')),...
    getString(message('SDI:dialogs:SigSettingsSampleMode'))...
    };
    framesCombo.RowSpan=framesLabel.RowSpan;
    framesCombo.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{framesLabel,framesCombo}];
    curRow=curRow+1;


    if Simulink.sdi.enableSDIVideo>1
        visTypeLabel.Tag='lblVisualType';
        visTypeLabel.Type='text';
        visTypeLabel.Name=getString(message('SDI:dialogs:SigSettingsVisualType'));
        visTypeLabel.ToolTip=getString(message('SDI:dialogs:SigSettingsVisualTypeTooltip'));
        visTypeLabel.RowSpan=[curRow,curRow];
        visTypeLabel.ColSpan=[1,1];

        visTypeCombo.Tag=this.VISUAL_TYPE_TAG;
        visTypeCombo.Type='combobox';
        visTypeCombo.Values=[0,1];
        visTypeCombo.Value=0;
        visTypeCombo.Entries={...
        getString(message('SDI:dialogs:SigSettingsVisModeAuto')),...
        getString(message('SDI:dialogs:SigSettingsVisModeVideo'))...
        };
        visTypeCombo.RowSpan=visTypeLabel.RowSpan;
        visTypeCombo.ColSpan=[2,2];
        logVisGroup.Items=[logVisGroup.Items,{visTypeLabel,visTypeCombo}];
        curRow=curRow+1;
    end


    complexFormatLabel.Tag='lblComplexFormat';
    complexFormatLabel.Type='text';
    complexFormatLabel.Name=getString(message('SDI:dialogs:SigSettingsComplexFormatLabel'));
    complexFormatLabel.ToolTip=getString(message('SDI:dialogs:SigSettingsComplexFormatTooltip'));
    complexFormatLabel.RowSpan=[curRow,curRow];
    complexFormatLabel.ColSpan=[1,1];

    complexFormatCombo.Tag=this.COMPLEX_FORMAT_TAG;
    complexFormatCombo.Type='combobox';
    complexFormatCombo.Values=(0:3);
    complexFormatCombo.Value=0;
    complexFormatCombo.Entries={...
    getString(message('SDI:sdi:ComplexityFormatRIVal')),...
    getString(message('SDI:sdi:ComplexityFormatMPVal')),...
    getString(message('SDI:sdi:ComplexityFormatMagVal')),...
    getString(message('SDI:sdi:ComplexityFormatPhaseVal'))...
    };
    complexFormatCombo.RowSpan=complexFormatLabel.RowSpan;
    complexFormatCombo.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{complexFormatLabel,complexFormatCombo}];
    curRow=curRow+1;


    subPlotLabel.Tag='lblSubPlot';
    subPlotLabel.Type='text';
    subPlotLabel.Name=getString(message('SDI:dialogs:SigSettingsSubPlotsLabel'));
    subPlotLabel.ToolTip=getString(message('SDI:dialogs:SigSettingsSubPlotsTooltip'));
    subPlotLabel.RowSpan=[curRow,curRow];
    subPlotLabel.ColSpan=[1,1];

    subPlotEdit.Tag='txtSubPlot';
    subPlotEdit.Type='edit';
    subPlotEdit.PlaceholderText=getString(message('SDI:dialogs:SigSettingsSubPlotsPlaceholder'));
    subPlotEdit.ObjectMethod='loggingSettingChangeCB';
    subPlotEdit.MethodArgs={'%dialog'};
    subPlotEdit.ArgDataTypes={'handle'};
    subPlotEdit.RowSpan=subPlotLabel.RowSpan;
    subPlotEdit.ColSpan=[2,2];
    logVisGroup.Items=[logVisGroup.Items,{subPlotLabel,subPlotEdit}];
    curRow=curRow+1;





    if isfield(visualizationProps,'MinMaxButtons')
        visualizationProps=rmfield(visualizationProps,'MinMaxButtons');
    end
    visualizationProps.Items{1}.RowSpan=[curRow,curRow];
    visualizationProps.Items{1}.ColSpan=[1,2];
    logVisGroup.Items=[logVisGroup.Items,visualizationProps.Items];


    logVisGroup.LayoutGrid=[curRow,2];
    logVisGroup.RowStretch=zeros(1,curRow);
    logVisGroup.RowStretch(end)=1;
    logVisGroup.ColStretch=[0,1];

    tab.Name=getString(message('SDI:dialogs:SigSettingsLogTab'));
    tab.Items={logVisGroup};
end
