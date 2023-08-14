classdef architectureDictionaryCustomContext<dig.ContextProvider




    properties(SetObservable=true)


        GuiObj;
        SelectedPlatformContextId;
        SelectedPlatformId;
        SelectedTabId;
        TypeChainHandler;
    end

    methods(Access=public)
        function this=architectureDictionaryCustomContext()
            this.TypeChainHandler=sl.interface.dictionaryApp.toolstrip.TypeChainHandler(this);
        end
    end

    methods(Access=public)


        function initContextWithGuiObj(this,guiObj)

            this.GuiObj=guiObj;
            this.SelectedPlatformId=guiObj.SelectedPlatformId;
            this.SelectedPlatformContextId=guiObj.SelectedPlatformId;
            this.SelectedTabId=guiObj.getCurrentTabName;
            this.TypeChainHandler.initTypeChain();
        end

        function setContextTypeChainToSelectedNodes(this,selection)
            this.TypeChainHandler.setContextTypeChainToSelectedNodes(selection);
        end

        function setContextTypeChainToCurrentList(this,listObj)
            this.TypeChainHandler.setContextTypeChainToCurrentList(listObj);
        end

        function tabAdapter=getTabAdapter(this)
            tabAdapter=this.GuiObj.getTabAdapter();
        end
    end
end
