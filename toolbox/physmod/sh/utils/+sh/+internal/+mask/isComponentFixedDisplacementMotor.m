function result=isComponentFixedDisplacementMotor(componentPath)

    result=any(strcmp(componentPath,...
    {'sh.pumps_motors.hydraulic_motor'}));
end