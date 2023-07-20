function configureFCA()








    if~builtin('license','test','Aerospace_Blockset')
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:noLicenseASB'));
    end

    if~builtin('license','checkout','Aerospace_Blockset')
        return;
    end


    if~builtin('license','test','Aerospace_Toolbox')
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:noLicenseAST'));
    end

    if~builtin('license','checkout','Aerospace_Toolbox')
        return;
    end


    if~builtin('license','test','Simulink_Control_Design')
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:noLicenseSCD'));
    end

    if~builtin('license','checkout','Simulink_Control_Design')
        return;
    end
end
