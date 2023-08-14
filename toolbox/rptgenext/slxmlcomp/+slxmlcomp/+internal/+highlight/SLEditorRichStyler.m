classdef SLEditorRichStyler<handle





    properties(Access=private)
ComparisonNotifier
AttentionStyler
BackgroundStyler
DiffStyler
RichStylerID
SystemName
    end

    methods(Access=public)

        function obj=SLEditorRichStyler(systemName)
            obj.AttentionStyler=slxmlcomp.internal.highlight.style.AttentionStyler();
            obj.BackgroundStyler=slxmlcomp.internal.highlight.style.BackgroundStyler();
            obj.DiffStyler=slxmlcomp.internal.highlight.style.DiffStyler();
            obj.SystemName=char(systemName);
        end

        function applyAttentionStyle(obj,location)
            handle=obj.getHandle(location);

            if~isempty(handle)
                obj.AttentionStyler.applyHighlight(handle);
            end
        end

        function clearAttentionStyles(obj)
            if~bdIsLoaded(obj.SystemName)
                return
            end
            obj.AttentionStyler.removeAllStyles(obj.SystemName);

        end

        function fadeAll(obj)
            obj.BackgroundStyler.applyStyle(obj.SystemName);
        end

        function isApplied=isBackgroundStyleApplied(obj)
            if(isempty(obj.SystemName))
                isApplied=false;
                return
            end
            isApplied=obj.BackgroundStyler.hasStyle(obj.SystemName);
        end

        function clearBackgroundStyle(obj)
            if~bdIsLoaded(obj.SystemName)
                return
            end

            obj.BackgroundStyler.removeAllStyles(obj.SystemName);
        end

        function clearDiffStyles(obj)
            if~bdIsLoaded(obj.SystemName)
                return
            end

            obj.DiffStyler.removeAllStyles(obj.SystemName);
            obj.BackgroundStyler.removeNoGreyStyles(obj.SystemName);
        end

        function clearAllStyles(obj,varargin)
            if nargin>1
                systemName=varargin{1};
            else
                systemName=obj.SystemName;
            end

            if~bdIsLoaded(systemName)
                return
            end

            obj.AttentionStyler.removeAllStyles(systemName);
            obj.DiffStyler.removeAllStyles(systemName);
            obj.BackgroundStyler.removeAllStyles(systemName);
        end

        function clearForegroundStyles(obj)
            if~bdIsLoaded(obj.SystemName)
                return
            end

            obj.AttentionStyler.removeAllStyles(obj.SystemName);
            obj.DiffStyler.removeAllStyles(obj.SystemName);
            obj.BackgroundStyler.removeNoGreyStyles(obj.SystemName);
        end

        function styleLocation(obj,location,style)
            if style=="Unmodified"
                return
            end

            handle=obj.getHandle(location);
            if isempty(handle)
                return
            end

            obj.BackgroundStyler.applyNoGrey(handle);
            mlStyle=slxmlcomp.internal.highlight.style.StyleType.(style);

            obj.DiffStyler.applyStyle(handle,mlStyle);
        end

        function updateDiffStyle(obj,location,style)

            handle=obj.getHandle(location);

            if isempty(handle)
                return
            end

            obj.BackgroundStyler.applyNoGrey(handle);

            mlStyle=slxmlcomp.internal.highlight.style.StyleType.(style);
            obj.DiffStyler.updateStyle(handle,mlStyle);
        end
    end

    methods(Access=private)
        function handle=getHandle(~,location)
            handle=[];

            slResolver=slxmlcomp.internal.highlight.SimulinkHandleResolver();
            if slResolver.canResolve(location)
                handle=slResolver.resolve(location);
                switch class(handle)
                case{'Stateflow.Data','Stateflow.Event','Stateflow.Message'}
                    handle=[];
                end
            end
            return;
        end
    end
end

