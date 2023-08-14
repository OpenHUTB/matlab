function obj=hmiCreateDDGDialog(h,className)






    if isempty(className)
        className={get_param(h,'BlockType')};
    end


    switch className{1}
    case{'SliderSwitchBlock','ToggleSwitchBlock','RockerSwitchBlock'}
        className{1}='SwitchBlock';

    case{'CircularGaugeBlock','SemiCircularGaugeBlock','QuarterGaugeBlock','LinearGaugeBlock'}
        className{1}='GaugeBlock';

    case 'SliderBlock'
        className{1}='KnobBlock';

    otherwise

    end


    obj=hmiblockdlg.(className{1})(h);
end