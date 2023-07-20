function hasConstraint=hasFloatingPointConstraint(blockObject)























    hasConstraint=any(strcmp(blockObject.InterpMethod,{'Cubic spline','Akima spline'}))...
    ||(strncmp(blockObject.InterpMethod,'Linear',6)&&~strcmp(blockObject.ExtrapMethod,'Clip'));
end
