function hdlbody=hdltestdone(this,task_rdenb,done,checkDone,instance)







    check_done=hdlsignalname(checkDone);
    last_data=hdlsignalname(done);
    ceo=hdlsignalname(task_rdenb);
    snk=this.OutportSnk(instance);

    if hdlgetparameter('isvhdl')
        if snk.datalength>1
            done_condition=[check_done,' = ''0'' AND ',last_data,' = ''1'' AND ',ceo,' = ''1'''];
        else
            done_condition=[check_done,' = ''0'' AND ',ceo,' = ''1'''];
        end

        if hdlgetparameter('clockedge')==0
            clock_str=['    ELSIF ',this.ClockName,'''event and ',this.ClockName,' =''1'' THEN\n'];
        else
            clock_str=['    ELSIF ',this.ClockName,'''event and ',this.ClockName,' =''0'' THEN\n'];
        end

        hdlbody=[...
        '  checkDone_',num2str(instance),': PROCESS(',this.ClockName,', ',this.ResetName,')\n',...
        '  BEGIN\n',...
        '    IF ',this.ResetName,' = ',sprintf('''%d''',this.ForceResetValue),' THEN\n',...
        '      ',check_done,' <= ''0'';\n',...
        clock_str];
        hdlbody=[hdlbody,...
        '      IF ',done_condition,' THEN\n',...
        '        ',check_done,' <= ''1'';\n',...
        '      END IF;\n',...
        '    END IF;\n',...
        '  END PROCESS checkDone_',num2str(instance),';\n'];
    else
        if(this.ForceResetValue==0)
            resetedge='negedge';
        else
            resetedge='posedge';
        end

        if snk.datalength>1
            done_condition=['((',check_done,' == 0) && (',last_data,' == 1) && (',ceo,' == 1))'];
        else
            done_condition=['((',check_done,' == 0) && (',ceo,' == 1))'];
        end

        if hdlgetparameter('clockedge')==0
            clk_str=['  always @ (posedge ',this.ClockName,' or ',resetedge,' ',this.ResetName,') // checkDone_',num2str(instance),'\n'];
        else
            clk_str=['  always @ (negedge ',this.ClockName,' or ',resetedge,' ',this.ResetName,') // checkDone_',num2str(instance),'\n'];
        end

        hdlbody=[...
        clk_str,...
        '  begin\n',...
        '    if (',this.ResetName,' == ',sprintf('%d',this.ForceResetValue),')\n',...
        '      ',check_done,' <= 0;\n',...
        '    else if ',done_condition,'\n'...
        ,'      ',check_done,' <= 1;\n',...
        '  end\n\n'];
    end