













































function dngConfigure()

    if connector.securePort==31515
        oslc.configure();
    else
        wrongPortMessage=[...
        getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine1',connector.securePort)),...
        newline,...
        getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine3'))];
        error(wrongPortMessage);
    end
end
