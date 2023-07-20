function hdlbody=hdlresetgenbeh(this)


    hdlbody=[];
    if this.ForceReset==1
        singleClock=this.isDUTsingleClock;
        if singleClock
            default_reset_wait=this.resetlength;
            [ClockName,ResetName,~]=this.getSlowClockBundleNames;
        else
            default_reset_wait=this.lcm_clocktable*this.resetlength;
            if default_reset_wait<this.resetlength
                default_reset_wait=default_reset_wait*this.resetlength;
            end
            ClockName=this.ClockName;
            ResetName=this.ResetName;
        end

        isVhdl=hdlgetparameter('isvhdl');
        if isVhdl
            hdlbody=sprintf('%s  %s_gen: PROCESS\n  BEGIN\n    %s <= ''%d'';\n',...
            hdlbody,ResetName,ResetName,this.ForceResetValue);
            if default_reset_wait==0
                hdlbody=sprintf('%s    WAIT FOR %s;\n',...
                hdlbody,this.hdlclkhold(ClockName));
            else
                if singleClock
                    if hdlgetparameter('clockedge')==0
                        hdlbody=...
                        sprintf('%s    WAIT FOR %s * %d;\n    WAIT UNTIL %s''event AND %s = ''1'';\n    WAIT FOR %s;\n',...
                        hdlbody,this.hdlclkperiod(ClockName),...
                        default_reset_wait,ClockName,ClockName,...
                        this.hdlclkhold(ClockName));
                    else
                        hdlbody=...
                        sprintf('%s    WAIT FOR %s * %d;\n    WAIT UNTIL %s''event AND %s = ''0'';\n    WAIT FOR %s;\n',...
                        hdlbody,this.hdlclkperiod(ClockName),...
                        default_reset_wait,ClockName,ClockName,...
                        this.hdlclkhold(ClockName));
                    end
                else
                    hdlbody=...
                    sprintf('%s    WAIT FOR (%s * %d) - (%s - %s);\n',...
                    hdlbody,this.hdlclkperiod(ClockName),...
                    default_reset_wait,this.hdlclkperiod(ClockName),...
                    this.hdlclkhold(ClockName));
                end
            end
            hdlbody=sprintf('%s    %s <= ''%d'';\n    WAIT;\n  END PROCESS %s_gen;\n\n',...
            hdlbody,ResetName,1-this.ForceResetValue,ResetName);
            gp=pir;
            if hdlgetparameter('ResettableTimingController')&&...
                hdlgetparameter('ClockInputs')==1&&...
                gp.hasMultipleDataRates==1
                hN=gp.getTopNetwork;
                hP=hN.getInputPorts('reset');
                hdlbody=sprintf('%s  %s <= %s;\n\n',hdlbody,hP(end).Name,ResetName);
            end
        else
            hdlbody=sprintf('%s  initial  // reset block\n  begin // %s_gen\n    %s <= 1''b%d;\n',...
            hdlbody,ResetName,ResetName,this.ForceResetValue);
            if default_reset_wait==0
                hdlbody=sprintf('%s    # (%s);\n',hdlbody,this.hdlclkhold(ClockName));
            else
                if singleClock
                    if hdlgetparameter('clockedge')==0
                        hdlbody=...
                        sprintf('%s    # (%s * %d);\n    @ (posedge %s);\n    # (%s);\n',...
                        hdlbody,this.hdlclkperiod(ClockName),...
                        default_reset_wait,ClockName,this.hdlclkhold(ClockName));
                    else
                        hdlbody=...
                        sprintf('%s    # (%s * %d);\n    @ (negedge %s);\n    # (%s);\n',...
                        hdlbody,this.hdlclkperiod(ClockName),...
                        default_reset_wait,ClockName,this.hdlclkhold(ClockName));
                    end
                else
                    hdlbody=...
                    sprintf('%s    # ((%s * %d) - (%s - %s));\n',...
                    hdlbody,this.hdlclkperiod(ClockName),...
                    default_reset_wait,this.hdlclkperiod(ClockName),...
                    this.hdlclkhold(ClockName));
                end
            end
            hdlbody=sprintf('%s    %s <= 1''b%d;\n  end  // %s_gen\n\n',...
            hdlbody,ResetName,1-this.ForceResetValue,ResetName);
        end



        for ii=1:length(this.clockTable)
            if this.clockTable(ii).Kind==1&&~strcmp(this.clockTable(ii).Name,ResetName)
                if isVhdl
                    hdlbody=sprintf('%s  %s <= %s;\n\n',...
                    hdlbody,this.clockTable(ii).Name,ResetName);
                else
                    hdlbody=sprintf('%s  always @* %s = %s;\n\n',...
                    hdlbody,this.clockTable(ii).Name,ResetName);
                end
            end
        end
    end


