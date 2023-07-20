function refHiliteInfo=getHiliteInfoForChoiceModelRefInports(refBlock,inportBlocks)

    import Simulink.Structure.HiliteTool.internal.*

    refHiliteInfo=[];

    for i=1:length(inportBlocks)

        refSegment=...
        walkToModelRefChoiceSourceInport(refBlock,inportBlocks(i));

        hiliteInfo=getHiliteInfoFromBlock(refBlock);

        refHiliteInfo=[refHiliteInfo;hiliteInfo];

        refHiliteInfo=[refHiliteInfo;getHiliteInfo(true,refSegment)];
    end
    refHiliteInfo=mergeHiliteInfos(refHiliteInfo);
end