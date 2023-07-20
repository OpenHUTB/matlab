function hiliteInfo=getHiliteInfoFromBlock(blockHandle)
    import Simulink.Structure.HiliteTool.internal.*

    blockBD=getBlockDiagram(blockHandle);
    parentHandle=get_param(get_param(blockHandle,'Parent'),'handle');

    hiliteInfo.graphHighlightMap=cell(1,2);
    hiliteInfo.termGraphHandle=parentHandle;
    hiliteInfo.initGraphHandle=parentHandle;
    hiliteInfo.traceBD=blockBD;
    hiliteInfo.graphHighlightMap{1,1}=parentHandle;
    hiliteInfo.graphHighlightMap{1,2}=blockHandle;

end

