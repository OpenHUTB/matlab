function plotExternalInit(varargin)









    if nargin==0

        modelHandle=bdroot;
    elseif nargin==1
        modelHandle=varargin{1};
    end
    mws=get_param(modelHandle,'ModelWorkspace');

    ImpulseOut=evalin('caller','ImpulseOut');
    mws.assignin('EqualizedImpulse',ImpulseOut);

    serdes.internal.callbacks.configurationPlotImpulse(modelHandle);
end
