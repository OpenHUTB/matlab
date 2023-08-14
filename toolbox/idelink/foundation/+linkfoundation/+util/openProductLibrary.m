function openProductLibrary




    if linkfoundation.util.isMWSoftwareInstalled('simulink')
        uiopen('idelinklib.mdl',1);
    else
        error(message('ERRORHANDLER:utils:SimulinkNotInstalled',linkfoundation.util.getProductName));
    end


