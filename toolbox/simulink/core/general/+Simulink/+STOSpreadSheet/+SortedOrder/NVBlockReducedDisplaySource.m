classdef NVBlockReducedDisplaySource<Simulink.Structure.HiliteTool.EmphasisStyleSheet






    properties
BDMap
listenerMap
    end

    methods(Access=private)
        function obj=NVBlockReducedDisplaySource
            obj.BDMap=containers.Map('KeyType','double','ValueType','any');
            obj.listenerMap=containers.Map('KeyType','double','ValueType','any');
        end
    end


    methods(Static,Access=public)



        function HighlightElements(cbinfo,BD,currentBD,varargin)
            import Simulink.STOSpreadSheet.SortedOrder.*
            st=cbinfo.studio;
            highlighter=NVBlockReducedDisplaySource.getExistingHighlighterForBD(BD);
            if isempty(highlighter)
                highlighter=NVBlockReducedDisplaySource.createNewHighlighterForBD(BD,currentBD);

                c=st.getService('GLUE2:ActiveEditorChanged');
                registerCallbackId=c.registerServiceCallback(@NVBlockReducedDisplaySource.handleEditorChanged);%#ok<NASGU>
            end
            highlighter.highlightingElements(BD,currentBD,varargin{:});
        end








        function RemoveHighlight(BD)
            import Simulink.STOSpreadSheet.SortedOrder.*

            manager=NVBlockReducedDisplaySource.getInstance;

            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if(~isempty(studios))
                st=studios(1);
                stApp=st.App;
                topModelHandle=stApp.topLevelDiagram.handle;
                BD=topModelHandle;
            end


            if(isequal(get_param(BD,'NVBlockReducedDisplay'),'on'))
                set_param(BD,'NVBlockReducedDisplay','off');
            end

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


        function highlighter=createNewHighlighterForBD(BD,currentBD)
            import Simulink.STOSpreadSheet.SortedOrder.*
            manager=NVBlockReducedDisplaySource.getInstance;
            NVBlockReducedDisplaySource.cleanUpExistingHighlightForBD(BD);

            highlighter=hiliteForNVBlkReduced(BD,currentBD);

            manager.BDMap(BD)=highlighter;
            manager.listenerMap(BD)=Simulink.listener(BD,'CloseEvent',...
            @(~,~)NVBlockReducedDisplaySource.RemoveHighlight(BD));
        end



        function cleanUpExistingHighlightForBD(BD)

            import Simulink.STOSpreadSheet.SortedOrder.*

            highlighter=NVBlockReducedDisplaySource.getExistingHighlighterForBD(BD);
            delete(highlighter);
        end



        function highlighter=getExistingHighlighterForBD(BD)
            import Simulink.STOSpreadSheet.SortedOrder.*
            manager=NVBlockReducedDisplaySource.getInstance;
            if(isKey(manager.BDMap,BD)&&isvalid(manager.BDMap(BD)))
                highlighter=manager.BDMap(BD);
            else
                highlighter=[];
            end
        end



        function manager=getInstance
            import Simulink.STOSpreadSheet.SortedOrder.*
            persistent obj
            if(isempty(obj)||~isvalid(obj))
                obj=NVBlockReducedDisplaySource;
                manager=obj;
            else
                manager=obj;
            end
        end


        function handleEditorChanged(this,cbinfo,ev)%#ok<DEFNU>


            import Simulink.STOSpreadSheet.SortedOrder.*
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            if(~isempty(studios))
                st=studios(1);
                stApp=st.App;
                activeEditor=stApp.getActiveEditor;
                blockDiagramHandle=activeEditor.blockDiagramHandle;
                currentLevelModel=getfullname(blockDiagramHandle);
                topLevelModel=getfullname(stApp.topLevelDiagram.handle);


                if strcmpi(get_param(topLevelModel,'NVBlockReducedDisplay'),'off')

                    Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.removeStyler(blockDiagramHandle);
                    RemoveHighlight(topLevelModel);
                else
                    highlighter=NVBlockReducedDisplaySource.getExistingHighlighterForBD(stApp.topLevelDiagram.handle);
                    blks=get_param(currentLevelModel,'ReducedNonVirtualBlockList');
                    highlighter.setCurrentBD(blockDiagramHandle);
                    highlighter.highlightingElements(stApp.topLevelDiagram.handle,blockDiagramHandle,blks);
                end
            end
        end
    end
end

