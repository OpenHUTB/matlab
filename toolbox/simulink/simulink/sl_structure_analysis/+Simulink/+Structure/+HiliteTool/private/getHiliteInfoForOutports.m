function refHiliteInfo=getHiliteInfoForOutports(outportBlocks,shouldRecurse)

    import Simulink.Structure.HiliteTool.internal.*

    refHiliteInfo=[];

    for i=1:length(outportBlocks)
        [refSegments,refBlocks]=walkToModelRefDestinationOutport(outportBlocks(i));

        for j=1:length(refBlocks)

            refBlock=refBlocks(j);
            refSegment=refSegments(j);
            hiliteInfo=getHiliteInfoFromBlock(refBlock);
            refHiliteInfo=[refHiliteInfo;hiliteInfo];

            if(shouldRecurse)
                hiliteInfo=getHiliteInfo(false,refSegment);
                refHiliteInfo=[refHiliteInfo;hiliteInfo];
            end
        end
    end
    refHiliteInfo=mergeHiliteInfos(refHiliteInfo);
end
