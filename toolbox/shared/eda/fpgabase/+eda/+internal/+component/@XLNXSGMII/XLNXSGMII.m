


classdef(ConstructOnLoad)XLNXSGMII<eda.internal.component.BlackBox


    properties
rxp
rxn
txp
txn
clk
gmii_txd
gmii_tx_en
gmii_tx_er
gmii_rxd
gmii_rx_dv
gmii_rx_er
gtrefclk_p
gtrefclk_n
mac_clk
dut_clk
reset
dcm_locked

CopyHDLFiles
    end

    methods
        function this=XLNXSGMII(varargin)

            this.rxp=eda.internal.component.Inport('FiType','boolean');
            this.rxn=eda.internal.component.Inport('FiType','boolean');
            this.txp=eda.internal.component.Outport('FiType','boolean');
            this.txn=eda.internal.component.Outport('FiType','boolean');
            this.clk=eda.internal.component.Inport('FiType','boolean');
            this.gmii_txd=eda.internal.component.Inport('FiType','std8');
            this.gmii_tx_en=eda.internal.component.Inport('FiType','boolean');
            this.gmii_tx_er=eda.internal.component.Inport('FiType','boolean');
            this.gmii_rxd=eda.internal.component.Outport('FiType','std8');
            this.gmii_rx_dv=eda.internal.component.Outport('FiType','boolean');
            this.gmii_rx_er=eda.internal.component.Outport('FiType','boolean');
            this.mac_clk=eda.internal.component.Outport('FiType','boolean');
            this.dut_clk=eda.internal.component.Outport('FiType','boolean');
            this.reset=eda.internal.component.Inport('FiType','boolean');
            this.dcm_locked=eda.internal.component.Outport('FiType','boolean');
            this.gtrefclk_p=eda.internal.component.Inport('FiType','boolean');
            this.gtrefclk_n=eda.internal.component.Inport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@XLNXSGMII')};
            this.HDLFiles={'XLNXSGMII.vhd'};

        end
    end

end

