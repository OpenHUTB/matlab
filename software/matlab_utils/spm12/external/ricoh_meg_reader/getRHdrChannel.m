








































































function out=getRHdrChannel(filepath)

    function_revision=0;
    function_name='getRHdrChannel';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    key='tzsvq27h';

    NullChannel=0;
    MagnetoMeter=1;
    AxialGradioMeter=2;
    PlannerGradioMeter=3;
    ReferenceChannelMark=hex2dec('0100');
    ReferenceMagnetoMeter=bitor(ReferenceChannelMark,MagnetoMeter);
    ReferenceAxialGradioMeter=bitor(ReferenceChannelMark,AxialGradioMeter);
    ReferencePlannerGradioMeter=bitor(ReferenceChannelMark,PlannerGradioMeter);
    TriggerChannel=-1;
    EegChannel=-2;
    EcgChannel=-3;
    EtcChannel=-4;


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    channel=GetSqf(fid,key,'Channel');


    fclose(fid);

    if isempty(channel)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        return;
    end


    channel_count=size(channel,2);


    for ch=1:channel_count
        switch channel(ch).type
        case MagnetoMeter
            channel(ch).data=rmfield(channel(ch).data,'spare');
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case AxialGradioMeter
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case PlannerGradioMeter
        case ReferenceMagnetoMeter
            channel(ch).data=rmfield(channel(ch).data,'spare');
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case ReferenceAxialGradioMeter
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case ReferencePlannerGradioMeter
        case TriggerChannel
            channel(ch).data=rmfield(channel(ch).data,'spare');
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case EegChannel
            if channel(ch).data.type==1
                channel(ch).data=rmfield(channel(ch).data,'spare');
                channel(ch).data=rmfield(channel(ch).data,'storage');
                channel(ch).data=rmfield(channel(ch).data,'average');
                channel(ch).data=rmfield(channel(ch).data,'gain');
                channel(ch).data=rmfield(channel(ch).data,'offset');
            else
                channel(ch).data=rmfield(channel(ch).data,'derivation_type');
                channel(ch).data=rmfield(channel(ch).data,'derivation_parameter');
                channel(ch).data=rmfield(channel(ch).data,'spare');
                channel(ch).data=rmfield(channel(ch).data,'order');
                channel(ch).data=rmfield(channel(ch).data,'color_enable');
                channel(ch).data=rmfield(channel(ch).data,'color');
            end
        case EcgChannel
            channel(ch).data=rmfield(channel(ch).data,'leadsystem_type');
            channel(ch).data=rmfield(channel(ch).data,'leadsystem_parameter');
            channel(ch).data=rmfield(channel(ch).data,'spare');
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case EtcChannel
            channel(ch).data=rmfield(channel(ch).data,'spare');
            channel(ch).data=rmfield(channel(ch).data,'order');
            channel(ch).data=rmfield(channel(ch).data,'color_enable');
            channel(ch).data=rmfield(channel(ch).data,'color');
        case NullChannel
        otherwise
        end
    end


    out.channel_count=channel_count;
    out.channel=channel;

