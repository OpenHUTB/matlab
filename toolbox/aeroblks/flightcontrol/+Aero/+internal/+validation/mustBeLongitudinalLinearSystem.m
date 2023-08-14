function mustBeLongitudinalLinearSystem(linSys)






    lonstates=Aero.internal.states.getLongitudinalStates(linSys.StateName);


    if numel(lonstates)~=4
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:InvalidStates'));
    end

end
