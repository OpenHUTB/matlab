function[hdlbody,hdlsignals]=verilogsrcinstantiation(this,component)





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

    hdlregsignal(addrIdx);
    hdlregsignal(doneIdx);

    if(this.ForceResetValue==0)
        reset_edge='negedge';
    else
        reset_edge='posedge';
    end

    sp='';
    num_sp=length([component.procedureName,'(']);
    spacing=eval(['sprintf(''%',num2str(num_sp),'s'',sp)']);

    if hdlgetparameter('clockedge')==0
        clk_str=['  always @(posedge ',this.getTaskClk(component),' or ',reset_edge,' ',this.getTaskReset(component),')\n'];
    else
        clk_str=['  always @(negedge ',this.getTaskClk(component),' or ',reset_edge,' ',this.getTaskReset(component),')\n'];
    end

    hdlbody=[clk_str,...
'  begin\n'...
    ,'    ',component.procedureName,'(',this.getTaskClk(component),',',this.getTaskReset(component),',\n'...
    ,'    ',spacing,hdlsignalname(rdenbIdx),',',hdlsignalname(addrIdx),',\n',...
    '    ',spacing,hdlsignalname(doneIdx),');\n'...
    ,'  end\n\n'];
