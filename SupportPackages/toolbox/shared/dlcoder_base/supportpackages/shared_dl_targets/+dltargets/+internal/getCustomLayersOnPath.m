function customLayerClasses=getCustomLayersOnPath(returnAllCustomLayersOnPath,classList)
























    if nargin==1
        classList=dltargets.internal.utils.GetSupportedLayersUtils.getClassListOnPath(returnAllCustomLayersOnPath);
    end



    customLayerClasses=getDerivedCustomLayerClasses(classList,'nnet.layer.Layer');



    customLayerClasses=filterToRedirectedLayers(customLayerClasses);


end

function customLayerClasses=getDerivedCustomLayerClasses(classList,baseCustomLayerClassNames)


    isCustomLayerClass=arrayfun(@(x)any(arrayfun(@(y)any(strcmp(y.Name,baseCustomLayerClassNames)),x.SuperclassList)),classList);

    customLayerClasses=classList(isCustomLayerClass);

    classList(isCustomLayerClass)=[];
    if~isempty(customLayerClasses)

        baseCustomLayerClassNames=cell(1,numel(customLayerClasses));
        [baseCustomLayerClassNames{:}]=customLayerClasses.Name;
        customLayerClasses=[customLayerClasses;getDerivedCustomLayerClasses(classList,baseCustomLayerClassNames)];
    end

end


function customLayerClasses=filterToRedirectedLayers(customLayerClasses)

    isToRedirectedLayerBoolVec=arrayfun(@(x)hasMethod(x.MethodList,"matlabCodegenToRedirected"),customLayerClasses);
    customLayerClasses=customLayerClasses(~isToRedirectedLayerBoolVec);

end


function boolFlag=hasMethod(methodList,methodName)

    boolFlag=dltargets.internal.utils.GetSupportedLayersUtils.hasPublicStaticMethod(methodList,methodName);
end
