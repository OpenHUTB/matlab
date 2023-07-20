function launchEditor(varargin)





    if Simulink.sta.SignalEditor.setGetFeatureOn

        aEditor=Simulink.sta.SignalEditor(varargin{:});
        aEditor.show();
        return;
    else
        aEditor=Simulink.sta.Editor(varargin{:});
        aEditor.show();
    end
