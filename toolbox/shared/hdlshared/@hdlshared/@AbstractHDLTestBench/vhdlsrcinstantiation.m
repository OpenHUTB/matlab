function[hdlbody,hdlsignals]=vhdlsrcinstantiation(this,component)





    bdt=hdlgetparameter('base_data_type');
    if component.datalength>1
        Size=ceil(log2(component.datalength));
    else
        Size=1;
    end
    [vtype,sltype]=hdlgettypesfromsizes(Size,0,0);

    [~,rdenbIdx]=hdlnewsignal([component.loggingPortName,'_rdenb'],'block',-1,0,0,bdt,'boolean');
    [~,addrIdx]=hdlnewsignal([component.loggingPortName,'_addr'],'block',-1,0,0,vtype,sltype);
    [~,doneIdx]=hdlnewsignal([component.loggingPortName,'_done'],'block',-1,0,0,bdt,'boolean');
    hdlsignals=[rdenbIdx,addrIdx,doneIdx];

    hdlbody=[...
    '  ',component.procedureName,...
    ' (\n',...
    '    clk       => ',this.getTaskClk(component),',\n',...
    '    reset     => ',this.getTaskReset(component),',\n',...
    '    rdenb     => ',hdlsignalname(rdenbIdx),',\n',...
    '    addr      => ',hdlsignalname(addrIdx),',\n',...
    '    done      => ',hdlsignalname(doneIdx),');\n\n'];

