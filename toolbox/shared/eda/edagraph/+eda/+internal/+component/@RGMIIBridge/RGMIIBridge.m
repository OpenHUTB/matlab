



classdef(ConstructOnLoad)RGMIIBridge<eda.internal.component.BlackBox

    properties
rxclk
txclk
reset

rgmii_rxd
rgmii_rxctrl

rgmii_txd
rgmii_txctrl

gmii_rxd
gmii_rx_dv
gmii_rx_er
gmii_txd
gmii_tx_en
gmii_tx_er
gmii_col
gmii_crs


CopyHDLFiles
    end

    methods
        function this=RGMIIBridge(varargin)

            this.setGenerics(varargin);

            this.rxclk=eda.internal.component.ClockPort;
            this.txclk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;

            this.rgmii_rxd=eda.internal.component.Inport('FiType','std8');
            this.rgmii_rxctrl=eda.internal.component.Inport('FiType','std2');
            this.rgmii_txd=eda.internal.component.Outport('FiType','std8');
            this.rgmii_txctrl=eda.internal.component.Outport('FiType','std2');

            this.gmii_txd=eda.internal.component.Inport('FiType','std8');
            this.gmii_tx_en=eda.internal.component.Inport('FiType','boolean');
            this.gmii_tx_er=eda.internal.component.Inport('FiType','boolean');
            this.gmii_rxd=eda.internal.component.Outport('FiType','std8');
            this.gmii_rx_dv=eda.internal.component.Outport('FiType','boolean');
            this.gmii_rx_er=eda.internal.component.Outport('FiType','boolean');
            this.gmii_col=eda.internal.component.Outport('FiType','boolean');
            this.gmii_crs=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','edagraph',...
            '+eda','+internal','+component','@RGMIIBridge')};
            this.HDLFiles={'rgmiiBridge.vhd'};
        end
    end

end

