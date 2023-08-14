classdef TypeChainHandler<handle



















    properties(Access=private)
        ContextObj sl.interface.dictionaryApp.toolstrip.architectureDictionaryCustomContext;
    end

    methods(Access=public)

        function this=TypeChainHandler(contextObj)
            this.ContextObj=contextObj;
        end

        function initTypeChain(this)

            assert(isempty(this.ContextObj.TypeChain),'TypeChain should be empty when initializing');
            typeChain={};
            typeChain{end+1}=this.ContextObj.SelectedPlatformId;
            typeChain{end+1}=this.ContextObj.SelectedTabId;
            typeChain=this.updateDefaultTypeChainForList(typeChain);
            this.setTypeChain(typeChain);
        end

        function setContextTypeChainToSelectedNodes(this,selection)

            assert(~isempty(selection),'Expected nodes to be selected');
            selectedNode=selection{1};
            typeChain=this.getPlatformTypeChain();
            typeChain=this.updateDefaultTypeChainForSelectedNode(typeChain);
            if length(selection)>1

                typeChain=this.disableAddChildElementsInTypeChain(typeChain);
            else

                typeChain=this.addSelectedNodeToTypeChain(typeChain,selectedNode);
                typeChain=this.updateTypeChainForSpecificNodeType(typeChain,selectedNode);
            end
            typeChain=this.updateCopyActionForSelection(typeChain,selection);
            typeChain=this.updateTypeChainForClipboard(typeChain,selection);
            this.setTypeChain(typeChain);
        end

        function setContextTypeChainToCurrentList(this,listObj)


            typeChain=this.getPlatformTypeChain();
            typeChain=this.addSelectedListToTypeChain(typeChain,listObj);
            typeChain=this.updateDefaultTypeChainForList(typeChain);
            this.setTypeChain(typeChain);
        end

        function setContextTypeChainForSelectedPlatform(this,selectedPlatformId)

            this.ContextObj.SelectedPlatformId=selectedPlatformId;
            this.ContextObj.SelectedPlatformContextId=this.getPlatformContextId(selectedPlatformId);
            typeChain=this.ContextObj.TypeChain;
            typeChain{1}=this.ContextObj.SelectedPlatformContextId;
            this.setTypeChain(typeChain);
        end

        function updateTypeChainForCleanDictionary(this)


            saveWidgetStateIdx=contains(this.ContextObj.TypeChain,'saveDictEnable');
            if any(saveWidgetStateIdx)
                this.ContextObj.TypeChain{saveWidgetStateIdx}='saveDictDisable';
            end
        end
    end

    methods(Static,Access=private)

        function typeChain=addSelectedNodeToTypeChain(typeChain,selectedNode)

            typeChain{end+1}=selectedNode.getNodeType();
        end

        function typeChain=addSelectedListToTypeChain(typeChain,listObj)

            typeChain{end+1}=listObj.getTab();
        end

        function typeChain=updateDefaultTypeChainForSelectedNode(typeChain)

            typeChain{end+1}='deleteActionEnable';
        end

        function typeChain=updateTypeChainForFeatureControls(typeChain)

            if~slfeature('InterfaceDictConstants')
                typeChain{end+1}='hideConstants';
            end

            if~slfeature('InterfaceDictionaryPlatforms')
                typeChain{end+1}='hidePlatformDropDown';
            end
        end

        function platformContextId=getPlatformContextId(platformId)
            builtInPlatformIds={'Native'};
            builtInPlatformIds(end+1)=Simulink.interface.Dictionary.getBuiltInPlatformNames();
            if~any(contains(builtInPlatformIds,platformId))

                platformContextId='SDP';
            else

                platformContextId=platformId;
            end
        end

        function typeChain=disableAddChildElementsInTypeChain(typeChain)

            typeChain{end+1}='addInterfaceElementActionDisable';
            typeChain{end+1}='addStructureElementActionDisable';
        end

        function typeChain=updateCopyActionForSelection(typeChain,selection)


            import sl.interface.dictionaryApp.toolstrip.TypeChainHandler;

            if isempty(selection)||...
                ~TypeChainHandler.isValidSelectionForCopy(selection)
                typeChain{end+1}='copyActionDisable';
            else
                typeChain{end+1}='copyActionEnable';
            end
        end

        function isValid=isValidSelectionForCopy(selection)

            if length(selection)==1

                isValid=true;
                return;
            end




            isChildNode=cellfun(...
            @(node)isa(node,'sl.interface.dictionaryApp.node.ElementNode'),...
            selection);


            isValid=~any(isChildNode)||...
            sl.interface.dictionaryApp.toolstrip.TypeChainHandler.isSelectionChildrenOfSingleParent(selection);

        end

        function tf=isSelectionChildrenOfSingleParent(selection)

            assert(numel(selection)>1,'Expected multiple node selection');

            tf=false;

            isChildNode=cellfun(...
            @(node)isa(node,'sl.interface.dictionaryApp.node.ElementNode'),...
            selection);

            if all(isChildNode)
                parentNodes=cellfun(@(node)node.getParentNode(),selection,...
                'UniformOutput',false);
                tf=length(unique([parentNodes{:}]))==1;
            end
        end
    end

    methods(Access=private)

        function typeChain=getPlatformTypeChain(this)

            typeChain=this.ContextObj.TypeChain(1);
        end

        function setTypeChain(this,typeChain)

            typeChain=this.updateTypeChainForCoreContextChecks(typeChain);
            this.ContextObj.TypeChain=typeChain;
        end

        function typeChain=updateTypeChainForSpecificNodeType(this,typeChain,selectedNode)
            import sl.interface.dictionaryApp.list.DragNDropHelper;

            selectedNodeType=selectedNode.getNodeType();
            switch selectedNodeType
            case{'Interface','InterfaceElement'}

                typeChain{end+1}='addInterfaceElementActionEnable';
                typeChain{end+1}='addStructureElementActionDisable';
            case{'Structure','StructureElement'}

                typeChain{end+1}='addInterfaceElementActionDisable';
                typeChain{end+1}='addStructureElementActionEnable';
            otherwise
                typeChain=this.disableAddChildElementsInTypeChain(typeChain);
            end

            switch selectedNodeType

            case{'ValueType','AliasType','Structure','Enumeration','Constant'}
                typeChain{end+1}='exportToMATActionEnable';
                typeChain{end+1}='exportToMActionEnable';
            otherwise
                typeChain{end+1}='exportToMATActionDisable';
                typeChain{end+1}='exportToMActionDisable';
            end
            if selectedNode.isValid()
                switch selectedNodeType
                case{'InterfaceElement','StructureElement'}
                    if DragNDropHelper.canSelectedNodeBeMovedUp(selectedNode)
                        typeChain{end+1}='moveUpActionEnable';
                    else
                        typeChain{end+1}='moveUpActionDisable';
                    end

                    if DragNDropHelper.canSelectedNodeBeMovedDown(selectedNode)
                        typeChain{end+1}='moveDownActionEnable';
                    else
                        typeChain{end+1}='moveDownActionDisable';
                    end
                otherwise
                    typeChain{end+1}='moveUpActionDisable';
                    typeChain{end+1}='moveDownActionDisable';
                end
            else




            end
        end

        function typeChain=updateDefaultTypeChainForList(this,typeChain)

            typeChain{end+1}='deleteActionDisable';
            typeChain{end+1}='exportToMATActionDisable';
            typeChain{end+1}='exportToMActionDisable';
            typeChain=this.disableAddChildElementsInTypeChain(typeChain);
            selection=[];
            typeChain=this.updateCopyActionForSelection(typeChain,selection);
            typeChain=this.updateTypeChainForClipboard(typeChain,selection);
        end

        function typeChain=updateTypeChainForCoreContextChecks(this,typeChain)
            typeChain{end+1}='enableAccelerators';
            typeChain=this.updateTypeChainForFeatureControls(typeChain);
            typeChain=this.updateTypeChainForDirtyDict(typeChain);
        end

        function typeChain=updateTypeChainForDirtyDict(this,typeChain)
            if this.ContextObj.GuiObj.isDictDirty
                typeChain{end+1}='saveDictEnable';
            else
                typeChain{end+1}='saveDictDisable';
            end
        end

        function typeChain=updateTypeChainForClipboard(this,typeChain,selection)



            if this.canClipboardBePastedAtCurrentLocation(selection)
                typeChain{end+1}='pasteActionEnable';
            else
                typeChain{end+1}='pasteActionDisable';
            end
        end

        function canPaste=canClipboardBePastedAtCurrentLocation(this,selection)



            clipboard=sl.interface.dictionaryApp.clipboard.Clipboard.getInstance();
            if clipboard.isEmpty()
                canPaste=false;
            else


                if isempty(selection)
                    canPaste=this.canClipboardBePastedOnCurrentTab(clipboard);
                else
                    canPaste=this.canClipboardBePastedAtCurrentSelection(clipboard,selection);
                end
            end
        end

        function canPaste=canClipboardBePastedOnCurrentTab(this,clipboard)


            if clipboard.HoldsChildElements


                canPaste=false;
            else
                tabAdapter=this.ContextObj.getTabAdapter();
                canPaste=tabAdapter.canPaste(clipboard.contents{1});
            end
        end

        function canPaste=canClipboardBePastedAtCurrentSelection(this,clipboard,selection)


            canPaste=false;
            if clipboard.HoldsChildElements
                if numel(selection)==1


                    canPaste=...
                    isa(selection{1},'sl.interface.dictionaryApp.node.InterfaceNode')||...
                    isa(selection{1},'sl.interface.dictionaryApp.node.StructTypeNode')||...
                    isa(selection{1},'sl.interface.dictionaryApp.node.ElementNode');
                elseif sl.interface.dictionaryApp.toolstrip.TypeChainHandler.isSelectionChildrenOfSingleParent(selection)
                    canPaste=true;
                end
            else


                canPaste=this.canClipboardBePastedOnCurrentTab(clipboard);
            end
        end
    end
end


