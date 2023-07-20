classdef FigureHelper<...
...
    matlab.ui.internal.componentframework.services.optional.ViewReadyInterface





    methods(Static)

        function flush(component)

            drawnow;

            fig=ancestor(component,'figure');
            if isempty(fig)
                return;
            end

            pollForViewReady(fig);





            refresh(fig);
            drawnow;
        end

        function L=setupLockListeners(driver)
            L=event.listener(?matlab.ui.Figure,...
            'InstanceCreated',@(o,e)addFigureViewReadyListener(e.Instance,driver));
        end

    end

    methods(Static,Hidden)

        function current=strict(bool)
            persistent pValue;
            if isempty(pValue)

                pValue=false;
            end

            current=pValue;
            if nargin>0
                pValue=bool;
            end
        end

    end

end

function pollForViewReady(component)
    import matlab.uiautomation.internal.FigureHelper;

    t0=tic;
    while~component.isViewReady&&toc(t0)<=60
        drawnow limitrate;
    end

    if FigureHelper.strict()
        assert(component.isViewReady,"Component was not view-ready");
    end

end

function addFigureViewReadyListener(fig,driver)
    addlistener(fig,'ViewReady',@(~,~)driver.lock(fig));
end