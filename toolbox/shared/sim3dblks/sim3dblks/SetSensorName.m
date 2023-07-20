function SetSensorName(Block)
    if autoblkschecksimstopped(Block)
        mask=Simulink.Mask.get(Block);
        sensorId=get_param(gcb,'sensorId');

        sensorTag=mask.getParameter('sensorTag');
        sensorTag.Value=['Sim3dSensor',sensorId];

        sensorName=mask.getParameter('sensorName');
        sensorName.Value=['Sim3dSensor',sensorId];
    end
end