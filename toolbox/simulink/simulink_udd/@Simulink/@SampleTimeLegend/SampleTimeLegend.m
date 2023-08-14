function this=SampleTimeLegend(varargin)



mlock
    persistent instance;
    if isempty(instance)
        instance=Simulink.SampleTimeLegend();
    end
    this=instance;
    return;



