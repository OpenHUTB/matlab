classdef RemoveHighlightMediator<handle





    properties(SetAccess=private,GetAccess=public)
        Listeners;
    end

    methods(Access=public,Static)
        function toReturn=getInstance()
            mlock;
            persistent instance
            if isempty(instance)
                instance=slxmlcomp.internal.highlight.RemoveHighlightMediator();
            end
            toReturn=instance;
        end
    end

    methods(Access=public)
        function obj=RemoveHighlightMediator()
            obj.Listeners={};
        end

        function removeHighlightForModel(obj,bdHandle)
            cellfun(...
            @(listener)listener(bdHandle),...
            obj.Listeners...
            );
        end

        function listenerCleanup=addListener(obj,listener)
            obj.Listeners{end+1}=listener;

            listenerCleanup=@()obj.removeListener(listener);
        end

        function removeListener(obj,toRemove)
            obj.Listeners=obj.Listeners(...
            cellfun(@(listener)~isequal(listener,toRemove),obj.Listeners)...
            );
        end

    end

end
