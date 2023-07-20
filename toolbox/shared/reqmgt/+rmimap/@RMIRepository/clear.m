



function clear()

    rmidata.RmiSlData.reset();
    rmiml.RmiMlData.reset();
    rmide.RmiDeData.reset();
    rmitm.RmiTmData.reset();

    rmimap.RMIRepository.getInstance.reset();
end
