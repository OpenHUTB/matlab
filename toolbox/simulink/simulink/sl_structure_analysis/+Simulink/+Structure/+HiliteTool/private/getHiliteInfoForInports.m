function refHiliteInfo=getHiliteInfoForInports(inportBlocks,shouldRecurse)

    import Simulink.Structure.HiliteTool.internal.*

    refHiliteInfo=[];

    for i=1:length(inportBlocks)
        [refSegments,refBlocks]=walkToModelRefSourceInport(inportBlocks(i));

        for j=1:length(refBlocks)

            refBlock=refBlocks(j);
            refSegment=refSegments(j);
            hiliteInfo=getHiliteInfoFromBlock(refBlock);
            refHiliteInfo=[refHiliteInfo;hiliteInfo];

            if(shouldRecurse)
                hiliteInfo=getHiliteInfo(true,refSegment);
                refHiliteInfo=[refHiliteInfo;hiliteInfo];
            end
        end
    end
    refHiliteInfo=mergeHiliteInfos(refHiliteInfo);
end