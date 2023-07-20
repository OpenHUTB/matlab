function rtwdemoOpenCalibrationTool(model)





    cbInfo.model.Handle=get_param(model,'handle');
    coder.internal.toolstrip.callback.exportASAP2CDF(cbInfo);
end
