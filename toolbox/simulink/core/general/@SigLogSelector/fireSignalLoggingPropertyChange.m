function fireSignalLoggingPropertyChange(varargin)






    if nargin<2||isempty(varargin{2})
        me=SigLogSelector.getExplorer;
    else
        me=varargin{2};
    end
    if isempty(me)||me.isSettingDataLoggingOveride
        return;
    end


    if nargin<3
        model=me.getRoot.Name;
    else
        model=varargin{3};
    end
    if isempty(model)||~strcmp(model,me.getRoot.Name)
        return;
    end


    switch varargin{1}
    case{'SignalLogging'}
        val=get_param(model,'SignalLogging');
        me.hLoggingOffTxt.setVisible(strcmpi(val,'off'));

    case{'DataLoggingOverride'}


        val=me.getRoot.getOverrideMode;
        me.setOverrideModeValue(val);


        me.getRoot.refreshSignals;

    otherwise
        assert(false);
    end

end
