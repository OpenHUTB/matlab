classdef SLXEditorDiffStyler<handle

    properties(Access=private)
SystemHandle
BackgroundStyler
DiffStyler
StylerXButtonNotifier
XButtonSubscription
    end

    properties(GetAccess=public,SetAccess=private)
isStyled
    end


    methods(Access=public)

        function obj=SLXEditorDiffStyler(systemHandle)
            obj.SystemHandle=systemHandle;
            obj.BackgroundStyler=systemcomposer.internal.highlight.style.BackgroundStyler();
            obj.DiffStyler=systemcomposer.internal.highlight.style.DiffStyler();
            obj.StylerXButtonNotifier=sldiff.internal.highlight.style.StylerXButtonNotifier(systemHandle);
            obj.XButtonSubscription=obj.listenerToStylerXButton();
            obj.isStyled=false;
        end


        function fadeAll(obj)
            if~obj.BackgroundStyler.hasStyle(obj.SystemHandle)
                obj.BackgroundStyler.applyStyle(obj.SystemHandle);
            end
            obj.isStyled=true;
        end


        function styleLocation(obj,location,style)
            for i=1:numel(location.Handles)
                obj.BackgroundStyler.applyNoGrey(location.Handles{i});
                obj.DiffStyler.applyStyle(location.Handles{i},style);
            end
            obj.isStyled=true;
        end


        function clearAllStyles(obj)
            obj.DiffStyler.removeAllStyles(obj.SystemHandle);
            obj.BackgroundStyler.removeAllStyles(obj.SystemHandle);
            obj.isStyled=false;
        end


        function delete(obj)
            try
                get_param(obj.SystemHandle,'Name');
            catch
                return;
            end
            obj.clearAllStyles();
        end
    end


    methods(Access=private)
        function subscription=listenerToStylerXButton(obj)
            function clearStyles()
                obj.clearAllStyles();
            end

            subscription=obj.StylerXButtonNotifier.addListener(@clearStyles);
        end
    end
end
