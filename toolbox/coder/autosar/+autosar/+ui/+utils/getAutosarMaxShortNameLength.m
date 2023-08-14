function maxShortNameLength=getAutosarMaxShortNameLength(m3iModelOrModelName)





    if isa(m3iModelOrModelName,'Simulink.metamodel.foundation.Domain')
        m3iModel=m3iModelOrModelName;
        modelName=autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel(m3iModel);
    else

        m3iModel=[];
        assert(~isempty(m3iModelOrModelName),'modelName cannot be empty');
        modelName=m3iModelOrModelName;
    end

    if isempty(modelName)

        assert(autosar.dictionary.Utils.isSharedM3IModel(m3iModel),...
        'Should only get here for Shared Dictionary');
        maxShortNameLength=autosar.api.internal.M3IModelDictionaryContext.MaxShortNameLength;
    elseif strcmp(get_param(modelName,'AutosarCompliant'),'on')
        maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
    else
        maxShortNameLength=128;
    end
end


