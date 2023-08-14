function[signals,srcDone,snkDone,tb_enb,testFailure]=hdltbsignaldecl(this)%#ok






    signals=[];

    bdt=hdlgetparameter('base_data_type');

    [~,tb_enb]=hdlnewsignal('tb_enb','block',-1,0,0,bdt,'boolean');
    hdlregsignal(tb_enb);
    hdladdclockenablesignal(tb_enb);
    signals=[signals,makehdlsignaldecl(tb_enb)];

    [~,srcDone]=hdlnewsignal('srcDone','block',-1,0,0,bdt,'boolean');
    signals=[signals,makehdlsignaldecl(srcDone)];

    [~,snkDone]=hdlnewsignal('snkDone','block',-1,0,0,bdt,'boolean');
    signals=[signals,makehdlsignaldecl(snkDone)];

    [~,testFailure]=hdlnewsignal('testFailure','block',-1,0,0,bdt,'boolean');
    signals=[signals,makehdlsignaldecl(testFailure)];
