function checkoutSLREQLicense()




    if~builtin('license','checkout','Simulink_Requirements')
        exception=MException(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
        exception.throwAsCaller;
    end
end