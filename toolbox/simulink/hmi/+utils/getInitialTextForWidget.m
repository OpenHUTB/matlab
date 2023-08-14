

function gettingStartedText=getInitialTextForWidget(widgetType)


    gettingStartedText='';
    switch widgetType
    case{'knob','KnobBlock','customTuningWebBlock','customtuningwebblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForKnobs');
    case 'radiobuttongroup'
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForRadioButtonGroup');
    case 'combobox'
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForComboBox');
    case 'checkbox'
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForCheckbox');
    case 'editfield'
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForEditField');
    case 'displayblock'
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForDisplayBlock');
    case{'slider','SliderBlock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForSlider');
    case{'switch','rotaryswitchblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForSwitches');
    case{'gauge','CircularGaugeBlock','SemiCircularGaugeBlock','QuarterGaugeBlock','LinearGaugeBlock','customGauge',...
        'customgaugeblock','customWebBlock','customwebblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForGauges');
    case{'lampblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForLamp');
    case{'multistateimage','multistateimageblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForMSI');
    case{'pushbutton','pushbuttonblock'}
        gettingStartedText=DAStudio.message('SimulinkHMI:selectionwidget:GettingStartedTextForPushButton');
    end

end