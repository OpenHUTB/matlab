


classdef(ConstructOnLoad)MWMdioBasic<eda.internal.component.BlackBox



    properties
RESET_IN
ETH_RESET_n
ETH_MDIO
ETH_MDC
CopyHDLFiles
    end

    methods
        function this=MWMdioBasic(varargin)
            this.RESET_IN=eda.internal.component.Inport('FiType','boolean');
            this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
            this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
            this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMdioBasic')};
            this.HDLFiles={'MWMdioBasic.vhd'};
        end
    end

end

