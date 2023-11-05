classdef AltJTAG<eda.internal.boardmanager.FILCommInterface

    properties(Constant)
        Name='Altera JTAG';
        ConnectionDispName='JTAG';
        Communication_Channel='Altera JTAG';
    end
    properties
        RTIOStreamLibName='libmwrtiostream_ajtag';
        RTIOStreamParams='';
    end
    methods
        function r=getFormInstruction(~)
            r=DAStudio.message('EDALink:boardmanagergui:AJTAG_Instruction');
        end
        function r=getFrequency(~)
            r=6.0;
        end
        function defineInterface(~)
        end
    end

end



