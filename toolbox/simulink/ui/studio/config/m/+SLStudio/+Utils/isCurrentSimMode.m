function checked=isCurrentSimMode(cbinfo,expMode)




    if nargin>1
        expMode=convertStringsToChars(expMode);
    end

    modelH=SLStudio.Utils.getModelHandle(cbinfo);
    mode='normal';%#ok<NASGU>
    checked='Unchecked';


    rapidAccelStatus=get_param(modelH,'RapidAcceleratorSimStatus');
    if~strcmp(rapidAccelStatus,'inactive')
        mode='rapid-accelerator';
    else
        mode=SLStudio.Utils.getSimulationModeForToolstrip(modelH);
    end
    if strcmp(mode,expMode)
        checked='Checked';
    end
end
