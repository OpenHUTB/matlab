function bool=isOn(feature,varargin)



    bool=0;
    s=settings;
    cdv=s.classviewer;
    if cdv.hasSetting(feature)
        bool=cdv.(feature).ActiveValue;
        return;
    end
    if isempty(varargin)||isempty(varargin{1})
        return;
    end
    group=varargin{1};
    if cdv.hasGroup(group)&&cdv.(group).hasSetting(feature)
        bool=cdv.(group).(feature).ActiveValue;
    end
end