function customDesignMap=getCustomDesignMap(target)





    customDesignClasses=dltargets.internal.getCustomLayerDesigns(target);

    customDesignMap=containers.Map('KeyType','char','ValueType','any');
    for k=1:numel(customDesignClasses)
        customDesign=customDesignClasses{k};
        layerType=customDesign.PropertyList(...
        ismember({customDesign.PropertyList(:).Name},'fType')).DefaultValue;
        customDesignMap(layerType)=customDesign;
    end
end
