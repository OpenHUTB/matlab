function validateSampleRate(obj,N)




%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

    coder.allowpcode('plain');
    if obj.getExecPlatformIndex()
        sts=getSampleTime(obj);
        if strcmp(sts.Type,'Discrete')||strcmp(sts.Type,'Inherited')
            Fs=phased.internal.samptime2rate(sts.SampleTime,N);
        elseif strcmp(sts.Type,'Controllable')
            Fs=1/sts.TickTime;
        else
            coder.internal.errorIf(true,...
            'phased:phased:invalidSampleTimeType',sts.Type);
        end
        cond=abs(obj.SampleRate-Fs)>eps(obj.SampleRate);
        if cond
            coder.internal.errorIf(cond,...
            'phased:phased:MatchedFilter:SampleRateMismatch',...
            'SampleRate',sprintf('%f',Fs));
        end
    end
end
