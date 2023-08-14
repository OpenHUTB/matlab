


classdef(ConstructOnLoad)MWMdioAdv<eda.internal.component.BlackBox



    properties
CLK
ETH_RESET_n
RESET
ETH_MDIO
ETH_MDC
CopyHDLFiles
        generic=generics('DownSampleFactor','integer','50',...
        'data0','std16','"0000000000000000"',...
        'data1','std16','"0000000000000000"',...
        'data2','std16','"0000000000000000"',...
        'data3','std16','"0000000000000000"',...
        'data4','std16','"0000000000000000"',...
        'data5','std16','"0000000000000000"',...
        'data6','std16','"0000000000000000"',...
        'data7','std16','"0000000000000000"');
    end

    methods
        function this=MWMdioAdv(varargin)

            this.setGenerics(varargin);

            this.CLK=eda.internal.component.ClockPort;
            this.RESET=eda.internal.component.ResetPort;

            this.RESET=eda.internal.component.Inport('FiType','boolean');
            this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
            this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
            this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMdioAdv')};
            this.HDLFiles={'MWMdioAdv.vhd','MDIOROM.vhd'};

        end
    end

end

