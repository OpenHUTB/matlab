classdef SLEditorHighlightWindow<comparisons.internal.highlight.HighlightWindow




    properties(Access=private)
SystemHandle
ContentId
AttentionStyler
StudioApp

StylerXButtonNotifier
XButtonSubscription
    end

    methods(Access=public)
        function obj=SLEditorHighlightWindow(location,contentId)
            obj.SystemHandle=bdroot(location.Handles(1));

            obj.ContentId=contentId;

            import sldiff.internal.highlight.style.AttentionStyler
            import sldiff.internal.highlight.style.StylerXButtonNotifier
            obj.AttentionStyler=AttentionStyler();
            unlockIfLibrary(obj.SystemHandle);
            obj.StylerXButtonNotifier=StylerXButtonNotifier(obj.SystemHandle);
            obj.XButtonSubscription=obj.listenerToStylerXButton();
        end


        function setPosition(obj,coordinates)
            if isempty(obj.StudioApp)
                set_param(obj.SystemHandle,"Location",coordinates);
            else
                coordinates(3)=coordinates(3)-coordinates(1);
                coordinates(4)=coordinates(4)-coordinates(2);
                obj.StudioApp.getStudio().setStudioPosition(coordinates);
            end
        end

        function applyAttentionStyle(obj,location)
            for handle=location.Handles
                obj.AttentionStyler.applyHighlight(handle);
            end
        end

        function clearAttentionStyle(obj)
            obj.AttentionStyler.removeAllStyles(obj.SystemHandle);
        end

        function zoomToShow(~,location)
            handle=location.Handles(1);
            if location.Type~="System"
                subsys=get_param(handle,"Parent");
                subsys=get_param(subsys,"Handle");
                openEditor(subsys);
                Simulink.scrollToVisible(handle);
            else
                openEditor(handle);
                set_param(handle,'ZoomFactor','FitSystem')
            end
        end

        function bool=canDisplay(obj,location)
            import sldiff.internal.highlight.window.isSupportedBySLEditor
            bool=isSupportedBySLEditor(location.Type)&&...
            bdroot(location.Handles(1))==obj.SystemHandle;
        end

        function bool=isVisible(obj)
            bool=obj.StudioApp.getStudio().isStudioVisible();
        end

        function show(obj)
            if isempty(obj.StudioApp)
                openEditor(obj.SystemHandle);
                apps=SLM3I.SLDomain.getAllStudioAppsFor(obj.SystemHandle);
                obj.StudioApp=apps(1);
            else
                obj.StudioApp.getStudio().show();
            end
        end

        function hide(obj)
            obj.StudioApp.getStudio().hide();
        end
    end

    methods(Access=private)

        function subscription=listenerToStylerXButton(obj)
            function clearStyles()
                obj.clearAttentionStyle();
            end

            subscription=obj.StylerXButtonNotifier.addListener(@clearStyles);
        end

    end

end

function openEditor(handle)
    if(get_param(handle,'Open')~="on")
        set_param(handle,'Open','on');
    end
    hideAllBdScopes(handle);
end

function hideAllBdScopes(handle)

    windows=find_system(handle,'LookUnderMasks','on','FollowLinks','off',...
    'Regexp','on','BlockType','Scope','Open','on');
    for i=1:numel(windows)
        set_param(windows(i),'Open','off');
    end

end

function unlockIfLibrary(handle)
    if~strcmp(get_param(handle,'blockdiagramtype'),'library')
        return
    end
    set_param(handle,'Lock','off');
end
