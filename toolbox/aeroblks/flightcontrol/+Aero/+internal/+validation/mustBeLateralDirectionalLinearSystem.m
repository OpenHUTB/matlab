function mustBeLateralDirectionalLinearSystem(linSys)






    latstates=Aero.internal.states.getLateralDirectionalStates(linSys.StateName);


    if numel(latstates)~=4
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:InvalidStatesLat'));
    end

end
