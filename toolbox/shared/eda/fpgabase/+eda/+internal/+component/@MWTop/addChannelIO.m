function addChannelIO(this)



    switch this.Partition.Device.Communication_Channel
    case 'PCIe'
        props={
        'pcie_clk_p',...
        'pcie_clk_n',...
        'pcie_slot_reset_b',...
        'pcie_tx_p',...
        'pcie_tx_n',...
        'pcie_rx_p',...
        'pcie_rx_n'};
        for m=1:numel(props)
            addprop(this,props{m});
        end
        this.pcie_clk_p=eda.internal.component.ClockPort;
        this.pcie_clk_n=eda.internal.component.ClockPort;
        this.pcie_slot_reset_b=eda.internal.component.Inport('FiType','boolean');
        this.pcie_tx_p=eda.internal.component.Outport('FiType','std4');
        this.pcie_tx_n=eda.internal.component.Outport('FiType','std4');
        this.pcie_rx_p=eda.internal.component.Inport('FiType','std4');
        this.pcie_rx_n=eda.internal.component.Inport('FiType','std4');
    case{'SGMII','XlnxSGMII','XlnxSGMII625MhzRef','Arria10SGMII'}
        this.addprop('ETH_MDC');
        this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_MDIO');
        this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
        this.addprop('ETH_RESET_n');
        this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_TXP');
        this.ETH_TXP=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_RXP');
        this.ETH_RXP=eda.internal.component.Inport('FiType','boolean');

        if strcmpi(this.Partition.Device.PartInfo.FPGAVendor,'Xilinx')
            this.addprop('ETH_TXN');
            this.ETH_TXN=eda.internal.component.Outport('FiType','boolean');
            this.addprop('ETH_RXN');
            this.ETH_RXN=eda.internal.component.Inport('FiType','boolean');
            this.addprop('ETH_GTREFCLK_P');
            this.ETH_GTREFCLK_P=eda.internal.component.Inport('FiType','boolean');
            this.addprop('ETH_GTREFCLK_N');
            this.ETH_GTREFCLK_N=eda.internal.component.Inport('FiType','boolean');
        elseif strcmpi(this.Partition.Device.Communication_Channel,'Arria10SGMII')
            this.addprop('ETH_GTREFCLK_P');
            this.ETH_GTREFCLK_P=eda.internal.component.Inport('FiType','boolean');
            this.addprop('ETH_GTREFCLK_N');
            this.ETH_GTREFCLK_N=eda.internal.component.Inport('FiType','boolean');
        end

    case 'GMII'
        this.addprop('ETH_MDC');
        this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_MDIO');
        this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
        this.addprop('ETH_RESET_n');
        this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_RXCLK');
        this.ETH_RXCLK=eda.internal.component.ClockPort;
        this.addprop('ETH_RXD');
        this.ETH_RXD=eda.internal.component.Inport('FiType','std8');
        this.addprop('ETH_RXDV');
        this.ETH_RXDV=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_RXER');
        this.ETH_RXER=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_GTXCLK');
        this.ETH_GTXCLK=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_TXD');
        this.ETH_TXD=eda.internal.component.Outport('FiType','std8');
        this.addprop('ETH_TXEN');
        this.ETH_TXEN=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_TXER');
        this.ETH_TXER=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_COL');
        this.ETH_COL=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_CRS');
        this.ETH_CRS=eda.internal.component.Inport('FiType','boolean');
    case{'MII','MIIwith25MHzOut'}
        this.addprop('ETH_MDC');
        this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_MDIO');
        this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
        this.addprop('ETH_RESET_n');
        this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_RXD');
        this.ETH_RXD=eda.internal.component.Inport('FiType','std4');
        this.addprop('ETH_RXDV');
        this.ETH_RXDV=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_RXER');
        this.ETH_RXER=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_RXCLK');
        this.ETH_RXCLK=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_TXD');
        this.ETH_TXD=eda.internal.component.Outport('FiType','std4');
        this.addprop('ETH_TXCLK');
        this.ETH_TXCLK=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_TXEN');
        this.ETH_TXEN=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_TXER');
        this.ETH_TXER=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_COL');
        this.ETH_COL=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_CRS');
        this.ETH_CRS=eda.internal.component.Inport('FiType','boolean');
        if strcmpi(this.Partition.Device.Communication_Channel,'MIIwith25MHzOut')
            this.addprop('ETH_CLK25');
            this.ETH_CLK25=eda.internal.component.Outport('FiType','boolean');
        end
    case 'RGMII'
        this.addprop('ETH_MDC');
        this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_MDIO');
        this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
        this.addprop('ETH_RESET_n');
        this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_RXCLK');
        this.ETH_RXCLK=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_RXD');
        this.ETH_RXD=eda.internal.component.Inport('FiType','std4');
        this.addprop('ETH_RX_CTL');
        this.ETH_RX_CTL=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_TXCLK');
        this.ETH_TXCLK=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_TXD');
        this.ETH_TXD=eda.internal.component.Outport('FiType','std4');
        this.addprop('ETH_TX_CTL');
        this.ETH_TX_CTL=eda.internal.component.Outport('FiType','boolean');
    case 'RMII'
        this.addprop('ETH_MDC');
        this.ETH_MDC=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_MDIO');
        this.ETH_MDIO=eda.internal.component.InOutport('FiType','boolean');
        this.addprop('ETH_RESET_n');
        this.ETH_RESET_n=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_CRS');
        this.ETH_CRS=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_RXD');
        this.ETH_RXD=eda.internal.component.Inport('FiType','std2');
        this.addprop('ETH_RXER');
        this.ETH_RXER=eda.internal.component.Inport('FiType','boolean');
        this.addprop('ETH_TXD');
        this.ETH_TXD=eda.internal.component.Outport('FiType','std2');
        this.addprop('ETH_TXEN');
        this.ETH_TXEN=eda.internal.component.Outport('FiType','boolean');
        this.addprop('ETH_REFCLK');
        this.ETH_REFCLK=eda.internal.component.Outport('FiType','boolean');
    end

end