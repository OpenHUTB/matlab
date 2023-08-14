



function getAddOnsCB(userdata,~)
    switch userdata
    case 'addOns'
        matlab.internal.addons.launchers.showExplorer("sltoolstrip","productFamily","Simulink","addOnType","apps");
    case 'hardware'
        matlab.internal.addons.launchers.showExplorer("sltoolstrip","productFamily","Simulink","addOnType","hardware_support");
    case 'manager'
        matlab.internal.addons.launchers.showManager("sltoolstrip");
    end
end
