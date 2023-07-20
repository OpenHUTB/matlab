function result=isComponentFixedDisplacementPump(componentPath)

    result=any(strcmp(componentPath,...
    {'sh.pumps_motors.fx_displ_pump'}));
end