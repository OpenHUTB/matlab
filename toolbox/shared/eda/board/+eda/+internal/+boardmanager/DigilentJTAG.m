

classdef DigilentJTAG<eda.internal.boardmanager.FILCommInterface

    properties(Constant)
        Name='JTAG';
        ConnectionDispName='JTAG';
        Communication_Channel='Digilent JTAG';
    end
    properties
        RTIOStreamLibName='libmwrtiostream_xjtag';
        RTIOStreamParams='';
    end
    properties
        User1Cmd='000010';
        User2Cmd='000011';
        User3Cmd='100010';
        User4Cmd='100011';
        InstrRegLenBefore=0;
        InstrRegLenAfter=0;
        TckFrequency=66;
    end
    methods
        function this=DigilentJTAG
        end
        function r=get.RTIOStreamParams(obj)
            r=sprintf('FPGAInstr=%s;FPGAInstr2=%s;FPGAInstr3=%s;FPGAInstr4=%s;InstrLenBefore=%d;InstrLenAfter=%d;TckFrequency=%f',...
            obj.User1Cmd,obj.User2Cmd,obj.User3Cmd,obj.User4Cmd,obj.InstrRegLenBefore,obj.InstrRegLenAfter,obj.TckFrequency);
        end
        function r=getFormInstruction(~)
            r=DAStudio.message('EDALink:boardmanagergui:XJTAG_Instruction');
        end
        function r=getFrequency(~)
            r=66.0;
        end
        function defineInterface(~)
        end
        function Value=getParam(obj,Name)
            Value=obj.(Name);
        end
        function r=getParamNames(~)
            r={'User1Cmd','InstrRegLenBefore','InstrRegLenAfter','TckFrequency'};
        end
        function setParam(obj,Name,Value)
            obj.(Name)=Value;
        end
    end

end



