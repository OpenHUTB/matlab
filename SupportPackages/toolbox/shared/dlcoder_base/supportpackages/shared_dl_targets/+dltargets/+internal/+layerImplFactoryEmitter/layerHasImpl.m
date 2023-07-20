







function hasImpl=layerHasImpl(layerString,target)





    switch lower(target)
    case 'cudnn'
        layerImplDirectory=...
        fullfile(dltargets.cudnn.SupportedLayerImpl.componentRootDir,'mangled','cudnn');
    case 'tensorrt'
        layerImplDirectory=...
        fullfile(dltargets.tensorrt.SupportedLayerImpl.componentRootDir,'mangled','tensorrt');
    case 'armmali'
        layerImplDirectory=...
        fullfile(dltargets.arm_mali.SupportedLayerImpl.componentRootDir,'mangled','arm_mali');
    case 'onednn'
        layerImplDirectory=...
        fullfile(dltargets.onednn.SupportedLayerImpl.componentRootDir,'mangled','onednn');
    case 'armneon'
        layerImplDirectory=...
        fullfile(dltargets.arm_neon.SupportedLayerImpl.componentRootDir,'mangled','arm_neon');
    otherwise


        assert(false,'Unexpected value for target in layerHasImpl');
    end

    layerImplFile=['MW',target,layerString,'LayerImpl.hpp'];
    layerImplFullFile=fullfile(layerImplDirectory,layerImplFile);



    hasImpl=isfile(layerImplFullFile);
end
