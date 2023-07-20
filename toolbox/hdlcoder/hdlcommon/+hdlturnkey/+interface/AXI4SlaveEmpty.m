


classdef AXI4SlaveEmpty<hdlturnkey.interface.AXI4SlaveBase

    properties(Constant,Hidden)

        DefaultInterfaceID='AXI4SlaveEmpty';

        BusPortLabel='';
        BusNameMPD='';
        BusProtocolMPD='';
        BusProtocol='';


        PIRNetworkName='';
    end

    methods

        function obj=AXI4SlaveEmpty(varargin)


            interfaceID=hdlturnkey.interface.AXI4SlaveEmpty.DefaultInterfaceID;
            obj=obj@hdlturnkey.interface.AXI4SlaveBase(interfaceID,varargin{:});

        end

        function isa=isEmptyAXI4SlaveInterface(obj)%#ok<MANU>
            isa=true;
        end

        function result=showInInterfaceChoice(~,~)

            result=false;
        end
    end


    methods

        function elaborate(obj,hN,hElab)

            scheduleDUTAddrElab(obj,hElab);

            hAddrCell=obj.hBaseAddr.getAllAssignedAddressObj;

            for ii=1:length(hAddrCell)
                if(~isempty(hAddrCell{ii}.ElabInternalSignal))

                    portID=hAddrCell{ii}.AssignedPortName;
                    outPortName=sprintf('const_%s',portID);
                    hNetOutSignal=hAddrCell{ii}.addPirSignal(hN,outPortName);

                    pirelab.getConstComp(hN,hNetOutSignal,hAddrCell{ii}.InitValue);

                    pirtarget.connectSignals(hElab,{hNetOutSignal},hAddrCell{ii}.ElabInternalSignal,portID);
                end
            end
        end

        function[BusInportList,BusOutPortList]=getExternalPortList(obj)

        end

        function elaborateAXI4SlaveIP(obj,hN,hElab,hIPInSignals,hIPOutSignals,readDelayCount)

        end

        function generateRDInsertIPVivadoTcl(obj,fid,hTool)

        end
    end
end
