

classdef(Abstract)InterfacePCIBase<hdlturnkey.interface.AddressBased


    properties

    end

    methods

        function obj=InterfacePCIBase(interfaceID)


            obj=obj@hdlturnkey.interface.AddressBased(interfaceID);

        end

        function isa=isPCIInterface(obj)%#ok<*MANU>
            isa=true;
        end

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

        function elaborate(obj,hN,hElab)



            hInterfaceSignal=obj.addInterfacePort(hN);



            hIPSignals=obj.elaborateIOIP(hN,hElab,hInterfaceSignal);


            obj.connectInterfacePort(hN,hElab,hIPSignals);

        end

        function connectInterfacePort(obj,hN,hElab,hIPSignals)



            scheduleDUTAddrElab(obj,hElab);


            topInSignals=hIPSignals.hInportSignals;
            topOutSignals=hIPSignals.hOutportSignals;
            hAddrLists=[obj.hBaseAddr,obj.hIPCoreAddr];
            networkName=sprintf('%s_pci_decoder',hElab.TopNetName);
            pirtarget.getAddrDecoderNetwork(hN,...
            topInSignals,topOutSignals,hElab,hAddrLists,networkName,true);


        end

    end


    methods

    end


end



