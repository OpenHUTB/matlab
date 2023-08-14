function generatetbcode(this,filterobj,varargin)








    usrpfiltertbname=this.HDLParameters.CLI.TestbenchName;

    rx=this.RxChain;
    tx=this.TxChain;




    if strcmpi(usrpfiltertbname(end-2:end),'_tb')
        rxfilttb_name=[usrpfiltertbname(1:end-3),'_rx_tb'];
        txfilttb_name=[usrpfiltertbname(1:end-3),'_tx_tb'];
    else
        rxfilttb_name=[usrpfiltertbname,'_rx_tb'];
        txfilttb_name=[usrpfiltertbname,'_tx_tb'];
    end

    this.RxChain.HDLParameters.CLI.TestbenchName=rxfilttb_name;
    generatetbcode(rx,filterobj.RxChain,varargin{:});

    this.TxChain.HDLParameters.CLI.TestbenchName=txfilttb_name;
    generatetbcode(tx,filterobj.TxChain,varargin{:});



