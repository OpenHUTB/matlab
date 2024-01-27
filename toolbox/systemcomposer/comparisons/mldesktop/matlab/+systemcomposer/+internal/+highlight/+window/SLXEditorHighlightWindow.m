classdef SLXEditorHighlightWindow<comparisons.internal.highlight.HighlightWindow

    properties(Access=private)
SystemHandle
ContentId
AttentionStyler
StudioApp

StylerXButtonNotifier
XButtonSubscription
    end


    methods(Access=public)
        function obj=SLXEditorHighlightWindow(location,contentId)
            obj.SystemHandle=bdroot(location.Handles{1});

            obj.ContentId=contentId;

            import sldiff.internal.highlight.style.*
            obj.AttentionStyler=AttentionStyler();
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
            for i=1:numel(location.Handles)
                obj.AttentionStyler.applyHighlight(location.Handles{i});
            end
        end


        function clearAttentionStyle(obj)
            obj.AttentionStyler.removeAllStyles(obj.SystemHandle);
        end


        function zoomToShow(~,location)
            handle=location.Handles{1};
            if location.Type~="System"
                parent=get_param(get_param(handle,"Parent"),"Handle");
                if isComponentPortLocation(location)
                    parent=get_param(get_param(parent,"Parent"),"Handle");
                end
                if(get_param(parent,'Open')~="on")
                    openEditor(parent);
                end
                Simulink.scrollToVisible(handle);
            else
                if(get_param(handle,'Open')~="on")
                    openEditor(handle);
                end
                set_param(handle,'ZoomFactor','FitSystem')
            end
        end


        function bool=canDisplay(obj,location)
            import systemcomposer.internal.highlight.window.isSupportedBySLXEditor
            bool=isSupportedBySLXEditor(location.Type)&&...
            bdroot(location.Handles{1})==obj.SystemHandle;
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
    set_param(handle,'Open','On');
    hideAllBdScopes(handle);
end


function hideAllBdScopes(handle)
    windows=find_system(handle,'LookUnderMasks','on','FollowLinks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Regexp','on','BlockType','Scope','Open','on');
    for i=1:numel(windows)
        set_param(windows(i),'Open','off');
    end
end


function isComponentPort=isComponentPortLocation(location)
    isComponentPort=false;
    if(location.Type=="Port")
        archPeerClass=class(systemcomposer.utils.getArchitecturePeer(location.Handles{1}));
        if strcmpi(archPeerClass,'systemcomposer.architecture.model.design.ComponentPort')
            isComponentPort=true;
        end
    end
end