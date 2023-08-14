

classdef mwfil_chifcore<eda.internal.component.BlackBox



    properties
clk
reset
din
din_valid
din_ready
dout
dout_valid
dout_ready
simcycle

dut_din
dut_dout
dut_enable


        generic=generics('INWORD','integer','1',...
        'OUTWORD','integer','1',...
        'WORDSIZE','integer','64',...
        'HASENABLE','integer','1');
CopyHDLFiles
    end

    methods
        function this=mwfil_chifcore(inWord,outWord,wordsize,hasenable)
            this.setGenerics({'INWORD',num2str(inWord),...
            'OUTWORD',num2str(outWord),...
            'WORDSIZE',num2str(wordsize),...
            'HASENABLE',num2str(hasenable)});
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;

            this.din=eda.internal.component.Inport('FiType',['std',num2str(wordsize)]);
            this.din_valid=eda.internal.component.Inport('FiType','boolean');
            this.din_ready=eda.internal.component.Outport('FiType','boolean');

            this.dout=eda.internal.component.Outport('FiType',['std',num2str(wordsize)]);
            this.dout_valid=eda.internal.component.Outport('FiType','boolean');
            this.dout_ready=eda.internal.component.Inport('FiType','boolean');

            this.simcycle=eda.internal.component.Inport('FiType','std16');


            this.dut_din=eda.internal.component.Outport('FiType',['std',num2str(inWord*wordsize)]);
            this.dut_dout=eda.internal.component.Inport('FiType',['std',num2str(outWord*wordsize)]);
            this.dut_enable=eda.internal.component.Outport('FiType','boolean');

            designDir=fullfile(matlabroot,'toolbox','shared','eda','fil','+eda','+internal','+filhdl','@mwfil_chifcore');
            this.HDLFileDir=designDir;
            this.HDLFiles={'mwfil_dpscram.vhd','mwfil_udfifo.vhd','mwfil_bus2dut.vhd','mwfil_chifcore.vhd','mwfil_controller.vhd','mwfil_dut2bus.vhd'};
        end


    end
end