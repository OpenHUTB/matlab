function status=feature(feature,varargin)


















    mlock;
    persistent features;

    if isempty(features)



        features=struct(...
        'InstrumentPanelSLNormalMode',1,...
        'MinMaxSetParam',1,...
        'CANExplorer',0,...
        'StateflowAnimationTesting',0,...
        'KeepAppDesUIsActiveWhenNotRecording',0...
        );
    end

    if strcmp(feature,'info')

        disp(features);
        return;
    end

    assert(isfield(features,feature),...
    'Feature ''%s'' is not available!',feature);

    status=features.(feature);

    if nargin==1

        return;
    end

    mode=varargin{1};
    assert(isnumeric(mode),'Mode must be numeric!');

    features.(feature)=mode;
end
