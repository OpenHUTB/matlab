function performGlobalTBChecks(this)


    if this.getParameter('clockinputs')==2
        if~strcmpi(this.getParameter('generatecosimmodel'),'None')
            errMsg=message('hdlcoder:engine:cosimmodelmulticlock');
            this.addTestbenchCheck(this.ModelName,'error',errMsg);
        end
    end


    clkHighTime=this.getParameter('force_clock_high_time');
    if rem(clkHighTime,1)~=0
        errMsg=message('HDLShared:CLI:timescale','ClockHighTime',int2str(clkHighTime));
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
    end

    clkLowTime=this.getParameter('force_clock_low_time');
    if rem(clkLowTime,1)~=0
        errMsg=message('HDLShared:CLI:timescale','ClockLowTime',int2str(clkLowTime));
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
    end

    clkHoldTime=this.getParameter('force_hold_time');
    if rem(clkHoldTime,1)~=0
        errMsg=message('HDLShared:CLI:timescale','ClockHoldTime',int2str(clkHoldTime));
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
    end


    if this.getParameter('TriggerAsClock')
        warnMsg=message('HDLShared:CLI:TriggerAsClock');
        this.addTestbenchCheck(this.ModelName,'warning',warnMsg);
        warning(warnMsg);
    end


    if this.getParameter('minimizeglobalresets')
        nrim=this.getParameter('NoResetInitializationMode');
        if strcmpi(nrim,'None')
            warnMsg=message('HDLShared:CLI:testbench_minGlobalResets');
            this.addTestbenchCheck(this.ModelName,'warning',warnMsg);
            warning(warnMsg);
        end
    end


    if this.getParameter('generatemodel')==0
        errMsg=message('hdlcoder:hdldisp:GenerateModelTB');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
    end



    if isempty(this.getParameter('vhdl_library_name'))
        errMsg=message('hdlcoder:validate:VHDLLibraryNameEmpty');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
    end

    if this.getParameter('MinimizeClockEnables')==1&&...
        this.getParameter('ClockInputs')==2
        warnMsg=message('hdlcoder:validate:MultiClockNoEnableTB');
        this.addTestbenchCheck(this.ModelName,'warning',warnMsg);
    end

end


