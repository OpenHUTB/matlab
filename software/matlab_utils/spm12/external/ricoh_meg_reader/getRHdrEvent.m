





















function out=getRHdrEvent(filepath)

    function_revision=0;
    function_name='getRHdrEvent';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    key='tzsvq27h';
    ContinuousRawDataAcquisition=1;
    EvokedAverageDataAcquisition=2;
    EvokedRawDataAcquisition=3;

    NoTriggerMode=0;
    InternalTriggerMode=1;
    ExternalTriggerMode=2;
    AnalogChannelTriggerMode=3;
    MarkerTriggerMode=4;


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    sqf_sysinfo=GetSqf(fid,key,'SystemInfo');
    if isempty(sqf_sysinfo)
        disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
        fclose(fid);
        return;
    end
    sqf_acqcond=GetSqf(fid,key,'AcqCondition');
    if isempty(sqf_acqcond)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        fclose(fid);
        return;
    end



    trigger_exist=true;
    trigger=GetSqf(fid,key,'TriggerEvent');
    if isempty(trigger)
        trigger_exist=false;
    end


    fclose(fid);














    event=[];

    switch sqf_acqcond.acq_type
    case ContinuousRawDataAcquisition

        if(sqf_sysinfo.version<3.0)
            event=[];

        elseif(sqf_sysinfo.version==3.0)
            if trigger_exist
                event_count=size(trigger,1);
                if sqf_acqcond.multi_trigger
                    event_list=zeros(sqf_acqcond.multi_trigger_count,1);

                    for ii=1:sqf_acqcond.multi_trigger_count
                        event_list(ii,:)=sqf_acqcond.multi_trigger_list(ii).event_code;
                    end

                    for ii=1:event_count
                        event(ii).sample_no=trigger(ii,1);
                        event(ii).code=trigger(ii,2);
                        index=find(event_list==event(ii).code);
                        if isempty(index)
                            event(ii).name='';
                        else
                            event(ii).name=sqf_acqcond.multi_trigger_list(index).name;
                        end
                    end
                end
            else

            end
        else
            if trigger_exist
                event_count=size(trigger,1);
                event_list=zeros(sqf_acqcond.multi_trigger_count,1);

                for ii=1:sqf_acqcond.multi_trigger_count
                    event_list(ii,:)=sqf_acqcond.multi_trigger_list(ii).event_code;
                end

                for ii=1:event_count
                    event(ii).sample_no=trigger(ii,1);
                    event(ii).code=trigger(ii,2);
                    index=find(event_list==event(ii).code);
                    if isempty(index)
                        event(ii).name='';
                    else
                        event(ii).name=sqf_acqcond.multi_trigger_list(index).name;
                    end
                end
            else

            end
        end

    case EvokedRawDataAcquisition
        if trigger_exist
            event_count=size(trigger,1);

            if sqf_acqcond.multi_trigger

                event_list=zeros(sqf_acqcond.multi_trigger_count,1);
                for ii=1:sqf_acqcond.multi_trigger_count
                    event_list(ii,:)=sqf_acqcond.multi_trigger_list(ii).event_code;
                end

                for ii=1:event_count
                    event(ii).sample_no=trigger(ii,1);
                    event(ii).code=trigger(ii,2);
                    index=find(event_list==event(ii).code);
                    if isempty(index)
                        event(ii).name='';
                    else
                        event(ii).name=sqf_acqcond.multi_trigger_list(index).name;
                    end
                end

            else
                for ii=1:event_count
                    event(ii).sample_no=trigger(ii,1);
                    event(ii).code=trigger(ii,2);
                    event(ii).name='';
                end
            end
        else
            switch sqf_acqcond.trigger_mode
            case NoTriggerMode
                str_name='NoTrigger';
            case InternalTriggerMode
                str_name='InternalTrigger';
            case ExternalTriggerMode
                str_name='ExternalTrigger';
            case AnalogChannelTriggerMode
                str_name=sprintf('ch%d',sqf_acqcond.analog_trigger_channel);
            case MarkerTriggerMode
                str_name='MarkerTrigger';
            otherwise
                str_name='';
            end
            for ii=1:sqf_acqcond.actual_count;
                event(ii).sample_no=sqf_acqcond.frame_length*(ii-1)+sqf_acqcond.pretrigger_length;
                event(ii).code=1;
                event(ii).name=str_name;
            end
        end

    case EvokedAverageDataAcquisition
        if trigger_exist
            event_count=size(trigger,1);

            if sqf_acqcond.multi_trigger

                event_list=zeros(sqf_acqcond.multi_trigger_count,1);
                for ii=1:sqf_acqcond.multi_trigger_count
                    event_list(ii,:)=sqf_acqcond.multi_trigger_list(ii).event_code;
                end

                for ii=1:event_count
                    event(ii).sample_no=trigger(ii,1);
                    event(ii).code=trigger(ii,2);
                    index=find(event_list==event(ii).code);
                    if isempty(index)
                        event(ii).name='';
                    else
                        event(ii).name=sqf_acqcond.multi_trigger_list(index).name;
                    end
                end

            else
                for ii=1:event_count
                    event(ii).sample_no=trigger(ii,1);
                    event(ii).code=trigger(ii,2);
                    event(ii).name='';
                end
            end
        else
            switch sqf_acqcond.trigger_mode
            case NoTriggerMode
                str_name='NoTrigger';
            case InternalTriggerMode
                str_name='InternalTrigger';
            case ExternalTriggerMode
                str_name='ExternalTrigger';
            case AnalogChannelTriggerMode
                str_name=sprintf('ch%d',sqf_acqcond.analog_trigger_channel);
            case MarkerTriggerMode
                str_name='MarkerTrigger';
            otherwise
                str_name='';
            end
            event(1).sample_no=sqf_acqcond.pretrigger_length;
            event(1).code=1;
            event(1).name=str_name;
        end

    end


    out=event;

