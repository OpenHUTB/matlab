function generatehdlcode(this,filterobj,varargin)










    usrpfiltername=this.HDLParameters.CLI.Name;
    usrpfiltertbname=this.HDLParameters.CLI.TestbenchName;




    if strcmpi(usrpfiltertbname(end-2:end),'_tb')
        rxfilttb_name=[usrpfiltertbname(1:end-3),'_rx_tb'];
        txfilttb_name=[usrpfiltertbname(1:end-3),'_tx_tb'];
    else
        rxfilttb_name=[usrpfiltertbname,'_rx_tb'];
        txfilttb_name=[usrpfiltertbname,'_tx_tb'];
    end

    rx=this.RxChain;
    tx=this.TxChain;


    rx.HDLParameters.CLI.Name=[usrpfiltername,'_rx'];
    rx.HDLParameters.CLI.TestbenchName=rxfilttb_name;




    rx.HDLParameters.CLI.EnableFPGAWorkflow='off';



    indx_name=strcmpi(varargin,'name');
    pos_name=1:length(indx_name);
    pos_name=pos_name(indx_name);
    if~isempty(pos_name)
        varargin([pos_name,pos_name+1])=[];
    end

    indx_tbname=strcmpi(varargin,'TestBenchName');
    pos_tbname=1:length(indx_tbname);
    pos_tbname=pos_tbname(indx_tbname);
    if~isempty(pos_name)
        varargin([pos_tbname,pos_tbname+1])=[];
    end

    generatehdlcode(rx,filterobj.RxChain,varargin{:});


    tx.HDLParameters.CLI.Name=[usrpfiltername,'_tx'];
    tx.HDLParameters.CLI.TestbenchName=txfilttb_name;
    tx.HDLParameters.CLI.EnableFPGAWorkflow='off';

    generatehdlcode(tx,filterobj.TxChain,varargin{:});





