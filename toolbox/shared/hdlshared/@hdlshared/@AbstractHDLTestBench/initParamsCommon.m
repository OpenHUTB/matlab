function initParamsCommon(this)


    this.TestBenchName=hdlgetparameter('tb_name');
    this.TestBenchPostfix=hdlgetparameter('tb_postfix');
    this.TestBenchDataPostfix=hdlgetparameter('tbdata_postfix');

    this.TBFileNameSuffix=hdlgetparameter('filename_suffix');

    this.TestBenchStimulus=hdlgetparameter('tb_stimulus');

    this.TBRefSignals=hdlgetparameter('tbrefsignals');

    this.ClockName=hdlgetparameter('clockname');
    this.ClockEnableName=hdlgetparameter('clockenablename');
    this.ResetName=hdlgetparameter('resetname');
    this.DataValidName=hdlgetparameter('clockenableoutputname');

    this.ForceClockEnable=hdlgetparameter('force_clockenable');
    this.ForceClockEnableValue=hdlgetparameter('force_clockenable_value');

    this.ForceClock=hdlgetparameter('force_clock');
    this.ForceClockHighTime=hdlgetparameter('force_clock_high_time');
    this.ForceClockLowTime=hdlgetparameter('force_clock_low_time');

    this.ForceReset=hdlgetparameter('force_reset');
    this.ForceResetValue=hdlgetparameter('force_reset_value');
    this.ForceHoldTime=hdlgetparameter('force_hold_time');

    this.ErrorMargin=hdlgetparameter('error_margin');

    setSimResoultion(this);


    this.TargetLanguage=hdlgetparameter('target_language');
    this.CodeGenDirectory=hdlGetCodegendir;


    this.TestBenchClockEnableDelay=hdlgetparameter('TestBenchClockEnableDelay');
    this.holdInputDataBetweenSamples=hdlgetparameter('HoldInputDataBetweenSamples');
    this.initializetestbenchinputs=hdlgetparameter('initializetestbenchinputs');
    this.resetlength=hdlgetparameter('resetlength');

    this.TestBenchFile='on';
    this.tbFileId=-1;
    this.tbPkgFileId=-1;
    this.tbDataFileId=-1;
    if hdlgetparameter('multifiletestbench')
        this.TestBenchPackageFile='on';
        this.TestBenchdataFile='on';
    else
        this.TestBenchPackageFile='off';
        this.TestBenchdataFile='off';
    end

    this.additionalSimFailureMsg='';


    function resolution=getResolution(value)

        resolution=1;
        if(rem(value,1)==0)
            resolution=1;
        else
            for exp=1:6;
                if(rem(value*10^exp,1)==0)
                    resolution=10^exp;
                    break;
                end
            end
        end


        function setSimResoultion(this)
            res1=getResolution(this.ForceClockHighTime);
            res2=getResolution(this.ForceClockLowTime);
            res3=getResolution(this.ForceHoldTime);
            res=max([res1,res2,res3]);
            this.HDLSimResolution='1 ns';
            if(res>1&&res<=1000)
                this.HDLSimResolution=('1 ps');
            elseif(res>1000&&res<=1000000)
                this.HDLSimResolution=('1 fs');
            end


