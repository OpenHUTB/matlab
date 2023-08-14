function is=isScalarParameterObj(d)





    is=~isempty(d)&&isscalar(d)&&...
    isa(d,'Simulink.Parameter');
end
