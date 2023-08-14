function result=isComponentMotorDrive(componentPath)





    result=any(strcmp(componentPath,...
    {'ee.electromech.motor_and_drive',...
    'ee.electromech.motor_and_drive_thermal'}));

end
