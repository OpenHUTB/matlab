
classdef MicrosemiSGMII<eda.internal.boardmanager.EthInterface
    properties(Constant)
        Name='Gigabit Ethernet - GMII';
        Communication_Channel='MicrosemiSGMII';
        isGigaEthInterface=true;
    end

    methods
        function defineInterface(~)
        end
    end
end
