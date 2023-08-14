classdef(Sealed,Hidden)ModelHierContextMenu<handle




    methods(Static,Hidden)

        function menu=createModelHierContextMenu(component,hierarchyviewrow,~)%#ok<INUSL>








            import sl_variants.manager.model.VMgrBlockType;
            menu=struct('label','','checked',false,'icon','',...
            'enabled',true,'command',{},'visible',true,'tag','');


            hierSSIdx=slvariants.internal.manager.ui.utils.getHierSSIndices();
            if~isempty(component)&&isequal(component.getCurrentTab(),hierSSIdx.ComponentConfigurations)
                return;
            end

            aVMgrCompBlock=hierarchyviewrow.Controller.OwnerBlock;
            if isempty(aVMgrCompBlock)


                baseVMgrBlock=[];
                isStateflowBased=false;
            else


                baseVMgrBlock=aVMgrCompBlock.EditTimeBlock;
                isStateflowBased=any(baseVMgrBlock.getBlockType()==...
                [VMgrBlockType.StateflowChart,VMgrBlockType.SFVariantTransition]);
            end

            if isempty(hierarchyviewrow.Controller.ParentRow)



                parentBaseVMgrBlock=[];
            else


                parentBaseVMgrBlock=hierarchyviewrow.Controller.ParentRow.OwnerBlock.EditTimeBlock;
            end


            if~isempty(baseVMgrBlock)&&any(baseVMgrBlock.getBlockType()==[VMgrBlockType.RootModel,VMgrBlockType.ModelReference])


                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openRootOrReferenceModel(menu,baseVMgrBlock,aVMgrCompBlock);
            end


            if~isempty(baseVMgrBlock)&&baseVMgrBlock.getBlockType()==VMgrBlockType.ModelReference


                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openModelReference(menu,baseVMgrBlock);
            end


            if~isempty(baseVMgrBlock)&&baseVMgrBlock.getBlockType()==VMgrBlockType.SubSystemReference


                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openReferencedSubSystem(menu,baseVMgrBlock);
            end


            if~isempty(baseVMgrBlock)&&~isempty(parentBaseVMgrBlock)


                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openAndHighlightBlockOrChart(menu,baseVMgrBlock,aVMgrCompBlock);
            end


            if getIsLabelModeBlock(parentBaseVMgrBlock)&&...
                getIsChoiceRow(parentBaseVMgrBlock,baseVMgrBlock)
                variantControlOfChoice=parentBaseVMgrBlock.ChoiceBlockInfos(1+hierarchyviewrow.Controller.ChoiceRowIdx).VariantControl;
                if~strcmp(variantControlOfChoice,get_param(parentBaseVMgrBlock.getBlockPathImpl,'LabelModeActiveChoice'))
                    menu=slvariants.internal.manager.ui.ModelHierContextMenu.setAsLabelModeActiveChoice(menu,parentBaseVMgrBlock,variantControlOfChoice,hierarchyviewrow.Controller.ParentRow);
                end
            end


            if~isempty(baseVMgrBlock)&&baseVMgrBlock.getIsVariantBlock()&&...
                ~isStateflowBased


                openForParent=false;
                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openBlockParameters(menu,baseVMgrBlock,openForParent);
            end


            if~isempty(baseVMgrBlock)&&baseVMgrBlock.getBlockType()==VMgrBlockType.StateflowChart


                isVariantTransition=false;
                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openChartParameters(menu,baseVMgrBlock,isVariantTransition);
            end



            if getIsChoiceRow(parentBaseVMgrBlock,baseVMgrBlock)&&~isStateflowBased


                openForParent=true;
                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openBlockParameters(menu,parentBaseVMgrBlock,openForParent);
            end


            if~isempty(baseVMgrBlock)&&baseVMgrBlock.getBlockType()==VMgrBlockType.SFVariantTransition


                isVariantTransition=true;
                menu=slvariants.internal.manager.ui.ModelHierContextMenu.openChartParameters(menu,parentBaseVMgrBlock,isVariantTransition);
            end
        end

        function menuItem=createDefaultMenuItem()
            menuItem=struct(...
            'label','',...
            'checked',false,...
            'icon','',...
            'enabled',true,...
            'command','',...
            'visible',true,...
            'tag','');
        end

        function menu=openRootOrReferenceModel(menu,baseVMgrBlock,aVMgrCompBlock)

            import sl_variants.manager.model.VMgrBlockType;
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyNavigateModel'));
            if baseVMgrBlock.getBlockType()==VMgrBlockType.RootModel




                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenRootMdl;
                menuItem.command=@(tag)open_system(baseVMgrBlock.getBlockPathImpl());
            else



                if baseVMgrBlock.getIsProtectedModel()
                    menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenProtectedRefMdl;
                    menuItem.command=@(tag)Simulink.ProtectedModel.open(baseVMgrBlock.ModelName);
                else
                    menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenRefMdl;
                    blockPathObject=Simulink.BlockPath(aVMgrCompBlock.getHierarchicalBlockPathsImpl());
                    menuItem.command=@(tag)blockPathObject.open('force','on');
                end
            end
            menu(end+1)=menuItem;
        end

        function menu=openReferencedSubSystem(menu,baseVMgrBlock)
            import sl_variants.manager.model.VMgrBlockType;
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            menuItem.label=getString(message('Simulink:SubsystemReference:OpenReferencedSubsysMenuText'));
            menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenRefSubSys;
            menuItem.command=@(tag)open_system(baseVMgrBlock.SubSystemName,'window');
            menu(end+1)=menuItem;
        end
        function menu=openModelReference(menu,baseVMgrBlock)
            import sl_variants.manager.model.VMgrBlockType;
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            menuItem.label=getString(message('Simulink:studio:ModelBlockOpenModelReferenceAsRoot'));
            menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenAsRootMdl;
            menuItem.command=@(tag)open_system(baseVMgrBlock.ModelName,'window');
            menu(end+1)=menuItem;
        end

        function menu=openAndHighlightBlockOrChart(menu,baseVMgrBlock,aVMgrCompBlock)
            import sl_variants.manager.model.VMgrBlockType;
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();

            rootModelName=aVMgrCompBlock.RootCompBlock.getBlockPathRootModelImpl();
            rootModelHandle=get_param(rootModelName,'handle');

            switch baseVMgrBlock.getBlockType()
            case VMgrBlockType.StateflowChart
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyNavigateChart'));
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenChart;
                menuItem.command=@(tag)slvariants.internal.manager.ui.openAndHiliteCB('HiliteBlock',rootModelHandle,aVMgrCompBlock.getHierarchicalBlockPathsImpl(),[]);
            case VMgrBlockType.SFVariantTransition
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyNavigateTransition'));
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenSFTransition;
                menuItem.command=@(tag)slvariants.internal.manager.ui.openAndHiliteCB('HiliteTransition',rootModelHandle,[],baseVMgrBlock.TransitionId);
            otherwise
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyNavigateBlock'));
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenBlk;
                menuItem.command=@(tag)slvariants.internal.manager.ui.openAndHiliteCB('HiliteBlock',rootModelHandle,aVMgrCompBlock.getHierarchicalBlockPathsImpl(),[]);
            end
            menu(end+1)=menuItem;
        end

        function menu=openBlockParameters(menu,baseVMgrBlock,openForParent)
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            if openForParent
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenParentBlkParams;
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyBlockOpenDdgParent'));
            else
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenBlkParams;
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyBlockOpenDdgSelf'));
            end
            objName=baseVMgrBlock.getBlockPathImpl();
            menuItem.command=@(tag)open_system(objName,'Parameter');
            menu(end+1)=menuItem;
        end

        function menu=openChartParameters(menu,baseVMgrBlock,isVariantTransition)
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            if isVariantTransition
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenParentChartParams;
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyChartOpenDdgParent'));
            else
                menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.OpenChartParams;
                menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyChartOpenDdgSelf'));
            end
            chartPath=baseVMgrBlock.getBlockPathImpl();
            menuItem.command=@(tag)slvariants.internal.manager.ui.ModelHierContextMenu.openSFChartProperties(chartPath);
            menu(end+1)=menuItem;
        end

        function menu=setAsLabelModeActiveChoice(menu,parentBaseVMgrBlock,newActiveChoice,parentHierarchyRow)
            menuItem=slvariants.internal.manager.ui.ModelHierContextMenu.createDefaultMenuItem();
            menuItem.tag=slvariants.internal.manager.ui.config.VMgrConstants.LabelModeActiveChoice;
            menuItem.label=getString(message('Simulink:VariantManagerUI:HierarchyBlockActivateLabelChoice'));
            menuItem.command=@(tag)(setNewLabelModeActiveChoice());
            menuItem.enabled=~parentHierarchyRow.OwnerBlock.getIsInsideReadOnlyHierarchy();
            menu(end+1)=menuItem;
            function setNewLabelModeActiveChoice()
                set_param(parentBaseVMgrBlock.getBlockPathImpl(),'LabelModeActiveChoice',newActiveChoice);

                parentHierarchyRow.lockSiblingSSRefBlocksAndUpdateView();
            end
        end

        function openSFChartProperties(chartPath)
            sfRoot=sfroot;
            chartObj=sfRoot.find('-isa','Stateflow.Chart','Path',chartPath);
            DAStudio.Dialog(chartObj);
        end

        function hiliteSFTransition(transitionId)
            stateflowH=sf('IdToHandle',transitionId);
            stateflowH.view();
            stateflowH.highlight();
        end
    end
end


function isLabelModeBlock=getIsLabelModeBlock(baseVMgrBlock)
    import sl_variants.manager.model.VMgrBlockType;
    if isempty(baseVMgrBlock)
        isLabelModeBlock=false;
    else
        isLabelModeSupportingBlock=((baseVMgrBlock.getBlockType()==VMgrBlockType.VariantSubSystem)||...
        (baseVMgrBlock.getBlockType()==VMgrBlockType.VariantSrcSink));
        isLabelModeBlock=isLabelModeSupportingBlock&&baseVMgrBlock.BlockParamInfos.getIsInLabelMode();
    end
end


function isChoiceRow=getIsChoiceRow(parentBaseVMgrBlock,baseVMgrBlock)
    isChoiceRow=~isempty(parentBaseVMgrBlock)&&(isempty(baseVMgrBlock)||...
    parentBaseVMgrBlock.isVariantChoiceBlock(baseVMgrBlock));
end


