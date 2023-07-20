function layerNames=getCustomLayersSupportedForCodegen(customLayerClasses,targetName)











    targetsSupportedForCustomLayers=["cudnn","tensorrt","mkldnn","onednn","arm-compute","none"];



    if~any(strcmpi(targetName,targetsSupportedForCustomLayers))
        layerNames=[];
        return;
    end



    isSupportedForCodegen=arrayfun(@(x)(dltargets.internal.hasCodegenPragmaInClassDef(x.Name)...
    ||hasMatlabCodegenRedirectMethod(x.MethodList)),customLayerClasses);
    supportedCustomLayerClasses=customLayerClasses(isSupportedForCodegen);


    layerNames=cell(1,numel(supportedCustomLayerClasses));
    [layerNames{:}]=supportedCustomLayerClasses.Name;
end

function boolFlag=hasMatlabCodegenRedirectMethod(methodList)




    methodList=methodList(strcmp({methodList.Name},"matlabCodegenRedirect"));
    boolFlag=~isempty(methodList)&&methodList.Static;
end
