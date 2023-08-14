


classdef(ConstructOnLoad)ALTSGMII<eda.internal.component.BlackBox


    properties
gmii_rx_d
gmii_rx_dv
gmii_rx_err
tx_clk
rx_clk
tx_clkena
rx_clkena
txp
gmii_tx_d
gmii_tx_en
gmii_tx_err
clk
reset
rxp
ref_clk

CopyHDLFiles
        generic=generics('DEVICE_FAMILY','string','"STRATIXIV"');
    end

    methods
        function this=ALTSGMII(varargin)

            this.setGenerics(varargin);

            this.gmii_rx_d=eda.internal.component.Outport('FiType','std8');
            this.gmii_rx_dv=eda.internal.component.Outport('FiType','boolean');
            this.gmii_rx_err=eda.internal.component.Outport('FiType','boolean');
            this.tx_clk=eda.internal.component.Outport('FiType','boolean');
            this.rx_clk=eda.internal.component.Outport('FiType','boolean');
            this.tx_clkena=eda.internal.component.Outport('FiType','boolean');
            this.rx_clkena=eda.internal.component.Outport('FiType','boolean');
            this.txp=eda.internal.component.Outport('FiType','boolean');
            this.gmii_tx_d=eda.internal.component.Inport('FiType','std8');
            this.gmii_tx_en=eda.internal.component.Inport('FiType','boolean');
            this.gmii_tx_err=eda.internal.component.Inport('FiType','boolean');
            this.clk=eda.internal.component.Inport('FiType','boolean');
            this.reset=eda.internal.component.Inport('FiType','boolean');
            this.rxp=eda.internal.component.Inport('FiType','boolean');
            this.ref_clk=eda.internal.component.Inport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@ALTSGMII')};
            this.HDLFiles={'ALTSGMII.vhd'};

        end
    end

end

