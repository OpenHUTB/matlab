function codeView=openCodeView(sudSid,initialId)



    error(javachk('swing'));
    validateattributes(sudSid,{'char'},{})
    import coder.internal.mlfb.gui.MlfbUtils;

    sudSid=Simulink.ID.getSID(sudSid);
    sudInfo=MlfbUtils.getSudInfo(sudSid);

    assert(MlfbUtils.isFixedPointToolWithBlock(sudSid),...
    'Code View can only be launched for the model showing in the Fixed-Point Tool');

    hierarchyBuilder=com.mathworks.toolbox.coder.mlfb.BlockHierarchyBuilder();
    subsystemSud=~MlfbUtils.isFunctionBlock(sudSid);
    launcher=com.mathworks.toolbox.coder.mlfb.CodeViewLauncher(sudInfo,subsystemSud);

    hasFbs=false;
    MlfbUtils.walkSidHierarchy(sudSid,@visitNode);

    if hasFbs
        if exist('initialId','var')&&~isempty(initialId)
            blockId=coder.internal.mlfb.idForBlock(initialId);
            if~isempty(blockId)
                launcher.markInitialBlock(blockId.toJava());
            end
        end

        import coder.internal.mlfb.gui.CodeViewManager;
        CodeViewManager.closeActive();
        launcher.withHierarchy(hierarchyBuilder.build());
        javaView=launcher.launch();
        codeView=CodeViewManager.manage(javaView);
    else
        codeView=[];
    end



    function cue=visitNode(parentId,nodeId)
        import coder.internal.mlfb.gui.MlfbUtils;
        cue=0;

        if MlfbUtils.isManagedVariantSubsystem(nodeId)

            [orig,fixpt]=coder.internal.mlfb.getMlfbVariants(nodeId.SID);
            assert(~isempty(orig)&&~isempty(fixpt));
            addFunctionBlockSystem(parentId,...
            nodeId,...
            coder.internal.mlfb.idForBlock(orig),...
            coder.internal.mlfb.idForBlock(fixpt));
        elseif nodeId.isFunctionBlock()

            addFunctionBlockSystem(parentId,[],nodeId,[]);
        else
            addSingleBlock(parentId,nodeId);
            cue=1;
        end
    end

    function addFunctionBlockSystem(parent,subsystem,origVariant,fixptVariant)
        assert(~isempty(origVariant));
        import coder.internal.mlfb.gui.MlfbUtils;
        import('coder.internal.gui.GuiUtils');

        blockInfo=MlfbUtils.getBlockInfo(origVariant);

        if~isempty(subsystem)
            addSingleBlock(parent,subsystem);
            addSingleBlock(subsystem,origVariant);
            addSingleBlock(subsystem,fixptVariant);

            outputBlockInfo=MlfbUtils.getBlockInfo(fixptVariant);
            outputCode=GuiUtils.getFunctionBlockCode(fixptVariant);
        else
            assert(isempty(fixptVariant));
            addSingleBlock(parent,origVariant);

            outputBlockInfo=[];
            outputCode=[];
        end

        launcher.withBlock(...
        blockInfo,...
        GuiUtils.getFunctionBlockCode(origVariant),...
        outputBlockInfo,...
        outputCode);
        hasFbs=true;
    end

    function addSingleBlock(parentId,nodeId)
        blockType=coder.internal.mlfb.gui.MlfbUtils.getJavaBlockType(nodeId);
        if~isempty(parentId)
            parentId=parentId.toJava();
        end
        hierarchyBuilder.addBlock(parentId,nodeId.toJava(),nodeId.Name,blockType);
    end
end

