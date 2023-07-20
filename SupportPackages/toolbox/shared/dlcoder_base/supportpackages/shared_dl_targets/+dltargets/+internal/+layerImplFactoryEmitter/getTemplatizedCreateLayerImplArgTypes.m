





function argTypes=getTemplatizedCreateLayerImplArgTypes(layerString,target)




    assert(dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(layerString),'layerString does not correspond to a templatized layer class');



    switch lower(target)
    case 'cudnn'
        fileDirectory=fullfile(dltargets.cudnn.SupportedLayerImpl.componentRootDir,...
        'mangled','cudnn');
    case 'tensorrt'
        fileDirectory=fullfile(dltargets.tensorrt.SupportedLayerImpl.componentRootDir,...
        'mangled','tensorrt');
    case 'armmali'
        fileDirectory=fullfile(dltargets.arm_mali.SupportedLayerImpl.componentRootDir,...
        'mangled','arm_mali');
    case 'mkldnn'
        fileDirectory=fullfile(dltargets.onednn.SupportedLayerImpl.componentRootDir,...
        'mangled','onednn');
    case 'armneon'
        fileDirectory=fullfile(dltargets.arm_neon.SupportedLayerImpl.componentRootDir,...
        'mangled','arm_neon');
    otherwise


        assert(false,'Unexpected value for target in getTemplatizedCreateLayerImplArgTypes');
    end



    layerImplClassName=['MW',layerString,'LayerImpl'];



    layerImplFile=fullfile(fileDirectory,['MW',target,layerString,'LayerImpl.hpp']);


    fid=fopen(layerImplFile,'r');
    assert(ftell(fid)==0);

    constructorPattern=[layerImplClassName,'('];
    destructorPattern=['~',layerImplClassName,'('];
    constructorFound=false;
    while~constructorFound
        assert(~feof(fid),'End of file before constructor for the layerImpl was found');
        line=fgetl(fid);


        constructorFound=contains(line,constructorPattern)&&~contains(line,destructorPattern);

        if constructorFound


            line=extractAfter(line,layerImplClassName);
            argTypes=dltargets.internal.layerImplFactoryEmitter.extractArgTypes(line,fid);
        end
    end
    fclose(fid);

    assert(~isempty(argTypes),'Argument types were not found');
end
