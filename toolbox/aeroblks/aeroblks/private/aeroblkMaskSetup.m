function aeroblkMaskSetup()








    if~builtin('license','test','Aerospace_Toolbox')
        error(message('aero:licensing:noLicenseTlbx'));
    end

    if~builtin('license','checkout','Aerospace_Toolbox')
        return;
    end

end
