function[sig,opts]=getTrigger()





    sig=Simulink.sdi.Signal.empty();
    opts=struct.empty();

    [id,trig]=Simulink.sdi.getTriggerImpl('sdi');
    if Simulink.sdi.isValidSignalID(id)
        sig=Simulink.sdi.getSignal(id);

        opts=struct;
        opts.Mode=trig.Mode;
        opts.Type=trig.Type;
        opts.Position=trig.Position;
        opts.Delay=trig.Delay;
        opts.SourceChannelComplexity=trig.SourceChannelComplexity;
        opts.Polarity=trig.Polarity;
        opts.AutoLevel=trig.AutoLevel;
        opts.Level=trig.Level;
        opts.UpperLevel=trig.UpperLevel;
        opts.LowerLevel=trig.LowerLevel;
        opts.Hysteresis=trig.Hysteresis;
        opts.MinTime=trig.MinTime;
        opts.MaxTime=trig.MaxTime;
        opts.Timeout=trig.Timeout;
        opts.Holdoff=trig.Holdoff;
    end
end
