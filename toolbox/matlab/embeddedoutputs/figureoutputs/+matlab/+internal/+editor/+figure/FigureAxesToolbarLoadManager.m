classdef(Hidden)FigureAxesToolbarLoadManager<handle





    properties(Hidden)
        OneShotAxesToolbarLoad matlab.lang.OnOffSwitchState='on'
    end

    methods(Static)
        function obj=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=matlab.internal.editor.figure.FigureAxesToolbarLoadManager();
            end
            obj=instance;
        end

        function ret=getAxesToolbarWaitCursorRequiredAndReset()
            import matlab.internal.editor.figure.FigureAxesToolbarLoadManager;
            fam=FigureAxesToolbarLoadManager.getInstance;
            ret=fam.OneShotAxesToolbarLoad;
            fam.OneShotAxesToolbarLoad=matlab.lang.OnOffSwitchState.off;
        end

    end
end