function baseEmit(this,varargin)





    rx=this.RxChain;
    tx=this.TxChain;

    disp(sprintf('%s',hdlcodegenmsgs(1)));
    disp(sprintf('\n'));
    usrpfiltername=hdlgetparameter('filter_name');

    hdlsetparameter('filter_name',[usrpfiltername,'_rx']);
    rx.emit;

    hdlsetparameter('filter_name',[usrpfiltername,'_tx']);
    tx.emit;

