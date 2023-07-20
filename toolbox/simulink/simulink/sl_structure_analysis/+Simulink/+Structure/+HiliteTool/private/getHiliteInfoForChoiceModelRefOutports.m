function refHiliteInfo=getHiliteInfoForChoiceModelRefOutports(refBlock,outportBlocks)

    import Simulink.Structure.HiliteTool.internal.*

    refHiliteInfo=[];

    for i=1:length(outportBlocks)

        refSegment=...
        walkToModelRefChoiceDestinationOutport(refBlock,outportBlocks(i));

        hiliteInfo=getHiliteInfoFromBlock(refBlock);

        refHiliteInfo=[refHiliteInfo;hiliteInfo];

        refHiliteInfo=[refHiliteInfo;getHiliteInfo(false,refSegment)];
    end
    refHiliteInfo=mergeHiliteInfos(refHiliteInfo);
end
