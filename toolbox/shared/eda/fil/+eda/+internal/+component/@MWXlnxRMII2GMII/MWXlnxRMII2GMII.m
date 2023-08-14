
classdef MWXlnxRMII2GMII<eda.internal.component.BlackBox



    properties
sysclk
dutclk
macclk
dcm_reset
ETH_CRS
ETH_RXD
ETH_RXER
ETH_TXD
ETH_TXEN
ETH_RESET_n
ETH_REFCLK
ETH_MDC
ETH_MDIO
txclk
rxclk
txclk_en
rxclk_en
rxd
txd
rxdvld
rxerror
txen
txerror
col
crs
rst

CopyHDLFiles
    end

    methods
        function this=MWXlnxRMII2GMII(varargin)
            this.sysclk=eda.internal.component.Inport('FiType','boolean');
            this.dutclk=eda.internal.component.Outport('FiType','boolean');
            this.macclk=eda.internal.component.Outport('FiType','boolean');
            this.dcm_reset=eda.internal.component.Inport('FiType','boolean');
            this.ETH_CRS=eda.internal.component.Inport('FiType','boolean');
            this.ETH_RXD=eda.internal.component.Inport('FiType','std2');
            this.ETH_RXER=eda.internal.component.Inport('FiType','boolean');
            this.ETH_TXD=eda.internal.component.Outport('FiType','std2');
            this.ETH_TXEN=eda.internal.component.Outport('FiType','boolean');
            this.ETH_REFCLK=eda.internal.component.Outport('FiType','boolean');
            this.txclk=eda.internal.component.Outport('FiType','boolean');
            this.rxclk=eda.internal.component.Outport('FiType','boolean');
            this.txclk_en=eda.internal.component.Outport('FiType','boolean');
            this.rxclk_en=eda.internal.component.Outport('FiType','boolean');
            this.rxd=eda.internal.component.Outport('FiType','std8');
            this.txd=eda.internal.component.Inport('FiType','std8');
            this.rxdvld=eda.internal.component.Outport('FiType','boolean');
            this.rxerror=eda.internal.component.Outport('FiType','boolean');
            this.txen=eda.internal.component.Inport('FiType','boolean');
            this.txerror=eda.internal.component.Inport('FiType','boolean');
            this.col=eda.internal.component.Outport('FiType','boolean');
            this.crs=eda.internal.component.Outport('FiType','boolean');
            this.rst=eda.internal.component.Outport('FiType','boolean');

            mfilepath=mfilename('fullpath');
            [pathstr,~,~]=fileparts(mfilepath);
            this.HDLFileDir={pathstr};
            this.HDLFiles={'MWXlnxRMII2GMII.vhd','MWMII2GMII.vhd'};

        end
    end

end

