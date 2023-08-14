function changeSampleRate(obj,popup)




    obj.pSampleRate=str2double(popup.Value);
    obj.pParameters.RadioDialog.setRate(obj.pSampleRate);

