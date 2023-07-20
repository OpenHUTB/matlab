
classdef(ConstructOnLoad)MWAPBArbiter<eda.internal.component.BlackBox



    properties

pClk
pReset
pSel
pRdata
pReady

dutData
dutReady

ddcData
ddcReady

ducData
ducReady

sysData
sysReady

UARTData
UARTReady

SPIData
SPIReady

I2CData
I2CReady

CopyHDLFiles

    end

    methods
        function this=MWAPBArbiter(varargin)

            this.setGenerics(varargin);

            this.pClk=eda.internal.component.ClockPort;
            this.pReset=eda.internal.component.ResetPort;
            this.pSel=eda.internal.component.Inport('FiType','std16');
            this.pRdata=eda.internal.component.Outport('FiType','std32');
            this.pReady=eda.internal.component.Outport('FiType','boolean');

            this.dutData=eda.internal.component.Inport('FiType','std32');
            this.dutReady=eda.internal.component.Inport('FiType','boolean');

            this.ddcData=eda.internal.component.Inport('FiType','std32');
            this.ddcReady=eda.internal.component.Inport('FiType','boolean');

            this.ducData=eda.internal.component.Inport('FiType','std32');
            this.ducReady=eda.internal.component.Inport('FiType','boolean');

            this.sysData=eda.internal.component.Inport('FiType','std32');
            this.sysReady=eda.internal.component.Inport('FiType','boolean');

            this.UARTData=eda.internal.component.Inport('FiType','std32');
            this.UARTReady=eda.internal.component.Inport('FiType','boolean');

            this.SPIData=eda.internal.component.Inport('FiType','std32');
            this.SPIReady=eda.internal.component.Inport('FiType','boolean');

            this.I2CData=eda.internal.component.Inport('FiType','std32');
            this.I2CReady=eda.internal.component.Inport('FiType','boolean');


            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWAPBArbiter')};
            this.HDLFiles={'MWAPBArbiter.vhd'};

        end
    end

end

