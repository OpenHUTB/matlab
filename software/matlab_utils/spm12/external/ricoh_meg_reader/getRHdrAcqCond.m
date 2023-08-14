













































function out=getRHdrAcqCond(filepath)

    function_revision=0;
    function_name='getRHdrAcqCond';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    ContinuousRawDataAcquisition=1;
    EvokedAverageDataAcquisition=2;
    EvokedRawDataAcquisition=3;

    NoTriggerMode=0;
    InternalTriggerMode=1;
    ExternalTriggerMode=2;
    AnalogChannelTriggerMode=3;
    MarkerTriggerMode=4;

    LOW_TO_HIGH=0;
    HIGH_TO_LOW=1;
    TOP_PEAK=2;
    BOTTOM_PEAK=3;












    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    key='tzsvq27h';
    sqf_acqcond=GetSqf(fid,key,'AcqCondition');
    sqf_sysinfo=GetSqf(fid,key,'SystemInfo');


    fclose(fid);

    if isempty(sqf_acqcond)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        return;
    end



    out.acq_type=sqf_acqcond.acq_type;
    switch sqf_acqcond.acq_type
    case ContinuousRawDataAcquisition
        out.sample_rate=sqf_acqcond.sample_rate;
        out.sample_count=sqf_acqcond.actual_count;
        out.specified_sample_count=sqf_acqcond.sample_count;
    case EvokedAverageDataAcquisition
        out.sample_rate=sqf_acqcond.sample_rate;
        out.frame_length=sqf_acqcond.frame_length;
        out.pretrigger_length=sqf_acqcond.pretrigger_length;
        out.average_count=sqf_acqcond.actual_count;
        out.specified_average_count=sqf_acqcond.average_count;
    case EvokedRawDataAcquisition
        out.sample_rate=sqf_acqcond.sample_rate;
        out.frame_length=sqf_acqcond.frame_length;
        out.pretrigger_length=sqf_acqcond.pretrigger_length;
        out.average_count=sqf_acqcond.actual_count;
        out.specified_average_count=sqf_acqcond.average_count;
    end





























    switch sqf_acqcond.acq_type
    case ContinuousRawDataAcquisition


    case{EvokedAverageDataAcquisition,EvokedRawDataAcquisition}
        multi_trigger_list=[];
        if sqf_acqcond.multi_trigger

            cnt=0;
            for ii=1:sqf_acqcond.multi_trigger_count
                if sqf_acqcond.multi_trigger_list(ii).event_code>0
                    cnt=cnt+1;
                    multi_trigger_list(cnt).enable=sqf_acqcond.multi_trigger_list(ii).enable;


                    multi_trigger_list(cnt).code=sqf_acqcond.multi_trigger_list(ii).event_code;
                    multi_trigger_list(cnt).name=sqf_acqcond.multi_trigger_list(ii).name;
                    multi_trigger_list(cnt).specified_average_count=sqf_acqcond.multi_trigger_list(ii).average_count;
                    multi_trigger_list(cnt).average_count=sqf_acqcond.multi_trigger_list(ii).actual_count;
                end
            end
        end
        if~isempty(multi_trigger_list)
            out.multi_trigger.enable=sqf_acqcond.multi_trigger;
            out.multi_trigger.count=sqf_acqcond.multi_trigger_count;
            out.multi_trigger.list=multi_trigger_list;
        else
            out.multi_trigger.enable=false;
            out.multi_trigger.count=0;
            out.multi_trigger.list=[];
        end
    end


























