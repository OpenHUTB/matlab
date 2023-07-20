function[hdlbody,hdlsignals]=hdlclkenb(this,tbenb,clkenb,snkDone,srcDone,rdEnb)





    enableBypassOn=this.isCEasDataValid();

    hdlbody=this.insertComment({'Global clock enable'});
    hdlsignals=[];


    clk_hold=this.hdlclkhold(this.ClockName);
    EnableName=hdlsignalname(clkenb);
    singleClock=this.isDUTsingleClock;
    isVhdl=hdlgetparameter('isvhdl');

    if~isempty(this.OutportSnk)


        if(enableBypassOn&&length(unique(rdEnb))==1)
            [~,srcDone_dly]=hdlnewsignal('srcDone_delay','block',-1,0,0,hdlgetparameter('base_data_type'),'boolean');
            [tmphdlbody,tmphdlsignals]=hdlintdelay(srcDone,srcDone_dly,'srcDone_delay_process',1,0);
            hdlbody=[hdlbody,tmphdlbody];
            hdlsignals=[hdlsignals,makehdlsignaldecl(srcDone_dly),tmphdlsignals];
            notDone=hdlsignalname(srcDone_dly);
            enbSrc=hdlsignalname(rdEnb(1));
        else
            notDone=hdlsignalname(snkDone);
            enbSrc=hdlsignalname(tbenb);
        end
    else
        notDone=hdlsignalname(srcDone);
        enbSrc=hdlsignalname(tbenb);
    end

    hdlbody=[hdlbody,createClkEnb(EnableName,enbSrc,clk_hold,notDone,isVhdl)];


    if~singleClock


        for ii=1:length(this.clockTable)
            if this.clockTable(ii).Kind==2&&~strcmp(this.clockTable(ii).Name,EnableName)
                delay=sprintf('(%s + %s)',this.hdlclkperiod(this.ClockName),clk_hold);
                hdlbody=[hdlbody,createClkEnb(this.clockTable(ii).Name,hdlsignalname(tbenb),delay,notDone,isVhdl)];%#ok<*AGROW>
            end
        end
    end

    function hdlbody=createClkEnb(EnableName,tbenb,delay,notDone,isVhdl)
        if isVhdl
            hdlbody=['  ',EnableName,' <= ',tbenb,' AFTER ',delay,' WHEN ',notDone,' = ''0'' ELSE\n',...
            '                ''0'' AFTER ',delay,';\n\n'];
        else
            hdlbody=['  always @(',notDone,', ',tbenb,')\n',...
            '  begin\n',...
            '    if (',notDone,' == 0)\n',...
            '      # ',delay,' ',EnableName,' <= ',tbenb,';\n',...
            '    else\n',...
            '      # ',delay,' ',EnableName,' <= 0;\n',...
            '  end\n\n'];
        end
