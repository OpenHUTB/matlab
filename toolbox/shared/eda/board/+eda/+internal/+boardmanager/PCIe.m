


classdef PCIe<eda.internal.boardmanager.FILCommInterface

    properties(Constant,Abstract)
        Name;
        ConnectionDispName;
        Communication_Channel;
    end
    properties(Abstract)
        MAC_Component_Name;
        RTIOStreamLibName;
        RTIOStreamParams;
    end
    methods
        function r=getFrequency(~)
            r=100.0;
        end
        function defineInterface(~)
        end
    end

end



