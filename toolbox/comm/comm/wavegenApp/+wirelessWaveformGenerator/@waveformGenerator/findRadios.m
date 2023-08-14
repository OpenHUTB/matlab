function findRadios(obj,varargin)




    if nargin==1
        checkProduct=true;
    else
        checkProduct=varargin{1};
    end

    if checkProduct
        success=checkTransmitterProduct(obj);
        if~success
            return
        end
    end


    if obj.useAppContainer
        freezeApp(obj);
    else
        obj.ToolGroup.setWaiting(true);
    end

    obj.pTransmitBtn.Enabled=false;
    obj.pExportTxBtn.Enabled=false;

    if strcmp(obj.pCurrentHWType,'Instrument')

        if~isConnected(obj.pParameters.RadioDialog.HardwareInterface)
            findHardware(obj.pParameters.RadioDialog);
        end

    elseif any(strcmp(obj.pCurrentHWType,{'Pluto','USRP B/N/X','Wireless Testbench'}))
        findHardware(obj.pParameters.RadioDialog);


    end



    if obj.useAppContainer
        unfreezeApp(obj);
    else
        obj.ToolGroup.setWaiting(false);
    end