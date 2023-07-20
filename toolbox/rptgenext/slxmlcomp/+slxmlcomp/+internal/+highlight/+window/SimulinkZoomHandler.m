classdef SimulinkZoomHandler<slxmlcomp.internal.highlight.window.SLEditorZoomHandler




    methods(Access=public)

        function canHandle=canHandle(~,~)
            canHandle=true;
        end

        function zoomTo(~,location)

            subsysPath=char(SubsystemResolver.getPath(location));

            if(get_param(subsysPath,'Open')~="on")
                model=bdroot(subsysPath);
                set_param(subsysPath,'Location',get_param(model,'Location'));
            end
            set_param(subsysPath,'Open','on');

            import slxmlcomp.internal.highlight.window.SubsystemResolver;
            resolver=slxmlcomp.internal.highlight.SimulinkHandleResolver();
            objectHandle=resolver.resolve(location);

            if~isempty(objectHandle)
                Simulink.scrollToVisible(objectHandle);
            end
        end

    end

end
