function fromRedirectedLayerClasses=getFromRedirectedLayersOnPath(returnAllRedirectedLayersOnPath,classList)


























    if nargin==1
        classList=dltargets.internal.utils.GetSupportedLayersUtils.getClassListOnPath(returnAllCustomLayersOnPath);
    end

    fromRedirectedLayerClasses=getFromRedirectedLayerClasses(classList);


end


function fromRedirectedLayerClasses=getFromRedirectedLayerClasses(classList)





    isCustomLayerClass=arrayfun(@(x)hasMethod(x.MethodList,"matlabCodegenRedirect"),classList);
    fromRedirectedLayerClasses=classList(isCustomLayerClass);



    filteredClassNames=["nnet.layer.Layer","nnet.internal.cnn.layer.CPUFusableLayer"];
    filterClasses=arrayfun(@(x)contains(x.Name,filteredClassNames),fromRedirectedLayerClasses);
    fromRedirectedLayerClasses=fromRedirectedLayerClasses(~filterClasses);

end

function boolFlag=hasMethod(methodList,methodName)

    boolFlag=dltargets.internal.utils.GetSupportedLayersUtils.hasPublicStaticMethod(methodList,methodName);
end
