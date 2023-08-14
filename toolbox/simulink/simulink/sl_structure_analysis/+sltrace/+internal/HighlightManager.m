classdef HighlightManager<handle






    properties
BDMap
listenerMap
    end

    methods(Access=private)
        function obj=HighlightManager
            obj.BDMap=containers.Map('KeyType','double','ValueType','any');
            obj.listenerMap=containers.Map('KeyType','double','ValueType','any');
        end

        function delete(obj)

        end
    end


    methods(Static,Access=public)



        function HighlightSignal(BD,TraceMap,originBlock)
            import sltrace.internal.*
            highlighter=HighlightManager.createNewHighlighterForBD(BD);
            highlighter.highlighting(BD,TraceMap,originBlock);
        end



        function HighlightElements(BD,varargin)
            import sltrace.internal.*
            highlighter=HighlightManager.getExistingHighlighterForBD(BD);
            if isempty(highlighter)
                highlighter=HighlightManager.createNewHighlighterForBD(BD);
            end
            highlighter.highlightingElements(BD,varargin{:});
        end








        function RemoveHighlight(BD)
            import sltrace.internal.*
            manager=HighlightManager.getInstance;

            if(isKey(manager.BDMap,BD))
                delete(manager.BDMap(BD));
                remove(manager.BDMap,BD);
            end

            if(isKey(manager.listenerMap,BD))
                delete(manager.listenerMap(BD));
                remove(manager.listenerMap,BD);
            end
        end

    end

    methods(Static,Access=private)


        function highlighter=createNewHighlighterForBD(BD)
            import sltrace.internal.*
            manager=HighlightManager.getInstance;
            HighlightManager.cleanUpExistingHighlightForBD(BD);

            highlighter=highlight();

            manager.BDMap(BD)=highlighter;
            manager.listenerMap(BD)=Simulink.listener(BD,'CloseEvent',...
            @(~,~)HighlightManager.RemoveHighlight(BD));
        end



        function cleanUpExistingHighlightForBD(BD)
            highlighter=sltrace.internal.HighlightManager.getExistingHighlighterForBD(BD);
            delete(highlighter);
        end



        function highlighter=getExistingHighlighterForBD(BD)
            import sltrace.internal.*
            manager=HighlightManager.getInstance;
            if(isKey(manager.BDMap,BD)&&isvalid(manager.BDMap(BD)))
                highlighter=manager.BDMap(BD);
            else
                highlighter=[];
            end
        end



        function manager=getInstance
            import sltrace.internal.*
            persistent obj
            if(isempty(obj)||~isvalid(obj))
                obj=HighlightManager;
                manager=obj;
            else
                manager=obj;
            end
        end
    end

end
































