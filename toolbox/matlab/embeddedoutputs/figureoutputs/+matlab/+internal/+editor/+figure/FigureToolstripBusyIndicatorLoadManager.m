classdef(Hidden)FigureToolstripBusyIndicatorLoadManager<handle





    properties(Hidden)
        OneShotFigureToolstripBusyIndicatorLoad matlab.lang.OnOffSwitchState='off'
    end

    methods(Static)
        function obj=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=matlab.internal.editor.figure.FigureToolstripBusyIndicatorLoadManager();
            end
            obj=instance;
        end

        function setCreateFigureToolstripBusyIndicatorLoadProperty()

            import matlab.internal.editor.figure.FigureToolstripBusyIndicatorLoadManager;

            fam=FigureToolstripBusyIndicatorLoadManager.getInstance;
            if~fam.OneShotFigureToolstripBusyIndicatorLoad
                fam.OneShotFigureToolstripBusyIndicatorLoad=matlab.lang.OnOffSwitchState.on;
            end
        end

        function ret=isFigureToolstripBusyIndicatorRequired()



            import matlab.internal.editor.figure.FigureToolstripBusyIndicatorLoadManager;

            fam=FigureToolstripBusyIndicatorLoadManager.getInstance;
            ret=false;
            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                ret=~fam.OneShotFigureToolstripBusyIndicatorLoad;
            end
        end
    end
end