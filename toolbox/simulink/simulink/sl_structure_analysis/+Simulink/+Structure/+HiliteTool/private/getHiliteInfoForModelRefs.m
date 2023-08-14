function refHiliteInfos=getHiliteInfoForModelRefs(refBlks,...
    elements,...
    isHiliteToSrc,...
    shouldRecurse)
    import Simulink.Structure.HiliteTool.internal.*

    refHiliteInfos=[];

    for j=1:length(refBlks)
        refBlk=refBlks(j);
        refModelName=get_param(refBlk,'ModelName');
        proceedWhenBDisLoaded(refModelName)
        traceBD=get_param(refModelName,'Handle');

        if(isHiliteToSrc)
            [startSegs,startBlks,~]=walkToModelRefSourceOutport(refBlk,elements);
        else
            [startSegs,startBlks,~]=walkToModelRefDestinationInport(refBlk,elements);
        end

        if(isempty(startBlks))
            continue;
        end

        hiliteInfo.graphHighlightMap=cell(1,2);
        hiliteInfo.termGraphHandle=traceBD;
        hiliteInfo.initGraphHandle=traceBD;
        hiliteInfo.graphHighlightMap{1,1}=traceBD;
        hiliteInfo.graphHighlightMap{1,2}=startBlks;
        hiliteInfo.traceBD=traceBD;

        refHiliteInfos=[refHiliteInfos;hiliteInfo];

        if(shouldRecurse)
            for k=1:length(startSegs)
                seg=startSegs(k);
                hiliteInfo=getHiliteInfo(isHiliteToSrc,seg);
                refHiliteInfos=[refHiliteInfos;hiliteInfo];
            end
        end
    end

end