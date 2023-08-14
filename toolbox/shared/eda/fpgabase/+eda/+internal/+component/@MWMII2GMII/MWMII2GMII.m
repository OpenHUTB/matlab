


classdef(ConstructOnLoad)MWMII2GMII<eda.internal.component.BlackBox


    properties
rxclk
txclk
reset
mii_rxdv
mii_rxer
mii_col
mii_crs
mii_rxd
mii_txd
mii_txen
mii_txer
rxdvld
rxerror
txerror
txen
txd
rxd
col
crs
txclk_en
rxclk_en
CopyHDLFiles
    end

    methods
        function this=MWMII2GMII(varargin)

            this.setGenerics(varargin);

            this.rxclk=eda.internal.component.Inport('FiType','boolean');
            this.txclk=eda.internal.component.Inport('FiType','boolean');
            this.reset=eda.internal.component.Inport('FiType','boolean');
            this.mii_rxdv=eda.internal.component.Inport('FiType','boolean');
            this.mii_rxer=eda.internal.component.Inport('FiType','boolean');
            this.mii_col=eda.internal.component.Inport('FiType','boolean');
            this.mii_crs=eda.internal.component.Inport('FiType','boolean');
            this.mii_rxd=eda.internal.component.Inport('FiType','std4');
            this.mii_txd=eda.internal.component.Outport('FiType','std4');
            this.mii_txen=eda.internal.component.Outport('FiType','boolean');
            this.mii_txer=eda.internal.component.Outport('FiType','boolean');

            this.rxdvld=eda.internal.component.Outport('FiType','boolean');
            this.txerror=eda.internal.component.Inport('FiType','boolean');
            this.rxerror=eda.internal.component.Outport('FiType','boolean');
            this.txd=eda.internal.component.Inport('FiType','std8');
            this.rxd=eda.internal.component.Outport('FiType','std8');
            this.col=eda.internal.component.Outport('FiType','boolean');
            this.crs=eda.internal.component.Outport('FiType','boolean');
            this.txen=eda.internal.component.Inport('FiType','boolean');
            this.txclk_en=eda.internal.component.Outport('FiType','boolean');
            this.rxclk_en=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMII2GMII')};
            this.HDLFiles={'MWMII2GMII.vhd'};

        end
    end

end

