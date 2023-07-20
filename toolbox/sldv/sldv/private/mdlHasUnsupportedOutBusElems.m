function hasUnsupportedBEP=mdlHasUnsupportedOutBusElems(modelH)










    hasUnsupportedBEP=false;


    refMdls=find_mdlrefs(modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    if length(refMdls)<2

        return;
    end
    for idx=1:(length(refMdls)-1)




        outBlks=find_system(refMdls{idx},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookInsideSubsystemReference','on','BlockType','Outport');
        for jdx=1:length(outBlks)
            if strcmp(get_param(outBlks{jdx},'IsBusElementPort'),'on')
                block=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(get_param(outBlks{jdx},'handle'));
                port=block.port;
                tree=port.tree;
                node=Simulink.internal.CompositePorts.TreeNode.findNode(tree,'');
                dataType=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
                if strcmp(dataType,'Inherit: auto')
                    hasUnsupportedBEP=true;
                    return;
                end
            end
        end
    end
end
