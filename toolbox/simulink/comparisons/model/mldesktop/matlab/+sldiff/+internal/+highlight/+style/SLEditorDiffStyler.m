classdef SLEditorDiffStyler<handle





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

        function obj=SLEditorDiffStyler(systemHandle)
            obj.SystemHandle=systemHandle;
            obj.BackgroundStyler=sldiff.internal.highlight.style.BackgroundStyler();
            obj.DiffStyler=sldiff.internal.highlight.style.DiffStyler();

            unlockIfLibrary(systemHandle);
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
            obj.styleLocationImpl(location,style,@(h,s)obj.DiffStyler.applyStyle(h,s));
        end

        function updateStyle(obj,location,style)
            obj.styleLocationImpl(location,style,@(h,s)obj.DiffStyler.updateStyle(h,s));
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

        function styleLocationImpl(obj,location,style,f)
            unmodified=style==sldiff.internal.highlight.style.StyleType.Unmodified;
            for handle=location.Handles
                if unmodified
                    obj.BackgroundStyler.removeNoGreyStyle(handle);
                else
                    obj.BackgroundStyler.applyNoGrey(handle);
                    f(handle,style);
                end

            end

            obj.isStyled=true;
        end

    end

end

function unlockIfLibrary(handle)
    if~strcmp(get_param(handle,'blockdiagramtype'),'library')
        return
    end
    set_param(handle,'Lock','off');
end
