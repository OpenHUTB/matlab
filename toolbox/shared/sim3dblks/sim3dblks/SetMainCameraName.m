function SetMainCameraName(Block)
    if autoblkschecksimstopped(Block)
        mask=Simulink.Mask.get(Block);
        sensorId=get_param(gcb,'sensorId');

        sensorTag=mask.getParameter('sensorTag');
        sensorTag.Value=['MainCamera',sensorId];

        sensorName=mask.getParameter('sensorName');
        sensorName.Value=['MainCamera',sensorId];
    end
end